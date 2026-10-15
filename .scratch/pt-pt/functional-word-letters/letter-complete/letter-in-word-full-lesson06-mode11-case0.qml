// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteLetterInWordLessonPT"
    when:activity.visible
    property var expectedWords:{"ankle.ogg": "tornozelo", "arm.ogg": "braço", "back.ogg": "costas", "beard.ogg": "barba", "belly.ogg": "barriga", "bottom.ogg": "rabo", "braid.ogg": "trança", "brain.ogg": "cérebro", "breast.ogg": "seio", "bump.ogg": "galo", "cheek.ogg": "bochecha", "chin.ogg": "queixo", "ear.ogg": "orelha", "elbow.ogg": "cotovelo", "eyelash.ogg": "pestana", "eyes.ogg": "olhos", "face.ogg": "cara", "femur.ogg": "fémur", "finger.ogg": "dedo", "fist.ogg": "punho", "foot.ogg": "pé", "grin.ogg": "sorriso rasgado", "hair.ogg": "cabelo", "hand.ogg": "mão", "head.ogg": "cabeça", "hip.ogg": "anca", "knee.ogg": "joelho", "lap.ogg": "colo", "leg.ogg": "perna", "lip.ogg": "lábios", "mouth.ogg": "boca", "muscle.ogg": "músculo", "navel.ogg": "umbigo", "neck.ogg": "pescoço", "nose.ogg": "nariz", "nostril.ogg": "narina", "scar.ogg": "cicatriz", "skeleton.ogg": "esqueleto", "skin.ogg": "pele", "spine.ogg": "espinha-dorsal", "stomach.ogg": "estômago", "sweat.ogg": "suor", "teeth.ogg": "dentes", "thigh.ogg": "coxa", "throat.ogg": "garganta", "thumb.ogg": "polegar", "toe.ogg": "dedo do pé", "tongue.ogg": "língua", "vein.ogg": "veia", "wart.ogg": "verruga", "wrist.ogg": "pulso"}
    property var incidence:{"m": ["femur.ogg", "hand.ogg", "muscle.ogg", "navel.ogg", "stomach.ogg"], "x": ["chin.ogg", "thigh.ogg"], "t": ["ankle.ogg", "back.ogg", "braid.ogg", "elbow.ogg", "eyelash.ogg", "scar.ogg", "skeleton.ogg", "stomach.ogg", "teeth.ogg", "throat.ogg"], "d": ["finger.ogg", "grin.ogg", "spine.ogg", "teeth.ogg", "toe.ogg"], "i": ["belly.ogg", "breast.ogg", "chin.ogg", "grin.ogg", "lip.ogg", "navel.ogg", "nose.ogg", "nostril.ogg", "scar.ogg", "spine.ogg", "vein.ogg"], "j": ["knee.ogg"], "g": ["belly.ogg", "bump.ogg", "grin.ogg", "navel.ogg", "stomach.ogg", "throat.ogg", "thumb.ogg", "tongue.ogg", "wart.ogg"], "z": ["ankle.ogg", "nose.ogg", "scar.ogg"], "s": ["back.ogg", "breast.ogg", "eyelash.ogg", "eyes.ogg", "grin.ogg", "lip.ogg", "muscle.ogg", "neck.ogg", "skeleton.ogg", "spine.ogg", "stomach.ogg", "sweat.ogg", "teeth.ogg", "wrist.ogg"], "o": ["ankle.ogg", "arm.ogg", "back.ogg", "bottom.ogg", "brain.ogg", "breast.ogg", "bump.ogg", "cheek.ogg", "chin.ogg", "ear.ogg", "elbow.ogg", "eyes.ogg", "finger.ogg", "fist.ogg", "grin.ogg", "hair.ogg", "hand.ogg", "knee.ogg", "lap.ogg", "lip.ogg", "mouth.ogg", "muscle.ogg", "navel.ogg", "neck.ogg", "skeleton.ogg", "spine.ogg", "stomach.ogg", "sweat.ogg", "thigh.ogg", "thumb.ogg", "toe.ogg", "wrist.ogg"], "c": ["back.ogg", "brain.ogg", "cheek.ogg", "elbow.ogg", "face.ogg", "hair.ogg", "head.ogg", "hip.ogg", "lap.ogg", "mouth.ogg", "muscle.ogg", "neck.ogg", "scar.ogg", "thigh.ogg"], "f": ["femur.ogg"], "e": ["ankle.ogg", "brain.ogg", "breast.ogg", "cheek.ogg", "chin.ogg", "ear.ogg", "elbow.ogg", "eyelash.ogg", "finger.ogg", "hair.ogg", "head.ogg", "knee.ogg", "leg.ogg", "neck.ogg", "skeleton.ogg", "skin.ogg", "spine.ogg", "stomach.ogg", "teeth.ogg", "thumb.ogg", "toe.ogg", "vein.ogg", "wart.ogg"], "v": ["elbow.ogg", "vein.ogg", "wart.ogg"], "ã": ["hand.ogg"], "r": ["ankle.ogg", "arm.ogg", "beard.ogg", "belly.ogg", "bottom.ogg", "braid.ogg", "brain.ogg", "ear.ogg", "face.ogg", "femur.ogg", "grin.ogg", "leg.ogg", "nose.ogg", "nostril.ogg", "scar.ogg", "spine.ogg", "sweat.ogg", "throat.ogg", "thumb.ogg", "wart.ogg"], "u": ["chin.ogg", "femur.ogg", "fist.ogg", "muscle.ogg", "navel.ogg", "skeleton.ogg", "sweat.ogg", "tongue.ogg", "wart.ogg", "wrist.ogg"], "q": ["chin.ogg", "skeleton.ogg"], "-": ["spine.ogg"], "á": ["lip.ogg"], "ô": ["stomach.ogg"], "í": ["tongue.ogg"], "ç": ["arm.ogg", "braid.ogg", "head.ogg", "neck.ogg"], "l": ["ankle.ogg", "bump.ogg", "ear.ogg", "elbow.ogg", "eyes.ogg", "hair.ogg", "knee.ogg", "lap.ogg", "lip.ogg", "muscle.ogg", "skeleton.ogg", "skin.ogg", "spine.ogg", "thumb.ogg", "tongue.ogg", "wrist.ogg"], "ú": ["muscle.ogg"], "a": ["arm.ogg", "back.ogg", "beard.ogg", "belly.ogg", "bottom.ogg", "braid.ogg", "bump.ogg", "cheek.ogg", "ear.ogg", "eyelash.ogg", "face.ogg", "grin.ogg", "hair.ogg", "head.ogg", "hip.ogg", "leg.ogg", "mouth.ogg", "nose.ogg", "nostril.ogg", "scar.ogg", "spine.ogg", "stomach.ogg", "thigh.ogg", "throat.ogg", "thumb.ogg", "tongue.ogg", "vein.ogg", "wart.ogg"], "p": ["eyelash.ogg", "fist.ogg", "foot.ogg", "leg.ogg", "neck.ogg", "skin.ogg", "spine.ogg", "thumb.ogg", "toe.ogg", "wrist.ogg"], "h": ["cheek.ogg", "ear.ogg", "eyes.ogg", "fist.ogg", "knee.ogg", "spine.ogg"], "n": ["ankle.ogg", "braid.ogg", "eyelash.ogg", "fist.ogg", "hip.ogg", "leg.ogg", "nose.ogg", "nostril.ogg", "spine.ogg", "teeth.ogg", "throat.ogg", "tongue.ogg"], "é": ["brain.ogg", "femur.ogg", "foot.ogg", "toe.ogg"], "b": ["arm.ogg", "beard.ogg", "belly.ogg", "bottom.ogg", "brain.ogg", "cheek.ogg", "hair.ogg", "head.ogg", "lip.ogg", "mouth.ogg", "navel.ogg"]}
    property var counts:{"ankle.ogg": {"t": 1, "o": 3, "r": 1, "n": 1, "z": 1, "e": 1, "l": 1}, "arm.ogg": {"b": 1, "r": 1, "a": 1, "ç": 1, "o": 1}, "back.ogg": {"c": 1, "o": 1, "s": 2, "t": 1, "a": 1}, "beard.ogg": {"b": 2, "a": 2, "r": 1}, "belly.ogg": {"b": 1, "a": 2, "r": 2, "i": 1, "g": 1}, "bottom.ogg": {"r": 1, "a": 1, "b": 1, "o": 1}, "braid.ogg": {"t": 1, "r": 1, "a": 2, "n": 1, "ç": 1}, "brain.ogg": {"c": 1, "é": 1, "r": 2, "e": 1, "b": 1, "o": 1}, "breast.ogg": {"s": 1, "e": 1, "i": 1, "o": 1}, "bump.ogg": {"g": 1, "a": 1, "l": 1, "o": 1}, "cheek.ogg": {"b": 1, "o": 1, "c": 2, "h": 2, "e": 1, "a": 1}, "chin.ogg": {"q": 1, "u": 1, "e": 1, "i": 1, "x": 1, "o": 1}, "ear.ogg": {"o": 1, "r": 1, "e": 1, "l": 1, "h": 1, "a": 1}, "elbow.ogg": {"c": 1, "o": 3, "t": 1, "v": 1, "e": 1, "l": 1}, "eyelash.ogg": {"p": 1, "e": 1, "s": 1, "t": 1, "a": 2, "n": 1}, "eyes.ogg": {"o": 2, "l": 1, "h": 1, "s": 1}, "face.ogg": {"c": 1, "a": 2, "r": 1}, "femur.ogg": {"f": 1, "é": 1, "m": 1, "u": 1, "r": 1}, "finger.ogg": {"d": 2, "e": 1, "o": 1}, "fist.ogg": {"p": 1, "u": 1, "n": 1, "h": 1, "o": 1}, "foot.ogg": {"p": 1, "é": 1}, "grin.ogg": {"s": 3, "o": 3, "r": 3, "i": 1, "a": 2, "g": 1, "d": 1}, "hair.ogg": {"c": 1, "a": 1, "b": 1, "e": 1, "l": 1, "o": 1}, "hand.ogg": {"m": 1, "ã": 1, "o": 1}, "head.ogg": {"c": 1, "a": 2, "b": 1, "e": 1, "ç": 1}, "hip.ogg": {"a": 2, "n": 1, "c": 1}, "knee.ogg": {"j": 1, "o": 2, "e": 1, "l": 1, "h": 1}, "lap.ogg": {"c": 1, "o": 2, "l": 1}, "leg.ogg": {"p": 1, "e": 1, "r": 1, "n": 1, "a": 1}, "lip.ogg": {"l": 1, "á": 1, "b": 1, "i": 1, "o": 1, "s": 1}, "mouth.ogg": {"b": 1, "o": 1, "c": 1, "a": 1}, "muscle.ogg": {"m": 1, "ú": 1, "s": 1, "c": 1, "u": 1, "l": 1, "o": 1}, "navel.ogg": {"u": 1, "m": 1, "b": 1, "i": 1, "g": 1, "o": 1}, "neck.ogg": {"p": 1, "e": 1, "s": 1, "c": 1, "o": 2, "ç": 1}, "nose.ogg": {"n": 1, "a": 1, "r": 1, "i": 1, "z": 1}, "nostril.ogg": {"n": 2, "a": 2, "r": 1, "i": 1}, "scar.ogg": {"c": 2, "i": 2, "a": 1, "t": 1, "r": 1, "z": 1}, "skeleton.ogg": {"e": 3, "s": 1, "q": 1, "u": 1, "l": 1, "t": 1, "o": 1}, "skin.ogg": {"p": 1, "e": 2, "l": 1}, "spine.ogg": {"e": 1, "s": 2, "p": 1, "i": 1, "n": 1, "h": 1, "a": 2, "-": 1, "d": 1, "o": 1, "r": 1, "l": 1}, "stomach.ogg": {"e": 1, "s": 1, "t": 1, "ô": 1, "m": 1, "a": 1, "g": 1, "o": 1}, "sweat.ogg": {"s": 1, "u": 1, "o": 1, "r": 1}, "teeth.ogg": {"d": 1, "e": 2, "n": 1, "t": 1, "s": 1}, "thigh.ogg": {"c": 1, "o": 1, "x": 1, "a": 1}, "throat.ogg": {"g": 2, "a": 3, "r": 1, "n": 1, "t": 1}, "thumb.ogg": {"p": 1, "o": 1, "l": 1, "e": 1, "g": 1, "a": 1, "r": 1}, "toe.ogg": {"d": 3, "e": 1, "o": 2, "p": 1, "é": 1}, "tongue.ogg": {"l": 1, "í": 1, "n": 1, "g": 1, "u": 1, "a": 1}, "vein.ogg": {"v": 1, "e": 1, "i": 1, "a": 1}, "wart.ogg": {"v": 1, "e": 1, "r": 2, "u": 1, "g": 1, "a": 1}, "wrist.ogg": {"p": 1, "u": 1, "l": 1, "s": 1, "o": 1}}
    property int lessonIndex:5
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
