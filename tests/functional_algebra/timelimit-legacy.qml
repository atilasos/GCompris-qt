// SPDX-License-Identifier: GPL-3.0-or-later
// A configuration saved before the option existed has only speedSetting: it
// keeps the countdown chosen by the teacher (balloon.duration == 100000/speed).
// Needs a fresh profile: saving never removes a key.
TestCase {
    name: "ArithmeticLegacySpeedKeepsTimeLimit"
    when: items.numberOfLevel > 0 && activity.visible
    readonly property int legacySpeed: 3
    property var evidence: ({})
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
    function stored() {
        return ApplicationSettings.loadActivityConfiguration(dialogActivityConfig.activityName);
    }
    function checkCountdown(label) {
        verify(iAmReady.visible, label);
        mouseClick(iAmReady);
        compare(balloon.duration, Math.floor(100000 / legacySpeed), label + ": duration");
        verify(balloon.visible, label + ": balloon shown");
        var y = balloon.y;
        wait(2500);
        verify(balloon.y !== y, label + ": balloon falls");
        return {duration: balloon.duration, yBefore: y, yAfter: balloon.y};
    }
    function test_legacy_speed_setting() {
        wait(1600);
        compare(activity.timeLimit, "off");
        var name = dialogActivityConfig.activityName;
        verify(stored().timeLimit === undefined && stored().speedSetting === undefined, "Fresh profile");
        ApplicationSettings.saveActivityConfiguration(name, {"speedSetting": legacySpeed});
        verify(stored().timeLimit === undefined, "Legacy configuration has no timeLimit key");
        compare(Number(stored().speedSetting), legacySpeed);

        // Reload it with the dialog loader function called on activity creation.
        var loader = descendants(dialogActivityConfig).find(child => child.getInitialConfiguration !== undefined && child.initializePanel !== undefined);
        verify(loader !== undefined, "Configuration loader found");
        loader.initializePanel();
        compare(activity.speedSetting, legacySpeed);
        compare(activity.timeLimit, "on", "Legacy speedSetting keeps the time limit");
        activityBackground.stop();
        activityBackground.start();
        evidence.loaded = checkCountdown("legacy load");

        // The real dialog shows it and saving makes the choice explicit.
        wait(150);
        clickItem(descendants(bar).find(child => child.source !== undefined && String(child.source).endsWith("bar_activity_config.svg") && child.visible));
        tryCompare(dialogActivityConfig, "visible", true, 2500);
        wait(500);
        var panel = descendants(dialogActivityConfig).find(child => child.noTimeLimitBox !== undefined);
        verify(panel !== undefined);
        verify(!panel.noTimeLimitBox.checked, "Legacy configuration shows the time limit on");
        verify(panel.speedSlider.enabled);
        compare(panel.speedSlider.value, legacySpeed);
        grabImage(pageView).save("__QA_OUTPUT__/config-legacy.png");
        clickItem(descendants(dialogActivityConfig).find(child => child.clicked !== undefined && child.text === "Gravar" && child.visible));
        tryCompare(dialogActivityConfig, "visible", false, 2500);
        wait(800);
        compare(String(stored().timeLimit), "on");
        compare(Number(stored().speedSetting), legacySpeed);
        evidence.saved = checkCountdown("after saving");
        evidence.stored = {timeLimit: String(stored().timeLimit), speedSetting: Number(stored().speedSetting)};
    }
    function cleanupTestCase() {
        if(qtest_results.failCount) grabImage(pageView).save("__QA_OUTPUT__/failure.png");
        console.log("NATIVE_ALGEBRA_RESULT", JSON.stringify({
            failures: qtest_results.failCount, passes: qtest_results.passCount,
            activity: activity.activityInfo.name, legacySpeed: legacySpeed, evidence: evidence
        }));
    }
}
