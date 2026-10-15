// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "GuessNumberByVisibleHints"
    when: items.numberOfLevel > 0 && activity.visible
    property var maxima: [10,15,20,50,100,200,500,1000,5000,10000,50000,100000,200000,300000,500000,800000,1000000]
    property var solved: []
    property int highHints: 0
    property int lowHints: 0
    function enterNumber(number, virtualKeys) {
        activityBackground.forceActiveFocus();
        while(numpad.answer.length) keyClick(Qt.Key_Backspace);
        var text = String(number);
        for(var i = 0; i < text.length; i++) {
            var digit = Number(text[i]);
            if(virtualKeys) {
                var panel = digit < 5 ? numpad.leftPanelComponent : numpad.rightPanelComponent;
                mouseClick(panel.children[digit % 5]);
            } else keyClick(Qt.Key_0 + digit);
            compare(numpad.answer, text.slice(0, i + 1));
        }
        compare(answerPanel.textItem.text.replace(/\s/g,""), text);
    }
    function test_all_levels_two_keyboards() {
        wait(1600);
        ApplicationSettings.isVirtualKeyboard = true;
        compare(items.numberOfLevel, maxima.length);
        for(var mode = 0; mode < 2; mode++) {
            for(var level = 0; level < maxima.length; level++) {
                compare(items.currentLevel, level);
                compare(instructionPanel.textItem.text.replace(/\s/g,""),
                        "Adivinhaumnúmeroentre1e" + maxima[level] + ".");
                var lower = 1, upper = maxima[level], won = false, attempts = [];
                for(var step = 0; step < 25 && !won; step++) {
                    var guess = Math.floor((lower + upper) / 2);
                    enterNumber(guess, mode === 1);
                    if(step === 0) {
                        keyClick(Qt.Key_Backspace);
                        compare(numpad.answer, String(guess).slice(0,-1));
                        keyClick(Qt.Key_0 + Number(String(guess).slice(-1)));
                    }
                    if(step % 2) keyClick(Qt.Key_Return);
                    else mouseClick(okButton);
                    var hint = userInfoPanel.textItem.text;
                    attempts.push({guess:guess, hint:hint});
                    if(hint === "O teu número é demasiado alto.") {
                        upper = guess - 1;
                        highHints++;
                        verify(!bonus.isPlaying);
                    } else if(hint === "O teu número é demasiado baixo.") {
                        lower = guess + 1;
                        lowHints++;
                        verify(!bonus.isPlaying);
                    } else {
                        compare(hint, "Descobriu o número!");
                        verify(bonus.isPlaying);
                        won = true;
                    }
                    verify(lower <= upper, "Visible hints keep a possible integer interval");
                }
                verify(won, "Binary search from visible hints finds a number");
                solved.push({level:level+1, virtualKeys:mode===1, attempts:attempts});
                tryCompare(items, "currentLevel", (level + 1) % maxima.length, 10000);
                tryCompare(bonus, "isPlaying", false, 5000);
            }
        }
        compare(solved.length, 34);
        verify(highHints > 0 && lowHints > 0);
    }
    function cleanupTestCase() {
        console.log("NATIVE_GUESS_RESULT", JSON.stringify({
            failures:qtest_results.failCount, passes:qtest_results.passCount,
            highHints:highHints, lowHints:lowHints, solved:solved
        }));
    }
}
