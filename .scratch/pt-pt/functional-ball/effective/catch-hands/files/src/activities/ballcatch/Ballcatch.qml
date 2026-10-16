import QtTest
/* gcompris - Ballcatch.qml

 SPDX-FileCopyrightText: 2014 Johnny Jazeix <jazeix@gmail.com>

 Bruno Coudoin: initial Gtk+ version

 SPDX-License-Identifier: GPL-3.0-or-later
*/
pragma ComponentBehavior: Bound

import QtQuick
import core 1.0

import "../../core"
import "../ballcatch"
import "ballcatch.js" as Activity

ActivityBase {
    id: activity

    onStart: {
        focus = true;
    }
    onStop: {}

    Keys.onPressed: (event) => {
        Activity.processKey(event);
    }

     onActivityNextLevel: {
         Activity.nextLevel()
    }

    pageComponent: Image {
        id: activityBackground
        signal start
        signal stop
        focus: true
        fillMode: Image.PreserveAspectCrop
        source: "qrc:/gcompris/src/activities/ballcatch/resource/beach1.svg"
        sourceSize.width: width
        sourceSize.height: height

        // Needed to get keyboard focus on IntroMessage
        Keys.forwardTo: [message]

        Component.onCompleted: {
            activity.start.connect(start);
            activity.stop.connect(stop);
        }
        QtObject {
            id: items
            property alias activityBackground: activityBackground
            property int currentLevel: activity.currentLevel
            onCurrentLevelChanged: activity.currentLevel = currentLevel
            property int numberOfLevel: 0
            onNumberOfLevelChanged: activity.numberOfLevel = numberOfLevel
            property alias ball: ball
            property alias smudgeSound: smudgeSound
            property alias rightHand: rightHand
            property alias leftHand: leftHand
            property alias deltaPressedTimer: deltaPressedTimer
            /* when the corresponding arrow key is pressed, the following boolean pass
               to true and is reset at the end of the level */
            property bool leftPressed
            property bool rightPressed
        }

        onStart: Activity.start(items);

        onStop: Activity.stop();

        onWidthChanged: {
            leftHand.reinitPosition();
            rightHand.reinitPosition();
            ball.reinitBall();
        }

        onHeightChanged: {
            leftHand.reinitPosition();
            rightHand.reinitPosition();
            ball.reinitBall();
        }

        GCSoundEffect {
            id: smudgeSound
            source: "qrc:/gcompris/src/core/resource/sounds/smudge.wav"
        }

        DialogHelp {
            id: dialogHelpLeftRight
            onClose: activity.home();
        }

        Bar {
            id: bar
            level: items.currentLevel + 1
            content: BarEnumContent { value: help | home | level }
            onHelpClicked: activity.displayDialog(dialogHelpLeftRight);
            onPreviousLevelClicked: if(!bonus.isPlaying) Activity.previousLevel();
            onNextLevelClicked: if(!bonus.isPlaying) Activity.nextLevel();
            onHomeClicked: activity.home();
        }

        Bonus {
            id: bonus
            winSound: "qrc:/gcompris/src/activities/ballcatch/resource/tuxok.wav"
            looseSound: "qrc:/gcompris/src/activities/ballcatch/resource/youcannot.wav"
            Component.onCompleted: {
                win.connect(activity.nextLevel);
                loose.connect(Activity.restartLevel);
            }
            onStart: tux.opacity = 0;
            onStop: tux.opacity = 1;
        }

        Image {
            id: tux
            x: activityBackground.width * 0.5 - width * 0.5
            y: activityBackground.height * 0.6 - height
            sourceSize.height: Math.min(activityBackground.height * 0.3, 200 * ApplicationInfo.ratio)
            source: "qrc:/gcompris/src/activities/ballcatch/resource/tux.svg"
            Behavior on opacity { PropertyAnimation { easing.type: Easing.InQuad; duration: 250 } }
        }

        Image {
            id: leftHand
            x: Math.max(0, activityBackground.width * 0.5 - width * 2)
            y: activityBackground.height * 0.5
            z: 5
            sourceSize.height: Math.min(Math.min(activityBackground.width * 0.25, activityBackground.height * 0.25), 150 * ApplicationInfo.ratio)
            source: "qrc:/gcompris/src/activities/ballcatch/resource/hand.svg"

            NumberAnimation {
                id: leftHandAnimation
                target: leftHand; property: "x";
                to: activityBackground.width * 0.5 - leftHand.width - 5;
                duration: 1000
                easing.type: Easing.InOutQuad
            }

            function animate(newTime: int) {
                leftHandAnimation.duration = newTime;
                leftHandAnimation.start();
            }

            function reinitPosition() {
                leftHandAnimation.stop();
                leftHand.x = Math.max(0, activityBackground.width * 0.5 - width * 2);
                leftHand.y = activityBackground.height * 0.5;
            }

            MultiPointTouchArea {

                id: mouseAreaLeftShift
                anchors.fill: parent
                onTouchUpdated: {
                    // left
                    if(!items.leftPressed && !Activity.gameFinished) {
                        Activity.leftShiftPressed();
                        items.leftPressed = true;
                    }
                }
            }
        }

        Image {
            id: rightHand
            mirror: true
            x: Math.min(activityBackground.width * 0.5 + width, activityBackground.width - width);
            y: activityBackground.height * 0.5
            z: 5
            sourceSize.height: leftHand.sourceSize.height
            source: "qrc:/gcompris/src/activities/ballcatch/resource/hand.svg"

            function animate(newTime: int) {
                rightHandAnimation.duration = newTime;
                rightHandAnimation.start();
            }

            function reinitPosition() {
                rightHandAnimation.stop();
                rightHand.x = Math.min(activityBackground.width * 0.5 + width, activityBackground.width - width);
                rightHand.y = activityBackground.height * 0.5;
            }

            NumberAnimation {
                id: rightHandAnimation
                target: rightHand; property: "x";
                to: activityBackground.width * 0.5 + 5;
                duration: 1000;
                easing.type: Easing.InOutQuad
            }

            MultiPointTouchArea {
                id: mouseAreaRightShift
                anchors.fill: parent
                onTouchUpdated: {
                    // right
                    if(!items.rightPressed && !Activity.gameFinished) {
                        Activity.rightShiftPressed();
                        items.rightPressed = true;
                    }
                }
            }
        }

        Image {
            id: leftShift
            z: 10
            x: activityBackground.width * 0.2 - width * 0.5
            y: activityBackground.height * 0.5 - height
            source: "qrc:/gcompris/src/activities/ballcatch/resource/arrow_key.svg"
            sourceSize.width: Math.min(100 * ApplicationInfo.ratio, Math.min(activityBackground.height * 0.2, activityBackground.width * 0.2))
            opacity: items.leftPressed ? 1 : 0.5
            visible: !ApplicationInfo.isMobile
        }

        Image {
            id: rightShift
            z: 10
            mirror: true
            x: activityBackground.width * 0.8 - width * 0.5
            y: leftShift.y
            source: "qrc:/gcompris/src/activities/ballcatch/resource/arrow_key.svg"
            sourceSize.width: leftShift.sourceSize.width
            opacity: items.rightPressed ? 1 : 0.5
            visible: !ApplicationInfo.isMobile
        }

        ListModel {
            id: tutoMobile
            ListElement {
                text: qsTr("Tap both hands at the same time, to make the ball go in a straight line.")
            }
        }
        ListModel {
            id: tutoDesktop
            ListElement {
                text: qsTr("Press left and right arrow keys at the same time, to make the ball go in a straight line.")
            }
        }
        // Instructions
        IntroMessage {
            id: message
            intro: ApplicationInfo.isMobile ? tutoMobile : tutoDesktop
            z: 10
        }

        /* Timer starting when user first presses a first key.
           If still running when the user presses the other key, he wins !
        */
        Timer {
            id: deltaPressedTimer
            running: false; repeat: false
            onTriggered: {
                Activity.endTimer();
                ball.startAnimation();
            }
        }

        Ball {
            id: ball
        }

// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name: 'CatchByVisibleTrajectoryAndRealInputs'
 when: activity.visible
 property int targetLevels: 9
 property bool useHands: true
 property var levels: []
 property var evidence: ({})
 function ensure(value,message){if(!value){console.log('BALL_ASSERT',message,new Error().stack);grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-ball-coordination/.scratch/pt-pt/functional-ball/catch-hands/failure.png');}verify(value,message||'');}
 function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var hit=find(child,predicate);if(hit)return hit;}return null;}
 function click(item){ensure(item!==null);var p=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);}
 function point(item){var p=item.mapToItem(activityBackground,item.width/2,item.height/2);return {x:p.x,y:p.y,width:item.width,height:item.height,scale:item.scale,rotation:item.rotation,source:String(item.source)};}
 function input(left){var now=Date.now();if(useHands)click(left?leftHand:rightHand);else keyClick(left?Qt.Key_Left:Qt.Key_Right,Qt.NoModifier,0);return {side:left?'left':'right',timestamp:now,kind:useHands?'mouse-on-hand':'arrow-key'};}
 function feedback(good){
  var samples=[],start=Date.now();
  while(!bonus.isPlaying&&Date.now()-start<12000){samples.push(point(ball));wait(20);}
  ensure(bonus.isPlaying,'Natural Bonus appears');tryVerify(function(){return bonus.opacity>0.5;},1500);var image=String(bonus.source);ensure(image.indexOf(good?'good':'bad')>=0,'Drawn Bonus matches real input');
  return {path:samples,bonus:image};
 }
 function test_complete(){
  wait(1200);compare(activity.numberOfLevel,9);compare(activity.currentLevel,0);ensure(message.visible,'Intro shown');
  var intro=find(message,function(o){return o.visible&&o.text!==undefined&&String(o.text).indexOf('linha reta')>=0;});ensure(intro!==null,'Portuguese drawn introduction');evidence.intro=String(intro.text);keyClick(Qt.Key_Return);tryCompare(message,'visible',false,2000);wait(300);
  for(var level=1;level<=targetLevels;level++){
   compare(activity.currentLevel,level-1);tryVerify(function(){return tux.opacity>0.9;},1500);var target=point(tux),before=point(ball);ensure(Math.abs(before.x-target.x)<1,'Ball initially aligned with Tux');
   var wrongInput=input(level%2===1),wrong=feedback(false);ensure(wrong.path.length>3,'Visible failing trajectory');var lastWrong=wrong.path[wrong.path.length-1];ensure(Math.abs(lastWrong.x-target.x)>target.width/2,'Miss passes beside Tux');
   tryCompare(bonus,'isPlaying',false,7000);compare(activity.currentLevel,level-1);wait(350);ensure(Math.abs(point(ball).x-before.x)<1&&Math.abs(point(ball).y-before.y)<1,'Natural failure repair resets visible ball');
   var inputs=[input(true),input(false)],correct=feedback(true);ensure(correct.path.length>3,'Visible straight trajectory');
   for(var sample of correct.path)ensure(Math.abs(sample.x-before.x)<1,'Synchronized ball stays in a straight line');ensure(correct.path[correct.path.length-1].y<before.y-20,'Ball moves towards Tux');
   levels.push({level:level,target:target,before:before,wrongInput:wrongInput,wrong:wrong,inputs:inputs,correct:correct});console.log('BALL_PROGRESS',level,targetLevels,useHands);grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-ball-coordination/.scratch/pt-pt/functional-ball/catch-hands/level-'+level+'.png');
   tryCompare(activity,'currentLevel',level%9,10000);tryCompare(bonus,'isPlaying',false,3000);wait(350);
  }
 }
 function cleanupTestCase(){console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,levels:levels,evidence:evidence}));}
}

    }
}
