// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "HanoiCoveredDiscNegative"
    when: activity.visible && discRepeater.count>0
    property var evidence: ({})
    function state() {
        var result=[];
        for(var i=0;i<discRepeater.count;i++) {
            var disc=discRepeater.itemAt(i);
            var point=disc.mapToItem(activityBackground,disc.width/2,disc.height/2);
            result.push({index:i,parent:towerModel.indexOf?0:0,x:point.x,y:point.y,
                         width:disc.width,height:disc.height,enabled:disc.enabled});
            for(var peg=0;peg<towerModel.count;peg++)if(disc.parent===towerModel.itemAt(peg))result[result.length-1].parent=peg;
        }
        return result;
    }
    function test_drag_covered_lower_disc_does_not_change_stack() {
        wait(1800);
        var first=towerModel.itemAt(0),stack=[];
        for(var i=0;i<discRepeater.count;i++) {
            var disc=discRepeater.itemAt(i);
            if(disc.parent===first)stack.push(disc);
        }
        stack.sort(function(a,b){return b.y-a.y;});
        verify(stack.length>=2);
        var lower=stack[0],upper=stack[stack.length-1];
        verify(lower.y>upper.y,"Lower disc selected from drawn vertical order");
        verify(!lower.enabled,"Covered lower disc is disabled");
        verify(!lower.discMouseArea.enabled,"Covered lower pointer handler is disabled");
        var before=state();
        var start=lower.mapToItem(activityBackground,lower.width/2,lower.height/2);
        var target=towerModel.itemAt(activity.activityMode==="real"?1:towerModel.count-2);
        var end=target.mapToItem(activityBackground,target.width/2,target.height/2);
        mousePress(activityBackground,start.x,start.y,Qt.LeftButton,Qt.NoModifier,20);
        mouseMove(activityBackground,start.x+15,start.y+15,20,Qt.LeftButton);
        mouseMove(activityBackground,start.x+30,start.y+30,20,Qt.LeftButton);
        mouseMove(activityBackground,end.x,end.y,60,Qt.LeftButton);
        mouseRelease(activityBackground,end.x,end.y,Qt.LeftButton,Qt.NoModifier,20);
        wait(400);
        evidence={activity:activity.activityInfo.shortName(),selectedLower:lower.index,
                  selectedUpper:upper.index,start:[start.x,start.y],end:[end.x,end.y],before:before,after:state()};
        console.log("HANOI_COVERED_OBSERVED",JSON.stringify(evidence));
        compare(JSON.stringify(evidence.after),JSON.stringify(before),"All drawn discs retain parents, coordinates and enabled state");
        grabImage(activityBackground).save("__QA_OUTPUT__/covered-disc.png");
    }
    function cleanupTestCase(){console.log("NATIVE_HANOI_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,covered:evidence}));}
}
