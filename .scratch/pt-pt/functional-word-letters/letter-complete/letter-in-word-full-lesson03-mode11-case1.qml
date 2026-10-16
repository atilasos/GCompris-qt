// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteLetterInWordLessonPT"
    when:activity.visible
    property var expectedWords:{"bald.ogg": "careca", "big.ogg": "grande", "blind.ogg": "cego", "blond.ogg": "loira", "bright.ogg": "brilhante", "crazy.ogg": "doido", "cute.ogg": "gira", "dirty.ogg": "sujo", "empty.ogg": "vazio", "fat.ogg": "gordo", "full.ogg": "cheio", "giant.ogg": "gigante", "golden.ogg": "dourado", "happy.ogg": "feliz", "high.ogg": "alto", "hot.ogg": "quente", "huge.ogg": "enorme", "hunchbacked.ogg": "corcunda", "ill.ogg": "doente", "liquid.ogg": "líquido", "magic.ogg": "ilusionista", "naked.ogg": "nú", "open.ogg": "aberto", "pretty.ogg": "bonita", "royal.ogg": "real", "shut.ogg": "fechado", "sick.ogg": "doente", "slim.ogg": "magra", "sloppy.ogg": "desajeitado", "small.ogg": "pequeno", "steep.ogg": "íngreme", "stinky.ogg": "fedorento", "straight.ogg": "direito", "strong.ogg": "forte", "tall.ogg": "alto", "thick.ogg": "grosso", "tired.ogg": "cansado", "wet.ogg": "molhado", "wide.ogg": "largo"}
    property var incidence:{"m": ["huge.ogg", "slim.ogg", "steep.ogg", "wet.ogg"], "r": ["bald.ogg", "big.ogg", "blond.ogg", "bright.ogg", "cute.ogg", "fat.ogg", "golden.ogg", "huge.ogg", "hunchbacked.ogg", "open.ogg", "royal.ogg", "slim.ogg", "steep.ogg", "stinky.ogg", "straight.ogg", "strong.ogg", "thick.ogg", "wide.ogg"], "u": ["dirty.ogg", "golden.ogg", "hot.ogg", "hunchbacked.ogg", "liquid.ogg", "magic.ogg", "small.ogg"], "q": ["hot.ogg", "liquid.ogg", "small.ogg"], "t": ["bright.ogg", "giant.ogg", "high.ogg", "hot.ogg", "ill.ogg", "magic.ogg", "open.ogg", "pretty.ogg", "sick.ogg", "sloppy.ogg", "stinky.ogg", "straight.ogg", "strong.ogg", "tall.ogg"], "í": ["liquid.ogg", "steep.ogg"], "d": ["big.ogg", "crazy.ogg", "fat.ogg", "golden.ogg", "hunchbacked.ogg", "ill.ogg", "liquid.ogg", "shut.ogg", "sick.ogg", "sloppy.ogg", "stinky.ogg", "straight.ogg", "tired.ogg", "wet.ogg"], "i": ["blond.ogg", "bright.ogg", "crazy.ogg", "cute.ogg", "empty.ogg", "full.ogg", "giant.ogg", "happy.ogg", "liquid.ogg", "magic.ogg", "pretty.ogg", "sloppy.ogg", "straight.ogg"], "l": ["blond.ogg", "bright.ogg", "happy.ogg", "high.ogg", "liquid.ogg", "magic.ogg", "royal.ogg", "tall.ogg", "wet.ogg", "wide.ogg"], "ú": ["naked.ogg"], "j": ["dirty.ogg", "sloppy.ogg"], "a": ["bald.ogg", "big.ogg", "blond.ogg", "bright.ogg", "cute.ogg", "empty.ogg", "giant.ogg", "golden.ogg", "high.ogg", "hunchbacked.ogg", "magic.ogg", "open.ogg", "pretty.ogg", "royal.ogg", "shut.ogg", "slim.ogg", "sloppy.ogg", "tall.ogg", "tired.ogg", "wet.ogg", "wide.ogg"], "p": ["small.ogg"], "h": ["bright.ogg", "full.ogg", "shut.ogg", "wet.ogg"], "n": ["big.ogg", "bright.ogg", "giant.ogg", "hot.ogg", "huge.ogg", "hunchbacked.ogg", "ill.ogg", "magic.ogg", "naked.ogg", "pretty.ogg", "sick.ogg", "small.ogg", "steep.ogg", "stinky.ogg", "tired.ogg"], "g": ["big.ogg", "blind.ogg", "cute.ogg", "fat.ogg", "giant.ogg", "slim.ogg", "steep.ogg", "thick.ogg", "wide.ogg"], "z": ["empty.ogg", "happy.ogg"], "s": ["dirty.ogg", "magic.ogg", "sloppy.ogg", "thick.ogg", "tired.ogg"], "o": ["blind.ogg", "blond.ogg", "crazy.ogg", "dirty.ogg", "empty.ogg", "fat.ogg", "full.ogg", "golden.ogg", "high.ogg", "huge.ogg", "hunchbacked.ogg", "ill.ogg", "liquid.ogg", "magic.ogg", "open.ogg", "pretty.ogg", "shut.ogg", "sick.ogg", "sloppy.ogg", "small.ogg", "stinky.ogg", "straight.ogg", "strong.ogg", "tall.ogg", "thick.ogg", "tired.ogg", "wet.ogg", "wide.ogg"], "c": ["bald.ogg", "blind.ogg", "full.ogg", "hunchbacked.ogg", "shut.ogg", "tired.ogg"], "f": ["happy.ogg", "shut.ogg", "stinky.ogg", "strong.ogg"], "e": ["bald.ogg", "big.ogg", "blind.ogg", "bright.ogg", "full.ogg", "giant.ogg", "happy.ogg", "hot.ogg", "huge.ogg", "ill.ogg", "open.ogg", "royal.ogg", "shut.ogg", "sick.ogg", "sloppy.ogg", "small.ogg", "steep.ogg", "stinky.ogg", "straight.ogg", "strong.ogg"], "b": ["bright.ogg", "open.ogg", "pretty.ogg"], "v": ["empty.ogg"]}
    property var counts:{"bald.ogg": {"c": 2, "a": 2, "r": 1, "e": 1}, "big.ogg": {"g": 1, "r": 1, "a": 1, "n": 1, "d": 1, "e": 1}, "blind.ogg": {"c": 1, "e": 1, "g": 1, "o": 1}, "blond.ogg": {"l": 1, "o": 1, "i": 1, "r": 1, "a": 1}, "bright.ogg": {"b": 1, "r": 1, "i": 1, "l": 1, "h": 1, "a": 1, "n": 1, "t": 1, "e": 1}, "crazy.ogg": {"d": 2, "o": 2, "i": 1}, "cute.ogg": {"g": 1, "i": 1, "r": 1, "a": 1}, "dirty.ogg": {"s": 1, "u": 1, "j": 1, "o": 1}, "empty.ogg": {"v": 1, "a": 1, "z": 1, "i": 1, "o": 1}, "fat.ogg": {"g": 1, "o": 2, "r": 1, "d": 1}, "full.ogg": {"c": 1, "h": 1, "e": 1, "i": 1, "o": 1}, "giant.ogg": {"g": 2, "i": 1, "a": 1, "n": 1, "t": 1, "e": 1}, "golden.ogg": {"d": 2, "o": 2, "u": 1, "r": 1, "a": 1}, "happy.ogg": {"f": 1, "e": 1, "l": 1, "i": 1, "z": 1}, "high.ogg": {"a": 1, "l": 1, "t": 1, "o": 1}, "hot.ogg": {"q": 1, "u": 1, "e": 2, "n": 1, "t": 1}, "huge.ogg": {"e": 2, "n": 1, "o": 1, "r": 1, "m": 1}, "hunchbacked.ogg": {"c": 2, "o": 1, "r": 1, "u": 1, "n": 1, "d": 1, "a": 1}, "ill.ogg": {"d": 1, "o": 1, "e": 2, "n": 1, "t": 1}, "liquid.ogg": {"l": 1, "í": 1, "q": 1, "u": 1, "i": 1, "d": 1, "o": 1}, "magic.ogg": {"i": 3, "l": 1, "u": 1, "s": 2, "o": 1, "n": 1, "t": 1, "a": 1}, "naked.ogg": {"n": 1, "ú": 1}, "open.ogg": {"a": 1, "b": 1, "e": 1, "r": 1, "t": 1, "o": 1}, "pretty.ogg": {"b": 1, "o": 1, "n": 1, "i": 1, "t": 1, "a": 1}, "royal.ogg": {"r": 1, "e": 1, "a": 1, "l": 1}, "shut.ogg": {"f": 1, "e": 1, "c": 1, "h": 1, "a": 1, "d": 1, "o": 1}, "sick.ogg": {"d": 1, "o": 1, "e": 2, "n": 1, "t": 1}, "slim.ogg": {"m": 1, "a": 2, "g": 1, "r": 1}, "sloppy.ogg": {"d": 2, "e": 2, "s": 1, "a": 2, "j": 1, "i": 1, "t": 1, "o": 1}, "small.ogg": {"p": 1, "e": 2, "q": 1, "u": 1, "n": 1, "o": 1}, "steep.ogg": {"í": 1, "n": 1, "g": 1, "r": 1, "e": 2, "m": 1}, "stinky.ogg": {"f": 1, "e": 2, "d": 1, "o": 2, "r": 1, "n": 1, "t": 1}, "straight.ogg": {"d": 1, "i": 2, "r": 1, "e": 1, "t": 1, "o": 1}, "strong.ogg": {"f": 1, "o": 1, "r": 1, "t": 1, "e": 1}, "tall.ogg": {"a": 1, "l": 1, "t": 1, "o": 1}, "thick.ogg": {"g": 1, "r": 1, "o": 2, "s": 2}, "tired.ogg": {"c": 1, "a": 2, "n": 1, "s": 1, "d": 1, "o": 1}, "wet.ogg": {"m": 1, "o": 2, "l": 1, "h": 1, "a": 1, "d": 1}, "wide.ogg": {"l": 1, "a": 1, "r": 1, "g": 1, "o": 1}}
    property int lessonIndex:2
    property int configuredMode:11
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
