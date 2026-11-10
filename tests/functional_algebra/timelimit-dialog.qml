// SPDX-License-Identifier: GPL-3.0-or-later
// Toggle the time limit through the real configuration dialog, save it and
// reopen the dialog, which reloads the saved configuration through the same
// getInitialConfiguration() path used when the activity is created.
TestCase {
    name: "ArithmeticTimeLimitDialog"
    when: items.numberOfLevel > 0 && activity.visible
    property int timeouts: 0
    property var evidence: ({})
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
    function clickItem(item) {
        verify(item !== undefined && item !== null);
        mouseClick(item, item.width / 2, item.height / 2, Qt.LeftButton, Qt.NoModifier, 5);
    }
    function openConfig() {
        wait(150);
        clickItem(descendants(bar).find(child => child.source !== undefined && String(child.source).endsWith("bar_activity_config.svg") && child.visible));
        tryCompare(dialogActivityConfig, "visible", true, 2500);
        wait(500);
        var panel = descendants(dialogActivityConfig).find(child => child.noTimeLimitBox !== undefined);
        verify(panel !== undefined, "Activity configuration panel is loaded");
        compare(panel.noTimeLimitBox.text, "Sem limite de tempo");
        verify(panel.noTimeLimitBox.visible);
        return panel;
    }
    function dialogButton(text) {
        var button = descendants(dialogActivityConfig).find(child => child.clicked !== undefined && child.text === text && child.visible);
        verify(button !== undefined, "Dialog button " + text);
        return button;
    }
    function closeWith(text) {
        clickItem(dialogButton(text));
        tryCompare(dialogActivityConfig, "visible", false, 2500);
        wait(800);
    }
    function stored() {
        return ApplicationSettings.loadActivityConfiguration(dialogActivityConfig.activityName);
    }
    function test_toggle_save_and_reopen() {
        wait(1600);
        balloon.timeout.connect(countTimeout);
        compare(activity.timeLimit, "off");

        // Default dialog: no time limit, speed control disabled.
        var panel = openConfig();
        verify(panel.noTimeLimitBox.checked, "No time limit by default");
        verify(!panel.speedSlider.enabled, "Speed is disabled without time limit");
        verify(panel.speedSlider.opacity < 1);
        var hint = descendants(panel).find(child => child.text !== undefined && String(child.text).indexOf("rapidez de cálculo") >= 0);
        verify(hint !== undefined && hint.visible, "Hint about training calculation speed");
        evidence.hint = String(hint.text);
        grabImage(pageView).save("__QA_OUTPUT__/config-no-limit.png");

        // Turn the time limit on at the fastest speed of this slider.
        clickItem(panel.noTimeLimitBox);
        verify(!panel.noTimeLimitBox.checked);
        verify(panel.speedSlider.enabled, "Speed is enabled with a time limit");
        compare(panel.speedSlider.opacity, 1);
        var fastest = panel.speedSlider.to;
        compare(fastest, dialogActivityConfig.activityName === "algebra_by" ? 10 : 5);
        // Slider gestures are not exercised: set the value like a drag would.
        panel.speedSlider.value = fastest;
        grabImage(pageView).save("__QA_OUTPUT__/config-time-limit.png");
        closeWith("Gravar");
        compare(activity.timeLimit, "on");
        compare(activity.speedSetting, fastest);
        compare(String(stored().timeLimit), "on");
        compare(Number(stored().speedSetting), fastest);
        verify(iAmReady.visible, "Saving restarts the activity");

        // The countdown runs and expires inside a known window.
        var limitMs = Math.floor(100000 / fastest);
        var windowMs = limitMs + 1000 + 3000;
        mouseClick(iAmReady);
        compare(balloon.duration, limitMs);
        verify(balloon.visible);
        var y = balloon.y;
        wait(2000);
        verify(balloon.y !== y, "Balloon falls with a time limit");
        var started = Date.now();
        tryVerify(function() { return timeouts === 1; }, windowMs, "Timeout with a time limit");
        evidence.on = {speed: fastest, durationMs: balloon.duration, windowMs: windowMs, timeoutAfterMs: Date.now() - started + 2000, timeouts: timeouts};
        tryVerify(function() { return !bonus.isPlaying; }, 10000);
        tryCompare(items, "buttonsBlocked", false, 3000);

        // Reopen: the saved "on" is shown; switch back to no time limit.
        panel = openConfig();
        verify(!panel.noTimeLimitBox.checked, "Saved time limit is shown after reopening");
        compare(panel.speedSlider.value, fastest);
        verify(panel.speedSlider.enabled);
        clickItem(panel.noTimeLimitBox);
        verify(panel.noTimeLimitBox.checked);
        verify(!panel.speedSlider.enabled);
        closeWith("Gravar");
        compare(activity.timeLimit, "off");
        compare(String(stored().timeLimit), "off");
        compare(Number(stored().speedSetting), fastest, "The chosen speed is kept for later");
        verify(iAmReady.visible);

        // Same window as above: nothing moves and no timeout. The previous
        // countdown may have expired again while the dialog was open.
        var timeoutsBefore = timeouts;
        mouseClick(iAmReady);
        tryCompare(items, "buttonsBlocked", false);
        for(var elapsed = 0; elapsed <= windowMs; elapsed += 500) {
            wait(500);
            // Resting place above the screen, as before the first question.
            compare(balloon.y, -balloon.height);
            compare(balloon.rotation, 0);
            verify(!balloon.visible);
            compare(timeouts, timeoutsBefore, "No timeout without time limit");
            verify(!bonus.isPlaying);
        }
        var before = score.currentSubLevel;
        activityBackground.forceActiveFocus();
        var answer = String(items.result);
        for(var i = 0; i < answer.length; i++) keyClick(Qt.Key_0 + Number(answer[i]));
        keyClick(Qt.Key_Return);
        compare(score.currentSubLevel, before + 1, "Answer accepted after the same window");
        evidence.off = {waitedMs: elapsed, timeoutsDuringWindow: timeouts - timeoutsBefore, accepted: true};

        // Reopen again: "off" was persisted; cancel keeps it.
        tryCompare(items, "buttonsBlocked", false, 6000);
        panel = openConfig();
        verify(panel.noTimeLimitBox.checked, "Saved no-limit is shown after reopening");
        compare(panel.speedSlider.value, fastest);
        verify(!panel.speedSlider.enabled);
        grabImage(pageView).save("__QA_OUTPUT__/config-reopened.png");
        closeWith("Cancelar");
        compare(activity.timeLimit, "off");
        evidence.reopened = {timeLimit: String(stored().timeLimit), speedSetting: Number(stored().speedSetting)};
        balloon.timeout.disconnect(countTimeout);
    }
    function cleanupTestCase() {
        if(qtest_results.failCount) grabImage(pageView).save("__QA_OUTPUT__/failure.png");
        console.log("NATIVE_ALGEBRA_RESULT", JSON.stringify({
            failures: qtest_results.failCount, passes: qtest_results.passCount,
            activity: activity.activityInfo.name, evidence: evidence
        }));
    }
}
