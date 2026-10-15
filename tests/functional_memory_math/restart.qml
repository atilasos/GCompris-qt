// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"MemoryRestartWithPendingCardTimer"
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
    property var restartedModes: []
    function test_restart_clears_partial_selection_and_pending_timer() {
        wait(1600);
        for(var players of (activity.withTux?[1]:[1,2])) {
            activity.stop();items.playerCount=players;activity.start();wait(1100);
            activityBackground.forceActiveFocus();
            // Interior row movement has unambiguous destinations; each event
            // must be processed once for both player modes.
            while(cardGrid.currentIndex!==0)keyClick(Qt.Key_Left,Qt.NoModifier,0);
            keyClick(Qt.Key_Right,Qt.NoModifier,0);compare(cardGrid.currentIndex,1);
            keyClick(Qt.Key_Down,Qt.NoModifier,0);compare(cardGrid.currentIndex,1+items.columns);
            keyClick(Qt.Key_Up,Qt.NoModifier,0);compare(cardGrid.currentIndex,1);
            keyClick(Qt.Key_Left,Qt.NoModifier,0);compare(cardGrid.currentIndex,0);
            var first=cardGrid.itemAtIndex(0);verify(first!==null);
            keyClick(Qt.Key_Space,Qt.NoModifier,0);
            keyClick(Qt.Key_Enter,Qt.NoModifier,0);keyClick(Qt.Key_Return,Qt.NoModifier,0);
            compare(items.selectionCount,1);verify(!first.isBack);
            activity.stop();activity.start();
            // Outlast the original 1500 ms card timer after restarting.
            wait(1800);
            compare(items.selectionCount,0);compare(items.playQueue.length,0);
            compare(items.player1Score.playerScore,0);compare(items.player2Score.playerScore,0);
            compare(items.blockClicks,false);compare(items.player2Turn,false);
            for(var index=0;index<cardGrid.count;index++) {
                var card=cardGrid.itemAtIndex(index);verify(card.isBack && !card.isFound);
            }
            if(activity.withTux) {
                var calculations=[];
                for(var i=0;i<cardGrid.count;i++)if(String(cardGrid.itemAtIndex(i).pairData.text).indexOf(" ")>=0)calculations.push(i);
                // Two distinct calculation cards cannot be a calculation/numeral pair.
                for(var index of calculations.slice(0,2)) {
                    var selected=cardGrid.itemAtIndex(index);
                    mouseClick(selected,selected.width/2,selected.height/2,Qt.LeftButton,Qt.NoModifier,0);
                }
                tryCompare(items,"tuxTurn",true,2200);
                verify(items.selectionCount>0,"Tux has a pending automatic card timer");
                activity.stop();activity.start();wait(1800);
                compare(items.selectionCount,0);compare(items.playQueue.length,0);
                compare(items.player1Score.playerScore,0);compare(items.player2Score.playerScore,0);compare(items.tuxTurn,false);
                for(var i=0;i<cardGrid.count;i++)verify(cardGrid.itemAtIndex(i).isBack&&!cardGrid.itemAtIndex(i).isFound);
            }
            restartedModes.push(players);
        }
    }
    function cleanupTestCase(){console.log("NATIVE_MEMORY_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,restartedModes:restartedModes}));}
}
