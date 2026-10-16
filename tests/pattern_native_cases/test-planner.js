// SPDX-License-Identifier: GPL-3.0-or-later
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const context = vm.createContext({});
vm.runInContext(fs.readFileSync(__dirname + '/planner.js', 'utf8'), context);
function cell(x,y,signature,width=8,height=6) {
    return {frame:{x,y,width,height},signature};
}
const question = [cell(14,16,'a'),cell(3,7,'a'),cell(25,7,'c'),
                  cell(25,16,'b'),cell(14,7,'b'),cell(3,16,'c')];
const answer = [cell(110,57,null,18,12),cell(160,40,null,18,12),
                cell(135,57,null,18,12),cell(110,40,null,18,12),
                cell(160,57,null,18,12),cell(135,40,null,18,12)];
const palette = [{id:'p-c',signature:'c'},{id:'p-a',signature:'a'},
                 {id:'p-b',signature:'b'}];
const result = context.visiblePlan(question,answer,palette,true);
assert.deepEqual(JSON.parse(JSON.stringify(result.placements.map(p=>[
    p.target_frame.x,p.target_frame.y,p.palette_id]))),
    [[160,40,'p-a'],[135,40,'p-b'],[110,40,'p-c'],
     [160,57,'p-c'],[135,57,'p-a'],[110,57,'p-b']]);
assert.throws(()=>context.visiblePlan(question,answer,palette.slice(0,2),false),/palette/);
assert.throws(()=>context.visiblePlan(question.slice(0,5),answer,palette,false),/Incomplete/);
assert.throws(()=>context.visiblePlan(question,answer,palette.concat(palette[0]),false),/Duplicate/);
console.log('Literal dynamic planner passed; no Qt/game completion claimed');
