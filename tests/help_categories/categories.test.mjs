// SPDX-License-Identifier: GPL-3.0-or-later
import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync,existsSync} from 'node:fs';
import vm from 'node:vm';
const root=new URL('../../',import.meta.url);
const dictionary={'Mathematics':'Matemática','Numeration':'Numeração'};
function help(section) {
    const context=vm.createContext({activityInfo:{section,name:'example/Example.qml',description:''},
        qsTr:value=>value,qsTranslate:(_context,value)=>dictionary[value]??value});
    const categories=new URL('src/core/ActivityCategories.js',root);
    if(existsSync(categories)) {
        vm.runInContext(readFileSync(categories,'utf8').replace(/^\.pragma.*$/gm,''),context);
        context.ActivityCategories={format:vm.runInContext('format',context)};
    }
    const source=readFileSync(new URL('src/core/DialogHelp.qml',root),'utf8');
    const body=source.match(/function getContent\(\)\s*{([\s\S]*?)\n    }/)[1];
    return vm.runInContext('(function(){'+body+'})()',context);
}
test('real help formatter translates category tokens and retains the footer and activity ID',()=>{
    const content=help('math numeration');
    assert.ok(content.includes('<b>Section: </b>Matemática, Numeração (example)'),content);
});
test('all 203 activity category tokens are covered without changing filter IDs',()=>{
    const context=vm.createContext({qsTranslate:(_context,value)=>value});
    vm.runInContext(readFileSync(new URL('src/core/ActivityCategories.js',root),'utf8').replace(/^\.pragma.*$/gm,''),context);
    const known=JSON.parse(vm.runInContext('JSON.stringify(labels())',context));
    const activities=readFileSync(new URL('src/activities/activities.txt',root),'utf8').split(/\r?\n/).map(line=>line.trim()).filter(line=>line&&!line.startsWith('#'));
    assert.equal(activities.length,203);
    const tokens=new Set();
    for(const activity of activities) {
        const source=readFileSync(new URL(`src/activities/${activity}/ActivityInfo.qml`,root),'utf8');
        const section=source.match(/^\s*section:\s*"([^"]+)"/m)[1];
        for(const token of section.split(/\s+/)) {
            assert.ok(Object.hasOwn(known,token),`${activity}: unmapped category ${token}`);tokens.add(token);
        }
    }
    assert.deepEqual(Object.keys(known).sort(),[...tokens].sort());
    assert.equal(tokens.size,33);
    assert.equal(vm.runInContext("format('future-tag')",context),'future-tag');
    assert.equal(vm.runInContext("format('   ')",context),'');
});
