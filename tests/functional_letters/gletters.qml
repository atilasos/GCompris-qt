// SPDX-License-Identifier: GPL-3.0-or-later
// Injected into the real Gletters.qml pageComponent by run-native-qml-case.py.
TestCase {
    name: "FunctionalFallingLettersPT"
    when: items.numberOfLevel > 0 && activity.visible
    property var completed: []
    property int correctInputs: 0
    property int wrongInputs: 0
    property var typedCharacters: ({})
    property var rejectedUnaccented: ({mixed: {}, uppercase: {}})

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
    function runMode(uppercaseOnly) {
        // Fixture the real configuration/lifecycle, never the answers or score.
        activityBackground.stop();
        activity.uppercaseOnly = uppercaseOnly;
        activity.speedSetting = 10;
        activityBackground.start();
        compare(items.wordlist.wordList.locale, "pt");
        compare(items.numberOfLevel, 13);
        compare(items.currentLevel, 0);
        for(var level = 0; level < 13; level++) {
            compare(items.currentLevel, level);
            compare(items.score.currentSubLevel, 0);
            var total = items.score.numberOfSubLevels;
            verify(total > 0);
            if(level === 0 || level >= 10) capture("falling-" + uppercaseOnly + "-level-" + (level + 1));
            // A character absent from every level must be rejected while an
            // actual FallingWord is on screen. There is no direct game call.
            tryVerify(function() { return Activity.droppedWords.length > 0; }, 3000);
            input("#");
            compare(items.score.currentSubLevel, 0);
            wrongInputs++;
            for(var question = 0; question < total; question++) {
                tryVerify(function() { return Activity.droppedWords.length > 0; }, 3000);
                var word = Activity.droppedWords[0];
                verify(word.text.length === 1);
                verify(!word.wonState);
                var target = word.text;
                // In strict mixed mode, the opposite case must not count.
                if(!uppercaseOnly && target.toLowerCase() !== target.toUpperCase()) {
                    var opposite = target === target.toUpperCase() ? target.toLowerCase() : target.toUpperCase();
                    // Other falling targets could legitimately accept opposite.
                    var otherMatch = false;
                    for(var i=0; i<Activity.droppedWords.length; i++)
                        if(Activity.droppedWords[i].text === opposite) otherMatch = true;
                    if(!otherMatch) {
                        input(opposite);
                        compare(items.score.currentSubLevel, question);
                        wrongInputs++;
                    }
                }
                // Independent spelling pairs: omitting an accent or cedilla
                // must not answer a different letter. An unrelated active
                // unaccented target could legitimately accept the same key.
                var plainLetters = {"à":"a", "á":"a", "â":"a", "ã":"a",
                    "é":"e", "ê":"e", "í":"i", "ó":"o", "ô":"o",
                    "õ":"o", "ú":"u", "ç":"c"};
                var accent = target.toLowerCase();
                var mode = uppercaseOnly ? "uppercase" : "mixed";
                if(plainLetters[accent] !== undefined && !rejectedUnaccented[mode][accent]) {
                    var plain = plainLetters[accent];
                    if(!uppercaseOnly && target === target.toUpperCase()) plain = plain.toUpperCase();
                    var activeMatch = false;
                    for(var active = 0; active < Activity.droppedWords.length; active++) {
                        var activeText = Activity.droppedWords[active].text;
                        if(uppercaseOnly ? activeText.toUpperCase() === plain.toUpperCase() : activeText === plain)
                            activeMatch = true;
                    }
                    if(!activeMatch) {
                        input(plain);
                        compare(items.score.currentSubLevel, question, "Accent omission must be rejected: " + target);
                        verify(!word.wonState, "Accented target remains unanswered");
                        rejectedUnaccented[mode][accent] = true;
                        wrongInputs++;
                        console.log("NATIVE_UNACCENTED_REJECT", JSON.stringify({mode:mode,
                            target:target, input:plain, level:level+1, score:items.score.currentSubLevel}));
                    }
                }
                var submitted = uppercaseOnly ? target.toLowerCase() : target;
                input(submitted);
                tryCompare(items.score, "currentSubLevel", question + 1, 1000);
                correctInputs++;
                typedCharacters[submitted] = true;
            }
            completed.push({mode: uppercaseOnly ? "uppercase-only" : "mixed-case", level: level + 1,
                            correct: total, score: items.score.currentSubLevel});
            console.log("NATIVE_LETTERS_LEVEL", JSON.stringify(completed[completed.length - 1]));
            // Bonus.win, not a manual nextLevel call, must advance/wrap the game.
            tryCompare(items, "currentLevel", (level + 1) % 13, 6000);
        }
    }
    function test_complete_every_portuguese_level_in_both_case_modes() {
        wait(1600);
        runMode(false);
        runMode(true);
        for(var character of "àáâãéêíóôõúç") verify(typedCharacters[character] === true, character);
        compare(correctInputs, 424);
        for(var mode of ["mixed", "uppercase"])
            for(var accent of "àáâãéêíóôõúç")
                verify(rejectedUnaccented[mode][accent] === true,
                       mode + ": reject unaccented " + accent);
        // Exercise the minimum speed configuration through the same lifecycle.
        activityBackground.stop();
        activity.speedSetting = 1;
        activityBackground.start();
        compare(items.wordDropTimer.interval, 59000);
        compare(Activity.speed, 1200);
        var before = items.score.currentSubLevel;
        input(Activity.droppedWords[0].text.toLowerCase());
        compare(items.score.currentSubLevel, before + 1);
        correctInputs++;
        capture("falling-minimum-speed");
    }
    function cleanupTestCase() {
        console.log("NATIVE_LETTERS_RESULT", JSON.stringify({failures:qtest_results.failCount,
            passes:qtest_results.passCount, completed:completed, correctInputs:correctInputs,
            wrongInputs:wrongInputs, rejectedUnaccented:rejectedUnaccented, typedCharacters:Object.keys(typedCharacters)}));
    }
}
