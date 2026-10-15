// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "MazeFromDrawnWalls"
    when: activity.visible && mazeRepeater.count > 0
    property var completed: []
    property int attempts: 0
    property int collisions: 0
    property int rotations: 0
    property int lastLevel: 0
    property int levelCount: 1
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
    function test_revealed_map_pauses_automatic_movement() {
        wait(1600);
        if(shoes.visible) {reveal(false);mouseClick(fastmode);}
        settled();reveal(true);var walls=observeWalls();reveal(false);
        var cols=maze.columns, rows=maze.rows, choice=null;
        for(var y=0;y<rows && choice===null;y++)for(var x=0;x<cols && choice===null;x++)for(var d=0;d<4;d++) {
            if(walls[y*cols+x][d])continue;
            var next=[x+vectors[d][0],y+vectors[d][1]];
            if(next[0]===cols-1)continue;
            var openings=walls[next[1]*cols+next[0]].filter(function(w){return !w;}).length;
            if(openings===2) {choice={cell:[x,y],direction:d,next:next};break;}
        }
        ensure(choice!==null,"Visible board contains an automatic corridor");
        var route=path(walls,coordinate(),choice.cell);
        for(var step of route) {checked(coordinate().join(),step.cell.join());travel(step.direction);}
        checked(coordinate().join(),choice.cell.join());
        mouseClick(fastmode);wait(100);checked(shoes.visible,true);
        keyClick([Qt.Key_Up,Qt.Key_Right,Qt.Key_Down,Qt.Key_Left][choice.direction]);
        wait(20);keyClick(Qt.Key_Space);wait(20);checked(message.visible,true);
        wait(700);
        console.log("MAP_PAUSE_OBSERVATION",JSON.stringify({expected:choice.next,actual:coordinate(),mapVisible:message.visible}));
        checked(coordinate().join(),choice.next.join(),"Revealed map suspends further automatic steps");
    }
    function cleanupTestCase() {console.log("NATIVE_MAZE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,attempts:attempts,collisions:collisions,rotations:rotations,lastLevel:lastLevel}));}
}
