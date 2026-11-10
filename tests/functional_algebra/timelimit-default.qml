// SPDX-License-Identifier: GPL-3.0-or-later
// Without a saved configuration there is no time limit: answers are accepted
// after more than the old 20 s countdown (speed 5 + 1 s rise), on the first
// question, after a previous right or wrong answer and after window resizes.
TestCase {
    name: "ArithmeticNoTimeLimitByDefault"
    when: items.numberOfLevel > 0 && activity.visible
    // Old default: 100000 / 5 ms falling plus the 1000 ms rise animation.
    readonly property int oldTimeout: 100000 / 5 + 1000
    property int timeouts: 0
    property var evidence: ({questions: []})
    function countTimeout() { timeouts++; }
    function descendants(item) {
        var found = [], stack = [item];
        while(stack.length) {
            var child = stack.pop();
            found.push(child);
            if(child.children)
                for(var i = 0; i < child.children.length; i++) stack.push(child.children[i]);
        }
        return found;
    }
    function findButton(item, suffix) {
        return descendants(item).find(child => child.source !== undefined && String(child.source).endsWith(suffix) && child.visible);
    }
    function typeAnswer(text) {
        activityBackground.forceActiveFocus();
        for(var i = 0; i < text.length; i++) keyClick(Qt.Key_0 + Number(text[i]));
        compare(numpad.answer, text);
    }
    function checked(condition, message) {
        if(!condition)
            console.log("NATIVE_ALGEBRA_FAILURE", message, JSON.stringify({y: balloon.y, height: balloon.height,
                rotation: balloon.rotation, timeouts: timeouts, bonus: bonus.isPlaying, blocked: items.buttonsBlocked,
                visible: balloon.visible, parentHeight: balloon.parentHeight}));
        verify(condition, message);
    }
    // Wait longer than the old countdown and prove the balloon never left its
    // resting place above the screen (y follows -height when the size changes).
    function waitBeyondOldTimeout(label, resize) {
        var height = balloon.parentHeight;
        var resized = false;
        for(var elapsed = 0; elapsed <= oldTimeout + 1000; elapsed += 500) {
            if(resize && !resized && elapsed >= 5000) {
                var win = activity.Window.window;
                win.width = Math.round(win.width * 0.8);
                win.height = Math.round(win.height * 0.8);
                tryVerify(function() { return balloon.parentHeight !== height; }, 2000, "Resize reached the balloon");
                resized = true;
            }
            wait(500);
            checked(balloon.y === -balloon.height, label + ": balloon must not fall");
            checked(balloon.rotation === 0, label + ": balloon must not swing");
            checked(timeouts === 0, label + ": no timeout");
            checked(!bonus.isPlaying, label + ": no bonus while waiting");
            checked(!items.buttonsBlocked, label + ": answer still possible");
            checked(!balloon.visible, label + ": balloon hidden without time limit");
        }
        return {label: label, waitedMs: elapsed, resized: resized, parentHeightBefore: height, parentHeightAfter: balloon.parentHeight};
    }
    function answerRight(label) {
        var before = score.currentSubLevel;
        typeAnswer(String(items.result));
        mouseClick(okButton);
        compare(score.currentSubLevel, before + 1, label + ": right answer accepted");
        tryCompare(items, "buttonsBlocked", false, 6000);
        compare(timeouts, 0);
    }
    function test_no_time_limit_by_default() {
        wait(1600);
        balloon.timeout.connect(countTimeout);
        compare(activity.timeLimit, "off");
        var stored = ApplicationSettings.loadActivityConfiguration(dialogActivityConfig.activityName);
        verify(stored.timeLimit === undefined && stored.speedSetting === undefined, "Runner starts without saved configuration");
        checked(!balloon.visible, "hidden at start");
        checked(balloon.y === -balloon.height, "at rest at start");
        // Resize on the ready screen: upstream restarted the countdown here.
        var win = activity.Window.window;
        var size = {width: win.width, height: win.height};
        win.width = Math.round(size.width * 0.9);
        win.height = Math.round(size.height * 0.9);
        wait(300);
        mouseClick(iAmReady);
        tryCompare(items, "buttonsBlocked", false);
        evidence.questions.push(waitBeyondOldTimeout("first question", false));
        answerRight("first question");
        evidence.questions.push(waitBeyondOldTimeout("after a right answer", false));
        answerRight("after a right answer");
        evidence.questions.push(waitBeyondOldTimeout("with window resize", true));
        answerRight("with window resize");
        // Wrong answer goes through checkAnswer's other branch.
        var wrong = String(items.result + 1);
        var before = score.currentSubLevel;
        typeAnswer(wrong);
        mouseClick(okButton);
        compare(score.currentSubLevel, before);
        tryCompare(items, "buttonsBlocked", false, 6000);
        evidence.questions.push(waitBeyondOldTimeout("after a wrong answer", false));
        answerRight("after a wrong answer");
        win.width = size.width;
        win.height = size.height;
        wait(500);
        compare(timeouts, 0);
        evidence.timeouts = timeouts;
        evidence.score = score.currentSubLevel;
        balloon.timeout.disconnect(countTimeout);
        grabImage(pageView).save("__QA_OUTPUT__/game-no-limit.png");
    }
    function cleanupTestCase() {
        if(qtest_results.failCount) grabImage(pageView).save("__QA_OUTPUT__/failure.png");
        console.log("NATIVE_ALGEBRA_RESULT", JSON.stringify({
            failures: qtest_results.failCount, passes: qtest_results.passCount,
            activity: activity.activityInfo.name, oldTimeoutMs: oldTimeout, evidence: evidence
        }));
    }
}
