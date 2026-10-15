// SPDX-License-Identifier: GPL-3.0-or-later
// Decoder/queue routing only; sound output and pronunciation still need audition.
TestCase {
    name:"FunctionalLetterVoiceRoutePT"
    when:items.numberOfLevel>0 && activity.visible
    SignalSpy { id: doneSpy; target:activity.audioVoices; signalName:"done" }
    property var observed: ({})
    function test_registered_portuguese_voices_follow_real_answer_path() {
        wait(1600);
        ApplicationSettings.isAudioVoicesEnabled=true;
        activityBackground.stop();
        activityBackground.start();
        var id=activity.activityInfo.shortName();
        compare(ApplicationInfo.getVoicesLocale(items.locale),"pt");
        doneSpy.clear();
        if(id==="click_on_letter" || id==="click_on_letter_up") {
            tryCompare(repeatItem,"visible",true,3000);
            compare(questionItem.visible,false);
            observed={activity:id,question:questionText.text,spokenQuestion:true};
            tryVerify(function(){return doneSpy.count>0;},10000);
            observed.voiceDone=doneSpy.count;
        } else {
            var target=id==="gletters"?Activity.droppedWords[0].text:items.questionText;
            textinput.forceActiveFocus();
            keyClick(target,Qt.NoModifier,0);
            compare(items.score.currentSubLevel,1);
            observed={activity:id,typed:target,answerScore:1};
            tryVerify(function(){return doneSpy.count>0;},10000);
            observed.voiceDone=doneSpy.count;
        }
        grabImage(activityBackground).save("__QA_OUTPUT__/voice-route.png");
    }
    function cleanupTestCase(){console.log("NATIVE_LETTERS_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,audioRoute:observed}));}
}
