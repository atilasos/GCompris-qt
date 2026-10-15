// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "NativePortugueseFallingWords"
    when: items.numberOfLevel > 0 && activity.visible
    property var unicodeInput: null
    property int correctWords: 0
    property int wrongInputs: 0
    property int characters: 0
    property var completed: []
    property var special: ({mixed:{}, uppercase:{}})
    property var selectedWords: []
    function input(text) {
        textinput.forceActiveFocus();
        if(text.charCodeAt(0)>127) {
            if(unicodeInput===null)
                unicodeInput=Qt.createQmlObject('import "file:__QA_SOURCE__/build/functional-input"; UnicodeInput {}',this);
            var before=items.score.currentSubLevel;
            verify(unicodeInput.preedit(textinput,text));
            compare(items.score.currentSubLevel,before,"IME preedit is not an answer");
            verify(unicodeInput.commit(textinput,text));
        } else keyClick(text,Qt.NoModifier,0);
        characters++;
    }
    function prepareAccentedWord(level) {
        // Reorder only the official unused deck so each run deterministically
        // exercises its existing special spelling; do not alter any answer.
        var wanted=[ ["peça"], ["dançar"], ["frigorífico","música"] ][level];
        var deck=items.wordlist.randomWordList.slice();
        for(var word of wanted) {
            var position=deck.indexOf(word);
            if(position>=0) { deck.splice(position,1);deck.push(word); }
        }
        items.wordlist.randomWordList=deck;
    }
    function runMode(uppercaseOnly) {
        activityBackground.stop();activity.uppercaseOnly=uppercaseOnly;
        activity.speedSetting=10;activityBackground.start();
        compare(activity.mode,"word");compare(items.wordlist.wordList.locale,"pt");
        compare(items.numberOfLevel,3);
        var mode=uppercaseOnly?"uppercase":"mixed";
        for(var level=0;level<3;level++) {
            compare(items.currentLevel,level);compare(items.score.currentSubLevel,0);
            compare(items.score.numberOfSubLevels,15);
            prepareAccentedWord(level);
            for(var question=0;question<15;question++) {
                tryVerify(function(){return Activity.droppedWords.length>0;},3000);
                var word=Activity.droppedWords[0];var target=word.text;
                verify(target.length>=2);verify(!word.wonState);
                input("#");wrongInputs++;
                compare(items.score.currentSubLevel,question);
                compare(word.unmatchedIndex,0);
                // A valid prefix earns no point. A subsequent typo resets it.
                input(uppercaseOnly?target[0].toLowerCase():target[0]);
                compare(word.unmatchedIndex,1);compare(items.score.currentSubLevel,question);
                input("#");wrongInputs++;
                compare(word.unmatchedIndex,0);compare(items.score.currentSubLevel,question);
                if(!uppercaseOnly) {
                    input(target[0].toUpperCase());wrongInputs++;
                    compare(word.unmatchedIndex,0);compare(items.score.currentSubLevel,question);
                }
                for(var i=0;i<target.length;i++) {
                    var character=target[i];var lower=character.toLowerCase();
                    if(lower==="ç" || lower==="í" || lower==="ú") {
                        var plain={"ç":"c","í":"i","ú":"u"}[lower];
                        input(uppercaseOnly || character===lower?plain:plain.toUpperCase());
                        wrongInputs++;
                        compare(items.score.currentSubLevel,question,"Missing accent/cedilla is not a word");
                        compare(word.unmatchedIndex,0,"Wrong spelling resets the word");
                        // Re-enter the valid prefix after the rejected letter.
                        for(var prefix=0;prefix<i;prefix++)
                            input(uppercaseOnly?target[prefix].toLowerCase():target[prefix]);
                        special[mode][lower]=true;
                        console.log("NATIVE_WORD_ACCENT",mode,target,i,lower);
                    }
                    input(uppercaseOnly?character.toLowerCase():character);
                    if(i+1<target.length) {
                        compare(items.score.currentSubLevel,question,"Incomplete word never scores");
                        compare(word.unmatchedIndex,i+1);
                    }
                }
                tryCompare(items.score,"currentSubLevel",question+1,1000);
                correctWords++;selectedWords.push({mode:mode,level:level+1,word:target});
                if(question===1)grabImage(activityBackground).save("__QA_OUTPUT__/"+mode+"-level-"+(level+1)+".png");
            }
            completed.push({mode:mode,level:level+1,correct:15});
            console.log("NATIVE_WORD_LEVEL",JSON.stringify(completed[completed.length-1]));
            tryCompare(items,"currentLevel",(level+1)%3,6000);
        }
        for(var accent of "çíú")verify(special[mode][accent]===true,mode+": "+accent);
    }
    function test_all_levels_and_case_modes() {wait(1600);runMode(false);runMode(true);compare(correctWords,90);}
    function cleanupTestCase(){console.log("NATIVE_WORDS_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,correctWords:correctWords,wrongInputs:wrongInputs,characters:characters,completed:completed,special:special,selectedWords:selectedWords}));}
}
