// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:'ManualMoneyFeedbackBlocksInput'
    when:activity.visible&&items.numberOfLevel>0
    property var denominations: __DENOMINATIONS__
    property var evidence: ({})
__VISIBLE__
__UI__
    function test_error_feedback_blocks_another_money_transfer(){
        wait(1600);var panel=openOptions();chooseMode(panel,1);saveOptions();verify(okButton.visible);
        var total=sum(prices()),wrong=money(pocketArea.answer).filter(function(row){return row.cents!==total;})[0];ensure(wrong!==undefined);
        click(wrong.item);wait(500);checked(answerArea.answer.count,1);click(okButton);
        tryVerify(function(){return errorRectangle.opacity>0;},1000);
        var before=answerArea.answer.count;click(pocketArea.answer.itemAt(0));wait(100);
        evidence={targetCents:total,before:before,after:answerArea.answer.count};
        checked(answerArea.answer.count,before,'Error feedback blocks repeated money clicks');
    }
    function cleanupTestCase(){console.log('NATIVE_MONEY_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
