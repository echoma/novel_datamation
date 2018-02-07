#!/usr/bin/env python3
import json
from collections import namedtuple
import pymysql

DB = pymysql.connect(host='localhost', port=3306, user='nd', passwd='nd', db='story_of_stone', charset='utf8')

# 关系图的数据结构

PERSON_INFO_FIELDS = None
with DB.cursor() as cursor:
    sql = 'select * from person limit 1'
    cursor.execute(sql)
    cursor.fetchone()
    PERSON_INFO_FIELDS = [col[0] for col in cursor.description]

class PersonInfo(namedtuple('PersonInfo', PERSON_INFO_FIELDS)):
    """数据库里一个人的基本信息"""
    pass

class Tree:
    """关系图"""
    def __init__(self, top_name):
        global DB
        self.db = DB
        self.level_list = []
        lvl = self.addLevel()
        lvl.addPerson(top_name)
    def addLevel(self):
        lvl = Level(self, len(self.level_list))
        self.level_list.append(lvl)
        return lvl
    def ensureExistanceOfNextLevel(self, current_level_number):
        if current_level_number+1<len(self.level_list):
            return self.level_list[current_level_number+1]
        if current_level_number+1==len(self.level_list):
            return self.addLevel()
        raise ValueError('invalid level number '+str(current_level_number))
    def cal(self):
        self.cal_lvl_idx = 0
        self.cal_psn_idx = 0
        for lvl in self.level_list:
            lvl.complete()
            lvl.derive()
        self.output()
    def output(self):
        for lvl in self.level_list:
            print('level '+str(lvl.level_number)+': '+ ' '.join([psn.name+'('+str(psn.info.sort_age)+')' for psn in lvl.person_list]))

class Level:
    """关系图-代际"""
    def __init__(self, tree, lvl_number):
        global DB
        self.db = DB
        self.tree = tree
        self.level_number = lvl_number
        self.person_list = []
    def addPerson(self, name):
        psn = Person(self, name)
        self.person_list.append(psn)
        return psn
    def addPersonAfter(self, after_name, new_name):
        psn = Person(self, new_name)
        idx = self.personIndex(after_name)
        self.person_list.insert(idx+1, psn)
        return psn
    def addPersonBefore(self, before_name, new_name):
        psn = Person(self, new_name)
        idx = self.personIndex(before_name)
        self.person_list.insert(idx, psn)
        return psn
    def personIndex(self, name):
        for idx, psn in enumerate(self.person_list):
            if psn.name == name:
                return idx
        raise ValueError(name+' is not in the person list')
    def complete(self):
        """
        补全本层人员。
        方法：逐人扫描，如果是男的就查询妻妾，女的就查询丈夫。
        """
        with self.db.cursor() as cursor:
            for psn in self.person_list:
                sql = ''
                if psn.info.gender=='男':
                    sql = 'select a.name from person a inner join kinship b on a.name=b.object where b.subject=%s and b.type="夫妻" order by b.sub_type desc'
                else:
                    sql = 'select a.name from person a inner join kinship b on a.name=b.object where b.object=%s and b.type="夫妻" limit 1'
                cursor.execute(sql, (psn.name))
                for row in cursor.fetchall():
                    if not Person.exists(row[0]):
                        if psn.info.gender=='男':
                            new_psn = self.addPersonAfter(psn.name, row[0])
                            new_psn.husband = psn
                        else:
                            new_psn = self.addPersonBefore(psn.name, row[0])
                            new_psn.wife_list.append(psn)
    def derive(self):
        """
        对于本层中的每个人人员找出其下一代。
        对于有妻妾节点的男性，本身不需要找下一代，其妻妾找出下一代即可。
        """
        with self.db.cursor() as cursor:
            for psn in self.person_list:
                male_with_wife_node = len(psn.wife_list)>0
                if not male_with_wife_node:
                    sql = 'select b.* from person a inner join kinship b on a.name=b.object where b.subject=%s and b.type="父母子女" order by a.sort_age desc'
                    cursor.execute(sql, (psn.name))
                    lvl = None
                    if cursor.rowcount>0:
                        lvl = self.tree.ensureExistanceOfNextLevel(self.level_number)
                    for row in cursor.fetchall():
                        if not Person.exists(row[1]):
                            lvl.addPerson(row[1])
class Person:
    """关系图-一个人"""
    _name_dict = {}
    def __init__(self, lvl, name):
        global DB
        self.db = DB
        self.level = lvl
        self.name = name
        self.parent = None
        self.child_list = []
        self.husband = None
        self.wife_list = []
        with self.db.cursor() as cursor:
            sql = 'select * from person where name=%s'
            cursor.execute(sql, (self.name))
            self.info = PersonInfo(*cursor.fetchone())
        Person._name_dict[self.name] = self
    @staticmethod
    def findPerson(name):
        if name in Person._name_dict.keys():
            return Person._name_dict[name]
        return None
    @staticmethod
    def exists(name):
        if name in Person._name_dict.keys():
            return True
        return False
    def calChildList(self):
        with self.db.cursor() as cursor:
            if self.info.gender=='女':
                sql = 'select a.name from person a inner join kinship b on a.name=b.object where b.subject=%s and b.type="父母子女" order by a.sort_age desc'
                cursor.execute(sql, (self.name))

def main():
    TREE_OF_JIA = Tree('贾公')
    TREE_OF_JIA.cal()

main()