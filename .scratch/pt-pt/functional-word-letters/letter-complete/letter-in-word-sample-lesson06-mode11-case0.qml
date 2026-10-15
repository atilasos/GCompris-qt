// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteLetterInWordLessonPT"
    when:activity.visible
    property var expectedWords:{"apple.ogg": "maçã", "apricot.ogg": "alperce", "coconut.ogg": "coco", "fruit.ogg": "fruta", "kiwi.ogg": "kiwi", "lemon.ogg": "limão", "melon.ogg": "melão", "orange.ogg": "laranja", "peach.ogg": "pêssego", "pear.ogg": "pera", "plum.ogg": "ameixa", "raspberry.ogg": "framboesa", "strawberry.ogg": "morango"}
    property var incidence:{"m": ["apple.ogg", "lemon.ogg", "melon.ogg", "plum.ogg", "raspberry.ogg", "strawberry.ogg"], "r": ["apricot.ogg", "fruit.ogg", "orange.ogg", "pear.ogg", "raspberry.ogg", "strawberry.ogg"], "u": ["fruit.ogg"], "w": ["kiwi.ogg"], "x": ["plum.ogg"], "t": ["fruit.ogg"], "i": ["kiwi.ogg", "lemon.ogg", "plum.ogg"], "ç": ["apple.ogg"], "l": ["apricot.ogg", "lemon.ogg", "melon.ogg", "orange.ogg"], "j": ["orange.ogg"], "a": ["apple.ogg", "apricot.ogg", "fruit.ogg", "orange.ogg", "pear.ogg", "plum.ogg", "raspberry.ogg", "strawberry.ogg"], "p": ["apricot.ogg", "peach.ogg", "pear.ogg"], "k": ["kiwi.ogg"], "n": ["orange.ogg", "strawberry.ogg"], "g": ["peach.ogg", "strawberry.ogg"], "s": ["peach.ogg", "raspberry.ogg"], "o": ["coconut.ogg", "lemon.ogg", "melon.ogg", "peach.ogg", "raspberry.ogg", "strawberry.ogg"], "c": ["apricot.ogg", "coconut.ogg"], "f": ["fruit.ogg", "raspberry.ogg"], "e": ["apricot.ogg", "melon.ogg", "peach.ogg", "pear.ogg", "plum.ogg", "raspberry.ogg"], "b": ["raspberry.ogg"], "ã": ["apple.ogg", "lemon.ogg", "melon.ogg"], "ê": ["peach.ogg"]}
    property var counts:{"apple.ogg": {"m": 1, "a": 1, "ç": 1, "ã": 1}, "apricot.ogg": {"a": 1, "l": 1, "p": 1, "e": 2, "r": 1, "c": 1}, "coconut.ogg": {"c": 2, "o": 2}, "fruit.ogg": {"f": 1, "r": 1, "u": 1, "t": 1, "a": 1}, "kiwi.ogg": {"k": 1, "i": 2, "w": 1}, "lemon.ogg": {"l": 1, "i": 1, "m": 1, "ã": 1, "o": 1}, "melon.ogg": {"m": 1, "e": 1, "l": 1, "ã": 1, "o": 1}, "orange.ogg": {"l": 1, "a": 3, "r": 1, "n": 1, "j": 1}, "peach.ogg": {"p": 1, "ê": 1, "s": 2, "e": 1, "g": 1, "o": 1}, "pear.ogg": {"p": 1, "e": 1, "r": 1, "a": 1}, "plum.ogg": {"a": 2, "m": 1, "e": 1, "i": 1, "x": 1}, "raspberry.ogg": {"f": 1, "r": 1, "a": 2, "m": 1, "b": 1, "o": 1, "e": 1, "s": 1}, "strawberry.ogg": {"m": 1, "o": 2, "r": 1, "a": 1, "n": 1, "g": 1}}
    property int lessonIndex:5
    property int configuredMode:11
    property int configuredCase:0
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
