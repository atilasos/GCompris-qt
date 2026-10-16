// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    id: keyCase
    name: "SingleKeyboardMovement_money"
    when: items.numberOfLevel > 0
    property int homeCalls: 0
    QtObject { id: navigationBoundary; function home() { keyCase.homeCalls++; } }
    function test_one_arrow_moves_once_and_escape_reaches_menu() {
        wait(1200);
        activityBackground.forceActiveFocus();
        items.selectedArea = items.pocket; items.itemIndex = 0; console.log("KEY_FIXTURE", JSON.stringify({coins:items.pocket.count})); verify(items.pocket.count >= 2);
        compare(items.itemIndex, 0);
        keyClick(Qt.Key_Right);
        console.log("KEY_OBSERVATION", JSON.stringify({afterRight: items.itemIndex}));
        compare(items.itemIndex, 1, "One arrow advances exactly one position");
        keyClick(Qt.Key_Left);
        compare(items.itemIndex, 0, "One left arrow returns exactly one position");
        var originalMenu = activity.menu;
        activity.menu = navigationBoundary;
        try { keyClick(Qt.Key_Escape); compare(homeCalls, 1, "Escape reaches menu.home exactly once"); }
        finally { activity.menu = originalMenu; }
    }
    function cleanupTestCase() {
        console.log("NATIVE_RESULT", JSON.stringify({failures: qtest_results.failCount, passes: qtest_results.passCount, menuCalls: homeCalls}));
    }
}
