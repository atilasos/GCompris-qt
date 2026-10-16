// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:'VisibleMoneyCompleteLevels'
    when:activity.visible&&items.numberOfLevel>0
    property var denominations: __DENOMINATIONS__
    property var observations: []
    property int validation: __MODE__
    property int levelCount: __LEVELS__
    property bool changeGame: __CHANGE__
__VISIBLE__
__UI__
    function plain(rows){return rows.map(function(row){return {source:row.source,cents:row.cents};});}
    function wrongPayment(sources,wanted,kind,keyboard){
        if(sources===null)return {kind:kind,available:false};
        for(var source of sources)transfer(source,false,keyboard);
        var paid=sum(money(answerArea.answer));
        ensure(kind==='insufficient'?paid<wanted:paid>wanted,'Independent wrong payment');
        checked(bonus.isPlaying,false);var level=items.currentLevel;
        if(validation===2){click(okButton);tryVerify(function(){return errorRectangle.opacity>0;},1500);tryVerify(function(){return errorRectangle.opacity===0;},3500);}
        else wait(300);
        checked(bonus.isPlaying,false);checked(items.currentLevel,level);
        clearAnswer();return {kind:kind,available:true,sources:sources,cents:paid,errorVisible:validation===2};
    }
    function excessive(wallet,wanted){
        // In automatic mode, every prefix is also validated. Never pass through the exact sum.
        var sorted=wallet.slice().sort(function(a,b){return b.cents-a.cents;}),result=[],total=0;
        for(var row of sorted){if(validation===1&&total+row.cents===wanted)continue;result.push(row.source);total+=row.cents;if(total>wanted)return result;}
        return null;
    }
    function test_all_visible_payments(){
        wait(1800);var panel=openOptions();chooseMode(panel,validation-1);saveOptions();checked(okButton.visible,validation===2);
        checked(items.numberOfLevel,levelCount);checked(items.currentLevel,0);
        for(var level=0;level<levelCount;level++){
            wait(450);checked(items.currentLevel,level);
            var products=prices(),wallet=money(pocketArea.answer),tender=changeGame?money(tuxMoney):[],price=sum(products),paid=sum(tender),wanted=changeGame?paid-price:price;
            ensure(wanted>0,'Positive visible payment or change');var answer=solve(wallet,wanted);ensure(answer!==null,'Visible wallet can pay exact amount');
            var keyboard=level%2===1;
            var low=wallet.filter(function(row){return row.cents<wanted;})[0];
            var under=wrongPayment(low?[low.source]:(validation===2?[]:null),wanted,'insufficient',keyboard);
            var over=wrongPayment(excessive(money(pocketArea.answer),wanted),wanted,'excessive',keyboard);
            var start=money(pocketArea.answer),solution=solve(start,wanted);ensure(solution!==null);
            for(var source of solution)transfer(source,false,keyboard);
            checked(sum(money(answerArea.answer)),wanted,'Exact visible cents');
            if(validation===2){checked(bonus.isPlaying,false);click(okButton);}
            tryCompare(bonus,'isPlaying',true,2000);
            observations.push({level:level+1,validation:validation,input:keyboard?'keyboard':'mouse',prices:products,tender:plain(tender),wallet:plain(wallet),targetCents:wanted,negative:[under,over],payment:solution,paidCents:sum(money(answerArea.answer)),bonus:true});
            console.log('MONEY_PROGRESS',level+1,levelCount,wanted,keyboard?'keyboard':'mouse');
            tryCompare(items,'currentLevel',(level+1)%levelCount,9000);tryCompare(bonus,'isPlaying',false,3000);
        }
        checked(items.currentLevel,0);
    }
    function cleanupTestCase(){console.log('NATIVE_MONEY_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,observations:observations}));}
}
