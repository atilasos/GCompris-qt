// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "DecimalPhysicalDragTracer"
    when: activity.visible
    function test_real_arrow_and_bar_drag() {
        wait(1400);
        activityBackground.forceActiveFocus();
        if(tutorialImage.visible) keyClick(Qt.Key_Escape);
        tryCompare(tutorialImage,"visible",false,2000);
        console.log("DECIMAL_CONTEXT", JSON.stringify({datasets:activity.activityInfo.currentLevels,all:activity.activityInfo.levels,levels:items.numberOfLevel,target:items.largestNumber,other:items.smallestNumber,width:activityBackground.width,height:activityBackground.height}));
        var units = Math.round(Number(items.largestNumber.replace(",","."))*10);
        var a = arrow.mapToItem(activityBackground,arrow.width/2,arrow.height/2);
        mouseDrag(activityBackground,a.x,a.y,(units-1)*unselectedBar.cellSize,0,Qt.LeftButton,Qt.NoModifier,15);
        console.log("DECIMAL_ARROW", JSON.stringify({requested:units,step:scrollBar.currentStep,selected:draggedItems.get(0).selectedSquareNumbers}));
        compare(scrollBar.currentStep,units-1);
        var from=selectedBar.mapToItem(activityBackground,unselectedBar.cellSize/2,unselectedBar.cellSize/2);
        var dest=topRectangle.mapToItem(activityBackground,topRectangle.width/2,topRectangle.height/2);
        mouseDrag(activityBackground,from.x,from.y,dest.x-from.x,dest.y-from.y,Qt.LeftButton,Qt.NoModifier,15);
        console.log("DECIMAL_DROP",JSON.stringify({bars:droppedItems.count,selected: droppedItems.count?droppedItems.get(0).selectedSquareNumbers:-1}));
        compare(droppedItems.count,1);
        compare(droppedItems.get(0).selectedSquareNumbers,units);
        mouseClick(okButton);
        tryCompare(score,"currentSubLevel",1,2000);
    }
    function cleanupTestCase() {console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount}));}
}
