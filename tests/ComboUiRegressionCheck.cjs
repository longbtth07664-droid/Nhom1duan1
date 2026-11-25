// Compare observable behavior before/after refactoring using the same DOM fixtures.
const fs = require('fs');
const vm = require('vm');
const cp = require('child_process');
const assert = require('assert');
const path = 'src/main/webapp/quanLyCombo.jsp';
const previous = cp.execFileSync('git', ['show', 'a7c658b:' + path], {encoding:'utf8'});
const current = fs.readFileSync(path, 'utf8');
function run(source, rate) {
    const nodes = {
        addEmpty: {},
        addTongGiaLe: {},
        addGiaCombo: {dataset:{original:'123000'}},
        addGiamGia: {value:String(rate)}
    };
    const rows = [{textContent:'Bắp rang'}, {textContent:'Nước suối'}];
    const selected = [
        {dataset:{gia:'45000'}, closest:()=>({querySelector:()=>({value:'2'})})},
        {dataset:{gia:'15000'}, closest:()=>({querySelector:()=>({value:'1'})})}
    ];
    nodes.addPickerBody = {querySelectorAll:()=>selected};
    const context = {document:{addEventListener(){}, getElementById:id=>nodes[id], querySelectorAll:()=>rows}};
    vm.createContext(context);
    for (const match of source.matchAll(/<script>([\s\S]*?)<\/script>/g)) vm.runInContext(match[1],context);
    context.locSanPham('add',' BAP ');
    context.tinhTongGiaLe('add');
    return JSON.stringify({rows,empty:nodes.addEmpty,total:nodes.addTongGiaLe,price:nodes.addGiaCombo});
}
for (const rate of [-1,0,10,20,50]) assert.strictEqual(run(current,rate),run(previous,rate));
console.log('PASS: combo Vietnamese filtering, selected products, discount 0/10/20/50 and preserve-price behavior match baseline a7c658b.');
