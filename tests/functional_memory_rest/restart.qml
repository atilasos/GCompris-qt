// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"MemoryRestartWithPendingCardTimer"
    when:true
    function levelCount(){return {"memory":6,"memory-tux":6,"memory-sound":7,"memory-sound-tux":7,"memory-case-association-tux":4}[activity.activityInfo.shortName()];}
    function initTestCase(){
        wait(1600);ApplicationSettings.isAudioVoicesEnabled=true;ApplicationSettings.isAudioEffectsEnabled=true;
        activity.audioVoices.muted=false;
        if(audioNeededDialog.active) {
            audioNeededDialog.item.forceActiveFocus();keyClick(Qt.Key_Escape);
            tryCompare(audioNeededDialog,"active",false,2000);
        }
        if(!activity.visible){keyClick(Qt.Key_Return,Qt.NoModifier,0);tryCompare(activity,"visible",true,2500);}
        activity.stop();activity.start();wait(1100);
        compare(items.numberOfLevel,levelCount());compare(activity.numberOfLevel,levelCount());
    }
    property var restartedModes: []
    function keyFor(data) {
        if(activity.activityInfo.shortName()==="memory-case-association-tux") {
            var letter=String(data.image).match(/(?:lower|upper)([A-Z])\.svg$/);verify(letter!==null);return letter[1];
        }
        if(activity.activityInfo.shortName().indexOf("memory-sound")===0)return String(data.sound);
        return String(data.image);
    }
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
                for(var i=0;i<cardGrid.count;i++)if(keyFor(cardGrid.itemAtIndex(i).pairData)!==keyFor(cardGrid.itemAtIndex(0).pairData))calculations.push(i);
                // Choose two distinct visible/sound identities, never matching codes.
                for(var index of [0,calculations[0]]) {
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
