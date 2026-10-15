// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteLetterInWordLessonPT"
    when:activity.visible
    property var expectedWords:{"arm.ogg": "braço", "back.ogg": "costas", "brain.ogg": "cérebro", "ear.ogg": "orelha", "eyes.ogg": "olhos", "face.ogg": "cara", "finger.ogg": "dedo", "foot.ogg": "pé", "hair.ogg": "cabelo", "hand.ogg": "mão", "head.ogg": "cabeça", "knee.ogg": "joelho", "leg.ogg": "perna", "mouth.ogg": "boca", "neck.ogg": "pescoço", "nose.ogg": "nariz", "skin.ogg": "pele", "teeth.ogg": "dentes", "thumb.ogg": "polegar", "tongue.ogg": "língua"}
    property var incidence:{"m": ["hand.ogg"], "r": ["arm.ogg", "brain.ogg", "ear.ogg", "face.ogg", "leg.ogg", "nose.ogg", "thumb.ogg"], "u": ["tongue.ogg"], "t": ["back.ogg", "teeth.ogg"], "í": ["tongue.ogg"], "d": ["finger.ogg", "teeth.ogg"], "i": ["nose.ogg"], "ç": ["arm.ogg", "head.ogg", "neck.ogg"], "l": ["ear.ogg", "eyes.ogg", "hair.ogg", "knee.ogg", "skin.ogg", "thumb.ogg", "tongue.ogg"], "j": ["knee.ogg"], "a": ["arm.ogg", "back.ogg", "ear.ogg", "face.ogg", "hair.ogg", "head.ogg", "leg.ogg", "mouth.ogg", "nose.ogg", "thumb.ogg", "tongue.ogg"], "p": ["foot.ogg", "leg.ogg", "neck.ogg", "skin.ogg", "thumb.ogg"], "h": ["ear.ogg", "eyes.ogg", "knee.ogg"], "é": ["brain.ogg", "foot.ogg"], "g": ["thumb.ogg", "tongue.ogg"], "z": ["nose.ogg"], "n": ["leg.ogg", "nose.ogg", "teeth.ogg", "tongue.ogg"], "s": ["back.ogg", "eyes.ogg", "neck.ogg", "teeth.ogg"], "o": ["arm.ogg", "back.ogg", "brain.ogg", "ear.ogg", "eyes.ogg", "finger.ogg", "hair.ogg", "hand.ogg", "knee.ogg", "mouth.ogg", "neck.ogg", "thumb.ogg"], "c": ["back.ogg", "brain.ogg", "face.ogg", "hair.ogg", "head.ogg", "mouth.ogg", "neck.ogg"], "e": ["brain.ogg", "ear.ogg", "finger.ogg", "hair.ogg", "head.ogg", "knee.ogg", "leg.ogg", "neck.ogg", "skin.ogg", "teeth.ogg", "thumb.ogg"], "b": ["arm.ogg", "brain.ogg", "hair.ogg", "head.ogg", "mouth.ogg"], "ã": ["hand.ogg"]}
    property var counts:{"arm.ogg": {"b": 1, "r": 1, "a": 1, "ç": 1, "o": 1}, "back.ogg": {"c": 1, "o": 1, "s": 2, "t": 1, "a": 1}, "brain.ogg": {"c": 1, "é": 1, "r": 2, "e": 1, "b": 1, "o": 1}, "ear.ogg": {"o": 1, "r": 1, "e": 1, "l": 1, "h": 1, "a": 1}, "eyes.ogg": {"o": 2, "l": 1, "h": 1, "s": 1}, "face.ogg": {"c": 1, "a": 2, "r": 1}, "finger.ogg": {"d": 2, "e": 1, "o": 1}, "foot.ogg": {"p": 1, "é": 1}, "hair.ogg": {"c": 1, "a": 1, "b": 1, "e": 1, "l": 1, "o": 1}, "hand.ogg": {"m": 1, "ã": 1, "o": 1}, "head.ogg": {"c": 1, "a": 2, "b": 1, "e": 1, "ç": 1}, "knee.ogg": {"j": 1, "o": 2, "e": 1, "l": 1, "h": 1}, "leg.ogg": {"p": 1, "e": 1, "r": 1, "n": 1, "a": 1}, "mouth.ogg": {"b": 1, "o": 1, "c": 1, "a": 1}, "neck.ogg": {"p": 1, "e": 1, "s": 1, "c": 1, "o": 2, "ç": 1}, "nose.ogg": {"n": 1, "a": 1, "r": 1, "i": 1, "z": 1}, "skin.ogg": {"p": 1, "e": 2, "l": 1}, "teeth.ogg": {"d": 1, "e": 2, "n": 1, "t": 1, "s": 1}, "thumb.ogg": {"p": 1, "o": 1, "l": 1, "e": 1, "g": 1, "a": 1, "r": 1}, "tongue.ogg": {"l": 1, "í": 1, "n": 1, "g": 1, "u": 1, "a": 1}}
    property int lessonIndex:2
    property int configuredMode:11
    property int configuredCase:2
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
