// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    id: keyCase
    name: "SingleKeyboardMovement_binary_bulb"
    when: items.numberOfLevel > 0
    property int homeCalls: 0
    QtObject { id: navigationBoundary; function home() { keyCase.homeCalls++; } }
    function test_one_arrow_moves_once_and_escape_reaches_menu() {
        wait(1200);
        activityBackground.forceActiveFocus();
        tutorialSection.visible = false; tutorialSection.skipPressed(); wait(300); items.currentSelectedBulb = 0;
        compare(items.currentSelectedBulb, 0);
        keyClick(Qt.Key_Right);
        console.log("KEY_OBSERVATION", JSON.stringify({afterRight: items.currentSelectedBulb}));
        compare(items.currentSelectedBulb, 1, "One arrow advances exactly one position");
        keyClick(Qt.Key_Left);
        compare(items.currentSelectedBulb, 0, "One left arrow returns exactly one position");
        var originalMenu = activity.menu;
        activity.menu = navigationBoundary;
        try { keyClick(Qt.Key_Escape); compare(homeCalls, 1, "Escape reaches menu.home exactly once"); }
        finally { activity.menu = originalMenu; }
    }
    function cleanupTestCase() {
        console.log("NATIVE_RESULT", JSON.stringify({failures: qtest_results.failCount, passes: qtest_results.passCount, menuCalls: homeCalls}));
    }
}
