// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteLetterInWordLessonPT"
    when:activity.visible
    property var expectedWords:{"appliance.ogg": "electrodoméstico", "baby_bottle.ogg": "biberão", "balance.ogg": "balança", "blade.ogg": "lâmina", "can.ogg": "lata", "carafe.ogg": "garrafa", "cauldron.ogg": "caldeirão", "chandelier.ogg": "candelabro", "clock.ogg": "relógio", "curtain.ogg": "cortina", "dish.ogg": "loiça", "fork.ogg": "garfo", "glass.ogg": "copo", "knife.ogg": "faca", "lid.ogg": "tampa", "mop.ogg": "esfregona", "mug.ogg": "chávena", "pan.ogg": "frigideira", "plate.ogg": "prato", "pot.ogg": "pote", "scale.ogg": "balança", "skimmer.ogg": "espumadeira", "spatula.ogg": "espátula", "sponge.ogg": "esponja", "spoon.ogg": "colher", "strainer.ogg": "escorredor", "tablecloth.ogg": "toalha", "tin.ogg": "lata", "toaster.ogg": "torradeira", "tongs.ogg": "tenaz", "trash.ogg": "lixo", "tray.ogg": "tabuleiro", "vase.ogg": "jarro", "whisk.ogg": "batedor", "alarmclock.ogg": "despertador"}
    property var incidence:{"m": ["appliance.ogg", "blade.ogg", "lid.ogg", "skimmer.ogg"], "r": ["appliance.ogg", "baby_bottle.ogg", "carafe.ogg", "cauldron.ogg", "chandelier.ogg", "clock.ogg", "curtain.ogg", "fork.ogg", "mop.ogg", "pan.ogg", "plate.ogg", "skimmer.ogg", "spoon.ogg", "strainer.ogg", "toaster.ogg", "tray.ogg", "vase.ogg", "whisk.ogg", "alarmclock.ogg"], "u": ["skimmer.ogg", "spatula.ogg", "tray.ogg"], "x": ["trash.ogg"], "á": ["mug.ogg", "spatula.ogg"], "t": ["appliance.ogg", "can.ogg", "curtain.ogg", "lid.ogg", "plate.ogg", "pot.ogg", "spatula.ogg", "tablecloth.ogg", "tin.ogg", "toaster.ogg", "tongs.ogg", "tray.ogg", "whisk.ogg", "alarmclock.ogg"], "d": ["appliance.ogg", "cauldron.ogg", "chandelier.ogg", "pan.ogg", "skimmer.ogg", "strainer.ogg", "toaster.ogg", "whisk.ogg", "alarmclock.ogg"], "i": ["appliance.ogg", "baby_bottle.ogg", "blade.ogg", "cauldron.ogg", "clock.ogg", "curtain.ogg", "dish.ogg", "pan.ogg", "skimmer.ogg", "toaster.ogg", "trash.ogg", "tray.ogg"], "â": ["blade.ogg"], "ç": ["balance.ogg", "dish.ogg", "scale.ogg"], "j": ["sponge.ogg", "vase.ogg"], "l": ["appliance.ogg", "balance.ogg", "blade.ogg", "can.ogg", "cauldron.ogg", "chandelier.ogg", "clock.ogg", "dish.ogg", "scale.ogg", "spatula.ogg", "spoon.ogg", "tablecloth.ogg", "tin.ogg", "trash.ogg", "tray.ogg"], "a": ["balance.ogg", "blade.ogg", "can.ogg", "carafe.ogg", "cauldron.ogg", "chandelier.ogg", "curtain.ogg", "dish.ogg", "fork.ogg", "knife.ogg", "lid.ogg", "mop.ogg", "mug.ogg", "pan.ogg", "plate.ogg", "scale.ogg", "skimmer.ogg", "spatula.ogg", "sponge.ogg", "tablecloth.ogg", "tin.ogg", "toaster.ogg", "tongs.ogg", "tray.ogg", "vase.ogg", "whisk.ogg", "alarmclock.ogg"], "p": ["glass.ogg", "lid.ogg", "plate.ogg", "pot.ogg", "skimmer.ogg", "spatula.ogg", "sponge.ogg", "alarmclock.ogg"], "h": ["mug.ogg", "spoon.ogg", "tablecloth.ogg"], "é": ["appliance.ogg"], "g": ["carafe.ogg", "clock.ogg", "fork.ogg", "mop.ogg", "pan.ogg"], "z": ["tongs.ogg"], "n": ["balance.ogg", "blade.ogg", "chandelier.ogg", "curtain.ogg", "mop.ogg", "mug.ogg", "scale.ogg", "sponge.ogg", "tongs.ogg"], "s": ["appliance.ogg", "mop.ogg", "skimmer.ogg", "spatula.ogg", "sponge.ogg", "strainer.ogg", "alarmclock.ogg"], "o": ["appliance.ogg", "baby_bottle.ogg", "cauldron.ogg", "chandelier.ogg", "clock.ogg", "curtain.ogg", "dish.ogg", "fork.ogg", "glass.ogg", "mop.ogg", "plate.ogg", "pot.ogg", "sponge.ogg", "spoon.ogg", "strainer.ogg", "tablecloth.ogg", "toaster.ogg", "trash.ogg", "tray.ogg", "vase.ogg", "whisk.ogg", "alarmclock.ogg"], "c": ["appliance.ogg", "cauldron.ogg", "chandelier.ogg", "curtain.ogg", "glass.ogg", "knife.ogg", "mug.ogg", "spoon.ogg", "strainer.ogg"], "f": ["carafe.ogg", "fork.ogg", "knife.ogg", "mop.ogg", "pan.ogg"], "e": ["appliance.ogg", "baby_bottle.ogg", "cauldron.ogg", "chandelier.ogg", "clock.ogg", "mop.ogg", "mug.ogg", "pan.ogg", "pot.ogg", "skimmer.ogg", "spatula.ogg", "sponge.ogg", "spoon.ogg", "strainer.ogg", "toaster.ogg", "tongs.ogg", "tray.ogg", "whisk.ogg", "alarmclock.ogg"], "b": ["baby_bottle.ogg", "balance.ogg", "chandelier.ogg", "scale.ogg", "tray.ogg", "whisk.ogg"], "v": ["mug.ogg"], "ã": ["baby_bottle.ogg", "cauldron.ogg"], "ó": ["clock.ogg"]}
    property var counts:{"appliance.ogg": {"e": 2, "l": 1, "c": 2, "t": 2, "r": 1, "o": 3, "d": 1, "m": 1, "é": 1, "s": 1, "i": 1}, "baby_bottle.ogg": {"b": 2, "i": 1, "e": 1, "r": 1, "ã": 1, "o": 1}, "balance.ogg": {"b": 1, "a": 3, "l": 1, "n": 1, "ç": 1}, "blade.ogg": {"l": 1, "â": 1, "m": 1, "i": 1, "n": 1, "a": 1}, "can.ogg": {"l": 1, "a": 2, "t": 1}, "carafe.ogg": {"g": 1, "a": 3, "r": 2, "f": 1}, "cauldron.ogg": {"c": 1, "a": 1, "l": 1, "d": 1, "e": 1, "i": 1, "r": 1, "ã": 1, "o": 1}, "chandelier.ogg": {"c": 1, "a": 2, "n": 1, "d": 1, "e": 1, "l": 1, "b": 1, "r": 1, "o": 1}, "clock.ogg": {"r": 1, "e": 1, "l": 1, "ó": 1, "g": 1, "i": 1, "o": 1}, "curtain.ogg": {"c": 1, "o": 1, "r": 1, "t": 1, "i": 1, "n": 1, "a": 1}, "dish.ogg": {"l": 1, "o": 1, "i": 1, "ç": 1, "a": 1}, "fork.ogg": {"g": 1, "a": 1, "r": 1, "f": 1, "o": 1}, "glass.ogg": {"c": 1, "o": 2, "p": 1}, "knife.ogg": {"f": 1, "a": 2, "c": 1}, "lid.ogg": {"t": 1, "a": 2, "m": 1, "p": 1}, "mop.ogg": {"e": 2, "s": 1, "f": 1, "r": 1, "g": 1, "o": 1, "n": 1, "a": 1}, "mug.ogg": {"c": 1, "h": 1, "á": 1, "v": 1, "e": 1, "n": 1, "a": 1}, "pan.ogg": {"f": 1, "r": 2, "i": 3, "g": 1, "d": 1, "e": 1, "a": 1}, "plate.ogg": {"p": 1, "r": 1, "a": 1, "t": 1, "o": 1}, "pot.ogg": {"p": 1, "o": 1, "t": 1, "e": 1}, "scale.ogg": {"b": 1, "a": 3, "l": 1, "n": 1, "ç": 1}, "skimmer.ogg": {"e": 2, "s": 1, "p": 1, "u": 1, "m": 1, "a": 2, "d": 1, "i": 1, "r": 1}, "spatula.ogg": {"e": 1, "s": 1, "p": 1, "á": 1, "t": 1, "u": 1, "l": 1, "a": 1}, "sponge.ogg": {"e": 1, "s": 1, "p": 1, "o": 1, "n": 1, "j": 1, "a": 1}, "spoon.ogg": {"c": 1, "o": 1, "l": 1, "h": 1, "e": 1, "r": 1}, "strainer.ogg": {"e": 2, "s": 1, "c": 1, "o": 2, "r": 3, "d": 1}, "tablecloth.ogg": {"t": 1, "o": 1, "a": 2, "l": 1, "h": 1}, "tin.ogg": {"l": 1, "a": 2, "t": 1}, "toaster.ogg": {"t": 1, "o": 1, "r": 3, "a": 2, "d": 1, "e": 1, "i": 1}, "tongs.ogg": {"t": 1, "e": 1, "n": 1, "a": 1, "z": 1}, "trash.ogg": {"l": 1, "i": 1, "x": 1, "o": 1}, "tray.ogg": {"t": 1, "a": 1, "b": 1, "u": 1, "l": 1, "e": 1, "i": 1, "r": 1, "o": 1}, "vase.ogg": {"j": 1, "a": 1, "r": 2, "o": 1}, "whisk.ogg": {"b": 1, "a": 1, "t": 1, "e": 1, "d": 1, "o": 1, "r": 1}, "alarmclock.ogg": {"d": 2, "e": 2, "s": 1, "p": 1, "r": 2, "t": 1, "a": 1, "o": 1}}
    property int lessonIndex:19
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
