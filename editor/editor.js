//whether run in nw.js
const is_nwjs = (typeof nw != 'undefined');
//whether run in dev mode (nw.js SDK version)
const is_nwjsdev = is_nwjs && (window.navigator.plugins.namedItem('Native Client') !== null);
function showDevTools() {
    if (is_nwjsdev)
        nw.Window.get().showDevTools();
}

let work_dir = '../01_stone_story';
let data_type_list = [];
let data_type_map = {};
function anaDataType(json_obj, up_type_str='') {
    for (let key in json_obj) {
        let name = key;
        let short_name = name;
        if (up_type_str.length>0)
            name = `${up_type_str}@${name}`;
        data_type_map[short_name] = name;
        data_type_list.push(name);
        const val = json_obj[key];
        if (!Number.isInteger(val))
            anaDataType(val, name);
    }
}
function rmRootOfDataType(name) {
    const idx = name.indexOf('@');
    if (idx==-1)
        return '';
    return name.substring(idx+1);
}
function leafOfDataType(name) {
    const idx = name.lastIndexOf('@');
    if (idx==-1)
        return name;
    return name.substring(idx+1);
}

let paneRelation = null;
$(document).ready(function(){
    const fs = require('fs');
    const con = fs.readFileSync('data_type.json', 'utf-8');
    const data_type = JSON.parse(con);
    anaDataType(data_type);
    const dom_sel = $('select[id=data_type_sample]');
    for(let name of data_type_list) {
        let dom_opt = $('<option></option>').text(name).val(name);
        dom_sel.append(dom_opt);
    }
    paneRelation = new RelationPane();
});

class RelationPane {
    constructor() {
        this.file_path = `${work_dir}/relation.json`;
        // select list
        const dom_pane = this.dom_pane = $('#pane_relation');
        const dom_sel_rel = dom_pane.find('select[name=relation]');
        const dom_sel_sub = dom_pane.find('select[name=subject]');
        const dom_sel_obj = dom_pane.find('select[name=object]');
        for(let name of data_type_list) {
            const sub_name = rmRootOfDataType(name);
            if (sub_name.length==0)
                continue;
            let dom_opt = $('<option></option>').text(sub_name).val(sub_name);
            if (name.indexOf('关系')==0) {
                dom_sel_rel.append(dom_opt);
            } else {
                dom_sel_sub.append(dom_opt);
                dom_sel_obj.append(dom_opt.clone());
            }
        }
        // add button
        dom_pane.find('button[name=add]').click(()=>{
            const rel = dom_sel_rel.val();
            const sub = dom_sel_sub.val();
            const obj = dom_sel_obj.val();
            this.add(rel, sub, obj);
        });
        // refresh button
        dom_pane.find('button[name=refresh]').click(()=>{
            this.refresh();
        });
        // table
        this.dom_tb = this.dom_pane.find('table');
        this.dom_tb_tr_sample = this.dom_tb.find('tr[name=sample]');
        this.dom_tb_tr_sample.find('button[name=del]').click((e)=>{
            this.delByReckey($(e.currentTarget).parents('tr').attr('key'));
        });
        // refresh
        this.refresh();
    }
    refresh() {
        const fs = require('fs');
        fs.readFile(this.file_path, 'utf-8', (err, file_con)=>{
            if (err)
                throw err;
            const data = JSON.parse(file_con);
            const dom_tb = this.dom_tb;
            let dom_tr_rec = dom_tb.find('tr[name=rec]').attr('count','0');
            for(let rec of data.list) {
                let key = this.reckey(rec);
                let dom_tr = dom_tr_rec.filter(`[key=${key}]`);
                if (dom_tr.length==0) {
                    dom_tr = this.dom_tb_tr_sample.clone(true).attr('key',key).attr('name','rec').show().attr('count','1').css('display','');
                    dom_tr.find('[name=rel]').text(data_type_map[rec.rel]);
                    dom_tr.find('[name=sub]').text(data_type_map[rec.sub]);
                    dom_tr.find('[name=obj]').text(data_type_map[rec.obj]);
                    this.dom_tb_tr_sample.parent().append(dom_tr);
                } else {
                    dom_tr.attr('count','1');
                }
            }
            dom_tr_rec.filter('[count=0]').remove();
        });
    }
    add(rel, sub, obj) {
        const new_rec = {};
        new_rec.rel = leafOfDataType(rel);
        new_rec.sub = leafOfDataType(sub);
        new_rec.obj = leafOfDataType(obj);
        const new_key = this.reckey(new_rec);
        const fs = require('fs');
        fs.readFile(this.file_path, 'utf-8', (err, file_con)=>{
            if (err)
                throw err;
            let data = JSON.parse(file_con);
            for (let rec of data.list) {
                let key = this.reckey(rec);
                if (key==new_key) {
                    alert('已经存在');
                    return;
                }
            }
            data.list.push(new_rec);
            const new_file_con = JSON.stringify(data);
            fs.writeFile(this.file_path, new_file_con, (err)=>{
                if (err)
                    throw err;
                this.refresh();
            });
        });
    }
    delByReckey(del_key) {
        const fs = require('fs');
        fs.readFile(this.file_path, 'utf-8', (err, file_con)=>{
            if (err)
                throw err;
            let data = JSON.parse(file_con);
            let found = false;
            for (let i=0; i<data.list.length; ++i) {
                let rec = data.list[i];
                let key = this.reckey(rec);
                if (key==del_key) {
                    data.list.splice(i,1);
                    found = true;
                    break;
                }
            }
            if (!found) {
                alert('没有找到，无法删除');
                return;
            }
            const new_file_con = JSON.stringify(data);
            fs.writeFile(this.file_path, new_file_con, (err)=>{
                if (err)
                    throw err;
                this.refresh();
            });
        });
    }
    reckey(rec) {
        return `${leafOfDataType(rec.rel)}#${leafOfDataType(rec.sub)}#${leafOfDataType(rec.obj)}`;
    }
}