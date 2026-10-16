// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteLetterInWordLessonPT"
    when:activity.visible
    property var expectedWords:{"bike.ogg": "bicicleta", "boat.ogg": "barco", "bus.ogg": "autocarro", "canoe.ogg": "canoa", "car.ogg": "automóvel", "motorcycle.ogg": "motocicleta", "parachute.ogg": "paraquedas", "plane.ogg": "avião", "raft.ogg": "jangada", "sail.ogg": "velejar", "ship.ogg": "navio", "sled.ogg": "trenó", "taxi.ogg": "táxi", "train.ogg": "comboio", "truck.ogg": "camioneta", "van.ogg": "carrinha"}
    property var incidence:{"m": ["car.ogg", "motorcycle.ogg", "train.ogg", "truck.ogg"], "r": ["boat.ogg", "bus.ogg", "parachute.ogg", "sail.ogg", "sled.ogg", "van.ogg"], "u": ["bus.ogg", "car.ogg", "parachute.ogg"], "q": ["parachute.ogg"], "x": ["taxi.ogg"], "á": ["taxi.ogg"], "t": ["bike.ogg", "bus.ogg", "car.ogg", "motorcycle.ogg", "sled.ogg", "taxi.ogg", "truck.ogg"], "d": ["parachute.ogg", "raft.ogg"], "i": ["bike.ogg", "motorcycle.ogg", "plane.ogg", "ship.ogg", "taxi.ogg", "train.ogg", "truck.ogg", "van.ogg"], "l": ["bike.ogg", "car.ogg", "motorcycle.ogg", "sail.ogg"], "j": ["raft.ogg", "sail.ogg"], "a": ["bike.ogg", "boat.ogg", "bus.ogg", "canoe.ogg", "car.ogg", "motorcycle.ogg", "parachute.ogg", "plane.ogg", "raft.ogg", "sail.ogg", "ship.ogg", "truck.ogg", "van.ogg"], "p": ["parachute.ogg"], "h": ["van.ogg"], "n": ["canoe.ogg", "raft.ogg", "ship.ogg", "sled.ogg", "truck.ogg", "van.ogg"], "g": ["raft.ogg"], "s": ["parachute.ogg"], "o": ["boat.ogg", "bus.ogg", "canoe.ogg", "car.ogg", "motorcycle.ogg", "plane.ogg", "ship.ogg", "train.ogg", "truck.ogg"], "c": ["bike.ogg", "boat.ogg", "bus.ogg", "canoe.ogg", "motorcycle.ogg", "train.ogg", "truck.ogg", "van.ogg"], "e": ["bike.ogg", "car.ogg", "motorcycle.ogg", "parachute.ogg", "sail.ogg", "sled.ogg", "truck.ogg"], "b": ["bike.ogg", "boat.ogg", "train.ogg"], "v": ["car.ogg", "plane.ogg", "sail.ogg", "ship.ogg"], "ã": ["plane.ogg"], "ó": ["car.ogg", "sled.ogg"]}
    property var counts:{"bike.ogg": {"b": 1, "i": 2, "c": 2, "l": 1, "e": 1, "t": 1, "a": 1}, "boat.ogg": {"b": 1, "a": 1, "r": 1, "c": 1, "o": 1}, "bus.ogg": {"a": 2, "u": 1, "t": 1, "o": 2, "c": 1, "r": 2}, "canoe.ogg": {"c": 1, "a": 2, "n": 1, "o": 1}, "car.ogg": {"a": 1, "u": 1, "t": 1, "o": 1, "m": 1, "ó": 1, "v": 1, "e": 1, "l": 1}, "motorcycle.ogg": {"m": 1, "o": 2, "t": 2, "c": 2, "i": 1, "l": 1, "e": 1, "a": 1}, "parachute.ogg": {"p": 1, "a": 3, "r": 1, "q": 1, "u": 1, "e": 1, "d": 1, "s": 1}, "plane.ogg": {"a": 1, "v": 1, "i": 1, "ã": 1, "o": 1}, "raft.ogg": {"j": 1, "a": 3, "n": 1, "g": 1, "d": 1}, "sail.ogg": {"v": 1, "e": 2, "l": 1, "j": 1, "a": 1, "r": 1}, "ship.ogg": {"n": 1, "a": 1, "v": 1, "i": 1, "o": 1}, "sled.ogg": {"t": 1, "r": 1, "e": 1, "n": 1, "ó": 1}, "taxi.ogg": {"t": 1, "á": 1, "x": 1, "i": 1}, "train.ogg": {"c": 1, "o": 3, "m": 1, "b": 1, "i": 1}, "truck.ogg": {"c": 1, "a": 2, "m": 1, "i": 1, "o": 1, "n": 1, "e": 1, "t": 1}, "van.ogg": {"c": 1, "a": 2, "r": 2, "i": 1, "n": 1, "h": 1}}
    property int lessonIndex:22
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
