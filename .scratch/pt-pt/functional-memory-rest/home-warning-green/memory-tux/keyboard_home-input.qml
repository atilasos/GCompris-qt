// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"MemoryUnhandledEscape"
    when:true
    function levelCount(){return {"memory":6,"memory-tux":6,"memory-sound":7,"memory-sound-tux":7,"memory-case-association-tux":4}[activity.activityInfo.shortName()];}
    function initTestCase(){
        wait(1600);ApplicationSettings.isAudioVoicesEnabled=true;ApplicationSettings.isAudioEffectsEnabled=true;
        activity.audioVoices.muted=false;
        // Dismiss the real initial audio warning through its keyboard route.
        // Destroying its Loader directly bypasses GCDialog.stop(), which restores
        // ActivityBase.Keys.enabled and would manufacture a broken Escape key.
        if(audioNeededDialog.active) {
            audioNeededDialog.item.forceActiveFocus();
            keyClick(Qt.Key_Escape,Qt.NoModifier,0);
            tryCompare(audioNeededDialog,"active",false,2000);
        }
        if(!activity.visible){keyClick(Qt.Key_Return,Qt.NoModifier,0);tryCompare(activity,"visible",true,2500);}
        activity.stop();activity.start();wait(1100);
        compare(items.numberOfLevel,levelCount());compare(activity.numberOfLevel,levelCount());
    }
    function test_escape_still_reaches_application_home() {
        wait(1600);ActivityInfoTree.startingActivity="";
        activityBackground.forceActiveFocus();
        console.log("MEMORY_ESCAPE_BEFORE",JSON.stringify({depth:pageView.depth,activityVisible:activity.visible,audioDisabled:activityBackground.audioDisabled,warningActive:audioNeededDialog.active,focus:activityBackground.activeFocus,isCurrent:pageView.currentItem===activity}));
        keyClick(Qt.Key_Escape,Qt.NoModifier,0);wait(700);
        console.log("MEMORY_ESCAPE_AFTER",JSON.stringify({depth:pageView.depth,menu:pageView.currentItem.isMenu,activityVisible:activity.visible,audioDisabled:activityBackground.audioDisabled,warningActive:audioNeededDialog.active,focus:activityBackground.activeFocus,isCurrent:pageView.currentItem===activity}));
        tryCompare(pageView,"depth",1,2000);verify(pageView.currentItem.isMenu);
    }
    function cleanupTestCase(){console.log("NATIVE_MEMORY_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount}));}
}
