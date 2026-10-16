import QtTest
/* GCompris - Left_right_click.qml
 *
 * SPDX-FileCopyrightText: 2022 Samarth Raj <mailforsamarth@gmail.com>
 * SPDX-FileCopyrightText: 2022 Timothée Giet <animtim@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import QtQml.Models

import core 1.0
import "../../core"
import "left_right_click.js" as Activity
import "qrc:/gcompris/src/core/core.js" as Core

ActivityBase {
    id: activity

    onStart: focus = true
    onStop: {}

     onActivityNextLevel: {
         Activity.nextLevel()
    }

    pageComponent: Image {
        id: activityBackground
        anchors.fill: parent
        source: "qrc:/gcompris/src/activities/canal_lock/resource/sky.svg"
        sourceSize.height: height
        sourceSize.width: width
        signal start
        signal stop

        Component.onCompleted: {
            activity.start.connect(start)
            activity.stop.connect(stop)
        }

        // Add here the QML items you need to access in javascript
        QtObject {
            id: items
            property Item main: activity.main
            property alias activityBackground: activityBackground
            property int currentLevel: activity.currentLevel
            onCurrentLevelChanged: activity.currentLevel = currentLevel
            property int numberOfLevel: 3
            onNumberOfLevelChanged: activity.numberOfLevel = numberOfLevel
            property alias bonus: bonus
            property alias badAnswerSound: badAnswerSound
            property alias animalListModel: animalListModel
            property alias animalCardsArea: animalCardsArea
            property alias leftArea: leftAreaTarget
            property alias rightArea: rightAreaTarget
            property alias displayMouse: displayMouse
            property alias leftClickDisplayMouse: leftClickDisplayMouse
            property alias rightClickDisplayMouse: rightClickDisplayMouse
            property alias cross: cross
            property int cardCount: 1
        }

        onStart: { Activity.start(items) }
        onStop: { Activity.stop() }

        GCSoundEffect {
            id: badAnswerSound
            source: "qrc:/gcompris/src/core/resource/sounds/crash.wav"
        }

        Image {
            id: hillArea
            source: "qrc:/gcompris/src/activities/left_right_click/resource/hill.svg"
            width: activityBackground.width
            height: activityBackground.height - leftAreaTarget.height * 0.5
            anchors.bottom: activityBackground.bottom
            sourceSize.width: width
            sourceSize.height: height
        }

        Item {
            id: layoutArea
            anchors.top: parent.top
            anchors.bottom: bar.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: GCStyle.baseMargins
            anchors.bottomMargin: bar.height * 0.2
        }

        Image {
            id: leftAreaTarget
            parent: layoutArea
            width: layoutArea.width * 0.3
            height: layoutArea.height * 0.5
            sourceSize.height: Math.min(width, height)
            anchors.left: layoutArea.left
            fillMode: Image.PreserveAspectFit
            source: "qrc:/gcompris/src/activities/left_right_click/resource/pond.svg"
        }

        Image {
            id: rightAreaTarget
            parent: layoutArea
            width: leftAreaTarget.width
            height: leftAreaTarget.height
            sourceSize.height: leftAreaTarget.sourceSize.height
            anchors.right: layoutArea.right
            fillMode: Image.PreserveAspectFit
            source: "qrc:/gcompris/src/activities/left_right_click/resource/tree.svg"
        }

        ListModel {
            id: animalListModel
        }

        Item {
            id: animalCardsArea
            parent: layoutArea
            width: layoutArea.width
            height: leftAreaTarget.height
            anchors.top: leftAreaTarget.bottom
            property int animalCardSize: Math.floor(Core.fitItems(animalCardsArea.width, animalCardsArea.height, items.cardCount))

            GridView {
                id: container
                height: parent.height
                width: parent.width
                anchors.centerIn: parent
                interactive: false
                cellHeight: animalCardsArea.animalCardSize
                cellWidth: animalCardsArea.animalCardSize
                model: animalListModel
                delegate: Animal {
                    leftArea: leftAreaTarget
                    rightArea: rightAreaTarget
                    width: animalCardsArea.animalCardSize
                }
            }
        }

        Item {
            id: mouseDisplayContainer
            parent: layoutArea
            anchors.top: layoutArea.top
            anchors.bottom: animalCardsArea.top
            anchors.left: leftAreaTarget.right
            anchors.right: rightAreaTarget.left

            Image {
                id: displayMouse
                source: "qrc:/gcompris/src/activities/left_right_click/resource/mouse.svg"
                width: Math.min(parent.width, parent.height)
                height: width
                sourceSize.width: width
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit

                MouseButton {
                    id: leftClickDisplayMouse
                }

                MouseButton {
                    id: rightClickDisplayMouse
                    isRightButton: true
                }

                Image {
                    id: cross
                    height: parent.width * 0.5
                    width: height
                    sourceSize.height: height
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    source: "qrc:/gcompris/src/core/resource/cancel.svg"
                    visible: false // only visible when a wrong click is pressed
                }
            }
        }

        // for left click of the mouse
        signal leftClickTrigger
        onLeftClickTrigger: {
            leftClickDisplayMouse.clickTrigger()
        }

        // for the right click of the mouse
        signal rightClickTrigger
        onRightClickTrigger: {
            rightClickDisplayMouse.clickTrigger()
        }

        //for the cross to hide
        signal wrongClick
        onWrongClick: {
            cross.visible = true
            hideCross.running = true
            Activity.playWrongClickSound()
        }

        PropertyAnimation {
            id: hideCross
            target: cross
            property: "visible"
            to: false
            duration: 500
        }

        DialogHelp {
            id: dialogHelp
            onClose: home()
        }

        Bar {
            id: bar
            level: items.currentLevel + 1
            content: BarEnumContent { value: help | home | level | reload }
            onHelpClicked: {
                displayDialog(dialogHelp)
            }
            onPreviousLevelClicked: Activity.previousLevel()
            onNextLevelClicked: Activity.nextLevel()
            onHomeClicked: activity.home()
            onReloadClicked: {
                Activity.start(items)
            }
        }

        Bonus {
            id: bonus
            Component.onCompleted: win.connect(activity.nextLevel)
        }
// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 function checkEqual(actual,expected,message){if(actual!==expected)console.log('COMPARE_FAILED',actual,expected,message);compare(actual,expected,message);}
 function checkTrue(value,message){if(!value)console.log('ASSERT_FAILED',message);verify(value,message);}

 name:"MouseControlsAndReload"
 when:activity.visible
 property var evidence:({})
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

 function test_controls(){
  wait(1000);var depth=pageView.depth;icon('bar_help.svg');tryCompare(pageView,'depth',depth+1,2000);wait(300);var help=pageView.currentItem;checkTrue(help.content.indexOf('peixe')>=0 && help.content.indexOf('macaco')>=0);evidence.help={title:String(help.title),content:String(help.content)};grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-orientation-mouse/.scratch/pt-pt/functional-orientation/mouse-controls/help.png');keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth,2000);wait(500);
  var before=animals().length,card=animals()[0],kind=String(animalImage(card).source).split('/').pop();click(card,kind==='fish.svg'?Qt.LeftButton:Qt.RightButton);tryCompare(card,'visible',false,1500);checkEqual(animals().length,before-1);evidence.focusAfterHelp=true;evidence.partialAnimal=kind;
  icon('bar_reload.svg');checkEqual(activity.currentLevel,0);checkEqual(animals().length,5);evidence.partialReload=true;
  icon('bar_next.svg');checkEqual(activity.currentLevel,1);checkEqual(animals().length,7);icon('bar_previous.svg');checkEqual(activity.currentLevel,0);checkEqual(animals().length,5);evidence.navigationReset=true;
  icon('bar_previous.svg');checkEqual(activity.currentLevel,2);checkEqual(animals().length,10);icon('bar_next.svg');checkEqual(activity.currentLevel,0);evidence.wrap=true;
  var counts=animals().length;keyClick(Qt.Key_Right);keyClick(Qt.Key_Left);keyClick(Qt.Key_Return);checkEqual(animals().length,counts);evidence.unsupportedKeys=true;
  evidence.configurationOffered=all(bar).some(child=>child.source!==undefined && String(child.source).endsWith('bar_activity_config.svg'));
  ActivityInfoTree.startingActivity='';keyClick(Qt.Key_W,Qt.ControlModifier);tryCompare(pageView,'depth',1,2000);checkTrue(pageView.currentItem.isMenu);evidence.menu=true;grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-orientation-mouse/.scratch/pt-pt/functional-orientation/mouse-controls/menu.png');
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-orientation-mouse/.scratch/pt-pt/functional-orientation/mouse-controls/failure.png');console.log('NATIVE_ORIENTATION_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}

    }
}
