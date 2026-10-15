// SPDX-License-Identifier: GPL-3.0-or-later
import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import {readFileSync,existsSync} from 'node:fs';
const root=new URL('../../',import.meta.url);
const core=vm.createContext({});
const coreSource=readFileSync(new URL('src/core/core.js',root),'utf8');
vm.runInContext(coreSource.match(/function getSoundFilenamForChar\(c\)[\s\S]*?\n}/)[0],core);
function dataset(file){
 const context=vm.createContext({GCompris:{ApplicationInfo:{getAudioFilePath:value=>value.replaceAll('$CA','ogg')}},Core:{getSoundFilenamForChar:char=>core.getSoundFilenamForChar(char)}});
 vm.runInContext(readFileSync(new URL('src/activities/'+file,root),'utf8').replace(/^\.import.*$/gm,''),context);
 return JSON.parse(JSON.stringify(vm.runInContext('get()',context)));
}
test('six visual grids contain the 21 original distinct animal/baby twins',()=>{
 const levels=dataset('memory/memorydataset.js');assert.equal(levels.length,6);
 assert.deepEqual(levels.map(l=>l.columns*l.rows/2),[3,4,5,6,9,10]);
 assert.equal(levels[0].images.length,21);
 for(const level of levels)for(const pair of level.images){assert.equal(pair[0],pair[1]);assert.ok(existsSync(new URL(pair[0].replace('qrc:/gcompris/',''),root)));}
 assert.equal(new Set(levels[0].images.map(p=>p[0])).size,21);
 assert.equal(new Set(levels[0].images.map(p=>readFileSync(new URL(p[0].replace('qrc:/gcompris/',''),root)).toString('base64'))).size,21);
});
test('seven sound grids retain 30 distinct, identical audio-file twins',()=>{
 const levels=dataset('memory-sound/memorysounddataset.js');assert.equal(levels.length,7);
 assert.deepEqual(levels.map(l=>l.columns*l.rows/2),[3,4,5,6,15,10,12]);
 for(const level of levels){assert.equal(level.sounds.length,30);assert.equal(level.images.length,30);
  for(const pair of level.sounds){assert.equal(pair[0],pair[1]);assert.ok(existsSync(new URL(pair[0].replace('qrc:/gcompris/',''),root)));}
 }
 const sounds=levels[0].sounds.map(p=>p[0]);assert.equal(new Set(sounds).size,30);
 assert.equal(new Set(sounds.map(p=>readFileSync(new URL(p.replace('qrc:/gcompris/',''),root)).toString('base64'))).size,30);
});
test('four uppercase/lowercase grids expose all 26 paired letter identities',()=>{
 const levels=dataset('memory-case-association/dataset.js');assert.equal(levels.length,4);assert.deepEqual(levels.map(l=>l.columns*l.rows/2),[3,4,5,6]);
 const letters=new Set();for(const level of levels)for(const [i,pair] of level.images.entries()){
  const a=pair[0].match(/lower([A-Z])\.svg$/),b=pair[1].match(/upper([A-Z])\.svg$/);assert.ok(a&&b);assert.equal(a[1],b[1]);letters.add(a[1]);
  for(const image of pair)assert.ok(existsSync(new URL(image.replace('qrc:/gcompris/',''),root)));
  assert.equal(level.sounds[i][0],level.sounds[i][1]);assert.ok(level.sounds[i][0].endsWith('/'+('U'+a[1].toLowerCase().codePointAt(0).toString(16).toUpperCase().padStart(4,'0'))+'.ogg'));
 }
 assert.equal(letters.size,26);
});
