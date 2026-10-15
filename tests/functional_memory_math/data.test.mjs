// SPDX-License-Identifier: GPL-3.0-or-later
import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import vm from 'node:vm';
const root=new URL('../../',import.meta.url);
const read=path=>readFileSync(new URL(path,root),'utf8');
const families={add:'Add',minus:'Minus',mult:'Mult',div:'Div','add-minus':'AddMinus','mult-div':'MultDiv','add-minus-mult-div':'AddMinusMultDiv'};
// A decimal counting oracle independent of math_util's formula and cached results.
function result(expression) {
 const [,a,op,b]=/^(\d+) ([+−×÷]) (\d+)$/.exec(expression)??[];
 assert.ok(op,`Readable mathematical card: ${expression}`);
 const left=Number(a),right=Number(b);
 const add=(x,y)=>[...Array(x),...Array(y)].length;
 const times=(x,y)=>Array.from({length:y},()=>Array(x).fill(1)).flat().length;
 if(op==='+')return add(left,right);
 if(op==='×')return times(left,right);
 if(op==='−')return Array.from({length:left+1},(_,n)=>n).find(n=>add(n,right)===left);
 return Array.from({length:left+1},(_,n)=>n).find(n=>times(n,right)===left);
}
function load(reverse=false) {
 const context=vm.createContext({qsTr:value=>value,Core:{shuffle:array=>reverse?array.reverse():array}});
 vm.runInContext(read('src/activities/memory/math_util.js').replace(/^\.(pragma|import).*$/gm,''),context);
 return context;
}
function evaluate(context,fn,table){return JSON.parse(JSON.stringify(vm.runInContext(`${fn}(${table})`,context)));}
function valid(pairs) {
 assert.ok(pairs.length>=5);assert.equal(new Set(pairs.map(pair=>pair[1])).size,pairs.length);
 for(const [expression,answer] of pairs)assert.equal(answer,result(expression),expression);
}
test('all 138 source datasets generate enough distinct, mathematically correct pairs',()=>{
 let datasets=0,pairs=0;
 for(const reverse of [false,true]) {
  const context=load(reverse);
  for(const [family,fn] of Object.entries(families))for(const tux of ['', '-tux']) {
   const count=family==='mult-div'?9:10;
   const info=read(`src/activities/memory-math-${family}${tux}/ActivityInfo.qml`);
   assert.equal(JSON.parse(info.match(/levels:\s*(\[[^\]]+\])/)[1]).length,count);
   for(let folder=1;folder<=count;folder++) {
    const table=family==='mult-div'?folder+1:folder;
    const source=read(`src/activities/memory-math-${family}${tux}/resource/${folder}/Data.qml`);
    assert.match(source,new RegExp(`texts: Memory.get${fn}Table\\(${table}\\)`));
    assert.match(source,/columns: 5/);assert.match(source,/rows: 2/);
    const generated=evaluate(context,`get${fn}Table`,table);valid(generated);
    const allowed=family==='add'?['+']:family==='minus'?['−']:family==='mult'?['×']:family==='div'?['÷']:family==='add-minus'?['+','−']:family==='mult-div'?['×','÷']:['+','−','×','÷'];
    for(const [expression] of generated)assert.ok(allowed.includes(expression.split(' ')[1]));
    datasets++;pairs+=generated.length;
   }
  }
 }
 assert.equal(datasets,276);console.log(JSON.stringify({datasets:datasets/2,shuffleOrders:2,pairs}));
});
test('primitive tables retain all ten known answers and operand order branches',()=>{
 const expected={Add:[2,3,4,5,6,7,8,9,10,11],Minus:[1,2,3,4,5,6,7,8,9,10],Mult:[1,2,3,4,5,6,7,8,9,10],Div:[1,2,3,4,5,6,7,8,9,10]};
 for(const [fn,answers] of Object.entries(expected))assert.deepEqual(evaluate(load(),`get${fn}Table`,1).map(pair=>pair[1]),answers);
 // Force each documented random operand order only at the JS boundary.
 for(const random of [0,0.99]) {
  const context=load();vm.runInContext(`Math.random=()=>${random}`,context);
  for(const fn of ['Add','Mult'])for(let table=1;table<=10;table++) {
   const pairs=evaluate(context,`get${fn}Table`,table);valid(pairs);
   for(let i=0;i<10;i++)assert.equal(Number(pairs[i][0].split(' ')[random===0?2:0]),table);
  }
 }
});
test('oracle rejects a wrong result and duplicate answers rather than trusting matchCode',()=>{
 assert.throws(()=>valid([['1 + 1',99],['1 + 2',3],['1 + 3',4],['1 + 4',5],['1 + 5',6]]));
 assert.throws(()=>valid([['1 + 1',2],['1 + 1',2],['1 + 3',4],['1 + 4',5],['1 + 5',6]]));
});
