// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteLetterInWordLessonPT"
    when:activity.visible
    property var expectedWords:{"ache.ogg": "dor", "angry.ogg": "zangado", "blush.ogg": "corar", "fear.ogg": "medo", "joy.ogg": "alegria", "laugh.ogg": "rir", "mad.ogg": "furioso", "rage.ogg": "raiva", "sad.ogg": "triste", "smile.ogg": "sorridente", "sob.ogg": "choro", "yum.ogg": "delicioso"}
    property var incidence:{"m": ["fear.ogg"], "r": ["ache.ogg", "blush.ogg", "joy.ogg", "laugh.ogg", "mad.ogg", "rage.ogg", "sad.ogg", "smile.ogg", "sob.ogg"], "u": ["mad.ogg"], "t": ["sad.ogg", "smile.ogg"], "d": ["ache.ogg", "angry.ogg", "fear.ogg", "smile.ogg", "yum.ogg"], "i": ["joy.ogg", "laugh.ogg", "mad.ogg", "rage.ogg", "sad.ogg", "smile.ogg", "yum.ogg"], "l": ["joy.ogg", "yum.ogg"], "a": ["angry.ogg", "blush.ogg", "joy.ogg", "rage.ogg"], "h": ["sob.ogg"], "n": ["angry.ogg", "smile.ogg"], "g": ["angry.ogg", "joy.ogg"], "z": ["angry.ogg"], "s": ["mad.ogg", "sad.ogg", "smile.ogg", "yum.ogg"], "o": ["ache.ogg", "angry.ogg", "blush.ogg", "fear.ogg", "mad.ogg", "smile.ogg", "sob.ogg", "yum.ogg"], "c": ["blush.ogg", "sob.ogg", "yum.ogg"], "f": ["mad.ogg"], "e": ["fear.ogg", "joy.ogg", "sad.ogg", "smile.ogg", "yum.ogg"], "v": ["rage.ogg"]}
    property var counts:{"ache.ogg": {"d": 1, "o": 1, "r": 1}, "angry.ogg": {"z": 1, "a": 2, "n": 1, "g": 1, "d": 1, "o": 1}, "blush.ogg": {"c": 1, "o": 1, "r": 2, "a": 1}, "fear.ogg": {"m": 1, "e": 1, "d": 1, "o": 1}, "joy.ogg": {"a": 2, "l": 1, "e": 1, "g": 1, "r": 1, "i": 1}, "laugh.ogg": {"r": 2, "i": 1}, "mad.ogg": {"f": 1, "u": 1, "r": 1, "i": 1, "o": 2, "s": 1}, "rage.ogg": {"r": 1, "a": 2, "i": 1, "v": 1}, "sad.ogg": {"t": 2, "r": 1, "i": 1, "s": 1, "e": 1}, "smile.ogg": {"s": 1, "o": 1, "r": 2, "i": 1, "d": 1, "e": 2, "n": 1, "t": 1}, "sob.ogg": {"c": 1, "h": 1, "o": 2, "r": 1}, "yum.ogg": {"d": 1, "e": 1, "l": 1, "i": 2, "c": 1, "o": 2, "s": 1}}
    property int lessonIndex:7
    property int configuredMode:11
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
