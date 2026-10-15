// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"DecimalToolbarSettlesAfterTutorial"
    when:activity.visible
    property var observations:[]
    function findNext(item) {
        if(item.source!==undefined && String(item.source).endsWith("bar_next.svg"))return item;
        if(item.children)for(var i=0;i<item.children.length;i++) {
            var result=findNext(item.children[i]);if(result)return result;
        }
        return null;
    }
    function test_toolbar_transition() {
        wait(1400);
        activityBackground.forceActiveFocus();
        verify(tutorialImage.visible);
        keyClick(Qt.Key_Escape);
        tryCompare(tutorialImage,"visible",false,2000);
        for(var tick=0;tick<30;tick++) {
            wait(100);
            var button=findNext(bar);
            if(button) {
                var center=button.mapToItem(activityBackground,button.width/2,button.height/2);
                var row=button.parent.parent;
                var entry={ms:(tick+1)*100,centerX:center.x,centerY:center.y,windowHeight:activityBackground.height,hidden:ApplicationSettings.isBarHidden,rowState:row.state,rowY:row.y};
                observations.push(entry);
                console.log("DECIMAL_TOOLBAR",JSON.stringify(entry));
            }
        }
        var lastObservation=observations[observations.length-1];
        verify(!lastObservation.hidden);
        compare(lastObservation.rowState,"shown");
        verify(lastObservation.centerY<lastObservation.windowHeight);
        var initial=items.currentLevel;
        var next=findNext(bar);
        mouseClick(next,next.width/2,next.height/2,Qt.LeftButton,Qt.NoModifier,50);
        tryCompare(items,"currentLevel",(initial+1)%items.numberOfLevel,2000);
        grabImage(pageView).save("__QA_OUTPUT__/settled-toolbar.png");
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,observations:observations}));}
}
