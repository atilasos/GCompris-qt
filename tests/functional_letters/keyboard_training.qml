// SPDX-License-Identifier: GPL-3.0-or-later
// Real TextInput, error animation, score animation, voice completion and bonus.
TestCase {
    name: "FunctionalKeyboardPT"
    when: items.numberOfLevel > 0 && activity.visible
    property var completed: []
    property int correctInputs: 0
    property int wrongInputs: 0
    property var typedCharacters: ({})
    property var unicodeInput: null
    function input(text) {
        textinput.forceActiveFocus();
        if(text.charCodeAt(0) > 127) {
            if(unicodeInput === null)
                unicodeInput = Qt.createQmlObject('import "file:__QA_SOURCE__/build/functional-input"; UnicodeInput {}', this);
            var before = items.score.currentSubLevel;
            verify(unicodeInput.preedit(textinput, text));
            compare(items.score.currentSubLevel, before, "Preedit is not a submitted answer");
            verify(unicodeInput.commit(textinput, text));
        } else {
            keyClick(text, Qt.NoModifier, 0);
        }
    }
    function capture(label) {
        grabImage(activityBackground).save("__QA_OUTPUT__/" + label + ".png");
    }
    function runMode(caseMode) {
        activityBackground.stop();
        items.caseMode = caseMode;
        activityBackground.start();
        compare(items.wordlist.wordList.locale, "pt");
        compare(items.numberOfLevel, 13);
        compare(items.currentLevel, 0);
        for(var level=0; level<13; level++) {
            compare(items.currentLevel, level);
            var total = items.score.numberOfSubLevels;
            compare(items.score.currentSubLevel, 0);
            tryCompare(items, "inputLocked", false, 3000);
            if(level === 0 || level >= 10) capture("keyboard-" + caseMode + "-level-" + (level + 1));
            input("#");
            compare(items.score.currentSubLevel, 0);
            wrongInputs++;
            tryCompare(items, "inputLocked", false, 3000);
            for(var question=0; question<total; question++) {
                tryCompare(items, "inputLocked", false, 3000);
                var target = items.questionText;
                compare(target.length, 1);
                // Case conversion is intentional in both modes. Alternate the
                // submitted case while retaining every accent and cedilla.
                var submitted = question % 2 ? target.toUpperCase() : target.toLowerCase();
                if(level >= 10 && question === 0) {
                    var unaccented = target.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
                    input(unaccented);
                    compare(items.score.currentSubLevel, question);
                    wrongInputs++;
                    tryCompare(items, "inputLocked", false, 3000);
                }
                input(submitted);
                tryCompare(items.score, "currentSubLevel", question + 1, 1000);
                correctInputs++;
                typedCharacters[submitted] = true;
                // Wait for the real score/audio completion path; no animation
                // shortening, direct nextSubLevel or manually unlocked input.
                if(question + 1 < total) tryCompare(items, "inputLocked", false, 4000);
            }
            completed.push({mode:caseMode,level:level+1,correct:total,score:items.score.currentSubLevel});
            console.log("NATIVE_LETTERS_LEVEL",JSON.stringify(completed[completed.length-1]));
            tryCompare(items,"currentLevel",(level+1)%13,7000);
        }
    }
    function test_complete_every_portuguese_level_in_both_case_modes() {
        wait(1600);
        runMode("uppercase");
        runMode("lowercase");
        compare(correctInputs,424);
        for(var character of "àáâãéêíóôõúç") {
            verify(typedCharacters[character] || typedCharacters[character.toUpperCase()],character);
        }
    }
    function cleanupTestCase() {
        console.log("NATIVE_LETTERS_RESULT",JSON.stringify({failures:qtest_results.failCount,
            passes:qtest_results.passCount,completed:completed,correctInputs:correctInputs,
            wrongInputs:wrongInputs,typedCharacters:Object.keys(typedCharacters)}));
    }
}
