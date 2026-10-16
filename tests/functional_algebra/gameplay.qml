// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "ArithmeticGameplay"
    when: items.numberOfLevel > 0 && activity.visible
    property var expected: __ARITHMETIC_ORACLE__
    property int correct: 0
    property int rejected: 0
    property int completed: 0
    property string operation: activity.activityInfo.name.split("/")[0]
    function typeAnswer(text, virtualKeys) {
        activityBackground.forceActiveFocus();
        for(var i = 0; i < text.length; i++) {
            var digit = Number(text[i]);
            if(virtualKeys) {
                var panel = digit < 5 ? numpad.leftPanelComponent : numpad.rightPanelComponent;
                mouseClick(panel.children[digit % 5]);
            } else {
                keyClick(Qt.Key_0 + digit);
            }
            compare(numpad.answer, text.slice(0, i + 1), "Each input appends one digit");
        }
    }
    function answerForDisplay() {
        var key = Number(firstOp.text) + ":" + Number(secondOp.text);
        verify(expected[operation][key] !== undefined, "Displayed operands have an independent reference: " + key);
        return String(expected[operation][key]);
    }
    function test_all_levels() {
        ApplicationSettings.isVirtualKeyboard = true;
        wait(1600);
        var levels = operation === "algebra_plus" || operation === "algebra_minus" ? 13 : 11;
        compare(items.numberOfLevel, levels);
        compare(operand.text, {algebra_plus:"+", algebra_minus:"\u2212", algebra_by:"\u00d7", algebra_div:"\u2215"}[operation]);
        for(var level = 0; level < levels; level++) {
            compare(items.currentLevel, level);
            verify(iAmReady.visible);
            mouseClick(iAmReady);
            tryCompare(items, "buttonsBlocked", false);
            var wrong = answerForDisplay() === "0" ? "1" : "0";
            typeAnswer(wrong, false);
            mouseClick(okButton);
            compare(score.currentSubLevel, 0, "Wrong answer must not score");
            verify(items.buttonsBlocked);
            rejected++;
            tryCompare(items, "buttonsBlocked", false, 6000);
            for(var question = 0; question < score.numberOfSubLevels; question++) {
                compare(score.currentSubLevel, question);
                compare(numpad.answer, "");
                var answer = answerForDisplay();
                typeAnswer(answer, question % 2 === 1);
                if(question === 0) {
                    keyClick(Qt.Key_Backspace);
                    compare(numpad.answer, answer.slice(0, -1));
                    keyClick(Qt.Key_0 + Number(answer[answer.length - 1]));
                    compare(numpad.answer, answer);
                }
                if(question % 2) keyClick(Qt.Key_Return);
                else mouseClick(okButton);
                compare(score.currentSubLevel, question + 1);
                verify(items.buttonsBlocked);
                correct++;
                if(question + 1 < score.numberOfSubLevels)
                    tryCompare(items, "buttonsBlocked", false, 6000);
                else {
                    tryCompare(items, "currentLevel", (level + 1) % levels, 10000);
                    tryCompare(iAmReady, "visible", true);
                }
            }
            completed++;
        }
        compare(correct, levels * 10);
        compare(rejected, levels);
    }
    function cleanupTestCase() {
        console.log("NATIVE_ALGEBRA_RESULT", JSON.stringify({
            failures: qtest_results.failCount, passes: qtest_results.passCount,
            activity: operation, correct: correct, rejected: rejected, levels: completed
        }));
    }
}
