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
let paneCognition = null;
let paneEntity = null;
let dlgEntity = null;
$(document).ready(function(){
    const fs = require('fs');
    const con = fs.readFileSync('data_type.json', 'utf-8');
    const data_type = JSON.parse(con);
    anaDataType(data_type);
    $('input[name=pane_type]').change(()=>{
        let sel_pane_name = $('input[name=pane_type]:checked').val();
        $('#pane_relation').hide();
        $('#pane_cognition').hide();
        $('#pane_entity').hide();
        $(`#pane_${sel_pane_name}`).show();
    });
    paneRelation = new RelationPane();
    paneCognition = new CognitionPane();
    paneEntity = new EntityPane();
    dlgEntity = new EntityDlg();
});

class RelationPane {
    constructor() {
        this.file_path = `${work_dir}/relation.json`;
        // select list
        const dom_pane = this.dom_pane = $('#pane_relation');
        const dom_sel_rel = dom_pane.find('select[name=relation]');
        const dom_sel_sub = dom_pane.find('select[name=subject]');
        const dom_sel_sub_ent = dom_pane.find('select[name=subject_entity]');
        const dom_sel_obj = dom_pane.find('select[name=object]');
        const dom_sel_obj_ent = dom_pane.find('select[name=object_entity]');
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
        dom_sel_sub.change((e)=>{
            this.updateEntity(dom_sel_sub, dom_sel_sub_ent);
        });
        dom_sel_obj.change((e)=>{
            this.updateEntity(dom_sel_obj, dom_sel_obj_ent);
        });
        setTimeout(()=>{
            this.updateEntity(dom_sel_sub, dom_sel_sub_ent);
            this.updateEntity(dom_sel_obj, dom_sel_obj_ent);
        }, 1000);
        // add button
        dom_pane.find('button[name=add]').click(()=>{
            const rel = dom_sel_rel.val();
            const sub = dom_sel_sub_ent.val();
            const obj = dom_sel_obj_ent.val();
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
    updateEntity(dom_sel, dom_sel_ent) {
        let sub_type = dom_sel.val();
        let ent_list = paneEntity.getEntityListByType(sub_type);
        dom_sel_ent.children().remove();
        for (let ent of ent_list) {
            let dom_opt = $('<option></option>').text(ent.name);
            dom_sel_ent.append(dom_opt);
        }
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
                    dom_tr.find('[name=sub]').text(rec.sub);
                    dom_tr.find('[name=obj]').text(rec.obj);
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
        new_rec.sub = sub;
        new_rec.obj = obj;
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
            data.list.sort((a,b)=>{
                return a.sub.localeCompare(b.sub);
            });
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
            data.list.sort((a,b)=>{
                return a.sub.localeCompare(b.sub);
            });
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

class CognitionPane {
    constructor() {
        this.file_path = `${work_dir}/cognition.json`;
        this.data = null;
        // select list
        const dom_pane = this.dom_pane = $('#pane_cognition');
        const dom_sel_cog = dom_pane.find('select[name=cognition]');
        for(let name of data_type_list) {
            const sub_name = rmRootOfDataType(name);
            if (sub_name.length==0)
                continue;
            let dom_opt = $('<option></option>').text(sub_name).val(sub_name);
            if (name.indexOf('认知')==0) {
                dom_sel_cog.append(dom_opt);
            }
        }
        const dom_inp_val = dom_pane.find('input[name=cogval]');
        // add button
        dom_pane.find('button[name=add]').click(()=>{
            const cog = dom_sel_cog.val();
            const val = dom_inp_val.val().trim();
            this.add(cog, val);
        });
        // refresh button
        dom_pane.find('button[name=refresh]').click(()=>{
            this.refresh();
        });
        // table
        this.dom_tb = this.dom_pane.find('table');
        this.dom_tb_tr_sample = this.dom_tb.find('tr[name=sample]');
        this.dom_tb_tr_sample.find('button[name=del]').click((e)=>{
            let dom_val = $(e.currentTarget).parents('span[name=val]');
            let dom_cog = dom_val.parents('[name=rec]');
            this.del(dom_cog.attr('key'), dom_val.attr('key'));
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
            this.data = data;
            const dom_tb = this.dom_tb;
            let dom_tr_rec = dom_tb.find('tr[name=rec]').attr('count','0');
            let dom_tr_val = dom_tb.find('span[name=val]').attr('count','0');
            for(let rec in data) {
                let key = this.reckey(rec);
                let dom_tr = dom_tr_rec.filter(`[key=${key}]`);
                if (dom_tr.length==0) {
                    dom_tr = this.dom_tb_tr_sample.clone(true).attr('key',key).attr('name','rec').show().attr('count','1').css('display','');
                    dom_tr.find('[name=cog]').text(data_type_map[rec]);
                    this.dom_tb_tr_sample.parent().append(dom_tr);
                } else {
                    dom_tr.attr('count','1');
                }
                let dom_val_sample = dom_tr.find('[name=sample_value]');
                for(let val of data[rec]) {
                    let dom_val = dom_tr.find(`span[name=val][key=${key}]`);
                    if (dom_val.length==0) {
                        dom_val = dom_val_sample.clone(true).attr('key', val).attr('name', 'val').show().attr('count','1').css('display','');
                        dom_val.find('span[name=text]').text(val);
                        dom_val_sample.parent().append(dom_val);
                    } else {
                        dom_val.attr('count','1');
                    }
                }
            }
            dom_tr_val.filter('[count=0]').remove();
            dom_tr_rec.filter('[count=0]').remove();
        });
    }
    val_list(cog_type) {
        let type = leafOfDataType(cog_type);
        if (this.data && this.data.hasOwnProperty(type)) {
            return this.data[type];
        }
        return [];
    }
    add(cog, val) {
        cog = leafOfDataType(cog);
        const new_key = this.reckey(cog);
        const fs = require('fs');
        fs.readFile(this.file_path, 'utf-8', (err, file_con)=>{
            if (err)
                throw err;
            let data = JSON.parse(file_con);
            if (data.hasOwnProperty(cog)) {
                if (data[cog].indexOf(val)!=-1) {
                    alert('已经存在');
                    return;
                } else {
                    data[cog].push(val);
                }
            } else {
                data[cog] = [];
                data[cog].push(val);
            }
            const new_file_con = JSON.stringify(data);
            fs.writeFile(this.file_path, new_file_con, (err)=>{
                if (err)
                    throw err;
                this.refresh();
            });
        });
    }
    del(cog, val) {
        const fs = require('fs');
        alert(cog+' <-> '+val);
        fs.readFile(this.file_path, 'utf-8', (err, file_con)=>{
            if (err)
                throw err;
            let data = JSON.parse(file_con);
            let found = false;
            if (data.hasOwnProperty(cog)) {
                let idx = data[cog].indexOf(val);
                if (idx!=-1) {
                    found = true;
                    data[cog].splice(idx, 1);
                    if (data[cog].length==0)
                        delete data[cog];
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
        return leafOfDataType(rec);
    }
}

class EntityPane {
    constructor() {
        this.file_path = `${work_dir}/entity.json`;
        this.data = null;
        // select list
        const dom_pane = this.dom_pane = $('#pane_entity');
        const dom_sel_ent = dom_pane.find('select[name=entity_type]');
        for(let name of data_type_list) {
            const sub_name = rmRootOfDataType(name);
            if (sub_name.length==0)
                continue;
            let dom_opt = $('<option></option>').text(sub_name).val(sub_name);
            if (name.indexOf('对象')==0) {
                dom_sel_ent.append(dom_opt);
            }
        }
        // filter button
        dom_pane.find('button[name=filter]').click(()=>{
            this.filter(dom_sel_ent.val());
        });
        // add button
        dom_pane.find('button[name=add]').click(()=>{
            dlgEntity.show();
        });
        // refresh button
        dom_pane.find('button[name=refresh]').click(()=>{
            this.refresh();
        });
        // table
        this.dom_tb = this.dom_pane.find('table');
        this.dom_tb_tr_sample = this.dom_tb.find('tr[name=sample]');
        this.dom_tb_tr_sample.find('button[name=del]').click((e)=>{
            let dom_rec = $(e.currentTarget).parents('tr[name=rec]');
            this.delByReckey(dom_rec.attr('key'));
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
            this.data = data;
            const dom_tb = this.dom_tb;
            let dom_tr_rec = dom_tb.find('tr[name=rec]').attr('count','0');
            for(let rec of data.list) {
                let key = this.reckey(rec);
                let dom_tr = dom_tr_rec.filter(`[key=${key}]`);
                if (dom_tr.length==0) {
                    dom_tr = this.dom_tb_tr_sample.clone(true).attr('key',key).attr('name','rec').show().attr('count','1').css('display','');
                    dom_tr.find('[name=type]').text(data_type_map[rec.type]);
                    dom_tr.find('[name=name]').text(rec.name);
                    dom_tr.find('[name=prop_list]').text(this.prop_text(rec));
                    this.dom_tb_tr_sample.parent().append(dom_tr);
                } else {
                    dom_tr.attr('count','1');
                }
            }
            dom_tr_rec.filter('[count=0]').remove();
        });
    }
    reckey(rec) {
        return rec.name;
    }
    prop_text(rec) {
        let txt = '';
        for (let prop of rec.pl) {
            let one = leafOfDataType(prop.type)+'='+prop.value;
            if (txt.length!=0)
                txt += ', ';
            txt += one;
        }
        return txt;
    }
    getEntityListByType(type) {
        let list = [];
        for (let rec of this.data.list) {
            if (data_type_map[rec.type].indexOf(type)!=-1) {
                list.push(rec);
            }
        }
        return list;
    }

    add(type, name, prop_list) {
        let new_rec = {};
        new_rec.type = leafOfDataType(type);
        new_rec.name = leafOfDataType(name);
        new_rec.pl = prop_list;
        for(let prop of new_rec.pl) {
            prop.type = leafOfDataType(prop.type);
        }
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
            data.list.sort((a,b)=>{
                return a.name.localeCompare(b.name);
            });
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
                alert('没有找到，无法删除。key='+del_key);
                return;
            }
            data.list.sort((a,b)=>{
                return a.name.localeCompare(b.name);
            });
            const new_file_con = JSON.stringify(data);
            fs.writeFile(this.file_path, new_file_con, (err)=>{
                if (err)
                    throw err;
                this.refresh();
            });
        });
    }
}

class EntityDlg {
    constructor() {
        // entity type select list
        const dom_entity_dlg = this.dom_entity_dlg = $('#entity_dlg');
        const dom_sel_ent = dom_entity_dlg.find('select[name=entity_type]');
        for(let name of data_type_list) {
            const sub_name = rmRootOfDataType(name);
            if (sub_name.length==0)
                continue;
            let dom_opt = $('<option></option>').text(sub_name).val(sub_name);
            if (name.indexOf('对象')==0) {
                dom_sel_ent.append(dom_opt);
            }
        }
        // cog type select list
        const dom_sel_cog = dom_entity_dlg.find('select[name=cog_type]');
        for(let name of data_type_list) {
            const sub_name = rmRootOfDataType(name);
            if (sub_name.length==0)
                continue;
            let dom_opt = $('<option></option>').text(sub_name).val(sub_name);
            if (name.indexOf('认知')==0) {
                dom_sel_cog.append(dom_opt);
            }
        }
        // ensure button
        dom_entity_dlg.find('button[name=ensure]').click(()=>{
            let type = this.dom_entity_dlg.find('[name=entity_type]').val();
            let name = this.dom_entity_dlg.find('[name=name]').val();
            let doms_cog_type = this.dom_entity_dlg.find('[name=cog_type]')
            let doms_cog_val = this.dom_entity_dlg.find('[name=cog_val]')
            let prop_list = [];
            for (let i=0; i<doms_cog_type.length; ++i) {
                let rec = {};
                rec.type = doms_cog_type.eq(i).val();
                rec.value = doms_cog_val.eq(i).val();
                if (rec.type && rec.value && rec.value.length>0)
                    prop_list.push(rec);
            }
            paneEntity.add(type, name, prop_list);
        });
        // cancel button
        dom_entity_dlg.find('button[name=cancel]').click(()=>{
            this.hide();
        });
        // add prop button
        let dom_prop_sample = this.dom_prop_sample = dom_entity_dlg.find('[name=prop_sample]');
        dom_prop_sample.find('button[name=del_prop]').click((e)=>{
            let dom_prop = $(e.currentTarget).parents('[name=prop]');
            dom_prop.remove();            
        });
        dom_prop_sample.find('[name=cog_type]').change((e)=>{
            let dom_prop = $(e.currentTarget).parents('[name=prop]');
            this.updateCogVal(dom_prop);
        });
        dom_entity_dlg.find('button[name=add_prop]').click(()=>{
            let dom_prop = dom_prop_sample.clone(true).attr('name','prop').show();
            dom_prop_sample.parent().append(dom_prop);
            this.updateCogVal(dom_prop);
        });
    }

    show() {
        this.dom_entity_dlg.show();
    }
    hide() {
        this.dom_entity_dlg.hide();
    }

    updateCogVal(dom_prop) {
        let cog_type = dom_prop.find('[name=cog_type]').val();
        let val_list = paneCognition.val_list(cog_type);
        let dom_sel = dom_prop.find('select[name=cog_val]');
        dom_sel.children().remove();
        for (let val of val_list) {
            let dom_opt = $('<option></option>').text(val);
            dom_sel.append(dom_opt);
        }
    }
}