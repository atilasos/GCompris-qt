// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "PathsFromVisibleMapAndArrows"
    when: activity.visible && mapView.width>0
    property int targetLevels: 7
    property var completed: []
    property int moves: 0
    property int rejected: 0
    property var vectors: [[0,-1],[1,0],[0,1],[-1,0]]
    function checked(a,b,message) {
        if(a!==b)console.log("PATH_ASSERT",String(a),String(b),message||"",new Error().stack);
        compare(a,b,message||"");
    }
    function ensure(value,message) {
        if(!value)console.log("PATH_ASSERT",message||"",new Error().stack);
        verify(value,message||"");
    }
    function find(root,predicate) {
        if(predicate(root))return root;
        if(root.children)for(var child of root.children){var found=find(child,predicate);if(found)return found;}
        return null;
    }
    function grid() {var value=find(mapView,function(o){return o.cellWidth!==undefined && o.itemAtIndex!==undefined;});ensure(value!==null);return value;}
    function position() {
        var g=grid(),point=tux.mapToItem(mapView,tux.width/2,tux.height/2);
        return [Math.floor(point.x/g.cellWidth),Math.floor(point.y/g.cellHeight)];
    }
    function settled() {
        var last=[tux.x,tux.y,tux.rotation],stable=0;
        for(var i=0;i<100 && stable<3;i++) {
            wait(50);var now=[tux.x,tux.y,tux.rotation];
            stable=now.every(function(v,j){return Math.abs(v-last[j])<0.01;})?stable+1:0;last=now;
        }
        ensure(stable>=3,"Tux animation settles naturally");
    }
    function facing() {return ((Math.round(tux.rotation/90)+2)%4+4)%4;}
    function arrow(image) {return ((Math.round(image.rotation/90)+1)%4+4)%4;}
    function instruction() {
        var box=moveBar.movesGridView.currentItem;ensure(box!==null,"Current instruction is drawn");
        var active=find(box,function(o){return o.color!==undefined && String(o.color)==="#e99e33";});
        ensure(active!==null,"Selected instruction has the orange highlight");
        var image=find(active,function(o){return o.source!==undefined && String(o.source).endsWith("/arrow.svg");});
        ensure(image!==null);checked(image.status,Image.Ready);return arrow(image);
    }
    function clickCell(cell) {
        var g=grid();mouseClick(mapView,(cell[0]+0.5)*g.cellWidth,(cell[1]+0.5)*g.cellHeight);settled();
    }
    function encodeInput(direction,useButton) {
        if(useButton) {
            var button=find(moveButtons,function(o){return o.source!==undefined && String(o.source).endsWith("/arrow.svg") && arrow(o)===direction;});
            ensure(button!==null);mouseClick(button);
        } else keyClick([Qt.Key_Up,Qt.Key_Right,Qt.Key_Down,Qt.Key_Left][direction]);
        settled();
    }
    function visibleRoute(start) {
        var g=grid(),allowed={},end=null;
        for(var i=0;i<g.count;i++) {
            var block=g.itemAtIndex(i);ensure(block!==null,"All map cells are drawn");
            var x=Math.round(block.x/g.cellWidth),y=Math.round(block.y/g.cellHeight);
            var path=find(block,function(o){return o.color!==undefined && o.visible && String(o.color)==="#d1c8be";});
            var flag=find(block,function(o){return o.source!==undefined && String(o.source).endsWith("/flag.svg");});
            if(path!==null || flag!==null)allowed[[x,y].join()]=true;
            if(flag!==null){ensure(end===null);end=[x,y];checked(flag.status,Image.Ready);}
        }
        ensure(end!==null);var queue=[start],seen={};seen[start.join()]=null;
        for(var at=0;at<queue.length;at++) {
            var cell=queue[at];if(cell.join()===end.join())break;
            for(var d=0;d<4;d++) {
                var next=[cell[0]+vectors[d][0],cell[1]+vectors[d][1]],key=next.join();
                if(!allowed[key] || seen[key]!==undefined)continue;
                seen[key]={cell:cell,direction:d};queue.push(next);
            }
        }
        ensure(seen[end.join()]!==undefined,"Visible path reaches the flag");
        var route=[],cell=end;
        while(seen[cell.join()]!==null){var entry=seen[cell.join()];route.unshift({next:cell,direction:entry.direction});cell=entry.cell;}
        return {route:route,end:end};
    }
    function test_complete_paths() {
        wait(1600);settled();checked(activity.numberOfLevel,7);
        ensure(errorsText.text.indexOf("Erros:")===0,"Portuguese error label");
        for(var level=0;level<targetLevels;level++) {
            checked(activity.currentLevel,level);var start=position(),before=moves;
            var encode=activity.mode==="encode",relative=activity.movement==="relative";
            var route=encode?visibleRoute(start):null;
            if(encode) {
                ensure(route.route.length>0);
                var correct=relative?(route.route[0].direction-facing()+4)%4:route.route[0].direction;
                encodeInput((correct+2)%4,false);
            } else clickCell(start);
            checked(position().join(),start.join(),"Wrong choice does not move Tux");
            checked(Number(errorsText.text.match(/\d+/)[0]),1);rejected++;
            if(encode) {
                for(var step of route.route) {
                    var command=relative?(step.direction-facing()+4)%4:step.direction;
                    encodeInput(command,moves%2===1);checked(position().join(),step.next.join());moves++;
                }
            } else {
                for(var guard=0;!bonus.isPlaying && guard<200;guard++) {
                    var command=instruction(),absolute=relative?(facing()+command)%4:command;
                    var current=position(),next=[current[0]+vectors[absolute][0],current[1]+vectors[absolute][1]];
                    clickCell(next);checked(position().join(),next.join());moves++;
                }
                ensure(bonus.isPlaying,"Visible instructions lead to completion");
            }
            completed.push({level:level+1,mode:activity.mode,movement:activity.movement,moves:moves-before});
            console.log("PATH_LEVEL_COMPLETE",JSON.stringify(completed[completed.length-1]));
            tryCompare(bonus,"isPlaying",true,5000);
            grabImage(activityBackground).save("__QA_OUTPUT__/path-"+(level+1)+".png");
            tryCompare(activity,"currentLevel",(level+1)%7,10000);wait(600);settled();
        }
    }
    function cleanupTestCase(){console.log("NATIVE_PATH_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,moves:moves,rejected:rejected}));}
}
