// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"FunctionalFallingSpeedPT"
    when:items.numberOfLevel>0 && activity.visible
    property var checked: []
    function test_all_ten_speed_settings_accept_real_keyboard_input() {
        wait(1600);
        var previousInterval=Infinity;
        for(var speedSetting=1;speedSetting<=10;speedSetting++) {
            activityBackground.stop();
            activity.speedSetting=speedSetting;
            activityBackground.start();
            compare(items.currentLevel,0);
            compare(items.score.currentSubLevel,0);
            var interval=items.wordDropTimer.interval;
            verify(interval>0 && interval<previousInterval,"Higher speed drops letters more frequently");
            previousInterval=interval;
            tryVerify(function(){return Activity.droppedWords.length>0;},2000);
            var letter=Activity.droppedWords[0].text;
            textinput.forceActiveFocus();
            keyClick("#",Qt.NoModifier,0);
            compare(items.score.currentSubLevel,0);
            keyClick(letter,Qt.NoModifier,0);
            compare(items.score.currentSubLevel,1);
            checked.push({setting:speedSetting,dropInterval:interval,correct:1,wrongRejected:1});
        }
    }
    function cleanupTestCase(){console.log("NATIVE_LETTERS_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,speeds:checked}));}
}
