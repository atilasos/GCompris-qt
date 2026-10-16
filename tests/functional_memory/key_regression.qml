// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"MemoryKeyPropagationRegression"
    when:items.numberOfLevel>0 && activity.visible
    property var proof: ({})
    function select(index) {
        activityBackground.forceActiveFocus();
        var guard=0;
        while(cardGrid.currentIndex!==index && guard++<cardGrid.count)keyClick(Qt.Key_Right,Qt.NoModifier,0);
        compare(cardGrid.currentIndex,index);
        keyClick(Qt.Key_Space,Qt.NoModifier,0);
    }
    function test_one_arrow_one_card_complete_level_and_escape() {
        wait(1600);
        var initial=cardGrid.currentIndex;
        activityBackground.forceActiveFocus();keyClick(Qt.Key_Right,Qt.NoModifier,0);
        compare(cardGrid.currentIndex,(initial+1)%cardGrid.count,"A handled key must not be forwarded back twice");
        var names=["zero","um","dois","três","quatro","cinco"];
        var pairs={};
        for(var index=0;index<cardGrid.count;index++) {
            var text=String(cardGrid.itemAtIndex(index).pairData.text);
            var value=/^\d+$/.test(text)?Number(text):names.indexOf(text);
            verify(value>=0);
            if(!pairs[value])pairs[value]=[];pairs[value].push(index);
        }
        for(var value of Object.keys(pairs)) {
            var indices=pairs[value];compare(indices.length,2);
            select(indices[0]);compare(items.selectionCount,1);
            select(indices[1]);compare(items.selectionCount,2);
            tryVerify(function(){return cardGrid.itemAtIndex(indices[0]).isFound && cardGrid.itemAtIndex(indices[1]).isFound;},2200);
        }
        compare(items.player1Score.playerScore,3);verify(items.blockClicks);
        tryCompare(items,"currentLevel",1,7000);
        compare(activity.numberOfLevel,5);
        proof={oneStep:true,completedPairs:3,advancedToLevel:2,activityLevels:activity.numberOfLevel};
        ActivityInfoTree.startingActivity="";
        activityBackground.forceActiveFocus();keyClick(Qt.Key_Escape,Qt.NoModifier,0);
        tryCompare(pageView,"depth",1,2000);verify(pageView.currentItem.isMenu);proof.escapeHome=true;
    }
    function cleanupTestCase(){console.log("NATIVE_MEMORY_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,proof:proof}));}
}
