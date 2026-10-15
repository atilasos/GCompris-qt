// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    id: inputCase
    name: "InactiveNumPad_swap"
    when: items.numberOfLevel > 0 && activity.visible
    property int homeCalls: 0
    QtObject { id: navigationBoundary; function home() { inputCase.homeCalls++; } }
    function test_inactive_pad_and_shortcuts() {
        wait(1000);
        compare(activity.mode, "swap");
        numPad.answer = "";
        activityBackground.forceActiveFocus();
        keyClick(Qt.Key_5);
        compare(numPad.answer, "", "No digit is entered in this phase");
        numPad.answer = "52";
        keyClick(Qt.Key_Backspace);
        compare(numPad.answer, "52", "Inactive numerical editing is ignored");
        var originalMenu=activity.menu;
        activity.menu=navigationBoundary;
        try {
            keyClick(Qt.Key_W, Qt.ControlModifier); compare(homeCalls, 1);
            keyClick(Qt.Key_Escape); compare(homeCalls, 2);
        } finally { activity.menu=originalMenu; }
    }
    function cleanupTestCase() {
        console.log("NATIVE_RESULT", JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,homeCalls:homeCalls}));
    }
}
