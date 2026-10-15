// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    id: keyCase
    name: "SingleKeyboardMovement_submarine"
    when: items.numberOfLevel > 0
    property int homeCalls: 0
    QtObject { id: navigationBoundary; function home() { keyCase.homeCalls++; } }
    function test_one_arrow_moves_once_and_escape_reaches_menu() {
        wait(1200);
        activityBackground.forceActiveFocus();
        tutorial.index = -1; tutorial.introDone(); submarine.currentFinalVelocity = 0;
        compare(submarine.currentFinalVelocity, 0);
        keyClick(Qt.Key_Right);
        console.log("KEY_OBSERVATION", JSON.stringify({afterRight: submarine.currentFinalVelocity}));
        compare(submarine.currentFinalVelocity, 1, "One arrow advances exactly one position");
        keyClick(Qt.Key_Left);
        compare(submarine.currentFinalVelocity, 0, "One left arrow returns exactly one position");
        var originalMenu = activity.menu;
        activity.menu = navigationBoundary;
        try {
            keyClick(Qt.Key_Escape); compare(homeCalls, 1, "Escape reaches menu.home exactly once");
            keyClick(Qt.Key_W, Qt.ControlModifier); compare(homeCalls, 2, "Ctrl+W remains a global exit shortcut");
        }
        finally { activity.menu = originalMenu; }
    }
    function cleanupTestCase() {
        console.log("NATIVE_RESULT", JSON.stringify({failures: qtest_results.failCount, passes: qtest_results.passCount, menuCalls: homeCalls}));
    }
}
