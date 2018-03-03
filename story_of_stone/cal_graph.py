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
数据库里一个人的扩展信息
读取数据库person_ext表的数据结构，用来动态生成PersonExt类
"""
PERSON_EXT_FIELDS = None
with DB.cursor() as cursor:
    sql = 'select * from person_ext limit 1'
    cursor.execute(sql)
    cursor.fetchone()
    PERSON_EXT_FIELDS = [col[0] for col in cursor.description]
PersonExt = namedtuple('PersonExt', PERSON_EXT_FIELDS)

"""
数据库里一个人的出场信息
读取数据库person_action表的数据结构，用来动态生成PersonAction类
"""
PERSON_ACTION_FIELDS = None
with DB.cursor() as cursor:
    sql = 'select * from person_action limit 1'
    cursor.execute(sql)
    cursor.fetchone()
    PERSON_ACTION_FIELDS = [col[0] for col in cursor.description]
PersonAction = namedtuple('PersonAction', PERSON_ACTION_FIELDS)

"""
数据库里月例银子类型的信息
"""
ALLOWANCE_TYPE_FIELDS = None
with DB.cursor() as cursor:
    sql = 'select * from allowance_type limit 1'
    cursor.execute(sql)
    cursor.fetchone()
    ALLOWANCE_TYPE_FIELDS = [col[0] for col in cursor.description]
AllowanceType = namedtuple('AllowanceType', ALLOWANCE_TYPE_FIELDS)

"""
数据库里一个人的月例银子的信息
"""
ALLOWANCE_FIELDS = None
with DB.cursor() as cursor:
    sql = 'select * from allowance limit 1'
    cursor.execute(sql)
    cursor.fetchone()
    ALLOWANCE_FIELDS = [col[0] for col in cursor.description]
Allowance = namedtuple('Allowance', ALLOWANCE_FIELDS)

"""
数据库里一个人的昵称
"""
NICK_FIELDS = None
with DB.cursor() as cursor:
    sql = 'select * from nick limit 1'
    cursor.execute(sql)
    cursor.fetchone()
    NICK_FIELDS = [col[0] for col in cursor.description]
Nick = namedtuple('Nick', NICK_FIELDS)

"""
数据库里一个人的尊称
"""
TITLE_FIELDS = None
with DB.cursor() as cursor:
    sql = 'select * from title limit 1'
    cursor.execute(sql)
    cursor.fetchone()
    TITLE_FIELDS = [col[0] for col in cursor.description]
Title = namedtuple('Title', TITLE_FIELDS)

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

"""
数据库里一条亲缘关系
"""
KINSHIP_FIELDS = None
with DB.cursor() as cursor:
    sql = 'select * from kinship limit 1'
    cursor.execute(sql)
    cursor.fetchone()
    KINSHIP_FIELDS = [col[0] for col in cursor.description]
Kinship = namedtuple('Kinship', KINSHIP_FIELDS)

def clearDict(d):
    if 'name' in d:
        del d['name']
    if 'subject' in d:
        del d['subject']
    if 'object' in d:
        del d['object']
    return d

class Graph:
    """
    关系图。
    这个树从祖先开始一级级向子辈进行扩散。
    当前实现下，关系图是树，而不是图。因为目前父亲和母亲节点不允许同时指向同一个孩子，只能由母亲指向。因此从树的结构看，分支数量是不能收敛的。
    """
    def __init__(self, top_name, family, branch):
        global DB
        self.db = DB
        self.family = family
        self.branch = branch
        self.level_list = []
        for n in range(6):
            lvl = Level(self, n)
            self.level_list.append(lvl)
        lvl = self.getLevel(0).addPerson(top_name)
        if not Person.exists(top_name):
            Person(lvl, top_name)
    def getLevel(self, i):
        return self.level_list[i]
    def cal(self):
        for lvl in self.level_list:
            lvl.complete()
            lvl.derive()
        self.employ()
    def employ(self):
        """
        找出丫头小厮仆人。
        """
        with self.db.cursor() as cursor:
            sql = 'select a.name, a.serve from serve a inner join person b on a.serve=b.name where b.family=%s and b.branch=%s order by b.sort_position desc'
            cursor.execute(sql, (self.family, self.branch))
            for row in cursor.fetchall():
                if not Person.exists(row[0]):
                    servant = Person(None, row[0])
                    Person.find(row[1]).addServant(servant)
    def output(self):
        for lvl in self.level_list:
            print('level '+str(lvl.level_number)+': '+ ' '.join(lvl.person_list))
    def toDict(self):
        o = {}
        o['family'] = self.family
        o['branch'] = self.branch
        o['level_list'] = [lvl.toDict() for lvl in self.level_list]
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
        if name not in self.person_list:
            self.person_list.append(name)
    def addPersonAfter(self, after_name, new_name):
        if new_name not in self.person_list:
            idx = self.person_list.index(after_name)
            self.person_list.insert(idx+1, new_name)
    def addPersonBefore(self, before_name, new_name):
        if new_name not in self.person_list:
            idx = self.person_list.index(before_name)
            self.person_list.insert(idx, new_name)
    def complete(self):
        """
        补全本层人员。
        方法：逐人扫描，如果是男的就查询妻妾，女的就查询丈夫。
        """
        with self.db.cursor() as cursor:
            for psn_name in self.person_list:
                psn = Person.find(psn_name)
                if psn.info.family!=self.tree.family or psn.info.branch!=self.tree.branch:
                    continue
                is_find_wife = True
                sql = ''
                if psn.info.gender=='男':
                    sql = 'select b.* from person a inner join kinship b on a.name=b.object where b.subject=%s and b.type="夫妻" order by b.sub_type asc, a.sort_position desc'
                else:
                    sql = 'select b.* from person a inner join kinship b on a.name=b.object where b.object=%s and b.type="夫妻" limit 1'
                    is_find_wife = False
                cursor.execute(sql, (psn_name))
                for row in cursor.fetchall():
                    kinship = Kinship(*row)
                    new_psn_name = kinship.object if is_find_wife else kinship.subject
                    if new_psn_name not in self.person_list:
                        if not Person.exists(new_psn_name):
                            Person(self, new_psn_name)
                        if is_find_wife:
                            add_after_name = psn_name if 0==len(psn.wife_list) else psn.wife_list[-1]
                            self.addPersonAfter(add_after_name, new_psn_name)
                        else:
                            self.addPersonBefore(psn_name, new_psn_name)
                    new_psn = Person.find(new_psn_name)
                    if psn.info.gender=='男':
                        psn.addWife(new_psn, kinship)
                    else:
                        new_psn.addWife(psn, kinship)
    def derive(self):
        """
        对于本层中的每个人找出其下一代。
        根据Graph类里树的要求，对于每一个小家庭，我们先扫描妻妾的孩子，再扫描男性的孩子。
        """
        with self.db.cursor() as cursor:
            for psn_name in self.person_list:
                psn = Person.find(psn_name)
                if psn.info.family!='' and psn.info.branch!='':
                    if psn.info.family!=self.tree.family or psn.info.branch!=self.tree.branch:
                        continue
                if psn.info.gender=='女':
                    self.deriveOfOne(psn, cursor)
                else:
                    for wife_name in psn.wife_list:
                        wife = Person.find(wife_name)
                        self.deriveOfOne(wife, cursor)
                    self.deriveOfOne(psn, cursor)
    def deriveOfOne(self, psn, cursor):
        """
        被derive调用，查询指定人的下一代。
        """
        if self.level_number==0:
            sql = 'select b.subject, b.object, b.type, b.sub_type, b.note, a.level from person a inner join kinship b on a.name=b.object where b.subject=%s and b.type="亲子" and a.family=%s and a.branch=%s order by a.sort_age desc'
            cursor.execute(sql, (psn.name, self.tree.family, self.tree.branch))
        else:
            sql = 'select b.subject, b.object, b.type, b.sub_type, b.note, a.level from person a inner join kinship b on a.name=b.object where b.subject=%s and b.type="亲子" order by a.sort_age desc'
            cursor.execute(sql, (psn.name))
        for row in cursor.fetchall():
            lvl = self.tree.getLevel(int(row[5]))
            kinship = Kinship(row[0],row[1],row[2],row[3],row[4])
            if kinship.object not in lvl.person_list:
                if not Person.exists(kinship.object):
                    Person(lvl, kinship.object)
                lvl.addPerson(kinship.object)
            child = Person.find(kinship.object)
            psn.addChild(child, kinship)
    def toDict(self):
        o = {}
        o['level_number'] = self.level_number
        o['person_list'] = self.person_list
        return o

class Person:
    """一个人"""
    _name_dict = {} # 静态变量，按照名字映射了所有的人
    _kinship_dict = {} # 静态变量，按照主宾映射了所有的亲缘关系
    def __init__(self, lvl, name):
        global DB
        self.db = DB
        self.level = lvl
        self.name = name
        # 亲子关系
        self.parent = None # Name # 每个人只有一个父母，不能既有父亲又有母亲，具体原因见“Graph类的注释”
        self.child_list = []
        # 夫妻关系
        self.husband = None # Name
        self.wife_list = [] # 按照地位顺序排列，正房大太太在前，偏房姨太太在后。
        # 主仆关系
        self.master = None # Name
        self.servant_list = []
        with self.db.cursor() as cursor:
            # 获取基本信息
            sql = 'select * from person where name=%s'
            cursor.execute(sql, (self.name))
            if cursor.rowcount==0:
                raise ValueError(self.name + ' not found in table `person`')
            self.info = PersonInfo(*cursor.fetchone())
            # 获取扩展信息
            sql = 'select * from person_ext where name=%s'
            cursor.execute(sql, (self.name))
            self.ext = PersonExt(*cursor.fetchone()) if cursor.rowcount>0 else None
            # 获取出场信息
            sql = 'select * from person_action where name=%s'
            cursor.execute(sql, (self.name))
            self.action = PersonAction(*cursor.fetchone()) if cursor.rowcount>0 else None
            # 获取昵称
            self.nick_list = []
            sql = 'select * from nick where name=%s'
            cursor.execute(sql, (self.name))
            for row in cursor.fetchall():
                self.nick_list.append(Nick(*row))
            # 获取尊称
            self.title_list = []
            sql = 'select * from title where name=%s'
            cursor.execute(sql, (self.name))
            for row in cursor.fetchall():
                self.title_list.append(Title(*row))
            # 获取月例银子信息
            sql = 'select * from allowance where name=%s'
            cursor.execute(sql, (self.name))
            self.allowance = Allowance(*cursor.fetchone()) if cursor.rowcount>0 else None
            # 获取社会地位信息
            sql = 'select * from social_position where name=%s'
            cursor.execute(sql, (self.name))
            self.social_position = SocialPositionInfo(*cursor.fetchone()) if cursor.rowcount>0 else None
        Person._name_dict[self.name] = self
    @staticmethod
    def find(name):
        return Person._name_dict[name]
    @staticmethod
    def exists(name):
        if name in Person._name_dict.keys():
            return True
        return False
    def addServant(self, servant):
        """
        添加仆人
        """
        if servant.master is None and servant.name not in self.servant_list:
            self.servant_list.append(servant.name)
            servant.master = self.name
    def addWife(self, wife, kinship):
        """
        添加妻子
        """
        if wife.husband is None and wife.name not in self.wife_list:
            self.wife_list.append(wife.name)
            wife.husband = self.name
            Person._kinship_dict[self.name+'@'+wife.name] = kinship
    def addChild(self, child, kinship):
        """
        添加孩子
        """
        if child.parent is None and child.name not in self.child_list:
            if self.husband:
                if child.name in Person.find(self.husband).child_list:
                    return
            self.child_list.append(child.name)
            child.parent = self.name
            Person._kinship_dict[self.name+'@'+child.name] = kinship
    def toDict(self):
        o = {}
        o['level'] = self.level.level_number if self.level is not None else None
        o['name'] = self.name
        o['info'] = clearDict(self.info._asdict())
        o['ext'] = clearDict(self.ext._asdict()) if self.ext is not None else None
        o['action'] = clearDict(self.action._asdict()) if self.action is not None else None
        o['nick_list'] = [clearDict(n._asdict()) for n in self.nick_list]
        o['title_list'] = [clearDict(t._asdict()) for t in self.title_list]
        o['allowance'] = clearDict(self.allowance._asdict()) if self.allowance is not None else None
        o['social_position'] = clearDict(self.social_position._asdict()) if self.social_position is not None else None
        o['parent'] = self.parent
        o['child_list'] = self.child_list
        o['husband'] = self.husband
        o['wife_list'] = self.wife_list
        o['master'] = self.master
        o['servant_list'] = self.servant_list
        return o

def main():
    family_list = [
        ['贾家','正'], 
        ['史家','正'], 
        ['王家','正']
    ]
    ob = {}
    ob['list'] = []
    for family in family_list:
        graph = Graph('根',family[0],family[1])
        graph.cal()
        graph.output()
        ob['list'].append(graph.toDict())
        ob['person_map'] = {name : Person.find(name).toDict() for name in Person._name_dict}
        ob['kinship_map'] = {k : clearDict(Person._kinship_dict[k]._asdict()) for k in Person._kinship_dict}
    with open('./graph.json', mode='w') as file:
        file.write(json.dumps(ob, indent=1, sort_keys=True, ensure_ascii=False, cls=DecimalEncoder))

main()