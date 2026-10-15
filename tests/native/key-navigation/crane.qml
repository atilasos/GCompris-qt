// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    id: keyCase
    name: "SingleKeyboardMovement_crane"
    when: items.numberOfLevel > 0
    property int homeCalls: 0
    QtObject { id: navigationBoundary; function home() { keyCase.homeCalls++; } }
    function test_one_arrow_moves_once_and_escape_reaches_menu() {
        wait(1200);
        activityBackground.forceActiveFocus();
        var pieces = [];
        for(var i = 0; i < items.answerRepeater.count; i++) {
            var piece = items.answerRepeater.itemAt(i);
            if(piece.initialIndex >= 0) pieces.push({identity: piece.initialIndex, slot: i});
        }
        pieces.sort(function(a, b) { return a.identity - b.identity; });
        verify(pieces.length >= 2);
        items.selected = pieces[0].slot;
        keyClick(Qt.Key_Tab);
        console.log("KEY_OBSERVATION", JSON.stringify({afterTab:items.selected, expected:pieces[1].slot}));
        compare(items.selected, pieces[1].slot, "One Tab chooses exactly the next piece");
        var originalMenu = activity.menu;
        activity.menu = navigationBoundary;
        try { keyClick(Qt.Key_Escape); compare(homeCalls, 1, "Escape reaches menu.home exactly once"); }
        finally { activity.menu = originalMenu; }
    }
    function cleanupTestCase() {
        console.log("NATIVE_RESULT", JSON.stringify({failures: qtest_results.failCount, passes: qtest_results.passCount, menuCalls: homeCalls}));
    }
}
