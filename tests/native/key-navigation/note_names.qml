// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    id: keyCase
    name: "SingleKeyboardMovement_note_names"
    when: items.numberOfLevel > 0
    property int homeCalls: 0
    QtObject { id: navigationBoundary; function home() { keyCase.homeCalls++; } }
    function test_one_arrow_moves_once_and_escape_reaches_menu() {
        wait(1200);
        if(audioNeededDialog.active) { audioNeededDialog.item.stop(); tryCompare(activityBackground, "audioDisabled", false, 2000); }
        activityBackground.forceActiveFocus();
        introMessage.index = -1; iAmReady.visible = false; Activity.startGame(); messageBox.visible = false; doubleOctave.currentOctaveNb = 0; verify(multipleStaff.musicElementModel.count > 1); verify(shiftKeyboardRight.visible);
        compare(doubleOctave.currentOctaveNb, 0);
        keyClick(Qt.Key_Right);
        console.log("KEY_OBSERVATION", JSON.stringify({afterRight: doubleOctave.currentOctaveNb}));
        compare(doubleOctave.currentOctaveNb, 1, "One arrow advances exactly one position");
        keyClick(Qt.Key_Left);
        console.log("KEY_LEFT_OBSERVATION", JSON.stringify({afterLeft: doubleOctave.currentOctaveNb}));
        compare(doubleOctave.currentOctaveNb, 0, "One left arrow returns exactly one position");
        var originalMenu = activity.menu;
        activity.menu = navigationBoundary;
        try { keyClick(Qt.Key_Escape); console.log("KEY_ESCAPE_OBSERVATION", JSON.stringify({homeCalls:homeCalls})); compare(homeCalls, 1, "Escape reaches menu.home exactly once"); }
        finally { activity.menu = originalMenu; }
    }
    function cleanupTestCase() {
        console.log("NATIVE_RESULT", JSON.stringify({failures: qtest_results.failCount, passes: qtest_results.passCount, menuCalls: homeCalls}));
    }
}
