TestCase {
    name: "MultipleChoiceAllLevels"
    when: items.numberOfLevel > 0
    property int solved: 0
    property int rejected: 0
    property int completedLevels: 0
    property bool restarted: false
    property string phase: "initialization"

    function checkpoint(label) {
        phase = label;
        console.log("NATIVE_SEQUENCE_STEP", label, items.currentLevel, items.currentSubLevel, items.instruction.text);
    }
    function correctWords(question) {
        if (question.indexOf("imediatamente") !== -1) return ["3"];
        if (question.indexOf("uma cor") !== -1) return ["amarelo"];
        if (question.indexOf("menores") !== -1) return ["1", "2"];
        if (question.indexOf("animais") !== -1) return ["gato", "cão"];
        if (question.indexOf("triângulo") !== -1) return ["3"];
        fail("Unexpected or untranslated question: " + question);
    }
    function selectWords(words) {
        for (var i = 0; i < items.answerModel.count; ++i) {
            var row = items.answerModel.get(i);
            var want = words.indexOf(row.content_) !== -1;
            if (row.checked_ !== want) mouseClick(answerList.itemAtIndex(i));
        }
    }
    function barButton(node, suffix) {
        if (typeof node.clicked === "function" && String(node.source).indexOf(suffix) !== -1) return node;
        if (!node.children) return null;
        for (var index = 0; index < node.children.length; ++index) {
            var found = barButton(node.children[index], suffix);
            if (found) return found;
        }
        return null;
    }
    function navigation() {
        var next = barButton(bar, "bar_next.svg");
        var previous = barButton(bar, "bar_previous.svg");
        verify(next !== null && previous !== null);
        mouseClick(next);
        compare(items.currentLevel, 1);
        mouseClick(previous);
        compare(items.currentLevel, 0);
        mouseClick(previous);
        compare(items.currentLevel, 2);
        mouseClick(next);
        compare(items.currentLevel, 0);
    }
    function test_complete_every_question_and_level() {
        wait(1500);
        compare(items.numberOfLevel, 3);
        var seen = {};
        for (var level = 0; level < 3; ++level) {
            compare(items.currentLevel, level);
            compare(items.numberOfSubLevel, level === 2 ? 1 : 2);
            for (var sub = 0; sub < (level === 2 ? 1 : 2); ++sub) {
                checkpoint("wrong-answer");
                compare(items.currentSubLevel, sub);
                tryCompare(items, "buttonsBlocked", false, 5000);
                tryCompare(score, "isWinAnimationPlaying", false, 5000);
                var question = items.instruction.text;
                verify(!seen[question]);
                var correct = correctWords(question);
                var wrong = [];
                for (var index = 0; index < items.answerModel.count; ++index) {
                    var content = items.answerModel.get(index).content_;
                    if (correct.indexOf(content) === -1) { wrong = [content]; break; }
                }
                compare(wrong.length, 1);
                if (level === 2) {
                    // This fixed-order question also exercises keyboard selection/validation.
                    activityBackground.forceActiveFocus();
                    keyClick(Qt.Key_Down);
                    keyClick(Qt.Key_Space);
                    compare(items.currentAnswerIndex, 0);
                    keyClick(Qt.Key_Return);
                } else {
                    selectWords(wrong);
                    mouseClick(okButton);
                }
                compare(feedbackArea.isCorrectAnswer, false);
                compare(items.score.currentSubLevel, sub);
                if (level !== 2) {
                    compare(feedbackArea.visible, true);
                    grabImage(activityBackground).save("__QA_OUTPUT__/level-" + (level + 1) + "-wrong-" + sub + ".png");
                    mouseClick(closeFeedbackClick);
                    compare(feedbackArea.visible, false);
                }
                tryCompare(items, "buttonsBlocked", false, 5000);
                compare(items.currentSubLevel, sub);
                rejected++;

                checkpoint("correct-answer");
                selectWords(correct);
                mouseClick(okButton);
                compare(feedbackArea.isCorrectAnswer, true);
                compare(items.score.currentSubLevel, sub + 1);
                grabImage(activityBackground).save("__QA_OUTPUT__/level-" + (level + 1) + "-correct-" + sub + ".png");
                solved++;
                seen[question] = true;
                if (level !== 2) {
                    compare(feedbackArea.visible, true);
                    tryCompare(score, "isWinAnimationPlaying", false, 5000);
                    // Correct explanatory feedback must not advance until it is closed.
                    compare(items.currentSubLevel, sub);
                    mouseClick(closeFeedbackClick);
                } else {
                    compare(feedbackArea.visible, false);
                }
                if (sub + 1 < (level === 2 ? 1 : 2)) {
                    tryCompare(items, "currentSubLevel", sub + 1, 6000);
                } else {
                    tryCompare(items, "currentLevel", (level + 1) % 3, 8000);
                    completedLevels++;
                }
            }
        }
        checkpoint("restart");
        compare(solved, 5);
        compare(rejected, 5);
        compare(completedLevels, 3);
        compare(Object.keys(seen).length, 5);
        activityBackground.stop();
        activityBackground.start();
        compare(items.currentLevel, 0);
        compare(items.currentSubLevel, 0);
        compare(items.score.currentSubLevel, 0);
        for (var row = 0; row < items.answerModel.count; ++row) compare(items.answerModel.get(row).checked_, false);
        restarted = true;
        checkpoint("navigation");
        navigation();
        grabImage(activityBackground).save("__QA_OUTPUT__/restart.png");
    }
    function cleanupTestCase() {
        grabImage(activityBackground).save("__QA_OUTPUT__/final.png");
        console.log("NATIVE_SEQUENCE_RESULT", JSON.stringify({failures:qtest_results.failCount, passes:qtest_results.passCount,
            solved:solved, rejected:rejected, completedLevels:completedLevels, restarted:restarted, phase:phase}));
    }
}
