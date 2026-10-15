// SPDX-License-Identifier: GPL-3.0-or-later
import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync,existsSync} from 'node:fs';
import vm from 'node:vm';
const root=new URL('../../',import.meta.url);
const read=path=>readFileSync(new URL(path,root),'utf8');
function dataset(activity) {
    const context=vm.createContext({qsTr:value=>value,
        GCompris:{ApplicationInfo:{getAudioFilePath:value=>value}},
        Core:{getSoundFilenamForChar:char=>'U'+char.codePointAt(0).toString(16).toUpperCase().padStart(4,'0')+'.$CA'}});
    vm.runInContext(read(`src/activities/${activity}/dataset.js`).replace(/^\.import.*$/gm,''),context);
    return JSON.parse(JSON.stringify(vm.runInContext('({levels:get(),texts:typeof texts==="undefined"?null:texts,images:typeof images==="undefined"?null:images,sounds})',context)));
}
function validLevels(levels) {
    for(const level of levels) {
        const count=level.rows*level.columns;
        assert.ok(count>0 && count%2===0);
        for(const name of ['texts','images','sounds','repeaterModels'])
            if(level[name]) {
                assert.ok(level[name].length>=count/2);
                for(const pair of level[name])assert.equal(pair.length,2);
            }
    }
}
test('all number-word data retain the 21 meanings and five playable grids',()=>{
    const data=dataset('memory-wordnumber');
    const english=['zero','one','two','three','four','five','six','seven','eight','nine','ten','eleven','twelve','thirteen','fourteen','fifteen','sixteen','seventeen','eighteen','nineteen','twenty'];
    assert.deepEqual(data.texts,english.map((word,number)=>[word,number]));
    assert.equal(data.sounds.length,21);assert.equal(data.levels.length,5);validLevels(data.levels);
    for(let n=0;n<21;n++)assert.ok(data.sounds[n][1].endsWith(`/alphabet/${n<10?'U003'+n:n}.$CA`));
    let occurrences=0;
    for(const level of data.levels) {
        assert.equal(new Set(level.texts.map(pair=>pair[1])).size,level.texts.length);
        for(const [index,pair] of level.texts.entries()) {
            assert.deepEqual(pair,data.texts[pair[1]]);
            assert.deepEqual(level.sounds[index],data.sounds[pair[1]]);
            occurrences++;
        }
    }
    assert.equal(occurrences,55);
});
test('all 26 case pairs have corresponding original lower/upper glyphs and sounds',()=>{
    const data=dataset('memory-case-association');assert.equal(data.levels.length,4);validLevels(data.levels);
    assert.equal(data.images.length,26);assert.equal(data.sounds.length,26);
    for(let i=0;i<26;i++) {
        const char=String.fromCharCode(65+i);
        for(const [index,prefix] of ['lower','upper'].entries()) {
            const file=data.images[i][index];assert.ok(file.endsWith(`/${prefix}${char}.svg`));
            assert.ok(existsSync(new URL(file.replace('qrc:/gcompris/',''),root)));
        }
        assert.equal(data.sounds[i][0],data.sounds[i][1]);
        assert.ok(data.sounds[i][0].endsWith('U'+char.codePointAt(0).toString(16).toUpperCase().padStart(4,'0')+'.$CA'));
    }
    let occurrences=0;
    for(const level of data.levels) {
        assert.equal(new Set(level.images.map(pair=>pair[0])).size,level.images.length);
        for(const [index,pair] of level.images.entries()) {
            const original=data.images.findIndex(candidate=>candidate[0]===pair[0]);
            assert.ok(original>=0);assert.deepEqual(pair,data.images[original]);
            assert.deepEqual(level.sounds[index],data.sounds[original]);occurrences++;
        }
    }
    assert.equal(occurrences,36);
});
function arrayAfter(source,marker) {
    const begin=source.indexOf('[',source.indexOf(marker));let depth=0,quote=null;
    for(let i=begin;i<source.length;i++) {
        const c=source[i];
        if(quote){if(c==='\\')i++;else if(c===quote)quote=null;continue;}
        if(c==='"'||c==="'"){quote=c;continue;}
        if(c==='[')depth++;
        if(c===']'&&!--depth)return source.slice(begin,i+1);
    }
    throw new Error('Unclosed '+marker);
}
test('all enumeration datasets count visible butterflies, including zero',()=>{
    let entries=0;
    for(let number=1;number<=8;number++) {
        const source=read(`src/activities/memory-enumerate/resource/${number}/Data.qml`);
        const imageUrl=source.match(/readonly property string imageUrl:\s*"([^"]+)"/)[1];
        assert.ok(existsSync(new URL(imageUrl.replace('qrc:/gcompris/',''),root)));
        const context=vm.createContext({imageUrl});
        for(const property of ['texts','repeaterModels','sounds','data'])
            vm.runInContext(`var ${property}=${arrayAfter(source,property+':')}`,context);
        const data=JSON.parse(JSON.stringify(vm.runInContext('({texts,repeaterModels,sounds,data})',context)));
        validLevels(data.data);
        assert.equal(data.texts.length,data.repeaterModels.length);
        assert.equal(data.texts.length,data.sounds.length);
        assert.equal(new Set(data.texts.map(pair=>pair[1])).size,data.texts.length);
        for(let i=0;i<data.texts.length;i++) {
            const value=data.texts[i][1];
            assert.equal(data.repeaterModels[i][0].filter(item=>item.itemSize>0).length,value);
            for(const item of data.repeaterModels[i][0]) {
                assert.ok(item.itemX>=0 && item.itemX<=1 && item.itemY>=0 && item.itemY<=1);
                assert.ok(item.itemSize>=0 && item.itemSize<=1);
            }
            assert.ok(data.sounds[i][1].endsWith(`/alphabet/U003${value}.$CA`));
            entries++;
        }
    }
    assert.equal(entries,49);
});
