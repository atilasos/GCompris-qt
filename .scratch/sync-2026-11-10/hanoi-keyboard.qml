TestCase {
    name: "UpstreamHanoiKeyboard"
    when: activity.visible && items.numberOfDisc > 0
    function test_keyboard_move() {
        try {
        wait(1600);
        activity.forceActiveFocus();
        keyClick(Qt.Key_Space);
        console.log("STATE",items.keyboardControls,items.columnCursorIndex,items.selectedDisc);
        verify(items.keyboardControls);
        compare(items.columnCursorIndex, 0);
        keyClick(Qt.Key_Space);
        console.log("STATE",items.keyboardControls,items.columnCursorIndex,items.selectedDisc);
        verify(items.selectedDisc !== null);
        var disc = items.selectedDisc;
        var original = disc.towerImage;
        keyClick(Qt.Key_Right);
        compare(items.columnCursorIndex, 1);
        grabImage(activityBackground).save("__QA_OUTPUT__/keyboard.png");
        keyClick(Qt.Key_Return);
        verify(disc.towerImage !== original);
        compare(disc.towerImage, items.towerModel.itemAt(1));
        compare(items.selectedDisc, null);
        } catch(error) { console.log("KEYBOARD_FAILURE", String(error), new Error().stack); throw error; }
    }
    function cleanupTestCase() {
        console.log("NATIVE_RESULT", JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount}));
    }
}
