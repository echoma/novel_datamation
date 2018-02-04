// 数据库连接
class Db {
    constructor() {
        this.mysql = require('mysql');
        this.conn = this.mysql.createConnection({
            host:'localhost',
            user:'nd',
            password:'nd',
            database:'story_of_stone'
        });
        this.conn.connect();
    }
    queryChildren(name, cbCallee, cb=null) {
        this.conn.query('select b.* from person a inner join kinship b on a.name=b.object where b.subject=? and b.type="父母子女" order by a.sort_age desc;', [name], function(err, results, fields) {
            if (err)
                throw err;
            cb(cbCallee, results);
        });
    }
    queryWives(name, cbCallee, cb=null) {
        this.conn.query('select b.* from person a inner join kinship b on a.name=b.object where b.subject=? and b.type="夫妻" order by a.sort_age desc;', [name], function(err, results, fields) {
            if (err)
                throw err;
            cb(cbCallee, results);
        });
    }
}
let db = new Db();


// 关系图的数据结构
// 关系图
class Tree {
    constructor(top_name) {
        this.levels = [];
        let lvl = this.addLevel();
        lvl.addPerson(top_name);
    }
    addLevel() {
        let lvl = new Level(this.levels.length);
        this.levels.push(lvl);
        return lvl;
    }
    cal() {
        //先计算父母子女关系
        this.cal_lvl_idx = 0;
        this.cal_psn_idx = 0;
        this.calChildren();
    }
    calChildren() {
        let psn = this.levels[this.cal_lvl_idx].persons[this.cal_psn_idx];
        db.queryChildren(psn.name, this, Tree.onChildrenS);
    }
    static onChildrenS(tree, results) { tree.onChildren(results); }
    onChildren(results) {
        let cur_lvl = this.levels[this.cal_lvl_idx];
        let cur_psn = this.levels[this.cal_lvl_idx].persons[this.cal_psn_idx];
        if (results.length>0) {
            if (this.levels.length <= this.cal_lvl_idx+1) {
                this.addLevel();
            }
            let next_lvl = this.levels[this.cal_lvl_idx+1];
            console.log('==== '+cur_psn.name+' 的子女：');
            console.log(results);
            for (let record of results) {
                let new_psn = next_lvl.addPerson(record.object);
                new_psn.parent = cur_psn;
                cur_psn.children.push(new_psn);
            }
        } else {
            console.log('==== '+cur_psn.name+' 无子女');
        }
        if (this.cal_psn_idx+1>=cur_lvl.persons.length) {
            //本level结束，看看是否有下一个level
            if (this.cal_lvl_idx+1>=this.levels.length) {
                //所有level都结束了，开始计算婚姻关系
                this.cal_lvl_idx = 0;
                this.cal_psn_idx = 0;
                this.calWives();
            } else {
                //开始下一个level
                ++this.cal_lvl_idx;
                this.cal_psn_idx = 0;
                this.calChildren();
            }
        } else {
            //继续计算本level下一个person
            ++this.cal_psn_idx;
            this.calChildren();
        }
    }
    calWives() {
        let psn = this.levels[this.cal_lvl_idx].persons[this.cal_psn_idx];
        db.queryWives(psn.name, this, Tree.onWivesS);
    }
    static onWivesS(tree, results) { tree.onWives(results); }
    onWives(results) {
        let cur_lvl = this.levels[this.cal_lvl_idx];
        let cur_psn = this.levels[this.cal_lvl_idx].persons[this.cal_psn_idx];
        if (results.length>0) {
            console.log('==== '+cur_psn.name+' 的妻妾：');
            console.log(results);
            for (let record of results) {
                let new_psn = cur_lvl.addPersonAfter(cur_psn.name, record.object);
                new_psn.husband = cur_psn;
                cur_psn.wives.push(new_psn);
            }
        } else {
            console.log('==== '+cur_psn.name+' 无妻妾');
        }
        if (this.cal_psn_idx+1>=cur_lvl.persons.length) {
            //本level结束，看看是否有下一个level
            if (this.cal_lvl_idx+1>=this.levels.length) {
                //所有level都结束了，开始计算婚姻关系
                this.cal_lvl_idx = 0;
                this.cal_psn_idx = 0;
                this.calEnd();
            } else {
                //开始下一个level
                ++this.cal_lvl_idx;
                this.cal_psn_idx = 0;
                this.calWives();
            }
        } else {
            //继续计算本level下一个person
            ++this.cal_psn_idx;
            this.calWives();
        }
    }
    calEnd() {
        console.log('==== 计算结束');
        for (let lvl of this.levels) {
            let str = '';
            for (let psn of lvl.persons) {
                str += ' '+psn.name;
            }
            console.log(str);
        }
    }
}
// 关系图-代际
class Level {
    constructor(tree, lvl) {
        this.tree = tree;
        this.level = lvl;
        this.persons = [];
    }
    
    addPerson(name) {
        let psn = new Person(this, name);
        this.persons.push(psn);
        return psn;
    }
    addPersonAfter(after_name, new_name) {
        let psn = new Person(this, new_name);
        let found = false;
        for (let idx in this.persons) {
            if (this.persons[idx].name==after_name) {
                this.persons.splice(idx+1, 0, psn);
                found = true;
                break;
            }
        }
        if (!found) {
            throw '没有找到要在其后插入的名字：'+after_name;
        }
        return psn;
    }
}
// 关系图-小家庭
class Person {
    constructor(lvl, name) {
        this.level = lvl;
        this.name = name;
        this.parent = null;
        this.children = [];
        this.husband = null;
        this.wives = [];
    }
}

let treeOfJia = new Tree('贾公');
treeOfJia.cal();
