// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:'NaturalMoneyPricesArePayable'
    when:activity.visible&&items.numberOfLevel>0
    property var denominations: __DENOMINATIONS__
    property var observations: []
__VISIBLE__
__UI__
    function test_naturally_drawn_prices_have_an_exact_visible_payment(){
        wait(1800);
        for(var skip=0;skip<19;skip++){clickIcon(bar,'bar_next.svg');wait(200);}
        checked(items.currentLevel,19);
        for(var attempt=0;attempt<12;attempt++){
            wait(500);var priceRows=prices(),wallet=money(pocketArea.answer),wanted=sum(priceRows),answer=solve(wallet,wanted);
            observations.push({level:20,attempt:attempt+1,prices:priceRows,wallet:wallet.map(function(row){return {source:row.source,cents:row.cents};}),payable:answer!==null});
            console.log('MONEY_REACHABILITY',attempt+1,wanted,answer!==null);
            ensure(answer!==null,'Every naturally displayed price has a payment from the drawn wallet');
            for(var source of answer)transfer(source,false,false);
            tryCompare(bonus,'isPlaying',true,2000);tryCompare(items,'currentLevel',20,9000);
            clickIcon(bar,'bar_previous.svg');checked(items.currentLevel,19);
        }
    }
    function cleanupTestCase(){console.log('NATIVE_MONEY_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,observations:observations}));}
}
