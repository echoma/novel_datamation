#!/usr/bin/env python3
import json
from collections import namedtuple
import decimal
import pymysql

DB = pymysql.connect(host='localhost', port=3306, user='nd', passwd='nd', db='story_of_stone', charset='utf8')

class DecimalEncoder(json.JSONEncoder):
    """
    目前默认的json不支持对Decimal类型的序列化，因此我们自己支持一下
    """
    def default(self, o):
        if isinstance(o, decimal.Decimal):
            return float(o)
        return super(DecimalEncoder, self).default(o)

"""
以下是关系图里用到的各种数据结构
"""

"""
数据库里一个人的基本信息
读取数据库person表的数据结构，用来动态生成PersonInfo类
"""
PERSON_INFO_FIELDS = None
with DB.cursor() as cursor:
    sql = 'select * from person limit 1'
    cursor.execute(sql)
    cursor.fetchone()
    PERSON_INFO_FIELDS = [col[0] for col in cursor.description]
PersonInfo = namedtuple('PersonInfo', PERSON_INFO_FIELDS)

"""
数据库里一个主子的信息
"""
MASTER_INFO_FIELDS = None
with DB.cursor() as cursor:
    sql = 'select * from master limit 1'
    cursor.execute(sql)
    cursor.fetchone()
    MASTER_INFO_FIELDS = [col[0] for col in cursor.description]
MasterInfo = namedtuple('MasterInfo', MASTER_INFO_FIELDS)

"""
数据库里一个人的社会地位信息
"""
SOCIAL_POSITION_INFO_FIELDS = None
with DB.cursor() as cursor:
    sql = 'select * from social_position limit 1'
    cursor.execute(sql)
    cursor.fetchone()
    SOCIAL_POSITION_INFO_FIELDS = [col[0] for col in cursor.description]
SocialPositionInfo = namedtuple('SocialPositionInfo', SOCIAL_POSITION_INFO_FIELDS)


class Graph:
    """
    关系图。
    这个树从祖先开始一级级向子辈进行扩散。
    当前实现下，关系图是树，而不是图。因为目前父亲和母亲节点不允许同时指向同一个孩子，只能由母亲指向。因此从树的结构看，分支数量是不能收敛的。
    """
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
        for lvl in self.level_list:
            lvl.complete()
            lvl.derive()
    def output(self):
        for lvl in self.level_list:
            print('level '+str(lvl.level_number)+': '+ ' '.join([psn.name+'('+str(psn.info.sort_age)+')' for psn in lvl.person_list]))
    def toDict(self):
        o = {}
        o['level_list'] = [lvl.toDict() for lvl in self.level_list]
        o['person_map'] = {name : Person.find(name).toDict() for name in Person._name_dict}
        return o

class Level:
    """
    代际
    从祖辈到子辈，一代人属于同一个level。
    """
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
                            psn.wife_list.append(new_psn)
                        else:
                            new_psn = self.addPersonBefore(psn.name, row[0])
                            new_psn.wife_list.append(psn)
                            psn.husband = new_psn
    def derive(self):
        """
        对于本层中的每个人找出其下一代。
        根据Graph类里树的要求，对于每一个小家庭，我们先扫描妻妾的孩子，再扫描男性的孩子。
        """
        with self.db.cursor() as cursor:
            for psn in self.person_list:
                if psn.info.gender=='女':
                    self.deriveOfOne(psn, cursor)
                else:
                    for wife in psn.wife_list:
                        self.deriveOfOne(wife, cursor)
                    self.deriveOfOne(psn, cursor)
                    
    def deriveOfOne(self, psn, cursor):
        """
        被derive调用，查询指定人的下一代。
        """
        sql = 'select b.* from person a inner join kinship b on a.name=b.object where b.subject=%s and b.type="父母子女" order by a.sort_age desc'
        cursor.execute(sql, (psn.name))
        lvl = None
        if cursor.rowcount>0:
            lvl = self.tree.ensureExistanceOfNextLevel(self.level_number)
        for row in cursor.fetchall():
            if not Person.exists(row[1]):
                new_psn = lvl.addPerson(row[1])
                psn.child_list.append(new_psn)
                new_psn.parent = psn
    def toDict(self):
        o = {}
        o['level_number'] = self.level_number
        o['person_list'] = [psn.name for psn in self.person_list]
        return o

class Person:
    """一个人"""
    _name_dict = {} # 静态变量，按照名字映射了所有的人
    def __init__(self, lvl, name):
        global DB
        self.db = DB
        self.level = lvl
        self.name = name
        self.parent = None # 每个人只有一个父母，不能既有父亲又有母亲，具体原因见“Graph类的注释”
        self.child_list = []
        self.husband = None
        self.wife_list = [] # 按照地位顺序排列，正房大太太在前，偏房姨太太在后。
        with self.db.cursor() as cursor:
            # 获取基本信息
            sql = 'select * from person where name=%s'
            cursor.execute(sql, (self.name))
            if cursor.rowcount==0:
                raise ValueError(self.name + ' not found in table `person`')
            self.info = PersonInfo(*cursor.fetchone())
            # 获取主子信息
            sql = 'select * from master where name=%s'
            cursor.execute(sql, (self.name))
            self.master = None if cursor.rowcount==0 else MasterInfo(*cursor.fetchone())
            # 获取社会地位信息
            sql = 'select * from social_position where name=%s'
            cursor.execute(sql, (self.name))
            self.social_position = None if cursor.rowcount==0 else SocialPositionInfo(*cursor.fetchone())
        Person._name_dict[self.name] = self
    @staticmethod
    def find(name):
        return Person._name_dict[name]
    @staticmethod
    def exists(name):
        if name in Person._name_dict.keys():
            return True
        return False
    def toDict(self):
        o = {}
        o['level'] = self.level.level_number
        o['name'] = self.name
        o['parent'] = None if self.parent is None else self.parent.name
        o['child_list'] = [psn.name for psn in self.child_list]
        o['husband'] = None if self.husband is None else self.husband.name
        o['wife_list'] = [psn.name for psn in self.wife_list]
        o['info'] = self.info._asdict()
        o['master'] = None if self.master is None else self.master._asdict()
        o['social_position'] = None if self.social_position is None else self.social_position._asdict()
        return o

def main():
    GRAPH_OF_JIA = Graph('贾公')
    GRAPH_OF_JIA.cal()
    GRAPH_OF_JIA.output()
    with open('./graph.json', mode='w') as file:
        o = {}
        o['贾'] = GRAPH_OF_JIA.toDict()
        file.write(json.dumps(o, indent=2, sort_keys=True, ensure_ascii=False, cls=DecimalEncoder))

main()