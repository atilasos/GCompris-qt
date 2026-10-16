// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    id: inputCase
    name: "NumPadConsumer_tens"
    when: items.numberOfLevel > 0 && activity.visible
    property int homeCalls: 0
    QtObject { id: navigationBoundary; function home() { inputCase.homeCalls++; } }
    function initTestCase() {
        wait(1000);
        compare(activity.mode, "input");
        var row = items.equations.get(0).listmodel;
        Activity.selectCard({rowNumber:0,columnNumber:row.count-1,type:"inputCard"});
        verify(numPad.enableInput);
    }
    function init() {
        numPad.answer = "";
        activityBackground.forceActiveFocus();
    }
    function test_digit_is_inserted_once() {
        keyClick(Qt.Key_5);
        console.log("NUMnumPad_DIGIT", JSON.stringify({answer:numPad.answer}));
        compare(numPad.answer, "5");
        keyClick(Qt.Key_2);
        compare(numPad.answer, "52");
    }
    function test_backspace_deletes_one_digit() {
        numPad.answer = "52";
        keyClick(Qt.Key_Backspace);
        console.log("NUMnumPad_BACKSPACE", JSON.stringify({answer:numPad.answer}));
        compare(numPad.answer, "5");
    }
    function test_unknown_key_and_global_shortcuts_propagate() {
        numPad.answer = "5";
        keyClick(Qt.Key_A);
        compare(numPad.answer, "5");
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
