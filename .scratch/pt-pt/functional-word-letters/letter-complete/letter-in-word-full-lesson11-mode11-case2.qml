// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteLetterInWordLessonPT"
    when:activity.visible
    property var expectedWords:{"athlete.ogg": "atleta", "ballet.ogg": "ballet", "cheer.ogg": "animar", "climb.ogg": "escalada", "dance.ogg": "dança", "dive.ogg": "mergulho", "explore.ogg": "explorar", "golf.ogg": "golfe", "hike.ogg": "caminhada", "hit.ogg": "luta", "hockey.ogg": "hóquei em patins", "hop.ogg": "salto", "jog.ogg": "jogging", "judo.ogg": "judo", "lift.ogg": "levantar", "race.ogg": "corrida", "ran.ogg": "correr", "ride.ogg": "andar de bicicleta", "rowing.ogg": "remo", "skate.ogg": "skate", "ski.ogg": "esqui", "sport.ogg": "desporto", "swim.ogg": "nadar", "tennis.ogg": "ténis", "throw.ogg": "atirar"}
    property var incidence:{"m": ["cheer.ogg", "dive.ogg", "hike.ogg", "hockey.ogg", "rowing.ogg"], "r": ["cheer.ogg", "dive.ogg", "explore.ogg", "lift.ogg", "race.ogg", "ran.ogg", "ride.ogg", "rowing.ogg", "sport.ogg", "swim.ogg", "throw.ogg"], "u": ["dive.ogg", "hit.ogg", "hockey.ogg", "judo.ogg", "ski.ogg"], "q": ["hockey.ogg", "ski.ogg"], "x": ["explore.ogg"], "t": ["athlete.ogg", "ballet.ogg", "hit.ogg", "hockey.ogg", "hop.ogg", "lift.ogg", "ride.ogg", "skate.ogg", "sport.ogg", "tennis.ogg", "throw.ogg"], "d": ["climb.ogg", "dance.ogg", "hike.ogg", "judo.ogg", "race.ogg", "ride.ogg", "sport.ogg", "swim.ogg"], "i": ["cheer.ogg", "hike.ogg", "hockey.ogg", "jog.ogg", "race.ogg", "ride.ogg", "ski.ogg", "tennis.ogg", "throw.ogg"], "ç": ["dance.ogg"], "l": ["athlete.ogg", "ballet.ogg", "climb.ogg", "dive.ogg", "explore.ogg", "golf.ogg", "hit.ogg", "hop.ogg", "lift.ogg", "ride.ogg"], "j": ["jog.ogg", "judo.ogg"], "a": ["athlete.ogg", "ballet.ogg", "cheer.ogg", "climb.ogg", "dance.ogg", "explore.ogg", "hike.ogg", "hit.ogg", "hockey.ogg", "hop.ogg", "lift.ogg", "race.ogg", "ride.ogg", "skate.ogg", "swim.ogg", "throw.ogg"], "p": ["explore.ogg", "hockey.ogg", "sport.ogg"], "h": ["dive.ogg", "hike.ogg", "hockey.ogg"], "k": ["skate.ogg"], "n": ["cheer.ogg", "dance.ogg", "hike.ogg", "hockey.ogg", "jog.ogg", "lift.ogg", "ride.ogg", "swim.ogg", "tennis.ogg"], "g": ["dive.ogg", "golf.ogg", "jog.ogg"], "é": ["tennis.ogg"], "s": ["climb.ogg", "hockey.ogg", "hop.ogg", "skate.ogg", "ski.ogg", "sport.ogg", "tennis.ogg"], "o": ["dive.ogg", "explore.ogg", "golf.ogg", "hop.ogg", "jog.ogg", "judo.ogg", "race.ogg", "ran.ogg", "rowing.ogg", "sport.ogg"], "c": ["climb.ogg", "hike.ogg", "race.ogg", "ran.ogg", "ride.ogg"], "f": ["golf.ogg"], "e": ["athlete.ogg", "ballet.ogg", "climb.ogg", "dive.ogg", "explore.ogg", "golf.ogg", "hockey.ogg", "lift.ogg", "ran.ogg", "ride.ogg", "rowing.ogg", "skate.ogg", "ski.ogg", "sport.ogg"], "b": ["ballet.ogg", "ride.ogg"], "v": ["lift.ogg"], "ó": ["hockey.ogg"]}
    property var counts:{"athlete.ogg": {"a": 2, "t": 2, "l": 1, "e": 1}, "ballet.ogg": {"b": 1, "a": 1, "l": 2, "e": 1, "t": 1}, "cheer.ogg": {"a": 2, "n": 1, "i": 1, "m": 1, "r": 1}, "climb.ogg": {"e": 1, "s": 1, "c": 1, "a": 3, "l": 1, "d": 1}, "dance.ogg": {"d": 1, "a": 2, "n": 1, "ç": 1}, "dive.ogg": {"m": 1, "e": 1, "r": 1, "g": 1, "u": 1, "l": 1, "h": 1, "o": 1}, "explore.ogg": {"e": 1, "x": 1, "p": 1, "l": 1, "o": 1, "r": 2, "a": 1}, "golf.ogg": {"g": 1, "o": 1, "l": 1, "f": 1, "e": 1}, "hike.ogg": {"c": 1, "a": 3, "m": 1, "i": 1, "n": 1, "h": 1, "d": 1}, "hit.ogg": {"l": 1, "u": 1, "t": 1, "a": 1}, "hockey.ogg": {"h": 1, "ó": 1, "q": 1, "u": 1, "e": 2, "i": 2, "m": 1, "p": 1, "a": 1, "t": 1, "n": 1, "s": 1}, "hop.ogg": {"s": 1, "a": 1, "l": 1, "t": 1, "o": 1}, "jog.ogg": {"j": 1, "o": 1, "g": 3, "i": 1, "n": 1}, "judo.ogg": {"j": 1, "u": 1, "d": 1, "o": 1}, "lift.ogg": {"l": 1, "e": 1, "v": 1, "a": 2, "n": 1, "t": 1, "r": 1}, "race.ogg": {"c": 1, "o": 1, "r": 2, "i": 1, "d": 1, "a": 1}, "ran.ogg": {"c": 1, "o": 1, "r": 3, "e": 1}, "ride.ogg": {"a": 3, "n": 1, "d": 2, "r": 1, "e": 2, "b": 1, "i": 2, "c": 2, "l": 1, "t": 1}, "rowing.ogg": {"r": 1, "e": 1, "m": 1, "o": 1}, "skate.ogg": {"s": 1, "k": 1, "a": 1, "t": 1, "e": 1}, "ski.ogg": {"e": 1, "s": 1, "q": 1, "u": 1, "i": 1}, "sport.ogg": {"d": 1, "e": 1, "s": 1, "p": 1, "o": 2, "r": 1, "t": 1}, "swim.ogg": {"n": 1, "a": 2, "d": 1, "r": 1}, "tennis.ogg": {"t": 1, "é": 1, "n": 1, "i": 1, "s": 1}, "throw.ogg": {"a": 2, "t": 1, "i": 1, "r": 2}}
    property int lessonIndex:10
    property int configuredMode:11
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
