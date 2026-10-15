// SPDX-License-Identifier: GPL-3.0-or-later
// Used with click_on_letter and inherited click_on_letter_up, real delegates.
TestCase {
    name: "FunctionalClickLettersPT"
    when: items.numberOfLevel > 0 && activity.visible
    property var completed: []
    property int correctInputs: 0
    property int wrongInputs: 0
    property int pointerInputs: 0
    property int keyboardInputs: 0
    function capture(label) {
        grabImage(activityBackground).save("__QA_OUTPUT__/"+label+".png");
    }
    function clickAnswer(index) {
        tryVerify(function(){return train.itemAtIndex(index)!==null;},3000);
        var carriage=train.itemAtIndex(index);
        tryCompare(carriage,"clickEnabled",true,3000);
        mouseClick(carriage,carriage.width/2,carriage.height/2,Qt.LeftButton,Qt.NoModifier,0);
        pointerInputs++;
    }
    function navigateAnswer(index) {
        eventHandler.forceActiveFocus();
        if(!items.keyNavigationMode) keyClick(Qt.Key_Right,Qt.NoModifier,0);
        var guard=0;
        while(train.currentIndex!==index) {
            keyClick(Qt.Key_Right,Qt.NoModifier,0);
            verify(++guard<=trainModel.count+1,"Answer must be reachable through actual arrow keys");
        }
        keyClick(Qt.Key_Space,Qt.NoModifier,0);
        keyboardInputs++;
    }
    function test_complete_every_portuguese_level_with_pointer_and_keyboard() {
        wait(1600);
        compare(items.numberOfLevel,11);
        compare(Activity.locale,"pt");
        var expectedMode=activity.activityInfo.shortName()==="click_on_letter_up"?"uppercase":"lowercase";
        compare(activity.mode,expectedMode);
        for(var level=0;level<11;level++) {
            compare(items.currentLevel,level);
            compare(items.score.currentSubLevel,0);
            var total=items.score.numberOfSubLevels;
            tryCompare(items,"buttonsBlocked",false,3000);
            if(level===0 || level===2 || level===10) capture("click-"+expectedMode+"-level-"+(level+1));
            var wrong=-1;
            for(var a=0;a<trainModel.count;a++) if(trainModel.get(a).letter!==questionText.text){wrong=a;break;}
            verify(wrong>=0);
            clickAnswer(wrong);
            compare(items.score.currentSubLevel,0);
            wrongInputs++;
            tryCompare(items,"buttonsBlocked",false,3000);
            for(var question=0;question<total;question++) {
                tryCompare(items,"buttonsBlocked",false,3000);
                var target=questionText.text;
                compare(target,expectedMode==="uppercase"?target.toUpperCase():target.toLowerCase());
                var correct=-1;
                for(var b=0;b<trainModel.count;b++) if(trainModel.get(b).letter===target){correct=b;break;}
                verify(correct>=0,"The visible question needs a matching visible answer");
                if(question%2===0) clickAnswer(correct);else navigateAnswer(correct);
                tryCompare(items.score,"currentSubLevel",question+1,1000);
                correctInputs++;
                if(question+1<total) tryCompare(items,"buttonsBlocked",false,4000);
            }
            completed.push({mode:expectedMode,level:level+1,correct:total,score:items.score.currentSubLevel});
            console.log("NATIVE_LETTERS_LEVEL",JSON.stringify(completed[completed.length-1]));
            tryCompare(items,"currentLevel",(level+1)%11,7000);
        }
        compare(correctInputs,94);
        verify(pointerInputs>0 && keyboardInputs>0);
    }
    function cleanupTestCase() {
        console.log("NATIVE_LETTERS_RESULT",JSON.stringify({failures:qtest_results.failCount,
            passes:qtest_results.passCount,completed:completed,correctInputs:correctInputs,
            wrongInputs:wrongInputs,pointerInputs:pointerInputs,keyboardInputs:keyboardInputs}));
    }
}
