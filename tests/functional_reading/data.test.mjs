// SPDX-License-Identifier: GPL-3.0-or-later
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import vm from 'node:vm';
const root = new URL('../../', import.meta.url);
const read = file => readFileSync(new URL(file, root), 'utf8');
const data = JSON.parse(read('src/activities/wordsgame/resource/default-pt.json'));
function game(random) {
    const context = vm.createContext({console: {log() {}}, GCompris: {ApplicationInfo: {
        getVoicesLocale: () => 'pt', getLocaleFilePath: path => path
    }}, Math: Object.assign(Object.create(Math), {random})});
    vm.runInContext(read('src/core/core.js').replace(/^\.(?:pragma|import).*$/gm, ''), context);
    context.Core = {shuffle: context.shuffle, getInitialLevel: () => 0,
        getNextLevel: (level, max) => (level+1)%max, getPreviousLevel: (level,max) => (level+max-1)%max};
    const functions = [...read('src/core/Wordlist.qml').matchAll(/^    function [\s\S]*?^    }/gm)].map(m => m[0]).join('\n');
    const list = vm.createContext({Core:context.Core, console:{log(){}}, error(message){throw Error(message)},
        parser:{parseFromUrl(path){assert.ok(path.endsWith('default-pt.json')); return structuredClone(data)}},
        wordList:{},maxLevel:0,useDefault:false});
    vm.runInContext(functions,list);
    vm.runInContext(read('src/activities/readingh/readingh.js').replace(/^\.(?:pragma|import).*$/gm,''),context);
    const items = {locale:'pt_PT',wordlist:list,score:{},wordDropTimer:{running:false,start(){this.running=true},stop(){this.running=false}},
        answerButtonsFlow:{},iAmReady:{},wordDisplayRepeater:{},answerButtonFound:{},bonus:{good(){}}};
    context.start(items);
    return {context,items};
}
test('all PT reading levels produce complete 15-word lists for present and absent targets',()=>{
    assert.deepEqual(data.levels.map(level=>level.words.length),[27,39,81]);
    for(const probability of [0,0.99999]) {
        const {context:g,items}=game(()=>probability);
        for(let level=0;level<3;level++) {
            assert.equal(items.numberOfLevel,3, "All three levels must be exposed to the activity-sequence scheduler");
            assert.equal(items.currentLevel,level);
            assert.equal(items.score.numberOfSubLevels,10);
            const source = data.levels[level].words;
            for(const word of source) {
                assert.equal(word,word.normalize('NFC'));
                assert.match(word,/^[\p{L}]+$/u);
            }
            for(let round=0;round<source.length;round++) {
                assert.ok(source.includes(items.textToFind));
                assert.equal(g.words.length,15,`level${level+1} probability${probability} round${round}`);
                assert.ok(g.words.every(word=>source.includes(word)));
                assert.equal(g.words.includes(items.textToFind),probability>0.5);
                assert.equal(items.answerButtonFound.isCorrectAnswer,probability>0.5);
                g.run();assert.equal(items.wordDropTimer.running,true);
                for(let index=0;index<g.words.length;index++) {
                    g.dropWord();assert.equal(items.currentIndex,index);assert.equal(items.answerButtonsFlow.visible,false);
                }
                g.dropWord();assert.equal(items.wordDropTimer.running,false);assert.equal(items.answerButtonsFlow.visible,true);
                if(round+1<source.length)g.initSubLevel();
            }
            g.nextLevel();
        }
        assert.equal(items.currentLevel,0);
        g.previousLevel();assert.equal(items.currentLevel,2);
        g.stop();assert.equal(items.wordDropTimer.running,false);
    }
});

test('Portuguese reading and typing vocabulary spells the music noun with its accent',()=>{
    const words=data.levels.flatMap(level=>level.words);
    assert.ok(words.includes('música'));
    assert.ok(!words.includes('musica'));
});
