// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteLetterInWordLessonPT"
    when:activity.visible
    property var expectedWords:{"armchair.ogg": "poltrona", "bath.ogg": "banheira", "bed.ogg": "cama", "bench.ogg": "banco", "bookcase.ogg": "estante", "carpet.ogg": "tapete", "chair.ogg": "cadeira", "chest.ogg": "arca", "couch.ogg": "sofá", "cradle.ogg": "berço", "crib.ogg": "berço", "desk.ogg": "secretária", "doormat.ogg": "tapete da porta", "drawer.ogg": "gaveta", "fan.ogg": "ventoinha", "lamp.ogg": "candeeiro", "mat.ogg": "tapete", "mattress.ogg": "colchão", "quilt.ogg": "colcha", "rug.ogg": "tapete", "seat.ogg": "cadeira", "shelf.ogg": "prateleira", "shower.ogg": "chuveiro", "sink.ogg": "lavatório", "stove.ogg": "fogão", "table.ogg": "mesa", "television.ogg": "televisão", "toilet.ogg": "sanita"}
    property var incidence:{"m": ["bed.ogg", "table.ogg"], "r": ["armchair.ogg", "bath.ogg", "chair.ogg", "chest.ogg", "cradle.ogg", "crib.ogg", "desk.ogg", "doormat.ogg", "lamp.ogg", "seat.ogg", "shelf.ogg", "shower.ogg", "sink.ogg"], "u": ["shower.ogg"], "á": ["couch.ogg", "desk.ogg"], "t": ["armchair.ogg", "bookcase.ogg", "carpet.ogg", "desk.ogg", "doormat.ogg", "drawer.ogg", "fan.ogg", "mat.ogg", "rug.ogg", "shelf.ogg", "sink.ogg", "television.ogg", "toilet.ogg"], "d": ["chair.ogg", "doormat.ogg", "lamp.ogg", "seat.ogg"], "i": ["bath.ogg", "chair.ogg", "desk.ogg", "fan.ogg", "lamp.ogg", "seat.ogg", "shelf.ogg", "shower.ogg", "sink.ogg", "television.ogg", "toilet.ogg"], "ç": ["cradle.ogg", "crib.ogg"], "l": ["armchair.ogg", "mattress.ogg", "quilt.ogg", "shelf.ogg", "sink.ogg", "television.ogg"], "a": ["armchair.ogg", "bath.ogg", "bed.ogg", "bench.ogg", "bookcase.ogg", "carpet.ogg", "chair.ogg", "chest.ogg", "desk.ogg", "doormat.ogg", "drawer.ogg", "fan.ogg", "lamp.ogg", "mat.ogg", "quilt.ogg", "rug.ogg", "seat.ogg", "shelf.ogg", "sink.ogg", "table.ogg", "toilet.ogg"], "p": ["armchair.ogg", "carpet.ogg", "doormat.ogg", "mat.ogg", "rug.ogg", "shelf.ogg"], "h": ["bath.ogg", "fan.ogg", "mattress.ogg", "quilt.ogg", "shower.ogg"], "n": ["armchair.ogg", "bath.ogg", "bench.ogg", "bookcase.ogg", "fan.ogg", "lamp.ogg", "toilet.ogg"], "g": ["drawer.ogg", "stove.ogg"], "s": ["bookcase.ogg", "couch.ogg", "desk.ogg", "table.ogg", "television.ogg", "toilet.ogg"], "o": ["armchair.ogg", "bench.ogg", "couch.ogg", "cradle.ogg", "crib.ogg", "doormat.ogg", "fan.ogg", "lamp.ogg", "mattress.ogg", "quilt.ogg", "shower.ogg", "sink.ogg", "stove.ogg", "television.ogg"], "c": ["bed.ogg", "bench.ogg", "chair.ogg", "chest.ogg", "desk.ogg", "lamp.ogg", "mattress.ogg", "quilt.ogg", "seat.ogg", "shower.ogg"], "f": ["couch.ogg", "stove.ogg"], "e": ["bath.ogg", "bookcase.ogg", "carpet.ogg", "chair.ogg", "cradle.ogg", "crib.ogg", "desk.ogg", "doormat.ogg", "drawer.ogg", "fan.ogg", "lamp.ogg", "mat.ogg", "rug.ogg", "seat.ogg", "shelf.ogg", "shower.ogg", "table.ogg", "television.ogg"], "b": ["bath.ogg", "bench.ogg", "cradle.ogg", "crib.ogg"], "v": ["drawer.ogg", "fan.ogg", "shower.ogg", "sink.ogg", "television.ogg"], "ã": ["mattress.ogg", "stove.ogg", "television.ogg"], "ó": ["sink.ogg"]}
    property var counts:{"armchair.ogg": {"p": 1, "o": 2, "l": 1, "t": 1, "r": 1, "n": 1, "a": 1}, "bath.ogg": {"b": 1, "a": 2, "n": 1, "h": 1, "e": 1, "i": 1, "r": 1}, "bed.ogg": {"c": 1, "a": 2, "m": 1}, "bench.ogg": {"b": 1, "a": 1, "n": 1, "c": 1, "o": 1}, "bookcase.ogg": {"e": 2, "s": 1, "t": 2, "a": 1, "n": 1}, "carpet.ogg": {"t": 2, "a": 1, "p": 1, "e": 2}, "chair.ogg": {"c": 1, "a": 2, "d": 1, "e": 1, "i": 1, "r": 1}, "chest.ogg": {"a": 2, "r": 1, "c": 1}, "couch.ogg": {"s": 1, "o": 1, "f": 1, "á": 1}, "cradle.ogg": {"b": 1, "e": 1, "r": 1, "ç": 1, "o": 1}, "crib.ogg": {"b": 1, "e": 1, "r": 1, "ç": 1, "o": 1}, "desk.ogg": {"s": 1, "e": 2, "c": 1, "r": 2, "t": 1, "á": 1, "i": 1, "a": 1}, "doormat.ogg": {"t": 3, "a": 3, "p": 2, "e": 2, "d": 1, "o": 1, "r": 1}, "drawer.ogg": {"g": 1, "a": 2, "v": 1, "e": 1, "t": 1}, "fan.ogg": {"v": 1, "e": 1, "n": 2, "t": 1, "o": 1, "i": 1, "h": 1, "a": 1}, "lamp.ogg": {"c": 1, "a": 1, "n": 1, "d": 1, "e": 2, "i": 1, "r": 1, "o": 1}, "mat.ogg": {"t": 2, "a": 1, "p": 1, "e": 2}, "mattress.ogg": {"c": 2, "o": 2, "l": 1, "h": 1, "ã": 1}, "quilt.ogg": {"c": 2, "o": 1, "l": 1, "h": 1, "a": 1}, "rug.ogg": {"t": 2, "a": 1, "p": 1, "e": 2}, "seat.ogg": {"c": 1, "a": 2, "d": 1, "e": 1, "i": 1, "r": 1}, "shelf.ogg": {"p": 1, "r": 2, "a": 2, "t": 1, "e": 2, "l": 1, "i": 1}, "shower.ogg": {"c": 1, "h": 1, "u": 1, "v": 1, "e": 1, "i": 1, "r": 1, "o": 1}, "sink.ogg": {"l": 1, "a": 2, "v": 1, "t": 1, "ó": 1, "r": 1, "i": 1, "o": 1}, "stove.ogg": {"f": 1, "o": 2, "g": 1, "ã": 1}, "table.ogg": {"m": 1, "e": 1, "s": 1, "a": 1}, "television.ogg": {"t": 1, "e": 2, "l": 1, "v": 1, "i": 1, "s": 1, "ã": 1, "o": 1}, "toilet.ogg": {"s": 1, "a": 2, "n": 1, "i": 1, "t": 1}}
    property int lessonIndex:18
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
