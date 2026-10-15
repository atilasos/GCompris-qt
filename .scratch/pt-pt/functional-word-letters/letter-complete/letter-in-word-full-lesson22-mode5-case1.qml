// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteLetterInWordLessonPT"
    when:activity.visible
    property var expectedWords:{"ax.ogg": "machado", "bolt.ogg": "porca", "brick.ogg": "tijolo", "brush.ogg": "trincha", "flash.ogg": "lanterna", "hammer.ogg": "martelo", "mower.ogg": "corta-relva", "needle.ogg": "agulha", "pliers.ogg": "alicate", "rake.ogg": "ancinho", "scissors.ogg": "tesoura", "screw.ogg": "parafuso", "screwdriver.ogg": "chave de fendas", "shovel.ogg": "pá", "spade.ogg": "pá", "spear.ogg": "lança", "tape_measure.ogg": "fita métrica", "tool.ogg": "ferramenta", "wedge.ogg": "cunha", "wrench.ogg": "chave inglesa"}
    property var incidence:{"m": ["ax.ogg", "hammer.ogg", "tape_measure.ogg", "tool.ogg"], "r": ["bolt.ogg", "brush.ogg", "flash.ogg", "hammer.ogg", "mower.ogg", "scissors.ogg", "screw.ogg", "tape_measure.ogg", "tool.ogg"], "u": ["needle.ogg", "scissors.ogg", "screw.ogg", "wedge.ogg"], "-": ["mower.ogg"], "á": ["shovel.ogg", "spade.ogg"], "t": ["brick.ogg", "brush.ogg", "flash.ogg", "hammer.ogg", "mower.ogg", "pliers.ogg", "scissors.ogg", "tape_measure.ogg", "tool.ogg"], "d": ["ax.ogg", "screwdriver.ogg"], "i": ["brick.ogg", "brush.ogg", "pliers.ogg", "rake.ogg", "tape_measure.ogg", "wrench.ogg"], "ç": ["spear.ogg"], "l": ["brick.ogg", "flash.ogg", "hammer.ogg", "mower.ogg", "needle.ogg", "pliers.ogg", "spear.ogg", "wrench.ogg"], "j": ["brick.ogg"], "a": ["ax.ogg", "bolt.ogg", "brush.ogg", "flash.ogg", "hammer.ogg", "mower.ogg", "needle.ogg", "pliers.ogg", "rake.ogg", "scissors.ogg", "screw.ogg", "screwdriver.ogg", "spear.ogg", "tape_measure.ogg", "tool.ogg", "wedge.ogg", "wrench.ogg"], "p": ["bolt.ogg", "screw.ogg", "shovel.ogg", "spade.ogg"], "h": ["ax.ogg", "brush.ogg", "needle.ogg", "rake.ogg", "screwdriver.ogg", "wedge.ogg", "wrench.ogg"], "n": ["brush.ogg", "flash.ogg", "rake.ogg", "screwdriver.ogg", "spear.ogg", "tool.ogg", "wedge.ogg", "wrench.ogg"], "g": ["needle.ogg", "wrench.ogg"], "é": ["tape_measure.ogg"], "s": ["scissors.ogg", "screw.ogg", "screwdriver.ogg", "wrench.ogg"], "o": ["ax.ogg", "bolt.ogg", "brick.ogg", "hammer.ogg", "mower.ogg", "rake.ogg", "scissors.ogg", "screw.ogg"], "c": ["ax.ogg", "bolt.ogg", "brush.ogg", "mower.ogg", "pliers.ogg", "rake.ogg", "screwdriver.ogg", "tape_measure.ogg", "wedge.ogg", "wrench.ogg"], "f": ["screw.ogg", "screwdriver.ogg", "tape_measure.ogg", "tool.ogg"], "e": ["flash.ogg", "hammer.ogg", "mower.ogg", "pliers.ogg", "scissors.ogg", "screwdriver.ogg", "tool.ogg", "wrench.ogg"], "v": ["mower.ogg", "screwdriver.ogg", "wrench.ogg"]}
    property var counts:{"ax.ogg": {"m": 1, "a": 2, "c": 1, "h": 1, "d": 1, "o": 1}, "bolt.ogg": {"p": 1, "o": 1, "r": 1, "c": 1, "a": 1}, "brick.ogg": {"t": 1, "i": 1, "j": 1, "o": 2, "l": 1}, "brush.ogg": {"t": 1, "r": 1, "i": 1, "n": 1, "c": 1, "h": 1, "a": 1}, "flash.ogg": {"l": 1, "a": 2, "n": 2, "t": 1, "e": 1, "r": 1}, "hammer.ogg": {"m": 1, "a": 1, "r": 1, "t": 1, "e": 1, "l": 1, "o": 1}, "mower.ogg": {"c": 1, "o": 1, "r": 2, "t": 1, "a": 2, "-": 1, "e": 1, "l": 1, "v": 1}, "needle.ogg": {"a": 2, "g": 1, "u": 1, "l": 1, "h": 1}, "pliers.ogg": {"a": 2, "l": 1, "i": 1, "c": 1, "t": 1, "e": 1}, "rake.ogg": {"a": 1, "n": 2, "c": 1, "i": 1, "h": 1, "o": 1}, "scissors.ogg": {"t": 1, "e": 1, "s": 1, "o": 1, "u": 1, "r": 1, "a": 1}, "screw.ogg": {"p": 1, "a": 2, "r": 1, "f": 1, "u": 1, "s": 1, "o": 1}, "screwdriver.ogg": {"c": 1, "h": 1, "a": 2, "v": 1, "e": 3, "d": 2, "f": 1, "n": 1, "s": 1}, "shovel.ogg": {"p": 1, "á": 1}, "spade.ogg": {"p": 1, "á": 1}, "spear.ogg": {"l": 1, "a": 2, "n": 1, "ç": 1}, "tape_measure.ogg": {"f": 1, "i": 2, "t": 2, "a": 2, "m": 1, "é": 1, "r": 1, "c": 1}, "tool.ogg": {"f": 1, "e": 2, "r": 2, "a": 2, "m": 1, "n": 1, "t": 1}, "wedge.ogg": {"c": 1, "u": 1, "n": 1, "h": 1, "a": 1}, "wrench.ogg": {"c": 1, "h": 1, "a": 2, "v": 1, "e": 2, "i": 1, "n": 1, "g": 1, "l": 1, "s": 1}}
    property int lessonIndex:21
    property int configuredMode:5
    property int configuredCase:1
    property bool externalWords:true
    property var completed:[]
    property int expectedQuestions:0
    property int physicalSelections:0
    property int mouseSelections:0
    Component.onCompleted: {
        // Configure before the normal first start, retaining the CLI lesson.
        items.currentMode=configuredMode;
        items.currentLetterCase=configuredCase;
    }
    function checked(actual,expected,message) {
        if(actual!==expected)console.log("WORD_FAILURE",JSON.stringify({actual:actual,expected:expected,message:message}));
        compare(actual,expected,message||"");
    }
    function keyFor(index) {
        var source=wordsModel.get(index).imgurl;
        return source.slice(source.lastIndexOf('/')+1).replace('.webp','.ogg');
    }
    function navigate(index) {
        activityBackground.forceActiveFocus();
        if(wordsView.currentIndex<0)keyClick(Qt.Key_Right);
        var columns=Math.max(1,Math.floor(wordsView.width/wordsView.cellWidth));
        for(var step=0;step<wordsModel.count*3 && wordsView.currentIndex!==index;step++) {
            var current=wordsView.currentIndex;
            var row=Math.floor(current/columns),targetRow=Math.floor(index/columns);
            keyClick(row<targetRow?Qt.Key_Down:row>targetRow?Qt.Key_Up:current<index?Qt.Key_Right:Qt.Key_Left);
            verify(wordsView.currentIndex!==current,"Arrow moves selection");
        }
        checked(wordsView.currentIndex,index,"Keyboard navigation reaches real card");
    }
    function choose(index,keyboardInput) {
        var before=wordsModel.get(index).selected;
        if(keyboardInput) {
            navigate(index);keyClick(Qt.Key_Space);
            physicalSelections++;
        } else {
            var card=wordsView.itemAtIndex(index);verify(card!==null);
            mouseClick(card,card.width/2,card.height/2,Qt.LeftButton,Qt.NoModifier,50);
            mouseSelections++;
        }
        checked(wordsModel.get(index).selected,!before,"One event toggles one card");
    }
    function test_complete_all_generated_questions() {
        wait(1800);
        wait(300);
        checked(items.currentLevel,lessonIndex);
        checked(ApplicationSettings.useExternalWordset(),externalWords);
        checked(activityBackground.englishFallback,false);
        checked(wordsModel.count,Math.min(configuredMode,Object.keys(expectedWords).length));
        var frequencies={},keys=[];
        for(var index=0;index<wordsModel.count;index++) {
            var key=keyFor(index);keys.push(key);
            checked(wordsModel.get(index).spelling,expectedWords[key]);
            for(var character in counts[key])frequencies[character]=(frequencies[character]||0)+counts[key][character];
        }
        var values=[];
        for(var letter in frequencies)values.push(frequencies[letter]);
        values.sort(function(a,b){return b-a;});
        expectedQuestions=Math.min(10,values.length);
        checked(score.numberOfSubLevels,expectedQuestions);
        var seen={};
        for(var questionIndex=0;questionIndex<expectedQuestions;questionIndex++) {
            tryCompare(items,"buttonsBlocked",false,5000);
            checked(score.currentSubLevel,questionIndex);
            var question=questionItem.text;
            verify(!seen[question]);seen[question]=true;
            verify(frequencies[question]>=values[expectedQuestions-1],"Question belongs to the ten most frequent characters, ties allowed");
            if(configuredCase===0)verify(questionItem.font.capitalization===Font.AllUppercase || questionItem.font.capitalization===Font.AllLowercase);
            else checked(questionItem.font.capitalization,configuredCase);
            for(var i=0;i<wordsModel.count;i++)checked(wordsModel.get(i).selected,false);
            if(questionIndex===0) {
                activityBackground.forceActiveFocus();keyClick(Qt.Key_Return);
                checked(score.currentSubLevel,0,"Empty answer is rejected");
                verify(items.buttonsBlocked);
                tryCompare(items,"buttonsBlocked",false,3000);
            }
            var selected=[];
            for(var cardIndex=0;cardIndex<wordsModel.count;cardIndex++) {
                var expected=incidence[question].indexOf(keys[cardIndex])!==-1;
                if(expected) {choose(cardIndex,questionIndex%2===0);selected.push(keys[cardIndex]);}
                checked(wordsModel.get(cardIndex).selected,expected);
            }
            verify(selected.length>0);
            if(questionIndex%2===0){activityBackground.forceActiveFocus();keyClick(Qt.Key_Return);}
            else mouseClick(ok);
            checked(score.currentSubLevel,questionIndex+1);
            completed.push({question:question,capitalization:questionItem.font.capitalization,selected:selected,cards:keys});
            console.log("LETTER_COMPLETED",JSON.stringify(completed[completed.length-1]));
            if(questionIndex===0)grabImage(pageView).save("__QA_OUTPUT__/first-question.png");
            if(questionIndex===expectedQuestions-1) {
                tryCompare(items,"currentLevel",(lessonIndex+1)%items.numberOfLevel,6500);
                checked(score.currentSubLevel,0);
            } else {
                tryCompare(score,"isWinAnimationPlaying",false,3500);
                tryCompare(items,"buttonsBlocked",false,2000);
            }
            wait(60);
        }
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,expectedQuestions:expectedQuestions,lesson:lessonIndex,externalWords:externalWords,mode:configuredMode,letterCase:configuredCase,physicalSelections:physicalSelections,mouseSelections:mouseSelections,completed:completed}));}
}
