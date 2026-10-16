// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"MemoryUnhandledEscape"
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
    function test_escape_still_reaches_application_home() {
        wait(1600);ActivityInfoTree.startingActivity="";
        activityBackground.forceActiveFocus();keyClick(Qt.Key_Escape,Qt.NoModifier,0);
        tryCompare(pageView,"depth",1,2000);verify(pageView.currentItem.isMenu);
    }
    function cleanupTestCase(){console.log("NATIVE_MEMORY_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount}));}
}
