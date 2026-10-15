// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteLetterInWordLessonPT"
    when:activity.visible
    property var expectedWords:{"U0030.ogg": "zero", "U0031.ogg": "um", "U0032.ogg": "dois", "U0033.ogg": "três", "U0034.ogg": "quatro", "U0035.ogg": "cinco", "U0036.ogg": "seis", "U0037.ogg": "sete", "U0038.ogg": "oito", "U0039.ogg": "nove", "10.ogg": "dez", "11.ogg": "onze", "12.ogg": "doze", "16.ogg": "dezasseis"}
    property var incidence:{"m": ["U0031.ogg"], "r": ["U0030.ogg", "U0033.ogg", "U0034.ogg"], "u": ["U0031.ogg", "U0034.ogg"], "q": ["U0034.ogg"], "t": ["U0033.ogg", "U0034.ogg", "U0037.ogg", "U0038.ogg"], "d": ["U0032.ogg", "10.ogg", "12.ogg", "16.ogg"], "i": ["U0032.ogg", "U0035.ogg", "U0036.ogg", "U0038.ogg", "16.ogg"], "a": ["U0034.ogg", "16.ogg"], "n": ["U0035.ogg", "U0039.ogg", "11.ogg"], "z": ["U0030.ogg", "10.ogg", "11.ogg", "12.ogg", "16.ogg"], "s": ["U0032.ogg", "U0033.ogg", "U0036.ogg", "U0037.ogg", "16.ogg"], "o": ["U0030.ogg", "U0032.ogg", "U0034.ogg", "U0035.ogg", "U0038.ogg", "U0039.ogg", "11.ogg", "12.ogg"], "c": ["U0035.ogg"], "e": ["U0030.ogg", "U0036.ogg", "U0037.ogg", "U0039.ogg", "10.ogg", "11.ogg", "12.ogg", "16.ogg"], "v": ["U0039.ogg"], "ê": ["U0033.ogg"]}
    property var counts:{"U0030.ogg": {"z": 1, "e": 1, "r": 1, "o": 1}, "U0031.ogg": {"u": 1, "m": 1}, "U0032.ogg": {"d": 1, "o": 1, "i": 1, "s": 1}, "U0033.ogg": {"t": 1, "r": 1, "ê": 1, "s": 1}, "U0034.ogg": {"q": 1, "u": 1, "a": 1, "t": 1, "r": 1, "o": 1}, "U0035.ogg": {"c": 2, "i": 1, "n": 1, "o": 1}, "U0036.ogg": {"s": 2, "e": 1, "i": 1}, "U0037.ogg": {"s": 1, "e": 2, "t": 1}, "U0038.ogg": {"o": 2, "i": 1, "t": 1}, "U0039.ogg": {"n": 1, "o": 1, "v": 1, "e": 1}, "10.ogg": {"d": 1, "e": 1, "z": 1}, "11.ogg": {"o": 1, "n": 1, "z": 1, "e": 1}, "12.ogg": {"d": 1, "o": 1, "z": 1, "e": 1}, "16.ogg": {"d": 1, "e": 2, "z": 1, "a": 1, "s": 3, "i": 1}}
    property int lessonIndex:1
    property int configuredMode:5
    property int configuredCase:1
    property bool externalWords:false
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
