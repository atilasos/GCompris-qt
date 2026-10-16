import QtTest
/* GCompris - lightsoff.qml
*
* SPDX-FileCopyrightText: 2014 Stephane Mankowski <stephane@mankowski.fr>
*
* Authors:
*   Bruno Coudoin <bruno.coudoin@gcompris.net> (GTK+ version)
*   Stephane Mankowski <stephane@mankowski.fr> (Qt Quick port)
*   Timothée Giet <animtim@gmail.com> (Layout and visual refactoring)
*
*   SPDX-License-Identifier: GPL-3.0-or-later
*/
pragma ComponentBehavior: Bound

import QtQuick
import core 1.0

import "../../core"
import "lightsoff.js" as Activity

ActivityBase {
    id: activity

    onStart: focus = true
    onStop: {

    }

     onActivityNextLevel: {
         Activity.nextLevel()
    }

    pageComponent: Image {
        id: activityBackground
        source: "qrc:/gcompris/src/activities/family/resource/background.svg"
        anchors.fill: parent
        sourceSize.width: width
        sourceSize.height: height
        fillMode: Image.PreserveAspectCrop

        signal start
        signal stop

        property bool keyNavigationVisible: false

        Component.onCompleted: {
            dialogActivityConfig.initialize()
            activity.start.connect(start)
            activity.stop.connect(stop)
        }

        // Add here the QML items you need to access in javascript
        QtObject {
            id: items
            property Item main: activity.main
            property alias activityBackground: activityBackground
            property alias scrollSound: scrollSound
            property int currentLevel: activity.currentLevel
            onCurrentLevelChanged: activity.currentLevel = currentLevel
            property int numberOfLevel: 0
            onNumberOfLevelChanged: activity.numberOfLevel = numberOfLevel
            property alias bonus: bonus
            property bool isPortrait: (activityBackground.height >= activityBackground.width - tux.width)
            property alias nightSky: nightSky.opacity
            property alias modelTable: modelTable
            readonly property var levels: activity.datasets
            property bool blockClicks: false
            property int nbCell: 5
            property int cellSize: isPortrait ? Math.min((activityBackground.height - bar.height * 2.5) / items.nbCell,
                                                         (activityBackground.width - 40) / items.nbCell) :
                                                (activityBackground.height - bar.height * 1.5) / items.nbCell
            property int nbCelToWin: 0
            property var lightRatio: items.nbCelToWin / (items.nbCell * items.nbCell)
        }

        onStart: {
            Activity.start(items)
        }
        onStop: {
            Activity.stop()
        }

        Keys.enabled: !items.blockClicks
        Keys.onPressed: (event) => {
            if ([Qt.Key_Left, Qt.Key_Right, Qt.Key_Up, Qt.Key_Down, Qt.Key_Space, Qt.Key_Enter, Qt.Key_Return].indexOf(event.key) === -1)
                return;
            event.accepted = true;
            activityBackground.keyNavigationVisible = true
            if (event.key === Qt.Key_Left)
                grid.moveCurrentIndexLeft()
            if (event.key === Qt.Key_Right)
                grid.moveCurrentIndexRight()
            if (event.key === Qt.Key_Down)
                grid.moveCurrentIndexDown()
            if (event.key === Qt.Key_Up)
                grid.moveCurrentIndexUp()
            if (event.key === Qt.Key_Space || event.key === Qt.Key_Enter || event.key === Qt.Key_Return)
                Activity.windowPressed(grid.currentIndex)
        }

        states: [
            State {
                id: verticalState
                when: items.isPortrait
                AnchorChanges {
                    target: building
                    anchors.bottom: tux.verticalCenter
                }
            },
            State {
                id: horizontalState
                when: !items.isPortrait
                AnchorChanges {
                    target: building
                    anchors.bottom: tux.bottom
                }
            }
        ]

        GCSoundEffect {
            id: scrollSound
            source: "qrc:/gcompris/src/core/resource/sounds/scroll.wav"
        }

        Rectangle {
            id: nightSky
            color: "#052e3c"
            opacity: items.lightRatio
            anchors.fill: activityBackground
        }

        Image {
            id: sun
            source: "qrc:/gcompris/src/activities/menu/resource/all.svg"
            sourceSize.height: items.cellSize * 2 * items.nbCell / 5
            anchors {
                left: parent.left
                top: parent.top
                topMargin: (parent.height - land.height) * items.lightRatio
            }
            Behavior on anchors.topMargin {
                PropertyAnimation {
                    duration: 1000
                }
            }
        }

        Image {
            id: land
            source: activity.resourceUrl + "back.svg"
            anchors.bottom: parent.bottom
            anchors.top: tux.top
            anchors.left: parent.left
            anchors.right: parent.right
            fillMode: Image.PreserveAspectCrop
            sourceSize.height: height
        }
        Rectangle {
            id: buildingBorders
            color: GCStyle.grayBorder
            width: building.width + GCStyle.halfMargins
            height: building.height + GCStyle.halfMargins * 0.5
            anchors.horizontalCenter: building.horizontalCenter
            anchors.bottom: building.bottom
        }
        Rectangle {
            id: building
            color: "#c8c8c8"
            width: gridarea.width
            anchors.top: grid.top
            anchors.bottom: tux.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: items.cellSize * -0.5
        }

        Rectangle {
            id: gridarea
            visible: false
            width: items.cellSize * items.nbCell
            anchors.top: parent.top
            anchors.bottom: tux.bottom
            anchors.horizontalCenter: parent.horizontalCenter
        }

        GridView {
            id: grid
            anchors.verticalCenter: gridarea.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            width: items.nbCell * items.cellSize
            height: width
            cellWidth: items.cellSize
            cellHeight: items.cellSize

            ListModel {
                id: modelTable
            }

            model: modelTable

            delegate: Rectangle {
                id: window
                required property int soluce
                required property int lighton
                required property int index
                color: soluce === 1 ? "#20df543d" : "transparent"
                height: items.cellSize
                width: items.cellSize
                border {
                    color: soluce === 1 ? "#df543d" : "transparent"
                    width: GCStyle.thinBorder
                }
                radius: GCStyle.halfMargins

                BarButton {
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: window.lighton === 1 ? activity.resourceUrl + "on.svg" : activity.resourceUrl + "off.svg"
                    mouseArea.hoverEnabled: !items.blockClicks
                    mouseArea.enabled: !items.blockClicks
                    onClicked: Activity.windowPressed(window.index)
                    visible: true
                }
            }

            interactive: false
            keyNavigationWraps: true
            highlightFollowsCurrentItem: true
            highlight: Rectangle {
                width: items.cellSize
                height: items.cellSize
                color: GCStyle.whiteBg
                opacity: 0.8
                radius: GCStyle.halfMargins
                visible: activityBackground.keyNavigationVisible
                Behavior on x { SpringAnimation { spring: 2; damping: 0.2 } }
                Behavior on y { SpringAnimation { spring: 2; damping: 0.2 } }
            }
        }

        Image {
            source: activity.resourceUrl + "grass.svg"
            anchors.verticalCenter: building.bottom
            anchors.horizontalCenter: building.horizontalCenter
            width: buildingBorders.width
            sourceSize.height: height
            fillMode: Image.TileHorizontally
        }

        BarButton {
            id: tux
            fillMode: Image.PreserveAspectFit
            source: "qrc:/gcompris/src/activities/ballcatch/resource/tux.svg"
            width: bar.height
            visible: true
            anchors {
                right: parent.right
                bottom: bar.top
                margins: GCStyle.baseMargins
            }
            onClicked: Activity.solve()
        }

        DialogHelp {
            id: dialogHelp
            onClose: activity.home()
        }

        DialogChooseLevel {
            id: dialogActivityConfig
            currentActivity: activity.activityInfo

            onSaveData: {
                activity.levelFolder = dialogActivityConfig.chosenLevels
                currentActivity.currentLevels = dialogActivityConfig.chosenLevels
            }
            onClose: {
                activity.home()
            }
            onStartActivity: {
                activityBackground.stop()
                activityBackground.start()
            }
        }

        Bar {
            id: bar
            level: items.currentLevel + 1
            content: BarEnumContent {
                value: help | home | level | reload | activityConfig
            }
            onHelpClicked: {
                activity.displayDialog(dialogHelp)
            }
            onPreviousLevelClicked: Activity.previousLevel()
            onNextLevelClicked: Activity.nextLevel()
            onHomeClicked: activity.home()
            onReloadClicked: Activity.initLevel()
            onActivityConfigClicked: {
                activity.displayDialog(dialogActivityConfig)
            }
        }

        Bonus {
            id: bonus
            onStop: items.blockClicks = false
            Component.onCompleted: win.connect(activity.nextLevel)
        }
// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name: 'VisibleLightsByIndependentElimination'
 when: activity.visible && grid.width>0
 property int targetLevels: 1
 property var boards: []
 property var evidence: ({})
 function ensure(value,message){if(!value){console.log('LIGHT_ASSERT',message,new Error().stack);grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-lights-off/.scratch/pt-pt/functional-lights/dynamic-red/failure.png');}verify(value,message||'');}
 function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var hit=find(child,predicate);if(hit)return hit;}return null;}
 function click(item){ensure(item!==null,'Visible control');var p=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);wait(45);}
 function icon(root,suffix){wait(1700);click(find(root,function(o){return o.visible&&o.source!==undefined&&String(o.source).endsWith(suffix);}));}
 function windows(){
  var images=[];
  function walk(item){
   if(item.visible&&item.opacity>0.9&&item.source!==undefined&&/lightsoff\/resource\/(?:on|off)\.svg$/.test(String(item.source))){
    tryCompare(item,'status',1,2000);var point=item.mapToItem(grid,item.width/2,item.height/2);
    ensure(point.x>=0&&point.y>=0&&point.x<=grid.width&&point.y<=grid.height,'Window centre inside board');
    images.push({item:item,x:point.x,y:point.y,width:item.width,height:item.height,source:String(item.source)});
   }
   if(item.children)for(var child of item.children)walk(child);
  }
  walk(grid);images.sort(function(a,b){return Math.abs(a.y-b.y)>1?a.y-b.y:a.x-b.x;});
  var size=Math.sqrt(images.length);ensure(Number.isInteger(size)&&size>=5&&size<=9,'Square visible board');
  for(var i=0;i<images.length;i++){var tile=images[i];ensure(Math.abs(tile.x-(i%size+0.5)*grid.cellWidth)<1&&Math.abs(tile.y-(Math.floor(i/size)+0.5)*grid.cellHeight)<1,'Row-major drawn geometry');}
  return images;
 }
 function state(){return windows().map(function(o){return o.source.endsWith('/on.svg')?1:0;});}
 function equal(a,b,message){compare(JSON.stringify(a),JSON.stringify(b),message||'Visible board');}
 function toggle(board,size,index){var result=board.slice(),r=Math.floor(index/size),c=index%size;for(var pair of [[r,c],[r-1,c],[r+1,c],[r,c-1],[r,c+1]])if(pair[0]>=0&&pair[0]<size&&pair[1]>=0&&pair[1]<size)result[pair[0]*size+pair[1]]=1-result[pair[0]*size+pair[1]];return result;}
 function solution(board,size){
  var count=board.length,matrix=[],pivots=[];
  for(var row=0;row<count;row++){var cells=[];for(var col=0;col<count;col++){var r=Math.floor(row/size),c=row%size,rr=Math.floor(col/size),cc=col%size;cells.push(Math.abs(r-rr)+Math.abs(c-cc)<=1?1:0);}cells.push(board[row]);matrix.push(cells);}
  for(var column=0;column<count;column++){
   var pivot=-1;for(var candidate=pivots.length;candidate<count;candidate++)if(matrix[candidate][column]){pivot=candidate;break;}
   if(pivot<0)continue;var at=pivots.length,swap=matrix[at];matrix[at]=matrix[pivot];matrix[pivot]=swap;
   for(var other=0;other<count;other++)if(other!==at&&matrix[other][column])for(var k=column;k<=count;k++)matrix[other][k]^=matrix[at][k];
   pivots.push(column);
  }
  for(var check=pivots.length;check<count;check++)ensure(matrix[check][count]===0,'Solvable observed board');
  var result=[];for(var p=0;p<pivots.length;p++)if(matrix[p][count])result.push(pivots[p]);return result;
 }
 function press(index,before,size){var expected=toggle(before,size,index);click(windows()[index].item);equal(state(),expected,'Cross toggle for real click');return expected;}
 function puzzle(level){
  wait(300);var before=state(),size=Math.sqrt(before.length);ensure(before.some(function(v){return v===1;}),'New puzzle is not already solved');
  var candidate=0;while(toggle(before,size,candidate).every(function(v){return v===0;}))candidate++;
  var changed=press(candidate,before,size);compare(activity.currentLevel,level-1);ensure(!bonus.isPlaying,'A nonwinning move stays in puzzle');
  var restored=press(candidate,changed,size);equal(restored,before,'Same click repairs nonwinning move');
  var answer=solution(before,size),steps=[],current=before;ensure(answer.length>0,'Nonempty independent solution');
  for(var index of answer){current=press(index,current,size);steps.push({cell:index,after:current});}
  ensure(current.every(function(v){return v===0;}),'All drawn lights off');
  tryCompare(bonus,'isPlaying',true,2500);tryVerify(function(){return bonus.opacity>0.5;},1500);var feedback=String(bonus.source);ensure(feedback.indexOf('good')>=0,'Natural good Bonus');
  return {level:level,size:size,before:before,probe:{cell:candidate,changed:changed,restored:restored},moves:steps,bonus:feedback};
 }
 function test_selected_dynamic_starts_with_an_exercise(){
  wait(1500);icon(bar,'bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2500);wait(900);
  var boxes=[];function collect(item){if(item.visible&&item.indicatorImageHeight!==undefined&&item.checked!==undefined)boxes.push(item);if(item.children)for(var child of item.children)collect(child);}collect(dialogActivityConfig);compare(boxes.length,9);
  for(var i=0;i<9;i++)ensure(boxes[i].checked,'Initial selected datasets');
  var labels=boxes.map(function(o){return String(o.text);});
  for(var j=0;j<8;j++){click(boxes[j]);compare(boxes[j].checked,false);}
  compare(dialogActivityConfig.chosenLevels.length,1);dialogActivityConfig.forceActiveFocus();keyClick(Qt.Key_Return);tryCompare(dialogActivityConfig,'visible',false,2500);wait(250);
  compare(activity.numberOfLevel,10);compare(activity.currentLevel,0);var before=state();
  evidence={selectedLabels:labels,selected:labels[8],size:Math.sqrt(before.length),before:before,bonusAtStart:bonus.isPlaying};
  grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-lights-off/.scratch/pt-pt/functional-lights/dynamic-red/selected.png');ensure(before.some(function(v){return v===1;}),'New selected dynamic puzzle is not already solved');ensure(!bonus.isPlaying,'No unearned Bonus at start');
 }
 function cleanupTestCase(){console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,boards:boards,evidence:evidence}));}
}

    }
}
