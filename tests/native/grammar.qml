// SPDX-License-Identifier: GPL-3.0-or-later
        TestCase {
            name: "PortugueseGrammarInteraction"
            when: items.numberOfLevel > 0
            property string stage: "initial"
            function equal(actual, expected, message) {
                if (actual !== expected)
                    console.error("NATIVE_GRAMMAR_ASSERT", JSON.stringify({stage: stage, actual: actual, expected: expected, message: message}));
                compare(actual, expected, message);
            }
            function checked(condition, message) {
                if (!condition) console.error("NATIVE_GRAMMAR_ASSERT", stage, message);
                verify(condition, message);
            }
            property int solved: 0
            property int wrongRejected: 0
            property int keyboardExercises: 0
            property int erased: 0
            property int completedLevels: 0
            property int mergedWords: 0

            function chooseToken(code, keyboard) {
                stage = "select " + code + " at box " + items.selectedBox + " tokensFocus=" + items.keysOnTokens;
                var target = -1;
                for (var i = 0; i < items.goalModel.count; i++) {
                    if (items.goalModel.get(i).code === (code === "_" ? "eraser" : code))
                        target = i;
                }
                checked(target >= 0, "Requested grammatical class is available: " + code);
                if (keyboard) {
                    activityBackground.forceActiveFocus();
                    var guard = items.goalModel.count;
                    while (items.selectedClass !== target && guard-- > 0) {
                        var before = items.selectedClass;
                        keyClick(Qt.Key_Right);
                        equal(items.selectedClass, (before + 1) % items.goalModel.count,
                              "One arrow key advances exactly one grammatical class");
                    }
                } else {
                    var token = items.gridGoalTokens.children[target];
                    mouseClick(token, token.width / 2, token.height / 2);
                }
                equal(items.selectedClass, target);
            }

            function assignBox(card, box, code, keyboard) {
                chooseToken(code, keyboard);
                if (keyboard) {
                    keyClick(Qt.Key_Space);
                } else {
                    var target = card.rowWords.children[box];
                    mouseClick(target, target.width / 2, target.height / 2);
                }
                tryVerify(function() { return !Activity.animRunning; }, 2000);
                stage = "proposal " + card.wordText + " box " + box + " selectedBox " + items.selectedBox;
                equal(card.boxModel.get(box).proposal, code);
            }

            function test_every_level_and_exercise() {
                // The real page transition must finish before events reach it.
                wait(1800);
                activityBackground.forceActiveFocus();
                keyClick(Qt.Key_Return);
                tryCompare(tutorialScreen, "visible", false);
                equal(items.currentLevel, 0);
                var count = activity.grammarMode === "_classes" ? 8 : 7;
                equal(items.numberOfLevel, count);
                checked(items.translationFile.indexOf("-pt.json") >= 0);
                for (var level = 0; level < count; level++) {
                    equal(items.currentLevel, level);
                    var exercises = items.datasetModel.count;
                    checked(exercises > 0);
                    for (var exercise = 0; exercise < exercises; exercise++) {
                        tryVerify(function() {
                            return !items.buttonsBlocked && !items.score.isWinAnimationPlaying;
                        }, 8000);
                        equal(items.currentExercise, exercise);
                        wait(40);
                        checked(items.rowAnswer.count > 0);
                        equal(items.errors.text, "");
                        if (exercise === 0) {
                            mouseClick(items.okButton, items.okButton.width / 2, items.okButton.height / 2);
                            equal(items.currentExercise, exercise, "An empty incorrect answer cannot progress");
                            checked(items.errorRectangle.errorAnimation.running);
                            wrongRejected++;
                            tryCompare(items, "buttonsBlocked", false, 3000);
                        }
                        var keyboard = exercise === 0;
                        if (keyboard) keyboardExercises++;
                        for (var word = 0; word < items.rowAnswer.count; word++) {
                            var card = items.rowAnswer.itemAt(word);
                            if (card.expected === "") continue;
                            var classes = card.expected.split("+");
                            if (classes.length > 1) mergedWords++;
                            equal(card.boxModel.count, classes.length);
                            for (var box = 0; box < classes.length; box++) {
                                if (classes[box] === "_" && !keyboard) continue;
                                assignBox(card, box, classes[box], keyboard);
                            }
                            equal(card.proposition, card.expected);
                        }
                        if (exercise === 1) {
                            for (var w = 0; w < items.rowAnswer.count; w++) {
                                var first = items.rowAnswer.itemAt(w);
                                if (first.expected !== "" && first.expected.split("+")[0] !== "_") {
                                    var expected = first.expected.split("+")[0];
                                    assignBox(first, 0, "_", false);
                                    checked(first.proposition !== first.expected);
                                    assignBox(first, 0, expected, false);
                                    equal(first.proposition, first.expected);
                                    erased++;
                                    break;
                                }
                            }
                        }
                        mouseClick(items.okButton, items.okButton.width / 2, items.okButton.height / 2);
                        equal(items.currentExercise, exercise + 1);
                        checked(items.score.isWinAnimationPlaying);
                        solved++;
                    }
                    var following = (level + 1) % count;
                    tryCompare(items, "currentLevel", following, 10000);
                    equal(items.currentExercise, 0);
                    completedLevels++;
                    console.log("NATIVE_GRAMMAR_LEVEL", activity.grammarMode, level + 1, exercises, "passed");
                }
                equal(solved, activity.grammarMode === "_classes" ? 92 : 80);
                equal(completedLevels, count);
                equal(wrongRejected, count);
                equal(keyboardExercises, count);
                equal(erased, count);
                checked(mergedWords > 0, "Contractions with multiple boxes were exercised");
            }

            function cleanupTestCase() {
                console.log("NATIVE_GRAMMAR_RESULT", JSON.stringify({
                    failures: qtest_results.failCount, passes: qtest_results.passCount,
                    solved: solved, wrongRejected: wrongRejected,
                    keyboardExercises: keyboardExercises, erased: erased,
                    completedLevels: completedLevels, mergedWords: mergedWords
                }));
            }
        }
