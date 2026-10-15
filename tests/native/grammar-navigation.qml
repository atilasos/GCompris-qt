// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "PortugueseGrammarNavigation"
    when: items.numberOfLevel > 0
    property bool navigationPassed: false
    function test_keyboard_events_are_consumed_once() {
        wait(1800);
        activityBackground.forceActiveFocus();
        keyClick(Qt.Key_Return);
        tryCompare(tutorialScreen, "visible", false);
        compare(items.selectedClass, 0);
        keyClick(Qt.Key_Right);
        compare(items.selectedClass, 1, "A right arrow selects exactly the next class");
        keyClick(Qt.Key_Left);
        compare(items.selectedClass, 0);
        keyClick(Qt.Key_Tab);
        compare(items.keysOnTokens, false);
        keyClick(Qt.Key_Right);
        compare(items.selectedBox, 1);
        keyClick(Qt.Key_Backspace);
        compare(items.selectedBox, 0);
        keyClick(Qt.Key_Up);
        compare(items.keysOnTokens, true);
        keyClick(Qt.Key_Down);
        compare(items.keysOnTokens, false);
        keyClick(Qt.Key_Tab);
        compare(items.keysOnTokens, true);
        keyClick(Qt.Key_Space);
        tryVerify(function() { return !Activity.animRunning; }, 2000);
        compare(items.selectedBox, 1, "Space assigns one box and moves once");
        compare(items.currentExercise, 0);
        // Return every box to empty so the wrong-answer assertion is independent
        // of the randomly selected sentence and its first grammatical class.
        while (items.selectedClass !== items.goalModel.count - 1)
            keyClick(Qt.Key_Right);
        keyClick(Qt.Key_Tab);
        keyClick(Qt.Key_Backspace);
        compare(items.selectedBox, 0);
        keyClick(Qt.Key_Tab);
        keyClick(Qt.Key_Space);
        tryVerify(function() { return !Activity.animRunning; }, 2000);
        keyClick(Qt.Key_Return);
        compare(items.currentExercise, 0, "An incomplete keyboard answer is rejected");
        verify(items.errorRectangle.errorAnimation.running);
        navigationPassed = true;
        grabImage(activityBackground).save("__QA_OUTPUT__/keyboard.png");
    }
    function cleanupTestCase() {
        console.log("NATIVE_GRAMMAR_NAVIGATION", JSON.stringify({
            failures: qtest_results.failCount, passes: qtest_results.passCount,
            navigationPassed: navigationPassed
        }));
    }
}
