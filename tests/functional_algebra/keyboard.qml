// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "ArithmeticKeyboard"
    when: items.numberOfLevel > 0 && activity.visible
    property int typed: 0
    function test_one_key_is_one_digit() {
        wait(1600);
        mouseClick(iAmReady);
        compare(numpad.answer, "");
        activityBackground.forceActiveFocus();
        keyClick(Qt.Key_5);
        console.log("NATIVE_ALGEBRA_KEY", JSON.stringify({key:"5", displayed:resultText.text, answer:numpad.answer}));
        compare(numpad.answer, "5", "One physical key must enter one digit");
        typed++;
        keyClick(Qt.Key_2);
        compare(numpad.answer, "52");
        keyClick(Qt.Key_Backspace);
        compare(numpad.answer, "5", "Backspace must delete just the last digit");
    }
    function cleanupTestCase() {
        console.log("NATIVE_ALGEBRA_RESULT", JSON.stringify({
            failures: qtest_results.failCount, passes: qtest_results.passCount,
            typed: typed
        }));
    }
}
