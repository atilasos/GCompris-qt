import QtTest
/* GCompris - Babymatch.qml
 *
 * SPDX-FileCopyrightText: 2015 Pulkit Gupta <pulkitgenius@gmail.com>
 *
 * Authors:
 *   Bruno Coudoin <bruno.coudoin@gcompris.net> (GTK+ version)
 *   Pulkit Gupta <pulkitgenius@gmail.com> (Qt Quick port)
 *
 *   SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import core 1.0

import "../../core"
import "babymatch.js" as Activity

ActivityBase {
    id: activity

    // In most cases, these 3 are the same.
    // But for imageName for example, we reuse the images of babymatch, so we need to differentiate them
    property string imagesUrl: boardsUrl
    property string soundsUrl: boardsUrl
    property bool useMultipleDataset: false
    property string boardsUrl: "qrc:/gcompris/src/activities/babymatch/resource/"
    property int levelCount: 7
    property bool answerGlow: true	//For highlighting the answers
    property bool displayDropCircle: true	//For displaying drop circles

    onStart: focus = true;
    onStop: {}

     onActivityNextLevel: {
         Activity.nextLevel()
    }

    pageComponent: Image {
        id: activityBackground
        anchors.fill: parent
        source: "qrc:/gcompris/src/activities/guesscount/resource/backgroundW01.svg" 

        signal start
        signal stop

        property bool verticalBar: activityBackground.width >= activityBackground.height

        Component.onCompleted: {
            dialogActivityConfig.initialize();
            activity.start.connect(start);
            activity.stop.connect(stop);
        }

        // Add here the QML items you need to access in javascript
        QtObject {
            id: items
            property alias activityBackground: activityBackground
            property int currentLevel: activity.currentLevel
            onCurrentLevelChanged: activity.currentLevel = currentLevel
            property int numberOfLevel: 0
            onNumberOfLevelChanged: activity.numberOfLevel = numberOfLevel
            property alias bonus: bonus
            property alias availablePieces: availablePieces
            property alias backgroundPiecesModel: backgroundPiecesModel
            property alias grid: grid
            property alias backgroundImageSource: backgroundImageSource
            property alias backgroundImage: backgroundImage
            property alias spotsContainer: spotsContainer
            property alias leftWidget: leftWidget
            property alias instructionPanel: instructionPanel
            property alias toolTip: toolTip
            property alias score: score
            property alias goodAnswerSound: goodAnswerSound
            property alias badAnswerSound: badAnswerSound
            readonly property var levels: activity.datasets.length !== 0 ? activity.datasets : null
            property alias dataset: dataset
            property bool inputLocked: false
            // same formula used to define dropCircle size, here to define a minimum MouseArea
            // size for dropped items if they are smaller than the circles.
            property double minimumClickArea: backgroundImage.width >= backgroundImage.height ? backgroundImage.height/35 : backgroundImage.width/35

            // For keyboard controls
            property bool keyboardControls: false
            property bool listFocus: true
            property int selectedSpotIndex: -1
            property DropAnswerItem selectedSpot: null
        }

        Keys.onPressed: (event) => {
            if ([Qt.Key_Left, Qt.Key_Right, Qt.Key_Up, Qt.Key_Down, Qt.Key_Space,
                 Qt.Key_Tab, Qt.Key_Delete, Qt.Key_Backspace, Qt.Key_Return, Qt.Key_Enter].indexOf(event.key) === -1)
                return;
            event.accepted = true;
            if(items.inputLocked) {
                return;
            }
            if(event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if(availablePieces.okEnabled) {
                    availablePieces.view.checkAnswer();
                    return;
                }
            }
            if(!items.keyboardControls) {
                items.keyboardControls = true;
            }
            switch(event.key) {
                case Qt.Key_Left:
                case Qt.Key_Up:
                    Activity.moveCursorLeft();
                    break;
                case Qt.Key_Right:
                case Qt.Key_Down:
                    Activity.moveCursorRight();
                    break;
                case Qt.Key_Space:
                    Activity.spacePressed();
                    break;
                case Qt.Key_Tab:
                    Activity.switchFocus();
                    break;
                case Qt.Key_Delete:
                case Qt.Key_Backspace:
                    Activity.undropItem();
            }
        }


        Loader {
            id: dataset
            asynchronous: false
        }

        GCSoundEffect {
            id: goodAnswerSound
            source: "qrc:/gcompris/src/core/resource/sounds/completetask.wav"
        }

        GCSoundEffect {
            id: badAnswerSound
            source: "qrc:/gcompris/src/core/resource/sounds/crash.wav"
        }

        onStart: { Activity.start(items, imagesUrl, soundsUrl, boardsUrl, levelCount, answerGlow, displayDropCircle, useMultipleDataset); }
        onStop: { Activity.stop(); }

        DialogHelp {
            id: dialogHelp
            onClose: home();
        }

        Bar {
            id: bar
            level: items.currentLevel + 1
            content: BarEnumContent { value: useMultipleDataset ? (help | home | level | activityConfig) : (help | home | level) }
            onHelpClicked: displayDialog(dialogHelp);
            onPreviousLevelClicked: Activity.previousLevel();
            onNextLevelClicked: Activity.nextLevel();
            onHomeClicked: {
                Activity.resetData();
                activity.home();
            }
            onActivityConfigClicked: {
                Activity.initLevel();
                displayDialog(dialogActivityConfig);
             }
        }

        DialogChooseLevel {
            id: dialogActivityConfig
            currentActivity: activity.activityInfo
            onSaveData: {
                levelFolder = dialogActivityConfig.chosenLevels;
                currentActivity.currentLevels = dialogActivityConfig.chosenLevels;
                activity.focus = true;
            }
            onLoadData: {
                if(activityData) {
                    Activity.initLevel();
                }
            }
            onClose: {
                home();
            }
            onStartActivity: {
                activityBackground.start();
            }
        }

        Score {
            id: score
            visible: numberOfSubLevels > 1
            anchors.right: parent.right
            anchors.rightMargin: GCStyle.baseMargins
            anchors.bottom: bar.top
            onStop: Activity.nextSubLevel()
        }

        Bonus {
            id: bonus
            Component.onCompleted: win.connect(activity.nextLevel);
        }

        Image {
            id: leftWidget
            source: "qrc:/gcompris/src/activities/guesscount/resource/backgroundW02.svg"
            width: activityBackground.verticalBar ?
                       90 * ApplicationInfo.ratio :
                       activityBackground.width
            height: activityBackground.verticalBar ?
                        activityBackground.height :
                        90 * ApplicationInfo.ratio
            anchors.left: parent.left
            ListWidget {
                id: availablePieces
            }
            MouseArea {
                anchors.fill: parent
                enabled: !items.inputLocked
                onPressed: {
                    Activity.resetKeyboardControls();
                    instructionPanel.opacity === 0 ? instructionPanel.show() : instructionPanel.hide();
                }
            }
        }

        Rectangle {
            id: toolTip
            anchors {
                bottom: bar.top
                left: leftWidget.left
                margins: GCStyle.halfMargins
            }
            width: toolTipTxt.contentWidth + GCStyle.baseMargins
            height: toolTipTxt.contentHeight + GCStyle.tinyMargins
            opacity: 1
            radius: GCStyle.halfMargins
            border.width: GCStyle.thinBorder
            border.color: GCStyle.blueBorder
            z: 100
            color: GCStyle.paperWhite
            property alias text: toolTipTxt.text
            Behavior on opacity { NumberAnimation { duration: 120 } }

            function show(newText: string) {
                if(newText) {
                    text = newText;
                    opacity = 0.8;
                } else {
                    opacity = 0;
                }
            }

            GCText {
                id: toolTipTxt
                anchors.centerIn: parent
                fontSize: regularSize
                color: GCStyle.darkText
                horizontalAlignment: Text.AlignHCenter
                wrapMode: TextEdit.WordWrap
            }
        }

        Item {
            id: grid
            z: 2
            x: activityBackground.verticalBar ? 90 * ApplicationInfo.ratio : 0
            y: activityBackground.verticalBar ? 0 : 90 * ApplicationInfo.ratio
            width: activityBackground.verticalBar ?
                       activityBackground.width - 90 * ApplicationInfo.ratio : activityBackground.width
            height: activityBackground.verticalBar ?
                        activityBackground.height - (bar.height * 1.1) :
                        activityBackground.height - (bar.height * 1.1) - 90 * ApplicationInfo.ratio

            // We need two items for the background image:
            // - backgroundImageSource is needed to keep the original sourceSize info which is used
            // in calculations, and to load quickly the image on startup;
            // - backgroundImage is used for the "clean" render of the image,
            // with its sourceSize linked to the actual size to get perfect svg rendering,
            // but as it can be slow on heavy maps we load this one asynchronously.
            Image {
                id: backgroundImageSource
                source: ""
                fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent
                property double ratio: sourceSize.width / sourceSize.height
                property double gridRatio: grid.width / grid.height
                // shrink size by 2 pixels to make sure it is always perfectly hidden by backgroundImage
                width: (source == "" ? grid.width :
                        (ratio > gridRatio ? grid.width : grid.height * ratio)) - 2
                height: (source == "" ? grid.height :
                        (ratio < gridRatio ? grid.height : grid.width / ratio)) - 2
            }

            Image {
                id: backgroundImage
                fillMode: Image.PreserveAspectFit
                source: backgroundImageSource.source
                z: 2
                width: backgroundImageSource.width + 2
                height: backgroundImageSource.height + 2
                sourceSize.width: width
                sourceSize.height: height
                anchors.centerIn: parent
                asynchronous: true

                //Inserting static background images
                Repeater {
                    id: backgroundPieces
                    model: backgroundPiecesModel
                    delegate: piecesDelegate
                    z: 2

                    Component {
                        id: piecesDelegate
                        Image {
                            id: shapeBackground
                            source: Activity.imagesUrl + imgName
                            x: posX * backgroundImage.width - width / 2
                            y: posY * backgroundImage.height - height / 2

                            height:
                                imgHeight ?
                                    imgHeight * backgroundImage.height :
                                    (backgroundImage.source == "" ?
                                         backgroundImage.height * sourceShape.sourceSize.height / backgroundImage.height :
                                         backgroundImage.height * sourceShape.sourceSize.height /
                                         backgroundImageSource.sourceSize.height)

                            width:
                                imgWidth ?
                                    imgWidth * backgroundImage.width :
                                    (backgroundImage.source == "" ?
                                         backgroundImage.width * sourceShape.sourceSize.width / backgroundImage.width :
                                         backgroundImage.width * sourceShape.sourceSize.width /
                                         backgroundImageSource.sourceSize.width)

                            sourceSize.width: width
                            sourceSize.height: height
                            fillMode: Image.PreserveAspectFit
                            Image {
                                id: sourceShape
                                anchors.centerIn: parent
                                source: Activity.imagesUrl + imgName
                                visible: false
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: !items.inputLocked
                    onPressed: {
                        instructionPanel.opacity === 0 ? instructionPanel.show() : instructionPanel.hide();
                        Activity.resetKeyboardControls();
                    }
                }

                Item {
                    id: spotsContainer
                    anchors.fill: parent
                }
            }
        }

        GCTextPanel {
            id: instructionPanel
            z: 10
            panelWidth: grid.width - 2 * GCStyle.baseMargins
            panelHeight: Math.min(50 * ApplicationInfo.ratio, grid.height * 0.2)
            fixedHeight: false
            anchors {
                top: activityBackground.verticalBar ? grid.top : leftWidget.bottom
                topMargin: GCStyle.baseMargins
                horizontalCenter: activityBackground.verticalBar ? grid.horizontalCenter : leftWidget.horizontalCenter
            }
            color: GCStyle.paperWhite
            border.color: GCStyle.blueBorder
            border.width: GCStyle.thinBorder
            textItem.color: GCStyle.darkText

            Behavior on opacity { NumberAnimation { duration: 100 } }

            function show() {
                if(textItem.text)
                    opacity = 1;
            }
            function hide() {
                opacity = 0;
            }
        }

        ListModel {
            id: backgroundPiecesModel
        }

        Item {
            id: movePlaceholder
            z: 1000
            anchors.fill: activityBackground
        }
// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 id:qa
 name:'PaintingsFromAlphaAndVisibleOrangeSlots'
 when:activity.visible&&activity.numberOfLevel>0
 property var boards:[]
 property var evidence:({})
 property int wins:0
 property int moves:0
 Connections {target:bonus;function onWin(){qa.wins++;}}
 function check(actual,expected,message){if(actual!==expected){evidence.failure={kind:'comparison',actual:String(actual),expected:String(expected),message:message||'',stack:new Error().stack};console.log('DETAIL_ASSERT',JSON.stringify(evidence.failure));}compare(actual,expected,message||'');}
 function ensure(value,message){if(!value){evidence.failure={kind:'verification',message:message||'',stack:new Error().stack};console.log('DETAIL_ASSERT',JSON.stringify(evidence.failure));}verify(value,message||'');}
 function all(root){var found=[];if(!root.visible||root.opacity===0)return found;found.push(root);if(root.children)for(var child of root.children)found=found.concat(all(child));return found;}
 function pose(item){var p=item.mapToItem(pageView,item.width/2,item.height/2);return {x:p.x,y:p.y,width:item.width,height:item.height,opacity:item.opacity,visible:item.visible,source:item.source!==undefined?String(item.source):null};}
 function images(root){return all(root).filter(o=>o.source!==undefined&&o.status===Image.Ready&&String(o.source).indexOf(String(activity.imagesUrl))===0&&o.width>10&&o.height>10);}
 function sidebar(){return images(availablePieces).filter(o=>pose(o).x>=0&&pose(o).x<pageView.width&&pose(o).y>=0&&pose(o).y<bar.y);}
 function icon(root,suffix){var target=all(root).find(o=>o.source!==undefined&&String(o.source).endsWith(suffix)&&o.width>5);ensure(target!==undefined,'Real drawn icon '+suffix);if(suffix==='bar_ok.svg'){var before={enabled:availablePieces.okEnabled,pose:pose(target)};tryCompare(availablePieces,'okEnabled',true,2500);if(!evidence.validationReadiness)evidence.validationReadiness=[];evidence.validationReadiness.push({before:before,after:{enabled:availablePieces.okEnabled,pose:pose(target)}});}var p=pose(target);mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);wait(100);}
 function drag(image,target){var a=pose(image),source=String(image.source);ensure(target.x>=0&&target.y>=0&&target.x<pageView.width&&target.y<bar.y);mousePress(pageView,a.x,a.y);mouseMove(pageView,a.x+14,a.y,60);for(var i=1;i<=14;i++)mouseMove(pageView,a.x+(target.x-a.x)*i/14,a.y+(target.y-a.y)*i/14,20);mouseRelease(pageView,target.x,target.y);wait(550);var placed=images(spotsContainer).filter(o=>String(o.source)===source);check(placed.length,1,'Drop accepted through actual pointer path');moves++;return {source:source,from:a,target:target,placed:pose(placed[0])};}
 function answer(image,rule){var source=String(image.source),match=rule.answers[source];ensure(match!==undefined,'Pixel-derived image identity');var p=backgroundImage.mapToItem(pageView,backgroundImage.width*match.center[0],backgroundImage.height*match.center[1]);return {x:p.x,y:p.y,pixelMatch:match};}
 function test_all_paintings(){
  wait(1500);check(activity.numberOfLevel,22);var file=Qt.createQmlObject('import core 1.0; File {}',this);var oracle=JSON.parse(file.read('/home/proteu/Projetos/GCompris-qt-worktrees/pt-visual-puzzles/build/functional-visual-puzzles/sources/5747488c2389f43ef1f50a5c41d8c95a713b7e8f/tests/functional_visual_puzzles/visual-oracle.json')).paintings;
  for(var level=1;level<=22;level++){
   check(activity.currentLevel,level-1);tryCompare(backgroundImage,'status',Image.Ready,4000);wait(450);var rule=oracle[String(level)];check(String(backgroundImage.source),rule.background);var frame=pose(backgroundImage),beforeWins=wins,first=sidebar();ensure(first.length>=2);var a=first[0],b=first[1],nameA=String(a.source),nameB=String(b.source),targetA=answer(a,rule),targetB=answer(b,rule);ensure(Math.abs(targetA.x-targetB.x)+Math.abs(targetA.y-targetB.y)>2);var placements=[];grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-visual-puzzles/.scratch/pt-pt/functional-visual-puzzles/paintings-complete2/level-'+level+'-question.png');
   var wrongA=drag(a,targetB),wrongB=drag(b,targetA);placements.push({piece:nameA,target:targetA});placements.push({piece:nameB,target:targetB});
   for(var step=0;step<40;step++){
    var remaining=sidebar();if(remaining.length===0)break;var image=remaining[0],source=String(image.source),target=answer(image,rule);placements.push({piece:source,target:target});drag(image,target);ensure(step<39,'Finite piece list');
   }
   check(placements.length,Object.keys(rule.answers).length,'All independently inventoried pieces placed');icon(availablePieces,'bar_ok.svg');wait(180);check(wins,beforeWins);ensure(!bonus.isPlaying);var errors=all(spotsContainer).filter(o=>o.source!==undefined&&String(o.source).endsWith('/error.svg'));ensure(errors.length>=2,'Swapped details visibly rejected');var errorViews=errors.map(pose);grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-visual-puzzles/.scratch/pt-pt/functional-visual-puzzles/paintings-complete2/level-'+level+'-wrong.png');
   var dropped=images(spotsContainer).filter(o=>String(o.source)===nameA);check(dropped.length,1);drag(dropped[0],targetA);var returned=sidebar().filter(o=>String(o.source)===nameB);check(returned.length,1,'Replaced piece returns to visible panel');drag(returned[0],targetB);grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-visual-puzzles/.scratch/pt-pt/functional-visual-puzzles/paintings-complete2/level-'+level+'-answer.png');icon(availablePieces,'bar_ok.svg');tryCompare(bonus,'isPlaying',true,2000);ensure(String(bonus.source).indexOf('good')>=0);var good=String(bonus.source);boards.push({level:level,frame:frame,instruction:String(instructionPanel.textItem.text),placements:placements,wrong:[wrongA,wrongB],errors:errorViews,bonus:good});tryCompare(qa,'wins',beforeWins+1,10000);tryCompare(activity,'currentLevel',level%22,3000);console.log('PAINTING_HEARTBEAT',level,boards.length);
  }
  ActivityInfoTree.startingActivity='';keyClick(Qt.Key_W,Qt.ControlModifier);tryCompare(pageView,'depth',1,2000);tryCompare(pageView,'busy',false,2000);ensure(pageView.currentItem.isMenu);evidence.menuAfterSuccess={depth:pageView.depth,busy:pageView.busy,isMenu:pageView.currentItem.isMenu};grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-visual-puzzles/.scratch/pt-pt/functional-visual-puzzles/paintings-complete2/menu-after-success.png');
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-visual-puzzles/.scratch/pt-pt/functional-visual-puzzles/paintings-complete2/failure.png');console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,boards:boards,wins:wins,moves:moves,evidence:evidence}));}
}

    }
}
