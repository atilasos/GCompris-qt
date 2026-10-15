// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    id: keyCase
    name: "BabymatchSingleKeyboardMovement"
    when: items.numberOfLevel > 0 && !items.inputLocked
    property int homeCalls: 0
    QtObject { id: navigationBoundary; function home() { keyCase.homeCalls++; } }
    function test_one_arrow_moves_once_and_escape_reaches_menu() {
        wait(1200);
        activityBackground.forceActiveFocus();
        items.listFocus = true;
        availablePieces.repeater.currentIndex = -1;
        keyClick(Qt.Key_Right);
        console.log("KEY_OBSERVATION", JSON.stringify({afterFirstRight: availablePieces.repeater.currentIndex}));
        compare(availablePieces.repeater.currentIndex, 0, "One arrow selects the first piece, without skipping it");
        keyClick(Qt.Key_Right);
        compare(availablePieces.repeater.currentIndex, 1, "The next arrow advances one piece");
        var originalMenu = activity.menu;
        activity.menu = navigationBoundary;
        try { keyClick(Qt.Key_Escape); compare(homeCalls, 1, "Escape reaches menu.home exactly once"); }
        finally { activity.menu = originalMenu; }
    }
    function cleanupTestCase() {
        console.log("NATIVE_RESULT", JSON.stringify({failures: qtest_results.failCount, passes: qtest_results.passCount, menuCalls: homeCalls}));
    }
}
