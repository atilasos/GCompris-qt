// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "VirtualKeypadInputLock"
    when: items.numberOfLevel > 0 && activity.visible
    property int blockedDigits: 0
    property int activeDigits: 0
    function button(digit) {
        var panel = digit < 5 ? numpad.leftPanelComponent : numpad.rightPanelComponent;
        return panel.children[digit % 5];
    }
    function initTestCase() {
        wait(1600);
        ApplicationSettings.isVirtualKeyboard = true;
        wait(200);
    }
    function test_all_digit_buttons_obey_input_lock() {
        numpad.enableInput = false;
        for(var digit = 0; digit <= 9; digit++) {
            numpad.answer = "1";
            mouseClick(button(digit));
            compare(numpad.answer, "1", "Disabled digit " + digit + " must not append");
            blockedDigits++;
        }
        numpad.answer = "12";
        mouseClick(numpad.backspaceButtonComponent);
        compare(numpad.answer, "12", "Disabled Backspace must not delete");
    }
    function test_enabled_buttons_still_work() {
        numpad.enableInput = true;
        for(var digit = 0; digit <= 9; digit++) {
            numpad.answer = "";
            mouseClick(button(digit));
            compare(numpad.answer, String(digit));
            activeDigits++;
        }
        numpad.answer = "12";
        mouseClick(numpad.backspaceButtonComponent);
        compare(numpad.answer, "1");
    }
    function cleanupTestCase() {
        console.log("NATIVE_NUMPAD_LOCK_RESULT", JSON.stringify({
            failures:qtest_results.failCount, passes:qtest_results.passCount,
            blockedDigits:blockedDigits, activeDigits:activeDigits
        }));
    }
}
