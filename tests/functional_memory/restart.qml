// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"MemoryRestartWithPendingCardTimer"
    when:items.numberOfLevel>0 && activity.visible
    property var restartedModes: []
    function test_restart_clears_partial_selection_and_pending_timer() {
        wait(1600);
        for(var players of [1,2]) {
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
            mouseClick(first,first.width/2,first.height/2,Qt.LeftButton,Qt.NoModifier,0);
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
            restartedModes.push(players);
        }
    }
    function cleanupTestCase(){console.log("NATIVE_MEMORY_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,restartedModes:restartedModes}));}
}
