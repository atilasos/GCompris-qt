// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    id: inputCase
    name: "NumPadConsumer_decimals"
    when: items.numberOfLevel > 0 && activity.visible
    property int homeCalls: 0
    QtObject { id: navigationBoundary; function home() { inputCase.homeCalls++; } }
    function initTestCase() {
        wait(1000);
        tutorialSection.visible = false;
        tutorialSection.skipPressed();
        verify(activity.isAdditionMode || activity.isSubtractionMode);
        Activity.calculateCorrectAnswer();
        var model = activity.isSubtractionMode ? items.largestNumberRepresentation : items.droppedItems;
        var squares = Math.round(Activity.correctAnswer * 10);
        model.clear();
        while(squares > 0) { var units=Math.min(10,squares); model.append({selectedSquareNumbers:units}); squares-=units; }
        Activity.verifyNumberRepresentation();
        tryCompare(items, "typeResult", true);
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
    function test_portuguese_decimal_separator() {
        compare(numpad.decimalPoint, ",");
        verify(numpad.displayDecimalButton);
        numpad.answer = "5";
        keyClick(Qt.Key_Comma);
        compare(numpad.answer, "5,");
        keyClick(Qt.Key_2);
        compare(numpad.answer, "5,2");
        keyClick(Qt.Key_Backspace);
        console.log("NUMPAD_DECIMAL", JSON.stringify({answer:numpad.answer}));
        compare(numpad.answer, "5,");
        numpad.answer = "5";
        keyClick(Qt.Key_Period);
        compare(numpad.answer, "5,", "A dot is normalised to the PT comma");
    }
    function cleanupTestCase() {
        console.log("NATIVE_RESULT", JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,homeCalls:homeCalls}));
    }
}
