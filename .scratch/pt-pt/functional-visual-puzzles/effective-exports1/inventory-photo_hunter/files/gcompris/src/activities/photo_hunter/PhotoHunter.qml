import QtTest
/* GCompris - PhotoHunter.qml
 *
 * SPDX-FileCopyrightText: 2016 Stefan Toncu <stefan.toncu29@gmail.com>
 *
 * Authors:
 *   <Marc Le Douarain> (GTK+ version)
 *   Stefan Toncu <stefan.toncu29@gmail.com> (Qt Quick port)
 *
 *   SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import core 1.0
import QtQuick.Controls.Basic

import "../../core"
import "photo_hunter.js" as Activity

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
        source: "qrc:/gcompris/src/activities/fifteen/resource/background.svg"
        sourceSize.width: width
        sourceSize.height: height
        fillMode: Image.PreserveAspectCrop
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
            property alias brickSound: brickSound
            property alias bleepSound: bleepSound
            property int currentLevel: activity.currentLevel
            onCurrentLevelChanged: activity.currentLevel = currentLevel
            property int numberOfLevel: 0
            onNumberOfLevelChanged: activity.numberOfLevel = numberOfLevel
            property alias bonus: bonus
            property var model
            property alias img1: img1
            property alias img2: img2
            property int total
            property int totalFound: img1.good + img2.good
            property alias frame: frame
        }

        onStart: { Activity.start(items) }
        onStop: { Activity.stop() }

        property bool isHorizontal: frame.width >= frame.height
        property double barHeight: ApplicationSettings.isBarHidden ? bar.height : bar.height * 1.5
        property bool startedHelp: false

        function checkAnswer() {
            if (items.totalFound === items.model.length) {
                bonus.good("flower")
            }
        }

        GCSoundEffect {
            id: brickSound
            source: "qrc:/gcompris/src/core/resource/sounds/brick.wav"
        }

        GCSoundEffect {
            id: bleepSound
            source: "qrc:/gcompris/src/core/resource/sounds/bleep.wav"
        }

        GCTextPanel {
            id: instructionPanel
            panelWidth: parent.width - score.width - 3 * GCStyle.baseMargins
            panelHeight: score.height
            fixedHeight: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: score.verticalCenter
            anchors.horizontalCenterOffset: -(score.width + GCStyle.baseMargins) * 0.5
            textItem.text: activityBackground.startedHelp ?
                qsTr("Drag the slider to show the differences.") :
                qsTr("Click on the differences between the two images.")
        }

        Item {
            id: frame
            anchors.top: score.bottom
            anchors.left: activityBackground.left
            anchors.right: activityBackground.right
            anchors.bottom: parent.bottom
            anchors.margins: GCStyle.baseMargins
            anchors.bottomMargin: activityBackground.barHeight

            //left/top image
            Observe {
                id: img1
                show: true
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            //right/bottom image
            Observe {
                id: img2
                opacity: activityBackground.startedHelp ? 1 - slider.value : 1
                show: false
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
            states: [
                State {
                    name: "horizontalImages"
                    when: activityBackground.isHorizontal && !activityBackground.startedHelp
                    PropertyChanges {
                        img1 {
                            anchors.horizontalCenterOffset: -img1.width * 0.5 - GCStyle.halfMargins
                            anchors.verticalCenterOffset: 0
                        }
                    }
                    PropertyChanges {
                        img2 {
                            anchors.horizontalCenterOffset: img1.width * 0.5 + GCStyle.halfMargins
                            anchors.verticalCenterOffset: 0
                        }
                    }
                },
                State {
                    name: "verticalImages"
                    when: !activityBackground.isHorizontal && !activityBackground.startedHelp
                    PropertyChanges {
                        img1 {
                            anchors.verticalCenterOffset: -img1.height * 0.5 - GCStyle.halfMargins
                        }
                    }
                    PropertyChanges {
                        img2 {
                            anchors.verticalCenterOffset: img1.height * 0.5 + GCStyle.halfMargins
                        }
                    }
                },
                State {
                    name: "verticallHelp"
                    when: activityBackground.startedHelp
                    PropertyChanges {
                        img1 {
                            anchors.verticalCenterOffset: 0
                        }
                    }
                    PropertyChanges {
                        img2 {
                            anchors.verticalCenterOffset: 0
                        }
                    }
                }
            ]

            GCSlider {
                id: slider
                value: 0
                width: img1.width * 0.9
                z: activityBackground.startedHelp ? 5 : -5
                opacity: activityBackground.startedHelp ? 1 : 0
                enabled: activityBackground.startedHelp
                snapMode: Slider.NoSnap
                stepSize: 0

                anchors {
                    top: img2.bottom
                    topMargin: GCStyle.baseMargins
                    horizontalCenter: img1.horizontalCenter
                }
            }
        }

        DialogHelp {
            id: dialogHelp
            onClose: home()
        }

        Bar {
            id: bar
            level: items.currentLevel + 1
            content: BarEnumContent { value: help | home | level | hint }
            onHelpClicked: {
                displayDialog(dialogHelp)
            }
            onPreviousLevelClicked: Activity.previousLevel()
            onNextLevelClicked: Activity.nextLevel()
            onHomeClicked: activity.home()
            onHintClicked: {
                activityBackground.startedHelp = !activityBackground.startedHelp
                slider.value = 0
            }
        }

        Bonus {
            id: bonus
            Component.onCompleted: win.connect(activity.nextLevel)
        }

        Score {
            id: score
            anchors {
                bottom: undefined
                left: undefined
                top: activityBackground.top
                right: parent.right
                margins: GCStyle.baseMargins
            }
            numberOfSubLevels: items.total
            currentSubLevel: items.totalFound
        }
// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'ActualRenderedPhotoDifferencesInventory'
 when:activity.visible&&activity.numberOfLevel>0
 property var boards:[]
 function all(root){var found=[];if(!root.visible||root.opacity===0)return found;found.push(root);if(root.children)for(var child of root.children)found=found.concat(all(child));return found;}
 function pose(item){var p=item.mapToItem(pageView,item.width/2,item.height/2);return {x:p.x,y:p.y,width:item.width,height:item.height,source:String(item.source)};}
 function test_inventory(){
  wait(1500);var count=activity.numberOfLevel;
  for(var level=0;level<count;level++){
   compare(activity.currentLevel,level);tryCompare(img1,'status',Image.Ready,4000);tryCompare(img2,'status',Image.Ready,4000);wait(1300);
   grabImage(img1).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-visual-puzzles/.scratch/pt-pt/functional-visual-puzzles/inventory-photo_hunter/level-'+(level+1)+'-left.png');grabImage(img2).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-visual-puzzles/.scratch/pt-pt/functional-visual-puzzles/inventory-photo_hunter/level-'+(level+1)+'-right.png');grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-visual-puzzles/.scratch/pt-pt/functional-visual-puzzles/inventory-photo_hunter/level-'+(level+1)+'-question.png');
   boards.push({level:level+1,total:count,left:pose(img1),right:pose(img2),instruction:String(instructionPanel.textItem.text)});
   if(level+1<count){var next=all(bar).find(o=>o.source!==undefined&&String(o.source).endsWith('bar_next.svg')&&o.width>5);verify(next!==undefined);var p=pose(next);mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);wait(500);}
  }
 }
 function cleanupTestCase(){console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,boards:boards}));}
}

    }
}
