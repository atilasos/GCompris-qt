import QtTest
/* GCompris - Penalty.qml
 *
 * SPDX-FileCopyrightText: 2014 Stephane Mankowski <stephane@mankowski.fr>
 * SPDX-FileCopyrightText: 2025 Timothée Giet <animtim@gmail.com>
 *
 * Authors:
 *   Bruno Coudoin <bruno.coudoin@gcompris.net> (GTK+ version)
 *   Stephane Mankowski <stephane@mankowski.fr> (Qt Quick port)
 *   Timothée Giet <animtim@gmail.com> (refactoring)
 *
 *   SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import core 1.0

import "../../core"
import "penalty.js" as Activity

ActivityBase {
    id: activity
    numberOfLevel: 9

    onStart: focus = true
    onStop: {}

     onActivityNextLevel: {
         Activity.nextLevel()
    }

    pageComponent: Image {
        id: activityBackground
        source: Activity.url + "penalty_bg.svg"
        anchors.fill: parent
        sourceSize.width: width
        sourceSize.height: height
        fillMode: Image.Stretch
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
            readonly property int numberOfLevel: activity.numberOfLevel
            property alias ball: ball
            property alias progressLeft: progressLeft
            property alias progressRight: progressRight
            property alias progressTop: progressTop
            property alias textItem: instructionPanel.textItem
            property alias brickSound: brickSound
            property alias flipSound: flipSound
            property alias bonus: bonus
            property alias timerFail: timerFail
            property alias ballAnim: ballAnim
            property int duration: 0
            property string saveBallState: "INITIAL"
            property bool ballToReturn: false
        }

        onStart: { Activity.start(items) }
        onStop: {
            timerFail.stop()
            ballAnim.stop()
            Activity.stop()
        }

        GCSoundEffect {
            id: brickSound
            source: "qrc:/gcompris/src/core/resource/sounds/brick.wav"
        }

        GCSoundEffect {
            id: flipSound
            source: "qrc:/gcompris/src/core/resource/sounds/flip.wav"
        }

        GCTextPanel {
            id: instructionPanel
            panelWidth: parent.width - 2 * GCStyle.baseMargins
            panelHeight: Math.min(50 * ApplicationInfo.ratio, activityBackground.height * 0.2)
            fixedHeight: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: GCStyle.baseMargins
            hideIfEmpty: true
            textItem.text: ball.initialInstruction
        }

        Item {
            id: layoutArea
            anchors.top: instructionPanel.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: GCStyle.baseMargins
            anchors.bottomMargin: bar.height * 1.2
        }

        Rectangle {
            id: playField
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: goal.top
            anchors.topMargin: goal.height * 0.75
            color: "#71ba50"
        }

        Rectangle {
            id: goalLine
            color: GCStyle.whiteBg
            width: activityBackground.width
            height: goal.height * 0.034
            anchors.bottom: goal.bottom
            anchors.left: activityBackground.left
        }

        Image {
            id: goal
            source: Activity.url + "goal.svg"
            anchors.bottom: activityBackground.verticalCenter
            anchors.horizontalCenter: activityBackground.horizontalCenter
            height: Math.min(activityBackground.height * 0.5 - instructionPanel.height - instructionPanel.anchors.topMargin - GCStyle.baseMargins, layoutArea.width * 0.5)
            width: height * 2
            sourceSize.width: width
            sourceSize.height: height
            fillMode: Image.PreserveAspectFit
        }

        // To enable tapping/clicking on left side of goal
        GoalZone {
            id: rectLeft
            side: "LEFT"
            progress: progressLeft
            anchors.right: player.left
            anchors.left: goal.left
            anchors.leftMargin: goal.width * 0.025
            anchors.bottom: goal.bottom
            anchors.top: goal.top
            anchors.topMargin: goal.height * 0.06
        }

        // To enable tapping/clicking on top of goal
        GoalZone {
            id: rectTop
            side: "TOP"
            progress: progressTop
            anchors.left: player.left
            anchors.right: player.right
            anchors.bottom: player.top
            anchors.top: goal.top
            anchors.topMargin: rectLeft.anchors.topMargin
        }

        // To enable tapping/clicking on right side of goal
        GoalZone {
            id: rectRight
            side: "RIGHT"
            progress: progressRight
            anchors.left: player.right
            anchors.right: goal.right
            anchors.rightMargin: rectLeft.anchors.leftMargin
            anchors.bottom: goal.bottom
            anchors.top: goal.top
            anchors.topMargin: rectLeft.anchors.topMargin
        }

        /* The progress bars */
        Progress {
            id: progressLeft
            anchors.centerIn: rectLeft
            width: rectLeft.width - GCStyle.baseMargins
            height: GCStyle.baseMargins
        }

        Progress {
            id: progressRight
            rotation: 180
            anchors.centerIn: rectRight
            width: progressLeft.width
            height: GCStyle.baseMargins
        }

        Progress {
            id: progressTop
            rotation: 90
            anchors.centerIn: rectTop
            width: rectTop.height - GCStyle.baseMargins
            height: GCStyle.baseMargins
        }

        /* The player */
        Image {
            id: player
            source: Activity.url + "penalty_player.svg"
            fillMode: Image.PreserveAspectFit
            height: goal.height * 0.6
            sourceSize.height: height
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: goal.bottom
            anchors.bottomMargin: -height * 0.2
        }

        /* The 2 click icon */
        Image {
            source: Activity.url + "click_icon.svg"
            sourceSize.width: GCStyle.bigButtonHeight
            anchors.bottom: bar.top
            anchors.right: parent.right
            anchors.margins: GCStyle.baseMargins
        }

        /* The spot under the ball */
        Rectangle {
            id: ballOrigin
            radius: width * 0.5
            width: ball.width * 0.5
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: layoutArea.bottom
            color: GCStyle.whiteBg
            transform: [
                Scale { origin.y: ballOrigin.height; yScale: 0.7 }
            ]
        }

        /* The ball */
        Image {
            id: ball
            source: Activity.url + "penalty_ball.svg"
            fillMode: Image.PreserveAspectFit
            width: Math.min(100 * ApplicationInfo.ratio, player.height * 0.5)
            sourceSize.width: width
            x: initialPoint.x
            y: initialPoint.y

            property string ballState: "INITIAL"
            property string initialInstruction: qsTr("Double click or double tap on the side of the goal you want to put the ball in.")
            property string resetBallInstruction: qsTr("Click or tap on the ball to bring it back to its initial position.")

            property point destinationPoint
            property real destinationScale
            property int animDuration: 500

            readonly property point initialPoint: Qt.point(
                (activityBackground.width - ball.width) * 0.5,
                ballOrigin.y - ball.height + ballOrigin.height * 0.7)
            readonly property point rightPoint: Qt.point(
                rectRight.x + (rectRight.width - ball.width) * 0.5,
                rectRight.y + (rectRight.height - ball.height) * 0.5)
            readonly property point leftPoint:  Qt.point(
                rectLeft.x + (rectLeft.width - ball.width) * 0.5,
                rectLeft.y + (rectLeft.height - ball.height) * 0.5)
            readonly property point topPoint:  Qt.point(
                rectTop.x + (rectTop.width - ball.width) * 0.5,
                rectTop.y + (rectTop.height - ball.height) * 0.5)
            readonly property point failPoint: Qt.point(
                player.x + (player.width - ball.width) * 0.5,
                player.y + player.height * 0.5)

            onBallStateChanged: {
                switch(ball.ballState) {
                    case "INITIAL":
                        ball.destinationPoint = ball.initialPoint
                        ball.destinationScale = 1
                        ball.animDuration = 500
                        ballAnim.restart();
                        break;
                    case "RIGHT":
                        ball.destinationPoint = ball.rightPoint
                        ball.destinationScale = 0.6
                        ball.animDuration = 500
                        ballAnim.restart();
                        break;
                    case "LEFT":
                        ball.destinationPoint = ball.leftPoint
                        ball.destinationScale = 0.6
                        ball.animDuration = 500
                        ballAnim.restart();
                        break;
                    case "TOP":
                        ball.destinationPoint = ball.topPoint
                        ball.destinationScale = 0.6
                        ball.animDuration = 500
                        ballAnim.restart();
                        break;
                    case "FAIL":
                        ball.destinationPoint = ball.failPoint
                        ball.destinationScale = 0.6
                        ball.animDuration = 1000
                        ballAnim.restart();
                        break;
                }
            }
        }

        SequentialAnimation {
            id: ballAnim
            ScriptAction {
                script: { instructionPanel.textItem.text = "" }
            }
            ParallelAnimation {
                NumberAnimation {
                    target: ball
                    property: "x"
                    to: ball.destinationPoint.x
                    duration: ball.animDuration
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: ball
                    property: "y"
                    to: ball.destinationPoint.y
                    duration: ball.animDuration
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: ball
                    property: "scale"
                    to: ball.destinationScale
                    duration: ball.animDuration
                    easing.type: Easing.OutQuad
                }
            }
            ScriptAction {
                script: {
                    if(ball.ballState === "INITIAL") {
                        instructionPanel.textItem.text = ball.initialInstruction;
                    } else if (ball.ballState === "FAIL") {
                        bonus.bad("smiley")
                    } else {
                        bonus.good("smiley")
                    }
                }
            }

        }

        MouseArea {
            anchors.centerIn: ball
            height: Math.max(GCStyle.bigButtonHeight, ball.height)
            width: height
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            enabled: items.ballToReturn
            onClicked: {
                Activity.resetLevel()
            }
        }

        Timer {
            id: timerFail
            interval: 1500
            onTriggered: ball.ballState = "FAIL";
        }

        DialogHelp {
            id: dialogHelp
            onClose: home()
        }

        Bar {
            id: bar
            level: items.currentLevel + 1
            content: BarEnumContent { value: help | home | level }
            onHelpClicked: {
                displayDialog(dialogHelp)
            }
            onPreviousLevelClicked: Activity.previousLevel()
            onNextLevelClicked: Activity.nextLevel()
            onHomeClicked: activity.home()
        }

        Bonus {
            id: bonus
            winSound: "qrc:/gcompris/src/activities/ballcatch/resource/tuxok.wav"
            looseSound: "qrc:/gcompris/src/activities/ballcatch/resource/youcannot.wav"
            Component.onCompleted: {
                loose.connect(Activity.setBallToRetun)
                win.connect(activity.nextLevel)
            }
        }
// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'PenaltyByDrawnGoalAndProgressBar'
 when:activity.visible&&goal.width>0
 property int targetLevels: 9
 property var levels: []
 property var evidence: ({})
 function ensure(value,message){if(!value){console.log('PENALTY_ASSERT',message,new Error().stack);grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-ball-coordination/.scratch/pt-pt/functional-ball/penalty-replay/failure.png');}verify(value,message||'');}
 function point(item){var p=item.mapToItem(activityBackground,item.width/2,item.height/2);return {x:p.x,y:p.y,width:item.width,height:item.height,scale:item.scale,rotation:item.rotation,source:item.source!==undefined?String(item.source):null};}
 function click(item,button){var p=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,p.x,p.y,button===undefined?Qt.LeftButton:button,Qt.NoModifier,0);}
 function fill(progress){var child=progress.children[0];ensure(child.color!==undefined&&child.width!==undefined,'Drawn progress fill');return {width:child.width,total:progress.width,height:child.height,color:String(child.color),visible:progress.visible};}
 function bonusResult(good,progress){
  var path=[],bars=[],start=Date.now();while(!bonus.isPlaying&&Date.now()-start<12000){path.push(point(ball));bars.push(fill(progress));wait(20);}
  ensure(bonus.isPlaying,'Natural Bonus');tryVerify(function(){return bonus.opacity>0.5;},1500);var image=String(bonus.source);ensure(image.indexOf(good?'good':'bad')>=0,'Drawn Bonus');return {path:path,bars:bars,bonus:image};
 }
 function test_complete(){
  wait(1300);compare(activity.numberOfLevel,9);compare(activity.currentLevel,0);
  for(var level=1;level<=targetLevels;level++){
   compare(activity.currentLevel,level-1);var zones=[rectLeft,rectTop,rectRight],bars=[progressLeft,progressTop,progressRight],zoneIndex=(level-1)%3,buttonIndex=Math.floor((level-1)/3),buttons=[Qt.LeftButton,Qt.RightButton,Qt.MiddleButton],zone=zones[zoneIndex],progress=bars[zoneIndex],target=point(zone),goalBox=point(goal),goalie=point(player),before=point(ball),button=buttons[buttonIndex];
   ensure(target.x>goalBox.x-goalBox.width/2&&target.x<goalBox.x+goalBox.width/2&&target.y>goalBox.y-goalBox.height/2&&target.y<goalBox.y+goalBox.height/2,'Clicked region lies inside drawn goal');
   var initialText=String(instructionPanel.textItem.text);ensure(initialText.indexOf('lado da baliza')>=0,'Portuguese instruction names goal');
   click(zone,button);var wrong=bonusResult(false,progress);ensure(wrong.bars.some(function(row){return row.visible&&row.color==='#ff0000';}),'One slow click exhausts visible red bar');
   tryCompare(bonus,'isPlaying',false,7000);compare(activity.currentLevel,level-1);wait(300);var repairText=String(instructionPanel.textItem.text);ensure(repairText.indexOf('bola')>=0&&repairText.indexOf('posição original')>=0,'Drawn instruction requests ball return');click(ball,button);wait(700);ensure(Math.abs(point(ball).x-before.x)<1&&Math.abs(point(ball).y-before.y)<1,'Real click returns ball');
   var first=Date.now();click(zone,button);tryVerify(function(){var row=fill(progress);return row.visible&&row.width>1&&row.width<row.total&&row.color==='#00ff00';},1500);var seen=fill(progress),second=Date.now();click(zone,button);var correct=bonusResult(true,progress);ensure(correct.path.length>2,'Visible shot trajectory');var last=correct.path[correct.path.length-1];ensure(Math.abs(last.x-target.x)<3&&Math.abs(last.y-target.y)<3,'Shot reaches centre of chosen visible region');
   levels.push({level:level,zone:zoneIndex,button:buttonIndex,target:target,goal:goalBox,goalie:goalie,before:before,initialText:initialText,wrong:wrong,repairText:repairText,firstClick:first,secondClick:second,stoppedBar:seen,correct:correct});console.log('PENALTY_PROGRESS',level,targetLevels);grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-ball-coordination/.scratch/pt-pt/functional-ball/penalty-replay/level-'+level+'.png');tryCompare(activity,'currentLevel',level%9,10000);tryCompare(bonus,'isPlaying',false,3000);wait(700);
  }
 }
 function cleanupTestCase(){console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,levels:levels,evidence:evidence}));}
}

    }

}
