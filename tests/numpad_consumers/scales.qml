// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    id: inputCase
    name: "NumPadConsumer_scales"
    when: items.numberOfLevel > 0 && activity.visible
    property int homeCalls: 0
    QtObject { id: navigationBoundary; function home() { inputCase.homeCalls++; } }
    function initTestCase() {
        wait(1000);
        var questionLevel = -1;
        for(var i = 0; i < items.levels.length; i++) if(items.levels[i].question) { questionLevel=i; break; }
        verify(questionLevel >= 0);
        items.currentLevel = questionLevel;
        Activity.initLevel();
        // The fixture supplies a balanced state; it does not solve the weighing puzzle.
        items.masseAreaLeft.weight = items.masseAreaRight.weight;
        tryCompare(question, "visible", true);
        verify(numpad.enableInput);
    }
    function init() {
        numpad.answer = "";
        activityBackground.forceActiveFocus();
    }
    function test_digit_is_inserted_once() {
        keyClick(Qt.Key_5);
        console.log("NUMnumpad_DIGIT", JSON.stringify({answer:numpad.answer}));
        compare(numpad.answer, "5");
        keyClick(Qt.Key_2);
        compare(numpad.answer, "52");
    }
    function test_backspace_deletes_one_digit() {
        numpad.answer = "52";
        keyClick(Qt.Key_Backspace);
        console.log("NUMnumpad_BACKSPACE", JSON.stringify({answer:numpad.answer}));
        compare(numpad.answer, "5");
    }
    function test_unknown_key_and_global_shortcuts_propagate() {
        numpad.answer = "5";
        keyClick(Qt.Key_A);
        compare(numpad.answer, "5");
        var originalMenu=activity.menu;
        activity.menu=navigationBoundary;
        try {
            keyClick(Qt.Key_W, Qt.ControlModifier);
            compare(homeCalls, 1, "Ctrl+W reaches the global menu shortcut");
            keyClick(Qt.Key_Escape);
            compare(homeCalls, 2, "Escape reaches the menu");
        } finally { activity.menu=originalMenu; }
    }
    
    function cleanupTestCase() {
        console.log("NATIVE_RESULT", JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,homeCalls:homeCalls}));
    }
}
