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
            result.push({index:i,parent:-1,x:point.x,y:point.y,
                         width:disc.width,height:disc.height,enabled:disc.enabled});
            for(var peg=0;peg<towerModel.count;peg++)if(disc.parent===towerModel.itemAt(peg))result[result.length-1].parent=peg;
        }
        return result;
    }
    function discStack(peg) {
        var result=[];
        for(var i=0;i<discRepeater.count;i++) {
            var disc=discRepeater.itemAt(i);
            if(disc.parent===peg)result.push(disc);
        }
        result.sort(function(a,b){return b.y-a.y;});
        return result;
    }
    function dragFrom(start,target) {
        var end=target.mapToItem(activityBackground,target.width/2,target.height/2);
        mousePress(activityBackground,start.x,start.y,Qt.LeftButton,Qt.NoModifier,20);
        mouseMove(activityBackground,start.x+15,start.y+15,20,Qt.LeftButton);
        mouseMove(activityBackground,start.x+30,start.y+30,20,Qt.LeftButton);
        mouseMove(activityBackground,end.x,end.y,60,Qt.LeftButton);
        mouseRelease(activityBackground,end.x,end.y,Qt.LeftButton,Qt.NoModifier,20);
        wait(300);
    }
    function test_covered_disc_stays_until_exposed_with_top_redirection() {
        wait(1800);
        var first=towerModel.itemAt(0),stack=discStack(first);
        verify(stack.length>=2);
        var lower=stack[0],initial=state(),redirects=[];
        verify(lower.y>stack[stack.length-1].y,"Lower disc selected from drawn vertical order");
        var lowerStart=lower.mapToItem(activityBackground,lower.width/2,lower.height/2);
        var count=stack.length-1;
        var real=activity.activityMode==="real";
        for(var step=0;step<count;step++) {
            stack=discStack(first);
            var upper=stack[stack.length-1];
            verify(!lower.enabled && !lower.discMouseArea.enabled,"Covered lower disc is blocked");
            verify(upper.enabled);
            var target=towerModel.itemAt(real?step+1:towerModel.count-2);
            var before=state();
            dragFrom(lowerStart,target);
            var after=state();
            compare(upper.parent,target,"Expanded input region redirects the real drag to the enabled top");
            compare(lower.parent,first);
            for(var i=0;i<before.length;i++) {
                if(i===upper.index)continue;
                compare(after[i].parent,before[i].parent,"Other discs retain parent");
                compare(after[i].x,before[i].x,"Other discs retain drawn x");
                compare(after[i].y,before[i].y,"Other discs retain drawn y");
            }
            redirects.push({lower:lower.index,upper:upper.index,start:[lowerStart.x,lowerStart.y],before:before,after:after});
        }
        compare(discStack(first).length,1);
        verify(lower.enabled && lower.discMouseArea.enabled,"The lower disc becomes movable only after exposure");
        if(real) {
            // Free peg1 by moving the small disc onto the medium disc on peg2.
            var small=discStack(towerModel.itemAt(1))[0];
            dragFrom(small.mapToItem(activityBackground,small.width/2,small.height/2),towerModel.itemAt(2));
            compare(small.parent,towerModel.itemAt(2));
        }
        var exposedBefore=state();
        dragFrom(lowerStart,towerModel.itemAt(1));
        compare(lower.parent,towerModel.itemAt(1),"The same lower-image drag works once it is exposed");
        evidence={activity:activity.activityInfo.shortName(),selectedLower:lower.index,
                  initial:initial,redirects:redirects,exposedBefore:exposedBefore,exposedAfter:state(),
                  coveredNeverMoved:true,onlyTopRedirected:true,exposedMoved:true};
        grabImage(activityBackground).save("__QA_OUTPUT__/covered-disc.png");
    }
    function cleanupTestCase(){console.log("NATIVE_HANOI_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,covered:evidence}));}
}
