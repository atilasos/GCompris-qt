import QtTest
/* GCompris - Leftright.qml
 *
 * SPDX-FileCopyrightText: 2014 Bruno Coudoin <bruno.coudoin@gcompris.net>
 *
 * Authors:
 *   Pascal Georges <pascal.georges1@free.fr> (GTK+ version)
 *   Bruno Coudoin <bruno.coudoin@gcompris.net> (Qt Quick port)
 *
 *   SPDX-License-Identifier: GPL-3.0-or-later
 */
pragma ComponentBehavior: Bound

import QtQuick
import core 1.0
import "../../core"
import "leftright.js" as Activity

ActivityBase {
    id: activity

    onStart: focus = true;

     onActivityNextLevel: {
         Activity.nextLevel()
    }

    pageComponent: Rectangle {
        id: activityBackground
        color: GCStyle.lightBlueBg
        focus: true
        signal start
        signal stop

        QtObject {
            id: items
            property int currentLevel: activity.currentLevel
            onCurrentLevelChanged: activity.currentLevel = currentLevel
            property int numberOfLevel: 0
            onNumberOfLevelChanged: activity.numberOfLevel = numberOfLevel
            property alias bonus: bonus
            property alias imageAnimOff: imageAnimOff
            property alias leftButton: leftButton
            property alias rightButton: rightButton
            property alias score: score
            property bool buttonsBlocked: false
        }

        Keys.onLeftPressed: leftButton.pressed()
        Keys.onRightPressed: rightButton.pressed()
        Keys.enabled: !items.buttonsBlocked

        Component.onCompleted: {
            activity.start.connect(start)
            activity.stop.connect(stop)
        }
        onStart: { Activity.start(items) }
        onStop: { Activity.stop() }

        Item {
            id: layoutArea
            width: parent.width - 2 * GCStyle.baseMargins
            height: parent.height - bar.height * 1.5 - score.height - 2 * GCStyle.baseMargins
            anchors.top: score.bottom
            anchors.left: parent.left
            anchors.margins: GCStyle.baseMargins
        }

        Image {
            id: blackBoard
            anchors.horizontalCenter: layoutArea.horizontalCenter
            anchors.verticalCenter: layoutArea.verticalCenter
            anchors.verticalCenterOffset: -leftButton.height * 0.5
            fillMode: Image.PreserveAspectFit
            height: (layoutArea.height - 10) * 0.85
            width: layoutArea.width
            sourceSize.height: height
            sourceSize.width: width
            source: "qrc:/gcompris/src/activities/leftright/resource/blackboard.svg"

            Image {
                id: lightImage
                source: "qrc:/gcompris/src/activities/leftright/resource/light.svg"
                fillMode: Image.PreserveAspectFit
                sourceSize.width: blackBoard.paintedWidth
                sourceSize.height: blackBoard.paintedHeight
                anchors.centerIn: parent
                anchors.topMargin: 2 * GCStyle.baseMargins
                opacity: 0
            }

            Image {
                id: handImage
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.PreserveAspectFit
                width: blackBoard.paintedHeight * 0.7
                height: width
                opacity: 0
            }

            ParallelAnimation {
                id: imageAnimOff
                onRunningChanged: {
                    if (!imageAnimOff.running) {
                        handImage.source = Activity.getCurrentHandImage()
                        handImage.rotation = Activity.getCurrentHandRotation()

                        imageAnimOn.start()
                    }
                }
                NumberAnimation {
                    target: handImage
                    property: "opacity"
                    from: 1; to: 0
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: lightImage
                    property: "opacity"
                    from: 1; to: 0
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
            ParallelAnimation {
                id: imageAnimOn
                onStopped: bonus.isPlaying ? items.buttonsBlocked = true : items.buttonsBlocked = false
                NumberAnimation {
                    target: handImage
                    property: "opacity"
                    from: 0; to: 1.0
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: lightImage
                    property: "opacity"
                    from: 0; to: 1
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            GCSoundEffect {
                id: goodAnswerEffect
                source: "qrc:/gcompris/src/core/resource/sounds/completetask.wav"
            }

            GCSoundEffect {
                id: badAnswerEffect
                source: "qrc:/gcompris/src/core/resource/sounds/crash.wav"
            }

            AnswerButton {
                id: leftButton
                width: blackBoard.paintedWidth * 0.45
                height: (layoutArea.height - 10) * 0.15
                anchors.right: blackBoard.horizontalCenter
                anchors.rightMargin: blackBoard.paintedWidth * 0.04
                anchors.top: blackBoard.verticalCenter
                anchors.topMargin: blackBoard.paintedHeight * 0.5 + GCStyle.halfMargins
                textLabel: qsTr("Left hand")
                onPressed: {
                    items.buttonsBlocked = true
                    if(isCorrectAnswer) {
                        goodAnswerEffect.play()
                        Activity.goodAnswerPressed()
                    } else {
                        badAnswerEffect.play()
                    }
                }
                blockAllButtonClicks: items.buttonsBlocked
                onIncorrectlyPressed: items.buttonsBlocked = false
            }

            AnswerButton {
                id: rightButton
                width: leftButton.width
                height: leftButton.height
                anchors.left: blackBoard.horizontalCenter
                anchors.leftMargin: leftButton.anchors.rightMargin
                anchors.top: blackBoard.verticalCenter
                anchors.topMargin: leftButton.anchors.topMargin
                textLabel: qsTr("Right hand")
                onPressed: {
                    items.buttonsBlocked = true
                    if(isCorrectAnswer) {
                        goodAnswerEffect.play()
                        Activity.goodAnswerPressed()
                    } else {
                        badAnswerEffect.play()
                    }
                }
                blockAllButtonClicks: items.buttonsBlocked
                onIncorrectlyPressed: items.buttonsBlocked = false
            }
        }

        DialogHelp {
            id: dialogHelpLeftRight
            onClose: activity.home()
        }

        Bar {
            id: bar
            level: items.currentLevel + 1
            content: BarEnumContent { value: help | home | level }
            onHelpClicked: {
                activity.displayDialog(dialogHelpLeftRight)
            }
            onPreviousLevelClicked: Activity.previousLevel()
            onNextLevelClicked: Activity.nextLevel()
            onHomeClicked: activity.home()
        }

        Bonus {
            id: bonus
            onStop: {
                Activity.nextLevel();
            }
        }

        Score {
            id: score
            anchors.top: activityBackground.top
            anchors.topMargin: GCStyle.baseMargins
            anchors.bottom: undefined
            onStop: Activity.displayNextHand()
        }
// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 function checkEqual(actual,expected,message){if(actual!==expected)console.log('COMPARE_FAILED',actual,expected,message);compare(actual,expected,message);}
 function checkTrue(value,message){if(!value)console.log('ASSERT_FAILED',message);verify(value,message);}

 id:campaign
 name:"AnatomicalHandsAndRotations"
 when:activity.visible
 property var semantics:{"main_droite_dessus_0.webp": {"side": "right", "view": "back", "thumb_in_unrotated_photo": "upper", "sha256": "05657aeb43336d513b6724533e79082b149bdf6e6af0680031b601c9bc78e77d"}, "main_droite_paume_0.webp": {"side": "right", "view": "palm", "thumb_in_unrotated_photo": "lower", "sha256": "7ac0058c04f93fd039a2acb06a7548e0a3990fe4074ae694367923380f29f356"}, "main_gauche_dessus_0.webp": {"side": "left", "view": "back", "thumb_in_unrotated_photo": "lower", "sha256": "f588e583051557a4f61a071b836a6091e67fae7a6703f912ab3a9bd44b5d4705"}, "main_gauche_paume_0.webp": {"side": "left", "view": "palm", "thumb_in_unrotated_photo": "upper", "sha256": "e57658199006929a6af8973974197acfa69c7da0cab7c835a1805ecb44e2ab59"}, "poing_droit_dessus_0.webp": {"side": "right", "view": "back", "thumb_in_unrotated_photo": "upper", "sha256": "305784dc75919d340ece5703d107e841376b4fb42965e324fe42c761c49a175a"}, "poing_droit_paume_0.webp": {"side": "right", "view": "palm", "thumb_in_unrotated_photo": "lower", "sha256": "6ae0836358634d700a6d1143c4527b14321c23b332f270a175843b8805f5308f"}, "poing_gauche_dessus_0.webp": {"side": "left", "view": "back", "thumb_in_unrotated_photo": "lower", "sha256": "a6a9a168d9920ddd1e77ee9611d7403f2a13e6de2a799a978af677d21a75dbac"}, "poing_gauche_paume_0.webp": {"side": "left", "view": "palm", "thumb_in_unrotated_photo": "upper", "sha256": "7c31b833b995dfa59a0fb69d550dcda48a07a785a76b60d1950c498115f3a0c7"}}
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

 function test_all_hands(){
  wait(900);checkEqual(leftButton.textLabel,'Mão esquerda');checkEqual(rightButton.textLabel,'Mão direita');
  var plan=[4,8,4,4,8,4];
  for(var level=0;level<6;level++){
   checkEqual(activity.currentLevel,level);
   for(var question=0;question<plan[level];question++){
    readyHand();var stimulus=hand();checkTrue(semantics[stimulus.image]!==undefined);checkTrue(!stimulus.mirror);
    var side=semantics[stimulus.image].side,correct=side==='left'?leftButton:rightButton,wrong=side==='left'?rightButton:leftButton;
    if(question===0){click(wrong);checkEqual(score.currentSubLevel,question);wait(120);var shown=all(wrong).find(child=>child.color!==undefined);checkTrue(String(shown.color)!==String(wrong.normalStateColor));readyHand();checkEqual(hand().image,stimulus.image);checkEqual(hand().rotation,stimulus.rotation);}
    grabImage(activityBackground).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-orientation-mouse/.scratch/pt-pt/functional-orientation/hands-complete/hand-'+(level+1)+'-'+(question+1)+'.png');
    if(question%2===0)keyClick(side==='left'?Qt.Key_Left:Qt.Key_Right);else click(correct);
    tryCompare(score,'currentSubLevel',question+1,1200);tryCompare(score,'isWinAnimationPlaying',false,4500);wait(100);
    completed.push({level:level+1,question:question+1,stimulus:stimulus,side:side,input:question%2===0?'keyboard':'mouse',wrong_repaired:question===0});console.log('ORIENTATION_HAND',JSON.stringify(completed[completed.length-1]));
   }
   tryCompare(bonus,'isPlaying',true,1500);tryCompare(activity,'currentLevel',(level+1)%6,10000);wait(150);
  }
  checkEqual(wins,6);
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(activityBackground).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-orientation-mouse/.scratch/pt-pt/functional-orientation/hands-complete/failure.png');console.log('NATIVE_ORIENTATION_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,wins:wins}));}
}

    }
}
