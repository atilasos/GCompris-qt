// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "MazeFromDrawnWalls"
    when: activity.visible && mazeRepeater.count > 0
    property var completed: []
    property int attempts: 0
    property int collisions: 0
    property int rotations: 0
    property int lastLevel: 0
    property int levelCount: 25
    property bool fast: false
    property bool pointerInput: false
    property var vectors: [[0,-1],[1,0],[0,1],[-1,0]]
    function checked(actual, expected, message) {
        if (actual !== expected) console.log("MAZE_ASSERT", String(actual), String(expected), message || "", new Error().stack);
        compare(actual, expected, message || "");
    }
    function ensure(value, message) {
        if (!value) console.log("MAZE_ASSERT", message || "", new Error().stack);
        verify(value, message || "");
    }
    function coordinate() {
        var size = mazeRepeater.itemAt(0).width;
        return [Math.floor((player.x-maze.x)/size), Math.floor((player.y-maze.y)/size)];
    }
    function settled() {
        var previous = [player.x,player.y], stable = 0;
        for(var tries=0; tries<300 && stable<4; tries++) {
            wait(50);
            var current=[player.x,player.y];
            stable = Math.abs(previous[0]-current[0])<0.01 && Math.abs(previous[1]-current[1])<0.01 ? stable+1 : 0;
            previous=current;
        }
        ensure(stable>=4, "Movement settles naturally");
    }
    function input(direction) {
        if(pointerInput) {
            var start=maze.mapToItem(activityBackground,maze.width/2,maze.height/2);
            var delta=vectors[direction];
            mousePress(activityBackground,start.x,start.y,Qt.LeftButton,Qt.NoModifier,20);
            mouseMove(activityBackground,start.x+delta[0]*50,start.y+delta[1]*50,30,Qt.LeftButton);
            mouseRelease(activityBackground,start.x+delta[0]*50,start.y+delta[1]*50,Qt.LeftButton,Qt.NoModifier,20);
        } else keyClick([Qt.Key_Up,Qt.Key_Right,Qt.Key_Down,Qt.Key_Left][direction]);
        attempts++; settled();
    }
    function facing() { return ((Math.round(player.rotation/90)+2)%4+4)%4; }
    function turn(direction) {
        for(var guard=0; facing()!==direction && guard<4; guard++) {
            var before=coordinate();input(1);rotations++;
            checked(coordinate().join(),before.join(),"Turning does not translate");
        }
        checked(facing(),direction);
    }
    function travel(direction) {if(activity.relativeMode) {turn(direction);input(0);} else input(direction);}
    function reveal(visible) {
        if(activity.invisibleMode && message.visible !== visible) {keyClick(Qt.Key_Space);wait(200);}
        if(activity.invisibleMode) checked(message.visible,visible);
    }
    function observeWalls() {
        var result=[];
        for(var i=0;i<mazeRepeater.count;i++) {
            var cell=mazeRepeater.itemAt(i), walls=[false,false,false,false], count=0;
            for(var wall of cell.children) {
                if(wall.color===undefined)continue;
                var direction=wall.width>wall.height ? (wall.y<0?0:2) : (wall.x<0?3:1);
                walls[direction]=wall.visible;count++;
            }
            checked(count,4);result.push(walls);
        }
        return result;
    }
    function path(walls,start,end) {
        var cols=maze.columns,rows=maze.rows,queue=[start],seen={};seen[start.join()]=null;
        for(var cursor=0;cursor<queue.length;cursor++) {
            var cell=queue[cursor];if(cell.join()===end.join())break;
            for(var d=0;d<4;d++) {
                if(walls[cell[1]*cols+cell[0]][d])continue;
                var next=[cell[0]+vectors[d][0],cell[1]+vectors[d][1]];
                ensure(next[0]>=0 && next[0]<cols && next[1]>=0 && next[1]<rows,"Drawn boundary is closed");
                checked(walls[next[1]*cols+next[0]][(d+2)%4],false,"Drawn passages agree");
                if(seen[next.join()]!==undefined)continue;
                seen[next.join()]={cell:cell,direction:d};queue.push(next);
            }
        }
        ensure(seen[end.join()]!==undefined,"Visible walls provide a route to the door");
        var route=[],here=end;
        while(seen[here.join()]!==null) {var entry=seen[here.join()];route.unshift({cell:entry.cell,direction:entry.direction});here=entry.cell;}
        return route;
    }
    function test_complete_visible_routes() {
        wait(1600);
        checked(activity.numberOfLevel,25);
        for(var level=0;level<levelCount;level++) {
            lastLevel=level+1;checked(activity.currentLevel,level);
            // Initial layout animations may still be moving the player in the
            // level's default fast mode. Choose the public control, then wait
            // before observing the starting cell and drawing a route.
            reveal(false);
            if(shoes.visible!==fast) {mouseClick(fastmode);wait(150);}
            checked(shoes.visible,fast);settled();
            reveal(true);
            var walls=observeWalls(),start=coordinate(),size=mazeRepeater.itemAt(0).width;
            var end=[maze.columns-1,Math.floor((door.y-maze.y)/size)];
            if(activity.invisibleMode) {
                var before=coordinate();input(1);checked(coordinate().join(),before.join(),"Cannot move while viewing the map");
                ensure(message.text.length>20 && message.text.indexOf("Look at")<0,"Portuguese map instruction");
                reveal(false);
            }
            // A drawn wall at the starting cell must block translation.
            var blocked=walls[start[1]*maze.columns+start[0]].indexOf(true);
            ensure(blocked>=0);travel(blocked);checked(coordinate().join(),start.join());collisions++;
            var route=path(walls,start,end), index=0, began=attempts;
            while(coordinate().join()!==end.join()) {
                ensure(index<route.length,"Player remains on the independently chosen route");
                checked(coordinate().join(),route[index].cell.join());
                travel(route[index].direction);
                var current=coordinate();
                if(current.join()===end.join())break;
                var next=index+1;
                while(next<route.length && route[next].cell.join()!==current.join())next++;
                ensure(next<route.length,"Automatic movement stops on the visible route");index=next;
            }
            completed.push({level:level+1,columns:maze.columns,rows:maze.rows,pathCells:route.length+1,inputs:attempts-began,fast:fast,relative:activity.relativeMode,invisible:activity.invisibleMode});
            console.log("MAZE_LEVEL_COMPLETE",JSON.stringify(completed[completed.length-1]));
            tryCompare(bonus,"isPlaying",true,5000);
            if(level===0 || level===13 || level===24)grabImage(activityBackground).save("__QA_OUTPUT__/maze-"+(level+1)+".png");
            tryCompare(activity,"currentLevel",(level+1)%25,10000);wait(600);
        }
    }
    function cleanupTestCase() {console.log("NATIVE_MAZE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,attempts:attempts,collisions:collisions,rotations:rotations,lastLevel:lastLevel}));}
}
