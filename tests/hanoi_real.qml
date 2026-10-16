// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "ClassicHanoiByVisibleSizes"
    when: activity.visible && discRepeater.count>0
    property var completed: []
    property int moves: 0
    property int rejected: 0
    function checked(actual,expected,message) {
        if(actual!==expected)console.log("HANOI_ASSERT",String(actual),String(expected),message||"",new Error().stack);
        compare(actual,expected,message||"");
    }
    function ensure(value,message) {
        if(!value)console.log("HANOI_ASSERT",message||"",new Error().stack);
        verify(value,message||"");
    }
    function drag(disc,target) {
        var start=disc.mapToItem(activityBackground,disc.width/2,disc.height/2);
        var end=target.mapToItem(activityBackground,target.width/2,target.height/2);
        mousePress(activityBackground,start.x,start.y,Qt.LeftButton,Qt.NoModifier,20);
        mouseMove(activityBackground,start.x+15,start.y+15,20,Qt.LeftButton);
        mouseMove(activityBackground,start.x+30,start.y+30,20,Qt.LeftButton);
        mouseMove(activityBackground,end.x,end.y,50,Qt.LeftButton);
        mouseRelease(activityBackground,end.x,end.y,Qt.LeftButton,Qt.NoModifier,20);
        wait(120);
    }
    function plan(count,from,to,spare,result) {
        if(!count)return;
        plan(count-1,from,spare,to,result);
        result.push({size:count-1,from:from,to:to});
        plan(count-1,spare,to,from,result);
    }
    function test_complete_three_classic_levels() {
        wait(1600);checked(activity.numberOfLevel,3);
        for(var level=0;level<3;level++) {
            checked(activity.currentLevel,level);
            var discs=[];
            for(var i=0;i<discRepeater.count;i++)discs.push(discRepeater.itemAt(i));
            discs.sort(function(a,b){return a.width-b.width;});
            checked(discs.length,level+3);
            for(var i=0;i<discs.length;i++) {
                checked(discs[i].parent,towerModel.itemAt(0));
                if(i)ensure(discs[i].width>discs[i-1].width);
            }
            // Put the smallest on a spare peg, then try the forbidden larger disc.
            drag(discs[0],towerModel.itemAt(1));checked(discs[0].parent,towerModel.itemAt(1));
            drag(discs[1],towerModel.itemAt(1));checked(discs[1].parent,towerModel.itemAt(0));
            checked(discs[0].parent,towerModel.itemAt(1));rejected++;
            drag(discs[0],towerModel.itemAt(0));checked(discs[0].parent,towerModel.itemAt(0));
            var sequence=[];plan(discs.length,0,2,1,sequence);
            checked(sequence.length,Math.pow(2,discs.length)-1);
            var stacks=[[],[],[]];
            for(var i=discs.length-1;i>=0;i--)stacks[0].push(i);
            for(var step of sequence) {
                checked(stacks[step.from][stacks[step.from].length-1],step.size);
                if(stacks[step.to].length)ensure(step.size<stacks[step.to][stacks[step.to].length-1]);
                var disc=discs[step.size];ensure(disc.enabled,"Only a top disc moves");
                drag(disc,towerModel.itemAt(step.to));checked(disc.parent,towerModel.itemAt(step.to));
                stacks[step.from].pop();stacks[step.to].push(step.size);moves++;
            }
            for(var disc of discs)checked(disc.parent,towerModel.itemAt(2));
            var drawn=discs.slice().sort(function(a,b){return b.y-a.y;});
            for(var i=1;i<drawn.length;i++)ensure(drawn[i-1].width>drawn[i].width,"Actual drawn stack decreases in size upwards");
            completed.push({level:level+1,discs:discs.length,moves:sequence.length});
            tryCompare(bonus,"isPlaying",true,5000);
            grabImage(activityBackground).save("__QA_OUTPUT__/classic-"+(level+1)+".png");
            tryCompare(activity,"currentLevel",(level+1)%3,10000);wait(600);
        }
    }
    function cleanupTestCase(){console.log("NATIVE_HANOI_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,moves:moves,rejected:rejected}));}
}
