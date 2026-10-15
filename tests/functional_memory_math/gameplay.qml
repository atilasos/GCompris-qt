// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    id: nativeMath
    name:"NativeMathematicalMemory"
    when:true
    function initTestCase() {
        wait(1600);
        if(!activity.visible){keyClick(Qt.Key_Return,Qt.NoModifier,0);tryCompare(activity,"visible",true,2500);}
        activity.stop();
        var count=activity.activityInfo.shortName().indexOf("memory-math-mult-div")===0?9:10;
        var folders=[];for(var i=1;i<=count;i++)folders.push(String(i));
        activity.levelFolder=folders;activity.start();wait(1100);
        compare(items.numberOfLevel,count);compare(activity.numberOfLevel,count);
    }
    property var completed: []
    property int correctPairs: 0
    property int wrongPairs: 0
    property int blockedClicks: 0
    property int tuxPairs: 0
    property int tuxTurns: 0
    property int losses: 0
    property int winSignals: 0
    property int lossSignals: 0
    property int forcedDefeats: 0
    Connections {
        target:bonus
        function onWin(){nativeMath.winSignals++;}
        function onLoose(){nativeMath.lossSignals++;}
    }
    function check(a,b,message){if(a!==b)console.log("MATH_FAILURE",a,b,message||"");compare(a,b,message||"");}
    // Counting and inverse relations, independent of production math_util formulas.
    function plus(a,b){var units=[];for(var i=0;i<a;i++)units.push(1);for(var j=0;j<b;j++)units.push(1);return units.length;}
    function times(a,b){var units=[];for(var i=0;i<b;i++)for(var j=0;j<a;j++)units.push(1);return units.length;}
    function answer(text) {
        var match=String(text).match(/^(\d+) ([+−×÷]) (\d+)$/);
        if(!match){verify(/^\d+$/.test(String(text)),"Numeric card: "+text);return Number(text);}
        var a=Number(match[1]),b=Number(match[3]);
        if(match[2]==="+")return plus(a,b);
        if(match[2]==="×")return times(a,b);
        for(var n=0;n<=a;n++)if(match[2]==="−"?plus(n,b)===a:times(n,b)===a)return n;
        fail("No non-negative integer answer for "+text);return -1;
    }
    function card(index){var item=cardGrid.itemAtIndex(index);verify(item!==null);return item;}
    function click(index){var item=card(index);mouseClick(item,item.width/2,item.height/2,Qt.LeftButton,Qt.NoModifier,0);}
    function pairs() {
        var result={};
        for(var i=0;i<cardGrid.count;i++) {
            var key=String(answer(card(i).pairData.text));
            if(result[key]===undefined)result[key]=[];result[key].push(i);
        }
        check(Object.keys(result).length,5);
        for(var key of Object.keys(result)) {
            check(result[key].length,2,"Exactly two semantic matches");
            var a=String(card(result[key][0]).pairData.text),b=String(card(result[key][1]).pairData.text);
            verify(a.indexOf(" ")>=0 !== (b.indexOf(" ")>=0),"One calculation and one numeral");
        }
        return result;
    }
    function verifyScores() {
        var found=0;
        for(var i=0;i<cardGrid.count;i++)if(card(i).isFound)found++;
        check(found,2*(items.player1Score.playerScore+items.player2Score.playerScore),"Scores count real found pairs");
    }
    function waitForTux() {
        var old=items.player2Score.playerScore;
        tuxTurns++;
        verify(items.tuxTurn);
        var before=items.selectionCount;
        var back=-1;
        for(var i=0;i<cardGrid.count;i++)if(card(i).isBack&&!card(i).isFound){back=i;break;}
        verify(back>=0);click(back);check(items.selectionCount,before,"Mouse blocked during Tux turn");verify(card(back).isBack);
        activityBackground.forceActiveFocus();keyClick(Qt.Key_Space,Qt.NoModifier,0);
        check(items.selectionCount,before,"Keyboard blocked during Tux turn");
        var deadline=Date.now()+45000;
        while(items.tuxTurn&&!items.blockClicks&&Date.now()<deadline){wait(100);verifyScores();}
        verify(!items.tuxTurn||items.blockClicks,"Original Tux timers return control or finish");
        tuxPairs+=items.player2Score.playerScore-old;
        verifyScores();
    }
    function wrongPair(group) {
        var names=Object.keys(group).filter(function(key){return !card(group[key][0]).isFound;});
        verify(names.length>=2);
        var a=group[names[0]][0],b=group[names[1]][0],third=group[names[0]][1];
        var score=items.player1Score.playerScore+items.player2Score.playerScore;
        click(a);check(items.selectionCount,1);click(a);check(items.selectionCount,1);
        click(b);check(items.selectionCount,2);wrongPairs++;
        click(third);check(items.selectionCount,2);verify(card(third).isBack);blockedClicks++;
        wait(500);verify(!card(a).isBack&&!card(b).isBack,"Wrong pair remains exposed");
        check(items.player1Score.playerScore+items.player2Score.playerScore,score);
        if(activity.withTux) {
            tryCompare(items,"tuxTurn",true,2000);waitForTux();
        } else {
            tryCompare(items,"selectionCount",0,2000);verify(card(a).isBack&&card(b).isBack);
        }
    }
    function solveRemaining(group) {
        var names=Object.keys(group);
        for(var name of names) {
            var indices=group[name];if(card(indices[0]).isFound)continue;
            verify(!items.tuxTurn);
            var s1=items.player1Score.playerScore,s2=items.player2Score.playerScore;
            click(indices[0]);click(indices[1]);check(items.selectionCount,2);
            wait(400);check(items.player1Score.playerScore,s1);check(items.player2Score.playerScore,s2);
            tryVerify(function(){return card(indices[0]).isFound&&card(indices[1]).isFound;},2000);
            correctPairs++;verifyScores();
            check(items.player1Score.playerScore,!items.player2Turn?s1+1:s1);
            check(items.player2Score.playerScore,items.player2Turn?s2+1:s2);
            if(!items.blockClicks){click(indices[0]);check(items.selectionCount,0,"Found card cannot be selected");}
        }
        verify(items.blockClicks);check(items.player1Score.playerScore+items.player2Score.playerScore,5);
    }
    function runMode(players) {
        activity.stop();items.playerCount=players;
        var count=activity.activityInfo.shortName().indexOf("memory-math-mult-div")===0?9:10;
        var folders=[];for(var i=1;i<=count;i++)folders.push(String(i));
        activity.levelFolder=folders;activity.start();
        check(items.numberOfLevel,count);check(activity.numberOfLevel,count,"Public level contract");
        for(var level=0;level<count;level++) {
            check(items.currentLevel,level);wait(1100);
            check(items.player1Score.playerScore,0);check(items.player2Score.playerScore,0);
            check(items.player2Turn,false);check(items.tuxTurn,false);check(items.selectionCount,0);
            // All generated pairs in each loaded dataset, not only the five drawn.
            for(var pair of items.levels[level].texts)check(answer(pair[0]),pair[1],"Generated arithmetic answer");
            var group=pairs();
            activityBackground.forceActiveFocus();var before=cardGrid.currentIndex;
            keyClick(Qt.Key_Right,Qt.NoModifier,0);check(cardGrid.currentIndex,(before+1)%10,"One arrow moves one card");
            wrongPair(group);
            if(!activity.withTux){check(items.player2Turn,players===2);if(players===2&&level%2===1){wrongPair(group);check(items.player2Turn,false);}}
            if(level===0)grabImage(activityBackground).save("__QA_OUTPUT__/"+players+"players-board.png");
            solveRemaining(group);
            var won=!activity.withTux||items.player1Score.playerScore>items.player2Score.playerScore;
            completed.push({players:players,level:level+1,score1:items.player1Score.playerScore,score2:items.player2Score.playerScore,won:won});
            console.log("MATH_LEVEL",JSON.stringify(completed[completed.length-1]));
            if(!won) {
                losses++;tryCompare(items,"blockClicks",false,7000);check(items.currentLevel,level,"Tux victory repeats level");
                wait(1100);solveRemaining(pairs());
            }
            tryCompare(items,"currentLevel",(level+1)%count,7000);
        }
    }
    function test_all_levels_modes_and_tux(){
        wait(1600);runMode(1);if(!activity.withTux)runMode(2);
        check(winSignals,items.numberOfLevel*(activity.withTux?1:2),"One real winning Bonus per completed level");
        check(lossSignals,losses,"Every natural loss emits the bad Bonus");
    }
    function test_defeat_by_tux_repeats_the_same_level(){
        if(!activity.withTux)return;
        wait(1100);var level=items.currentLevel,group=pairs();
        var deadline=Date.now()+180000;
        while(!items.blockClicks&&Date.now()<deadline) {
            var remaining=Object.keys(group).filter(function(key){return !card(group[key][0]).isFound;});
            if(remaining.length===1)solveRemaining(group);
            else wrongPair(group);
        }
        verify(items.blockClicks,"Tux finishes using original random turns");
        verify(items.player2Score.playerScore>=4&&items.player1Score.playerScore<=1,"Player deliberately yields pairs through real mistakes");
        var previous=lossSignals;
        tryCompare(items,"blockClicks",false,7000);
        check(lossSignals,previous+1,"Bad Bonus is emitted for a Tux victory");
        check(items.currentLevel,level,"Defeat repeats the selected level");
        check(items.player1Score.playerScore,0);check(items.player2Score.playerScore,0);check(items.tuxTurn,false);
        forcedDefeats++;
    }
    function cleanupTestCase(){console.log("NATIVE_MEMORY_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,correctPairs:correctPairs,wrongPairs:wrongPairs,blockedClicks:blockedClicks,tuxPairs:tuxPairs,tuxTurns:tuxTurns,losses:losses,winSignals:winSignals,lossSignals:lossSignals,forcedDefeats:forcedDefeats}));}
}
