// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"NativeMissedWordRecovery"
    when:items.numberOfLevel>0 && activity.visible
    property var missedEvidence: ({})
    function findKey(item,text) {
        if(item.specialKey!==undefined && item.text!==undefined && item.text===text)return item;
        if(item.children)for(var i=0;i<item.children.length;i++) {
            var found=findKey(item.children[i],text);if(found!==null)return found;
        }
        return null;
    }
    function clickCharacter(text) {
        var key=null;
        tryVerify(function(){key=findKey(keyboard,text);return key!==null;},2000);
        mouseClick(key,key.width/2,key.height/2,Qt.LeftButton,Qt.NoModifier,0);
    }
    function test_partial_word_falls_out_then_another_word_can_score() {
        wait(1600);ApplicationSettings.isVirtualKeyboard=true;
        activityBackground.stop();activity.speedSetting=10;activityBackground.start();
        tryCompare(keyboard,"visible",true,3000);wait(600);
        var first=Activity.droppedWords[0];var missed=first.text;
        clickCharacter(missed[0]);compare(first.unmatchedIndex,1);
        compare(items.score.currentSubLevel,0);
        grabImage(activityBackground).save("__QA_OUTPUT__/partial-word.png");
        // Allow the original animation to finish. No timer/position mutation.
        tryVerify(function(){return Activity.droppedWords.indexOf(first)<0;},65000);
        compare(items.score.currentSubLevel,0,"Missing the word earns no point");
        compare(Activity.currentWord,null,"Expired partial word releases typing state");
        compare(items.client.tmpMissedText,missed);
        verify(Activity.droppedWords.length>0);
        var next=Activity.droppedWords[0];var target=next.text;
        for(var i=0;i<target.length;i++)clickCharacter(target[i]);
        tryCompare(items.score,"currentSubLevel",1,1000);
        missedEvidence={missed:missed,recovered:target,score:items.score.currentSubLevel};
        grabImage(activityBackground).save("__QA_OUTPUT__/after-missed-recovery.png");
    }
    function cleanupTestCase(){console.log("NATIVE_WORDS_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,missed:missedEvidence}));}
}
