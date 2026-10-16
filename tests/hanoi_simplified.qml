// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "CopyVisibleHanoiTower"
    when: activity.visible && discRepeater.count>0
    property var completed: []
    property int moves: 0
    property int rejected: 0
    property var stacks: []
    property var pegs: []
    property var reference: []
    property int destination: 0
    property int capacity: 0
    property bool solved: false
    function checked(actual,expected,message) {
        if(actual!==expected)console.log("HANOI_ASSERT",String(actual),String(expected),message||"",new Error().stack);
        compare(actual,expected,message||"");
    }
    function ensure(value,message) {
        if(!value)console.log("HANOI_ASSERT",message||"",new Error().stack);
        verify(value,message||"");
    }
    function signature(disc) {return disc.text+":"+String(disc.color);}
    function observe() {
        pegs=[];stacks=[];
        for(var i=0;i<towerModel.count;i++){pegs.push(towerModel.itemAt(i));stacks.push([]);}
        for(var i=0;i<discRepeater.count;i++) {
            var disc=discRepeater.itemAt(i),peg=pegs.indexOf(disc.parent);
            ensure(peg>=0);stacks[peg].push(disc);
        }
        for(var stack of stacks)stack.sort(function(a,b){return b.y-a.y;});
        destination=pegs.length-2;
        ensure(String(pegs[destination].source).endsWith("disc_support-green.svg"));
        ensure(String(pegs[pegs.length-1].source).endsWith("disc_support-red.svg"));
        reference=stacks[stacks.length-1].map(signature);capacity=reference.length;
        checked(stacks[destination].length,0);
    }
    function drag(disc,target) {
        var start=disc.mapToItem(activityBackground,disc.width/2,disc.height/2);
        var end=target.mapToItem(activityBackground,target.width/2,target.height/2);
        mousePress(activityBackground,start.x,start.y,Qt.LeftButton,Qt.NoModifier,20);
        mouseMove(activityBackground,start.x+15,start.y+15,20,Qt.LeftButton);
        mouseMove(activityBackground,start.x+30,start.y+30,20,Qt.LeftButton);
        mouseMove(activityBackground,end.x,end.y,50,Qt.LeftButton);
        mouseRelease(activityBackground,end.x,end.y,Qt.LeftButton,Qt.NoModifier,20);wait(100);
    }
    function matchesReference() {
        return stacks[destination].length===capacity && stacks[destination].every(function(disc,i){return signature(disc)===reference[i];});
    }
    function move(from,to) {
        ensure(from!==to);ensure(stacks[from].length>0);ensure(stacks[to].length<capacity);
        var disc=stacks[from][stacks[from].length-1];ensure(disc.enabled,"Only visible top discs move");
        drag(disc,pegs[to]);checked(disc.parent,pegs[to]);
        stacks[from].pop();stacks[to].push(disc);moves++;
        solved=matchesReference();
        return solved;
    }
    function spare(exclude) {
        for(var i=0;i<destination;i++)if(i!==exclude && stacks[i].length<capacity)return i;
        return -1;
    }
    function extract(from,index) {
        // The green peg temporarily holds the segment in reverse. Park its
        // desired top elsewhere, restore blockers, then append the wanted disc.
        var blockers=stacks[from].length-index-1;
        var room=capacity-stacks[destination].length;
        while(blockers+1>room) {
            var target=spare(from);ensure(target>=0);
            if(move(from,target))return;blockers--;
        }
        if(spare(from)<0) {
            var donor=from===0?1:0;
            if(move(donor,from))return;blockers++;
        }
        ensure(blockers+1<=room);var parking=spare(from);ensure(parking>=0);
        for(var i=0;i<=blockers;i++)if(move(from,destination))return;
        if(move(destination,parking))return;
        for(var i=0;i<blockers;i++)if(move(destination,from))return;
        move(parking,destination);
    }
    function test_complete_six_visible_copy_levels() {
        wait(1600);checked(activity.numberOfLevel,6);
        for(var level=0;level<6;level++) {
            checked(activity.currentLevel,level);observe();solved=false;
            var before=moves;
            // Filling an auxiliary peg and dropping another disc there must fail.
            var first=stacks[0][stacks[0].length-1];
            move(0,1);checked(stacks[1].length,capacity);
            var blocked=stacks[0][stacks[0].length-1];
            drag(blocked,pegs[1]);checked(blocked.parent,pegs[0]);rejected++;
            drag(blocked,pegs[pegs.length-1]);checked(blocked.parent,pegs[0]);rejected++;
            move(1,0);checked(first.parent,pegs[0]);
            for(var wanted=0;wanted<capacity && !solved;wanted++) {
                checked(stacks[destination].length,wanted);
                var choice=null;
                for(var peg=0;peg<destination;peg++)for(var index=0;index<stacks[peg].length;index++) {
                    if(signature(stacks[peg][index])!==reference[wanted])continue;
                    var depth=stacks[peg].length-index-1;
                    if(choice===null || depth<choice.depth)choice={peg:peg,index:index,depth:depth};
                }
                ensure(choice!==null,"Visible reference has an available matching colour and symbol");
                extract(choice.peg,choice.index);
                if(!solved) {
                    checked(stacks[destination].length,wanted+1);
                    for(var i=0;i<=wanted;i++)checked(signature(stacks[destination][i]),reference[i]);
                }
            }
            ensure(solved);checked(stacks[stacks.length-1].map(signature).join("|"),reference.join("|"));
            var actual=[];
            for(var i=0;i<discRepeater.count;i++) {
                var visibleDisc=discRepeater.itemAt(i);
                if(visibleDisc.parent===pegs[destination])actual.push(visibleDisc);
            }
            actual.sort(function(a,b){return b.y-a.y;});
            checked(actual.map(signature).join("|"),reference.join("|"),"Actual drawn bottom-to-top order matches the visible reference");
            completed.push({level:level+1,height:capacity,auxiliaryPegs:destination,moves:moves-before,reference:reference.slice()});
            tryCompare(bonus,"isPlaying",true,5000);
            grabImage(activityBackground).save("__QA_OUTPUT__/simplified-"+(level+1)+".png");
            tryCompare(activity,"currentLevel",(level+1)%6,10000);wait(600);
        }
    }
    function cleanupTestCase(){console.log("NATIVE_HANOI_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,moves:moves,rejected:rejected}));}
}
