// SPDX-License-Identifier: GPL-3.0-or-later
import vm from 'node:vm';
import {readFileSync,existsSync} from 'node:fs';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';
const root=new URL('../../',import.meta.url), output={};
const strict=process.argv.includes("--strict-strokes");
const expected={number_sequence:9,clickanddraw:9,drawletters:26,drawnumbers:10};
for(const [activity,count] of Object.entries(expected)){
 const core=vm.createContext({});const text=readFileSync(new URL('src/core/core.js',root),'utf8');
 vm.runInContext(text.match(/function getSoundFilenamForChar\(c\)[\s\S]*?\n}/)[0],core);
 const c=vm.createContext({GCompris:{ApplicationInfo:{getAudioFilePath:x=>x.replaceAll('$CA','ogg').replace('$LOCALE','pt')}},Core:{getSoundFilenamForChar:x=>core.getSoundFilenamForChar(x)}});
 vm.runInContext(readFileSync(new URL(`src/activities/${activity}/${activity}_dataset.js`,root),'utf8').replace(/^\.import.*$/gm,''),c);
 const levels=JSON.parse(JSON.stringify(vm.runInContext('get()',c)));assert.equal(levels.length,count);
 output[activity]=levels.map((level,index)=>{
  assert.ok(level.coordinates.length>=2);for(const point of level.coordinates){assert.equal(point.length,2);for(const value of point)assert.ok(Number.isFinite(value)&&value>=0&&value<=520);}
  if(strict&&level.coordinates2)assert.equal(level.coordinates2.length,level.coordinates.length,activity+" level "+(index+1)+" stroke groups");
  const prefix=`src/activities/${activity==='clickanddraw'?'number_sequence':activity}/resource/`;
  if(strict)for(let i=1;i<level.coordinates.length;i++)assert.ok(JSON.stringify(level.coordinates[i])!==JSON.stringify(level.coordinates[i-1])||(level.coordinates2&&level.coordinates2[i]!==level.coordinates2[i-1]),level.imageName2+' duplicate consecutive point '+i);
  const images={};for(const name of [level.imageName1,level.imageName2]){const path=prefix+name;assert.ok(existsSync(new URL(path,root)));images[path]=createHash('sha256').update(readFileSync(new URL(path,root))).digest('hex');}
  if(activity==='drawletters'||activity==='drawnumbers'){
   const character=activity==='drawletters'?String.fromCharCode(97+index):String(index);
   assert.equal(level.sound,`voices-ogg/pt/alphabet/U${character.codePointAt(0).toString(16).toUpperCase().padStart(4,'0')}.ogg`);
  }
  const reviewedBreaks=activity==='drawletters'?{6:[28],12:[10],13:[12]}[index]:undefined;
  if(strict&&reviewedBreaks)assert.deepEqual(level.coordinates.map((_,i)=>i).filter(i=>i>0&&level.coordinates2[i]!==level.coordinates2[i-1]),reviewedBreaks,level.imageName2+' geometric stroke starts');
  return {...level,images,breaks:level.coordinates.map((_,i)=>i===0||(reviewedBreaks?reviewedBreaks.includes(i):!!(level.coordinates2&&level.coordinates2[i]!==level.coordinates2[i-1])))};
 });
}
console.log(JSON.stringify(output,null,2));
