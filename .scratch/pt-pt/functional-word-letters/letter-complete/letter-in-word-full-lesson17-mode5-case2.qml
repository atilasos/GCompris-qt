// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteLetterInWordLessonPT"
    when:activity.visible
    property var expectedWords:{"artichoke.ogg": "alcachofra", "asparagus.ogg": "espargo", "avocado.ogg": "abacate", "bean.ogg": "feijão", "broccoli.ogg": "brócolo", "cabbage.ogg": "couve", "carrot.ogg": "cenoura", "cauliflower.ogg": "couve-flor", "celery.ogg": "aipo", "corn.ogg": "milho", "cucumber.ogg": "pepino", "eggplant.ogg": "beringela", "garlic.ogg": "alho", "leek.ogg": "alho-porro", "lettuce.ogg": "alface", "mushroom.ogg": "cogumelo", "nut.ogg": "noz", "olive.ogg": "azeitona", "onion.ogg": "cebola", "pea.ogg": "ervilha", "peppers.ogg": "pimentos", "pod.ogg": "vagem", "potato.ogg": "batata", "pumpkin.ogg": "abóbora", "radish.ogg": "rabanete", "spinach.ogg": "espinafre", "squash.ogg": "abóbora", "tomatoe.ogg": "tomate", "turnip.ogg": "nabo", "vegetable.ogg": "vegetal", "walnut.ogg": "noz", "wheat.ogg": "trigo"}
    property var incidence:{"m": ["corn.ogg", "mushroom.ogg", "peppers.ogg", "pod.ogg", "tomatoe.ogg"], "r": ["artichoke.ogg", "asparagus.ogg", "broccoli.ogg", "carrot.ogg", "cauliflower.ogg", "eggplant.ogg", "leek.ogg", "pea.ogg", "pumpkin.ogg", "radish.ogg", "spinach.ogg", "squash.ogg", "wheat.ogg"], "u": ["cabbage.ogg", "carrot.ogg", "cauliflower.ogg", "mushroom.ogg"], "-": ["cauliflower.ogg", "leek.ogg"], "t": ["avocado.ogg", "olive.ogg", "peppers.ogg", "potato.ogg", "radish.ogg", "tomatoe.ogg", "vegetable.ogg", "wheat.ogg"], "i": ["bean.ogg", "celery.ogg", "corn.ogg", "cucumber.ogg", "eggplant.ogg", "olive.ogg", "pea.ogg", "peppers.ogg", "spinach.ogg", "wheat.ogg"], "l": ["artichoke.ogg", "broccoli.ogg", "cauliflower.ogg", "corn.ogg", "eggplant.ogg", "garlic.ogg", "leek.ogg", "lettuce.ogg", "mushroom.ogg", "onion.ogg", "pea.ogg", "vegetable.ogg"], "j": ["bean.ogg"], "a": ["artichoke.ogg", "asparagus.ogg", "avocado.ogg", "carrot.ogg", "celery.ogg", "eggplant.ogg", "garlic.ogg", "leek.ogg", "lettuce.ogg", "olive.ogg", "onion.ogg", "pea.ogg", "pod.ogg", "potato.ogg", "pumpkin.ogg", "radish.ogg", "spinach.ogg", "squash.ogg", "tomatoe.ogg", "turnip.ogg", "vegetable.ogg"], "p": ["asparagus.ogg", "celery.ogg", "cucumber.ogg", "leek.ogg", "peppers.ogg", "spinach.ogg"], "h": ["artichoke.ogg", "corn.ogg", "garlic.ogg", "leek.ogg", "pea.ogg"], "n": ["carrot.ogg", "cucumber.ogg", "eggplant.ogg", "nut.ogg", "olive.ogg", "peppers.ogg", "radish.ogg", "spinach.ogg", "turnip.ogg", "walnut.ogg"], "g": ["asparagus.ogg", "eggplant.ogg", "mushroom.ogg", "pod.ogg", "vegetable.ogg", "wheat.ogg"], "z": ["nut.ogg", "olive.ogg", "walnut.ogg"], "s": ["asparagus.ogg", "peppers.ogg", "spinach.ogg"], "o": ["artichoke.ogg", "asparagus.ogg", "bean.ogg", "broccoli.ogg", "cabbage.ogg", "carrot.ogg", "cauliflower.ogg", "celery.ogg", "corn.ogg", "cucumber.ogg", "garlic.ogg", "leek.ogg", "mushroom.ogg", "nut.ogg", "olive.ogg", "onion.ogg", "peppers.ogg", "pumpkin.ogg", "squash.ogg", "tomatoe.ogg", "turnip.ogg", "walnut.ogg", "wheat.ogg"], "c": ["artichoke.ogg", "avocado.ogg", "broccoli.ogg", "cabbage.ogg", "carrot.ogg", "cauliflower.ogg", "lettuce.ogg", "mushroom.ogg", "onion.ogg"], "f": ["artichoke.ogg", "bean.ogg", "cauliflower.ogg", "lettuce.ogg", "spinach.ogg"], "e": ["asparagus.ogg", "avocado.ogg", "bean.ogg", "cabbage.ogg", "carrot.ogg", "cauliflower.ogg", "cucumber.ogg", "eggplant.ogg", "lettuce.ogg", "mushroom.ogg", "olive.ogg", "onion.ogg", "pea.ogg", "peppers.ogg", "pod.ogg", "radish.ogg", "spinach.ogg", "tomatoe.ogg", "vegetable.ogg"], "b": ["avocado.ogg", "broccoli.ogg", "eggplant.ogg", "onion.ogg", "potato.ogg", "pumpkin.ogg", "radish.ogg", "squash.ogg", "turnip.ogg"], "v": ["cabbage.ogg", "cauliflower.ogg", "pea.ogg", "pod.ogg", "vegetable.ogg"], "ã": ["bean.ogg"], "ó": ["broccoli.ogg", "pumpkin.ogg", "squash.ogg"]}
    property var counts:{"artichoke.ogg": {"a": 3, "l": 1, "c": 2, "h": 1, "o": 1, "f": 1, "r": 1}, "asparagus.ogg": {"e": 1, "s": 1, "p": 1, "a": 1, "r": 1, "g": 1, "o": 1}, "avocado.ogg": {"a": 3, "b": 1, "c": 1, "t": 1, "e": 1}, "bean.ogg": {"f": 1, "e": 1, "i": 1, "j": 1, "ã": 1, "o": 1}, "broccoli.ogg": {"b": 1, "r": 1, "ó": 1, "c": 1, "o": 2, "l": 1}, "cabbage.ogg": {"c": 1, "o": 1, "u": 1, "v": 1, "e": 1}, "carrot.ogg": {"c": 1, "e": 1, "n": 1, "o": 1, "u": 1, "r": 1, "a": 1}, "cauliflower.ogg": {"c": 1, "o": 2, "u": 1, "v": 1, "e": 1, "-": 1, "f": 1, "l": 1, "r": 1}, "celery.ogg": {"a": 1, "i": 1, "p": 1, "o": 1}, "corn.ogg": {"m": 1, "i": 1, "l": 1, "h": 1, "o": 1}, "cucumber.ogg": {"p": 2, "e": 1, "i": 1, "n": 1, "o": 1}, "eggplant.ogg": {"b": 1, "e": 2, "r": 1, "i": 1, "n": 1, "g": 1, "l": 1, "a": 1}, "garlic.ogg": {"a": 1, "l": 1, "h": 1, "o": 1}, "leek.ogg": {"a": 1, "l": 1, "h": 1, "o": 3, "-": 1, "p": 1, "r": 2}, "lettuce.ogg": {"a": 2, "l": 1, "f": 1, "c": 1, "e": 1}, "mushroom.ogg": {"c": 1, "o": 2, "g": 1, "u": 1, "m": 1, "e": 1, "l": 1}, "nut.ogg": {"n": 1, "o": 1, "z": 1}, "olive.ogg": {"a": 2, "z": 1, "e": 1, "i": 1, "t": 1, "o": 1, "n": 1}, "onion.ogg": {"c": 1, "e": 1, "b": 1, "o": 1, "l": 1, "a": 1}, "pea.ogg": {"e": 1, "r": 1, "v": 1, "i": 1, "l": 1, "h": 1, "a": 1}, "peppers.ogg": {"p": 1, "i": 1, "m": 1, "e": 1, "n": 1, "t": 1, "o": 1, "s": 1}, "pod.ogg": {"v": 1, "a": 1, "g": 1, "e": 1, "m": 1}, "potato.ogg": {"b": 1, "a": 3, "t": 2}, "pumpkin.ogg": {"a": 2, "b": 2, "ó": 1, "o": 1, "r": 1}, "radish.ogg": {"r": 1, "a": 2, "b": 1, "n": 1, "e": 2, "t": 1}, "spinach.ogg": {"e": 2, "s": 1, "p": 1, "i": 1, "n": 1, "a": 1, "f": 1, "r": 1}, "squash.ogg": {"a": 2, "b": 2, "ó": 1, "o": 1, "r": 1}, "tomatoe.ogg": {"t": 2, "o": 1, "m": 1, "a": 1, "e": 1}, "turnip.ogg": {"n": 1, "a": 1, "b": 1, "o": 1}, "vegetable.ogg": {"v": 1, "e": 2, "g": 1, "t": 1, "a": 1, "l": 1}, "walnut.ogg": {"n": 1, "o": 1, "z": 1}, "wheat.ogg": {"t": 1, "r": 1, "i": 1, "g": 1, "o": 1}}
    property int lessonIndex:16
    property int configuredMode:5
    property int configuredCase:2
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
