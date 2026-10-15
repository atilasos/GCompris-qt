// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"MemoryUnhandledEscape"
    when:items.numberOfLevel>0 && activity.visible
    function test_escape_still_reaches_application_home() {
        wait(1600);ActivityInfoTree.startingActivity="";
        activityBackground.forceActiveFocus();keyClick(Qt.Key_Escape,Qt.NoModifier,0);
        tryCompare(pageView,"depth",1,2000);verify(pageView.currentItem.isMenu);
    }
    function cleanupTestCase(){console.log("NATIVE_MEMORY_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount}));}
}
