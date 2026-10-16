// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteLetterInWordLessonPT"
    when:activity.visible
    property var expectedWords:{"zero.ogg": "zero", "one.ogg": "um", "two.ogg": "dois", "three.ogg": "três", "four.ogg": "quatro", "five.ogg": "cinco", "six.ogg": "seis", "seven.ogg": "sete", "eight.ogg": "oito", "nine.ogg": "nove", "ten.ogg": "dez", "eleven.ogg": "onze", "twelve.ogg": "doze", "sixteen.ogg": "dezasseis"}
    property var incidence:{"a": ["four.ogg", "sixteen.ogg"], "c": ["five.ogg"], "d": ["two.ogg", "ten.ogg", "twelve.ogg", "sixteen.ogg"], "e": ["zero.ogg", "six.ogg", "seven.ogg", "nine.ogg", "ten.ogg", "eleven.ogg", "twelve.ogg", "sixteen.ogg"], "i": ["two.ogg", "five.ogg", "six.ogg", "eight.ogg", "sixteen.ogg"], "m": ["one.ogg"], "n": ["five.ogg", "nine.ogg", "eleven.ogg"], "o": ["zero.ogg", "two.ogg", "four.ogg", "five.ogg", "eight.ogg", "nine.ogg", "eleven.ogg", "twelve.ogg"], "q": ["four.ogg"], "r": ["zero.ogg", "three.ogg", "four.ogg"], "s": ["two.ogg", "three.ogg", "six.ogg", "seven.ogg", "sixteen.ogg"], "t": ["three.ogg", "four.ogg", "seven.ogg", "eight.ogg"], "u": ["one.ogg", "four.ogg"], "v": ["nine.ogg"], "z": ["zero.ogg", "ten.ogg", "eleven.ogg", "twelve.ogg", "sixteen.ogg"], "ê": ["three.ogg"]}
    property var counts:{"zero.ogg": {"z": 1, "e": 1, "r": 1, "o": 1}, "one.ogg": {"u": 1, "m": 1}, "two.ogg": {"d": 1, "o": 1, "i": 1, "s": 1}, "three.ogg": {"t": 1, "r": 1, "ê": 1, "s": 1}, "four.ogg": {"q": 1, "u": 1, "a": 1, "t": 1, "r": 1, "o": 1}, "five.ogg": {"c": 2, "i": 1, "n": 1, "o": 1}, "six.ogg": {"s": 2, "e": 1, "i": 1}, "seven.ogg": {"s": 1, "e": 2, "t": 1}, "eight.ogg": {"o": 2, "i": 1, "t": 1}, "nine.ogg": {"n": 1, "o": 1, "v": 1, "e": 1}, "ten.ogg": {"d": 1, "e": 1, "z": 1}, "eleven.ogg": {"o": 1, "n": 1, "z": 1, "e": 1}, "twelve.ogg": {"d": 1, "o": 1, "z": 1, "e": 1}, "sixteen.ogg": {"d": 1, "e": 2, "z": 1, "a": 1, "s": 3, "i": 1}}
    property int lessonIndex:4
    property int configuredMode:5
    property int configuredCase:0
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
