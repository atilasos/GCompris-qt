// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "PathsFromVisibleMapAndArrows"
    when: activity.visible && mapView.width>0
    property int targetLevels: 1
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
    property var controls: ({})
    function icon(suffix) {
        wait(1600);var button=find(bar,function(o){return o.source!==undefined && String(o.source).endsWith(suffix);});
        ensure(button!==null,suffix);mouseClick(button);
    }
    function firstCheckbox() {return find(dialogActivityConfig,function(o){return o.indicatorImageHeight!==undefined && o.checked!==undefined;});}
    function saveConfig() {dialogActivityConfig.forceActiveFocus();keyClick(Qt.Key_Return);tryCompare(activity,"visible",true,3000);wait(1200);settled();}
    function test_configuration_restart_help_and_menu() {
        wait(1600);settled();checked(activity.numberOfLevel,7);
        var titles={path_encoding:"Codificação de caminhos",path_encoding_relative:"Codificação de caminhos relativos",
                    path_decoding:"Descodificação de caminhos",path_decoding_relative:"Descodificação de caminhos relativos"};
        var shortName=activity.activityInfo.shortName();checked(activity.activityInfo.title,titles[shortName]);
        var start=position(),encode=activity.mode==="encode",relative=activity.movement==="relative";
        if(encode) {
            var step=visibleRoute(start).route[0],command=relative?(step.direction-facing()+4)%4:step.direction;
            encodeInput(command,true);checked(position().join(),step.next.join());
        } else {
            var command=instruction(),absolute=relative?(facing()+command)%4:command;
            clickCell([start[0]+vectors[absolute][0],start[1]+vectors[absolute][1]]);
        }
        ensure(position().join()!==start.join(),"Partial real move before configuration");
        icon("bar_activity_config.svg");tryCompare(dialogActivityConfig,"visible",true,3000);wait(1200);
        var first=firstCheckbox();ensure(first!==null && first.checked);var label=first.text;
        mouseClick(first);checked(first.checked,false);saveConfig();checked(activity.numberOfLevel,5);checked(activity.currentLevel,0);
        checked(Number(errorsText.text.match(/\d+/)[0]),0);checked(grid().count,64);
        if(encode)checked(moveBar.movesGridView.count,0);
        icon("bar_activity_config.svg");tryCompare(dialogActivityConfig,"visible",true,3000);wait(1200);
        first=firstCheckbox();checked(first.text,label);checked(first.checked,false);
        checked(activity.activityInfo.currentLevels.length,3);checked(ApplicationSettings.ignoredLevels(shortName).length,1);
        mouseClick(first);saveConfig();checked(activity.numberOfLevel,7);checked(grid().count,36);
        icon("bar_previous.svg");tryCompare(activity,"currentLevel",6);wait(600);settled();
        icon("bar_next.svg");tryCompare(activity,"currentLevel",0);wait(600);settled();
        var depth=pageView.depth;icon("bar_help.svg");tryCompare(pageView,"depth",depth+1);wait(600);
        var help=pageView.currentItem;checked(help.title,titles[shortName]);
        ensure(help.content.indexOf(activity.activityInfo.manual)>=0);
        ensure(help.content.indexOf("Use the arrow buttons")<0 && help.content.indexOf("The directions are")<0);
        grabImage(pageView).save("__QA_OUTPUT__/help.png");
        keyClick(Qt.Key_Escape);tryCompare(pageView,"depth",depth);wait(600);settled();
        var before=position();
        if(encode) {
            var step=visibleRoute(before).route[0],command=relative?(step.direction-facing()+4)%4:step.direction;
            encodeInput(command,false);checked(position().join(),step.next.join());
        } else {
            var command=instruction(),absolute=relative?(facing()+command)%4:command;
            clickCell([before[0]+vectors[absolute][0],before[1]+vectors[absolute][1]]);
        }
        ensure(position().join()!==before.join(),"Input works after closing help without forcing focus");
        controls={activity:shortName,title:activity.activityInfo.title,datasets:4,levels:7,reducedLevels:5,
                  configurationSaved:true,restartClearedPartial:true,helpEscape:true,moveAfterHelp:true,navigation:true};
        ActivityInfoTree.startingActivity="";icon("bar_home.svg");tryCompare(pageView,"depth",1);ensure(pageView.currentItem.isMenu);
        grabImage(pageView).save("__QA_OUTPUT__/menu.png");
    }
    function cleanupTestCase(){console.log("NATIVE_PATH_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,controls:controls}));}
}
