// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "ArithmeticSpeedsAndTimeout"
    when: items.numberOfLevel > 0 && activity.visible
    property var speeds: []
    property bool recovered: false
    function test_speeds_restart_and_timeout() {
        wait(1600);
        for(var speed = 1; speed <= 10; speed++) {
            activityBackground.stop();
            activity.speedSetting = speed;
            activityBackground.start();
            verify(iAmReady.visible);
            compare(score.currentSubLevel, 0);
            mouseClick(iAmReady);
            compare(balloon.duration, Math.floor(100000 / speed));
            keyClick(Qt.Key_5);
            compare(numpad.answer, "5");
            speeds.push({speed: speed, duration: balloon.duration});
        }
        // Restart an unfinished answer through the actual lifecycle.
        activityBackground.stop();
        activityBackground.start();
        verify(iAmReady.visible);
        mouseClick(iAmReady);
        compare(numpad.answer, "");
        compare(score.currentSubLevel, 0);
        var timedOut = false;
        function recordTimeout() { timedOut = true; }
        balloon.timeout.connect(recordTimeout);
        // Wait for the real 10 second animation. Do not emit timeout or move it.
        tryVerify(function() { return timedOut; }, 16000);
        tryVerify(function() { return !bonus.isPlaying; }, 10000);
        compare(score.currentSubLevel, 0);
        tryCompare(items, "buttonsBlocked", false);
        compare(numpad.answer, "");
        keyClick(Qt.Key_5);
        compare(numpad.answer, "5");
        recovered = true;
        balloon.timeout.disconnect(recordTimeout);
    }
    function cleanupTestCase() {
        console.log("NATIVE_ALGEBRA_RESULT", JSON.stringify({
            failures: qtest_results.failCount, passes: qtest_results.passCount,
            speeds: speeds, recoveredAfterTimeout: recovered
        }));
    }
}
