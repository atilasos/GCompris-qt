// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"HangmanWrongGuessesAndLossPT"
    when:activity.visible
    property var expectedWords:__WORDS__
    property var evidence:({})
    function test_six_wrong_guesses_reveal_word_then_enter_advances_once() {
        wait(1800);
        var source=String(wordImage.source),key=source.slice(source.lastIndexOf('/')+1).replace('.webp','.ogg');
        var target=expectedWords[key];verify(target!==undefined);
        var initial=score.currentSubLevel,mask=items.hidden.text;
        for(var digit=0;digit<6;digit++) {
            textinput.forceActiveFocus();keyClick(Qt.Key_0+digit);
            compare(items.remainingLife,5-digit);
            compare(score.currentSubLevel,initial);
            if(digit<5)compare(items.hidden.text,mask);
        }
        compare(items.hidden.text,target);
        compare(goodIcon.visible,false);
        verify(bonus.isPlaying);
        tryCompare(okButton,"visible",true,6500);
        grabImage(pageView).save("__QA_OUTPUT__/lost-word.png");
        textinput.forceActiveFocus();keyClick(Qt.Key_Return);
        tryCompare(score,"currentSubLevel",initial+1,2000);
        compare(items.remainingLife,6);
        compare(okButton.visible,false);
        verify(items.hidden.text.indexOf('_')>=0);
        evidence={word:target,wrongGuesses:6,lossRevealsWord:true,enterAdvancedExactlyOneWord:true};
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
