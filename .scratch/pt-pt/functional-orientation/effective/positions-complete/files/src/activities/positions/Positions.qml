import QtTest
/* GCompris - Positions.qml
 *
 * SPDX-FileCopyrightText: 2021 Mariam Fahmy <mariamfahmy66@gmail.com>
 *
 * Authors:
 *   Mariam Fahmy <mariamfahmy66@gmail.com>
 *
 *   SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import core 1.0
import "../../core"
import "positions.js" as Activity
import "qrc:/gcompris/src/core/core.js" as Core

ActivityBase {
    id: activity

    onStart: focus = true;
     onActivityNextLevel: {
         Activity.nextLevel()
    }

    pageComponent: Image {
        id: activityBackground
        source: "qrc:/gcompris/src/activities/family/resource/background.svg"
        sourceSize.width: width
        sourceSize.height: height
        focus: true
        signal start
        signal stop
        fillMode: Image.PreserveAspectCrop

        property bool keyboardMode: false

        QtObject {
            id: items
            property int currentLevel: activity.currentLevel
            onCurrentLevelChanged: activity.currentLevel = currentLevel
            property int numberOfLevel: 0
            onNumberOfLevelChanged: activity.numberOfLevel = numberOfLevel
            property alias bonus: bonus
            readonly property var levels: activity.datasets
            property alias goodAnswerSound: goodAnswerSound
            property alias badAnswerSound: badAnswerSound
            property alias score: score
            property int checkState: -1
            property int selectedPosition: -1
            property string questionText: ""
            property alias positionModels: positionModels
            property var view: items.currentLevel % 2 !== 0 ? answerViews : positionViews
            property bool buttonsBlocked: false
            property alias errorRectangle: errorRectangle
        }

        Component.onCompleted: {
            activity.start.connect(start)
            activity.stop.connect(stop)
        }
        onStart: { Activity.start(items) }
        onStop: { Activity.stop() }

        Keys.enabled: !items.buttonsBlocked
        Keys.onPressed: (event) => {
            if((event.key === Qt.Key_Space || event.key === Qt.Key_Enter || event.key === Qt.Key_Return) && items.view.currentItem !== null) {
                Activity.verifyAnswer()
                event.accepted = true
            }
            else if(event.key === Qt.Key_Left) {
                items.view.moveCurrentIndexLeft()
                items.view.currentItem.selectCurrentItem()
                event.accepted = true
            }
            else if(event.key === Qt.Key_Right) {
                items.view.moveCurrentIndexRight()
                items.view.currentItem.selectCurrentItem()
                event.accepted = true
            }
            else if(event.key === Qt.Key_Up) {
                items.view.moveCurrentIndexUp()
                items.view.currentItem.selectCurrentItem()
                event.accepted = true
            }
            else if(event.key === Qt.Key_Down) {
                items.view.moveCurrentIndexDown()
                items.view.currentItem.selectCurrentItem()
                event.accepted = true
            }
        }

        Keys.onReleased: (event) => {
            keyboardMode = true
            event.accepted = false
        }

        GCSoundEffect {
            id: goodAnswerSound
            source: "qrc:/gcompris/src/core/resource/sounds/completetask.wav"
        }

        GCSoundEffect {
            id: badAnswerSound
            source: "qrc:/gcompris/src/core/resource/sounds/crash.wav"
        }

        Item {
            id: mainScreen
            height: activityBackground.height - bar.height * 1.5
            anchors.top: activityBackground.top
            anchors.left: activityBackground.left
            anchors.right: okButton.width > score.width ? okButton.left : score.left
            anchors.margins: GCStyle.baseMargins

            property bool horizontalLayout: mainScreen.width >= mainScreen.height

            Rectangle {
                id: backgroundScreen
                width: parent.width
                height: mainScreen.horizontalLayout ? parent.height * 0.6 : parent.height * 0.4
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                visible: items.currentLevel % 2 !== 0
                color: "#55333333"
                radius: GCStyle.halfMargins

                BoxBoyPosition {
                    id: currentPosition
                    anchors.centerIn: parent
                    checkState: items.checkState
                    width: Math.min(parent.width, parent.height)
                }
            }

            GridView {
                id: answerViews
                width: parent.width + GCStyle.baseMargins
                visible: backgroundScreen.visible
                anchors.top: backgroundScreen.bottom
                anchors.left: backgroundScreen.left
                anchors.bottom: parent.bottom
                anchors.topMargin: GCStyle.baseMargins
                cellWidth: mainScreen.horizontalLayout ? answerViews.width / answerViews.count : answerViews.width
                cellHeight: mainScreen.horizontalLayout ? answerViews.height : answerViews.height / answerViews.count
                keyNavigationWraps: true
                model: positionModels
                focus: false
                currentIndex: -1

                delegate: Rectangle {
                    id: answer
                    color: index == answerViews.currentIndex ? GCStyle.lightBg : "#80FFFFFF"
                    radius: GCStyle.halfMargins
                    width: answerViews.cellWidth - GCStyle.baseMargins
                    height: answerViews.cellHeight - GCStyle.baseMargins
                    border.width: index == answerViews.currentIndex ? GCStyle.thinBorder : 0
                    border.color: GCStyle.blueBorder

                    property alias text: answerText.text
                    GCText {
                        id: answerText
                        text: stateName
                        fontSize: mediumSize
                        wrapMode: Text.WordWrap
                        fontSizeMode: Text.Fit
                        width: answer.width - 2 * GCStyle.baseMargins
                        height: answer.height - GCStyle.baseMargins
                        anchors.centerIn: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }

                    MouseArea {
                        id: textArea
                        anchors.fill: parent
                        onClicked: selectCurrentItem()
                        enabled: !items.buttonsBlocked
                    }

                    function selectCurrentItem() {
                        answerViews.currentIndex = index
                        items.selectedPosition = stateId
                    }
                }
            }
        }

        GCTextPanel {
            id: questionPanel
            visible: items.currentLevel % 2 === 0
            panelWidth: activityBackground.width - score.width - 3 * GCStyle.baseMargins
            panelHeight: Math.min(50 * ApplicationInfo.ratio, activityBackground.height * 0.2)
            fixedHeight: true
            anchors.horizontalCenter: activityBackground.horizontalCenter
            anchors.horizontalCenterOffset: -(score.height + 2 * GCStyle.baseMargins) * 0.5
            anchors.top: mainScreen.top
            textItem.text: items.questionText
        }

        GridView {
            id: positionViews
            anchors.top: questionPanel.bottom
            anchors.topMargin: GCStyle.baseMargins
            anchors.left: mainScreen.left
            width: mainScreen.width
            height: mainScreen.height - questionPanel.height - GCStyle.baseMargins
            visible: questionPanel.visible
            interactive: false
            cellWidth: itemWidth
            cellHeight: itemWidth
            keyNavigationWraps: true
            model: positionModels
            layoutDirection: Qt.LeftToRight
            highlightFollowsCurrentItem: true
            focus: false
            currentIndex: -1

            property int itemWidth: Core.fitItems(positionViews.width, positionViews.height, Math.max(positionModels.count, 1))

            delegate: Item {
                id: posItem
                width: positionViews.itemWidth
                height: positionViews.itemWidth

                BoxBoyPosition {
                    checkState: stateId
                    width: positionViews.itemWidth
                    height: positionViews.itemWidth
                    scale: mouseArea.containsMouse?  1.1 : 1
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    onClicked: selectCurrentItem()
                    enabled: !items.buttonsBlocked
                    hoverEnabled: index != positionViews.currentIndex
                }

                function selectCurrentItem() {
                    positionViews.currentIndex = index
                    items.selectedPosition = positionModels.get(index).stateId
                }
            }

            highlight: Rectangle {
                width: positionViews.itemWidth
                height: positionViews.itemWidth
                radius: GCStyle.halfMargins
                color: GCStyle.lightTransparentBg
                border.width: GCStyle.thinBorder
                border.color: GCStyle.blueBorder
                Behavior on x { SpringAnimation { spring: 2; damping: 0.2 } }
                Behavior on y { SpringAnimation { spring: 2; damping: 0.2 } }
            }
        }

        ListModel {
            id: positionModels
        }
        
        ErrorRectangle {
            id: errorRectangle
            radius: GCStyle.halfMargins
            imageSize: Math.min(okButton.width, width, height)

            function releaseControls() { items.buttonsBlocked = false; }

            function startAnimation() {
                errorRectangle.width = items.view.currentItem.width;
                errorRectangle.height = items.view.currentItem.height;
                var itemPosition = items.view.currentItem.mapToItem(activityBackground, 0, 0)
                errorRectangle.x = itemPosition.x;
                errorRectangle.y = itemPosition.y;
                errorAnimation.restart();
            }
        }

        DialogHelp {
            id: dialogHelpLeftRight
            onClose: home()
        }

        DialogChooseLevel {
            id: dialogActivityConfig
            currentActivity: activity.activityInfo

            onSaveData: {
                levelFolder = dialogActivityConfig.chosenLevels
                currentActivity.currentLevels = dialogActivityConfig.chosenLevels
            }

            onClose: {
                home()
            }

            onStartActivity: {
                activityBackground.stop()
                activityBackground.start()
            }
        }

        Bar {
            id: bar
            level: items.currentLevel + 1
            content: BarEnumContent { value: help | home | level | activityConfig }
            onHelpClicked: {
                displayDialog(dialogHelpLeftRight)
            }
            onActivityConfigClicked: {
                displayDialog(dialogActivityConfig)
            }
            onPreviousLevelClicked: Activity.previousLevel()
            onNextLevelClicked: Activity.nextLevel()
            onHomeClicked: home()
        }

        BarButton {
            id: okButton
            anchors.verticalCenter: mainScreen.verticalCenter
            anchors.right: activityBackground.right
            anchors.margins: GCStyle.baseMargins
            source: "qrc:/gcompris/src/core/resource/bar_ok.svg"
            width: Math.min(GCStyle.bigButtonHeight, activityBackground.width * 0.2)
            onClicked: Activity.verifyAnswer()
            mouseArea.enabled: !items.buttonsBlocked && items.selectedPosition != -1
        }

        Bonus {
            id: bonus
            onWin: activity.nextLevel()
        }

        Score {
            id: score
            anchors.top: activityBackground.top
            anchors.right: activityBackground.right
            anchors.bottom: undefined
            anchors.margins: GCStyle.baseMargins
            onStop: Activity.nextSubLevel()
        }
// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 function checkEqual(actual,expected,message){if(actual!==expected)console.log('COMPARE_FAILED',actual,expected,message);compare(actual,expected,message);}
 function checkTrue(value,message){if(!value)console.log('ASSERT_FAILED',message);verify(value,message);}

 id:campaign
 name:"VisibleChildBoxRelations"
 when:activity.visible
 property var completed:[]
 property int wins:0
 Connections {target:bonus;function onWin(){campaign.wins++;}}
 function all(root){var result=[root];if(root.children)for(var child of root.children)result=result.concat(all(child));return result;}
 function click(item,button){var p=item.mapToItem(activityBackground,item.width/2,item.height/2);checkTrue(p.x>=0 && p.y>=0 && p.x<activityBackground.width && p.y<activityBackground.height,'Gesture center inside window');mouseClick(activityBackground,p.x,p.y,button===undefined?Qt.LeftButton:button,Qt.NoModifier,10);wait(30);}
 function icon(suffix){wait(400);var image=all(bar).find(child=>child.source!==undefined && String(child.source).endsWith(suffix));checkTrue(image!==undefined,suffix);click(image);wait(400);}
 function enabledArea(root){return all(root).find(child=>child.acceptedButtons!==undefined && child.enabled!==undefined);}
 function readyHand(){tryCompare(handImage,'opacity',1,2500);tryCompare(enabledArea(leftButton),'enabled',true,2500);tryCompare(enabledArea(rightButton),'enabled',true,2500);tryCompare(handImage,'status',Image.Ready,2000);}
 function hand(){return {image:String(handImage.source).split('/').pop(),rotation:handImage.rotation,mirror:handImage.mirror};}
 function picture(root){
  var images=all(root).filter(child=>child.source!==undefined),boy=images.find(i=>String(i.source).endsWith('/boy.svg')),back=images.find(i=>String(i.source).endsWith('/back_side.svg')),front=images.find(i=>String(i.source).endsWith('/front_side.svg')),lid=images.find(i=>String(i.source).endsWith('/top_side.svg'));
  checkTrue(boy!==undefined && back!==undefined && front!==undefined && lid!==undefined,'Painted child and box faces');
  for(var image of [boy,back,front,lid])tryCompare(image,'status',Image.Ready,1500);
  var b=boy.mapToItem(root,boy.width/2,boy.height/2),c=back.mapToItem(root,back.width/2,back.height/2);
  return {dx:(b.x-c.x)/back.width,dy:(b.y-c.y)/back.height,boy_z:boy.z,front_z:front.z,lid:lid.visible,boy:{x:b.x,y:b.y,width:boy.width,height:boy.height},box:{x:c.x,y:c.y,width:back.width,height:back.height}};
 }
 function relation(view){if(view.dx<-.5)return 'left';if(view.dx>.5)return 'right';if(view.dy<-.6)return 'above';if(view.dy>.5)return 'under';if(!view.lid)return 'inside';return view.boy_z<view.front_z?'behind':'front';}
 function meaning(text){var words=[['à frente','front'],['atrás','behind'],['dentro','inside'],['em cima','above'],['debaixo','under'],['direita','right'],['esquerda','left'],['ao lado','beside']];for(var row of words)if(text.indexOf(row[0])>=0)return row[1];checkTrue(false,'Unknown PT relation '+text);return '';}
 function matches(actual,wanted){return wanted==='beside'?(actual==='left'||actual==='right'):actual===wanted;}
 function animalImage(card){return all(card).find(child=>child.source!==undefined && /\/(fish|monkey)\.svg$/.test(String(child.source)));}
 function animals(){return all(container.contentItem).filter(child=>animalImage(child)!==undefined && child.clicked!==undefined && child.visible && child.width>0);}

 function options(textMode){var grid=textMode?answerViews:positionViews;return grid.contentItem.children.filter(child=>child.selectCurrentItem!==undefined && child.width>0 && child.height>0);}
 function keyboardSelect(grid,target){
  if(grid.currentItem===null)keyClick(Qt.Key_Right);
  var steps=0;
  while(grid.currentItem!==target){
   var before=grid.currentItem;checkTrue(before!==null);var a=before.mapToItem(activityBackground,before.width/2,before.height/2),b=target.mapToItem(activityBackground,target.width/2,target.height/2);
   keyClick(Math.abs(a.y-b.y)>before.height/2?(b.y>a.y?Qt.Key_Down:Qt.Key_Up):(b.x>a.x?Qt.Key_Right:Qt.Key_Left));
   checkTrue(grid.currentItem!==before,'One arrow changes visible selection toward target');checkTrue(++steps<12);
  }
 }
 function test_every_position(){
  wait(1000);checkEqual(activity.numberOfLevel,4);var plan=[6,6,7,7];
  for(var level=0;level<4;level++){
   checkEqual(activity.currentLevel,level);var textMode=level%2===1;
   for(var question=0;question<plan[level];question++){
    wait(100);var candidates=options(textMode);checkTrue(candidates.length>=3);var requested=textMode?picture(currentPosition):String(questionPanel.textItem.text),want=textMode?relation(requested):meaning(requested);
    var visible=candidates.map(child=>textMode?String(child.text):picture(child));var found=[];
    for(var i=0;i<visible.length;i++)if(textMode?matches(want,meaning(visible[i])):matches(relation(visible[i]),want))found.push(i);
    checkEqual(found.length,1,'Exactly one independent visible relation matches');var index=found[0],wrong=null;
    if(question===0){
     var bad=(index+1)%candidates.length;click(candidates[bad]);click(okButton);tryCompare(errorRectangle.errorAnimation,'running',true,1200);checkEqual(score.currentSubLevel,question);wrong={index:bad,choice:visible[bad]};tryCompare(errorRectangle.errorAnimation,'running',false,3500);wait(100);
    }
    var keyboard=question%2===0,grid=textMode?answerViews:positionViews;
    if(keyboard)keyboardSelect(grid,candidates[index]);else click(candidates[index]);
    grabImage(activityBackground).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-orientation-mouse/.scratch/pt-pt/functional-orientation/positions-complete/position-'+(level+1)+'-'+(question+1)+'.png');
    if(keyboard)keyClick(question%3===0?Qt.Key_Space:Qt.Key_Return);else click(okButton);
    tryCompare(score,'currentSubLevel',question+1,1200);tryCompare(score,'isWinAnimationPlaying',false,4500);wait(120);
    completed.push({level:level+1,question:question+1,mode:textMode?'picture-to-text':'text-to-picture',requested:requested,options:visible,index:index,input:keyboard?'keyboard':'mouse',wrong:wrong});console.log('ORIENTATION_POSITION',JSON.stringify(completed[completed.length-1]));
   }
   tryCompare(bonus,'isPlaying',true,1200);tryCompare(activity,'currentLevel',(level+1)%4,10000);wait(150);
  }
  checkEqual(wins,4);
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(activityBackground).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-orientation-mouse/.scratch/pt-pt/functional-orientation/positions-complete/failure.png');console.log('NATIVE_ORIENTATION_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,wins:wins}));}
}

    }
}
