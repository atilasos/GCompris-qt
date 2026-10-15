// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteLetterInWordLessonPT"
    when:activity.visible
    property var expectedWords:{"apple.ogg": "maçã", "apricot.ogg": "alperce", "blackberry.ogg": "amora", "blueberry.ogg": "mirtilo", "cacao.ogg": "cacau", "cherry.ogg": "cereja", "coconut.ogg": "coco", "date_fruit.ogg": "tâmara", "fig.ogg": "figo", "fruit.ogg": "fruta", "grape.ogg": "uva", "grapefruit.ogg": "toranja", "kernel.ogg": "caroço", "kiwi.ogg": "kiwi", "lemon.ogg": "limão", "lime.ogg": "lima", "mango.ogg": "manga", "melon.ogg": "melão", "orange.ogg": "laranja", "papaya.ogg": "papaia", "peach.ogg": "pêssego", "pear.ogg": "pera", "plum.ogg": "ameixa", "raspberry.ogg": "framboesa", "strawberry.ogg": "morango"}
    property var incidence:{"m": ["apple.ogg", "blackberry.ogg", "blueberry.ogg", "date_fruit.ogg", "lemon.ogg", "lime.ogg", "mango.ogg", "melon.ogg", "plum.ogg", "raspberry.ogg", "strawberry.ogg"], "r": ["apricot.ogg", "blackberry.ogg", "blueberry.ogg", "cherry.ogg", "date_fruit.ogg", "fruit.ogg", "grapefruit.ogg", "kernel.ogg", "orange.ogg", "pear.ogg", "raspberry.ogg", "strawberry.ogg"], "u": ["cacao.ogg", "fruit.ogg", "grape.ogg"], "w": ["kiwi.ogg"], "x": ["plum.ogg"], "t": ["blueberry.ogg", "date_fruit.ogg", "fruit.ogg", "grapefruit.ogg"], "i": ["blueberry.ogg", "fig.ogg", "kiwi.ogg", "lemon.ogg", "lime.ogg", "papaya.ogg", "plum.ogg"], "â": ["date_fruit.ogg"], "ç": ["apple.ogg", "kernel.ogg"], "j": ["cherry.ogg", "grapefruit.ogg", "orange.ogg"], "l": ["apricot.ogg", "blueberry.ogg", "lemon.ogg", "lime.ogg", "melon.ogg", "orange.ogg"], "a": ["apple.ogg", "apricot.ogg", "blackberry.ogg", "cacao.ogg", "cherry.ogg", "date_fruit.ogg", "fruit.ogg", "grape.ogg", "grapefruit.ogg", "kernel.ogg", "lime.ogg", "mango.ogg", "orange.ogg", "papaya.ogg", "pear.ogg", "plum.ogg", "raspberry.ogg", "strawberry.ogg"], "p": ["apricot.ogg", "papaya.ogg", "peach.ogg", "pear.ogg"], "k": ["kiwi.ogg"], "n": ["grapefruit.ogg", "mango.ogg", "orange.ogg", "strawberry.ogg"], "g": ["fig.ogg", "mango.ogg", "peach.ogg", "strawberry.ogg"], "s": ["peach.ogg", "raspberry.ogg"], "o": ["blackberry.ogg", "blueberry.ogg", "coconut.ogg", "fig.ogg", "grapefruit.ogg", "kernel.ogg", "lemon.ogg", "melon.ogg", "peach.ogg", "raspberry.ogg", "strawberry.ogg"], "c": ["apricot.ogg", "cacao.ogg", "cherry.ogg", "coconut.ogg", "kernel.ogg"], "f": ["fig.ogg", "fruit.ogg", "raspberry.ogg"], "e": ["apricot.ogg", "cherry.ogg", "melon.ogg", "peach.ogg", "pear.ogg", "plum.ogg", "raspberry.ogg"], "b": ["raspberry.ogg"], "v": ["grape.ogg"], "ã": ["apple.ogg", "lemon.ogg", "melon.ogg"], "ê": ["peach.ogg"]}
    property var counts:{"apple.ogg": {"m": 1, "a": 1, "ç": 1, "ã": 1}, "apricot.ogg": {"a": 1, "l": 1, "p": 1, "e": 2, "r": 1, "c": 1}, "blackberry.ogg": {"a": 2, "m": 1, "o": 1, "r": 1}, "blueberry.ogg": {"m": 1, "i": 2, "r": 1, "t": 1, "l": 1, "o": 1}, "cacao.ogg": {"c": 2, "a": 2, "u": 1}, "cherry.ogg": {"c": 1, "e": 2, "r": 1, "j": 1, "a": 1}, "coconut.ogg": {"c": 2, "o": 2}, "date_fruit.ogg": {"t": 1, "â": 1, "m": 1, "a": 2, "r": 1}, "fig.ogg": {"f": 1, "i": 1, "g": 1, "o": 1}, "fruit.ogg": {"f": 1, "r": 1, "u": 1, "t": 1, "a": 1}, "grape.ogg": {"u": 1, "v": 1, "a": 1}, "grapefruit.ogg": {"t": 1, "o": 1, "r": 1, "a": 2, "n": 1, "j": 1}, "kernel.ogg": {"c": 1, "a": 1, "r": 1, "o": 2, "ç": 1}, "kiwi.ogg": {"k": 1, "i": 2, "w": 1}, "lemon.ogg": {"l": 1, "i": 1, "m": 1, "ã": 1, "o": 1}, "lime.ogg": {"l": 1, "i": 1, "m": 1, "a": 1}, "mango.ogg": {"m": 1, "a": 2, "n": 1, "g": 1}, "melon.ogg": {"m": 1, "e": 1, "l": 1, "ã": 1, "o": 1}, "orange.ogg": {"l": 1, "a": 3, "r": 1, "n": 1, "j": 1}, "papaya.ogg": {"p": 2, "a": 3, "i": 1}, "peach.ogg": {"p": 1, "ê": 1, "s": 2, "e": 1, "g": 1, "o": 1}, "pear.ogg": {"p": 1, "e": 1, "r": 1, "a": 1}, "plum.ogg": {"a": 2, "m": 1, "e": 1, "i": 1, "x": 1}, "raspberry.ogg": {"f": 1, "r": 1, "a": 2, "m": 1, "b": 1, "o": 1, "e": 1, "s": 1}, "strawberry.ogg": {"m": 1, "o": 2, "r": 1, "a": 1, "n": 1, "g": 1}}
    property int lessonIndex:13
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
