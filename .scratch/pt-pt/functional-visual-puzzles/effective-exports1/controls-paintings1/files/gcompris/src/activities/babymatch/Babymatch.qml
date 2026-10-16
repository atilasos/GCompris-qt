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
    id: qa
    name:'VisualPuzzlePublicControls'
    when: activity.visible && activity.numberOfLevel>0
    property int firstLevel: 1
    property int targetLevels: 1
    property var boards: []
    property int wins: 0
    property int wrong: 0
    property int moves: 0
    property var oracle: ({})
    Connections { target: bonus; function onWin(){qa.wins++;} }
    function check(a,b,message){if(a!==b)console.log('ASSOCIATION_ASSERT',a,b,message||'',new Error().stack);compare(a,b,message||'');}
    function ensure(v,message){if(!v)console.log('ASSOCIATION_ASSERT_FALSE',message||'',new Error().stack);verify(v,message||'');}
    function all(root,predicate){var out=[];function walk(o){if(!o.visible||o.opacity===0)return;if(predicate(o))out.push(o);if(o.children)for(var c of o.children)walk(c);}walk(root);return out;}
    function imageId(source){return String(source).split('/resource/').pop();}
    function point(item){var p=item.mapToItem(pageView,item.width/2,item.height/2);return {x:p.x,y:p.y};}
    function images(root){return all(root,function(o){return o.source!==undefined&&o.status!==undefined&&o.width>12&&o.height>12&&String(o.source).indexOf(String(activity.imagesUrl))===0;});}
    function blanks(){return Array.from(spotsContainer.children).filter(function(o){return o.visible&&o.radius!==undefined&&o.width>0&&o.width<30;});}
    function sidebar(){return images(availablePieces).filter(function(o){var p=point(o);return p.x>=0&&p.y>=0&&p.x<pageView.width&&p.y<bar.y;});}
    function click(item){ensure(item!==null);var p=point(item);mouseClick(pageView,p.x,p.y);wait(70);}
    function icon(root,suffix){var found=all(root,function(o){return o.source!==undefined&&String(o.source).endsWith(suffix)&&o.opacity>0&&o.width>5;});ensure(found.length>0,suffix);click(found[0]);}
    function nearest(items,p){var best=null,d=Infinity;for(var item of items){var q=point(item),dist=(q.x-p.x)*(q.x-p.x)+(q.y-p.y)*(q.y-p.y);if(dist<d){best=item;d=dist;}}ensure(best!==null);return best;}
    function drag(image,target){var a=point(image),b=point(target);mousePress(pageView,a.x,a.y);mouseMove(pageView,a.x+14,a.y,60);for(var i=1;i<=14;i++)mouseMove(pageView,a.x+(b.x-a.x)*i/14,a.y+(b.y-a.y)*i/14,20);mouseRelease(pageView,b.x,b.y);moves++;wait(520);}
    function answerFor(image,targets,backgrounds,labels){
        var name=imageId(image.source),base=name.split('/').pop(),activityName=activity.activityInfo.shortName();
        if(activityName==='imagename'){
            var text=oracle.semantic.names[base];ensure(text!==undefined,'Inspected image dictionary: '+base);
            var label=labels.filter(function(t){return String(t.text)===text;});ensure(label.length===1,'PT label for '+base+' must be '+text);
            var lp=point(label[0]);var above=targets.filter(function(t){var p=point(t);return p.y<lp.y;});return {target:nearest(above,lp),reason:'PT '+text,evidence:{name:text}};
        }
        if(activityName==='babymatch'){
            var pairs=oracle.semantic.relations.filter(function(r){return r[0]===base;});
            var matches=[];for(var pair of pairs)for(var background of backgrounds)if(imageId(background.source).split('/').pop()===pair[1])matches.push({image:background,reason:pair[2]});
            ensure(matches.length===1,'Inspected semantic relation '+base);return {target:nearest(targets,point(matches[0].image)),reason:matches[0].reason,evidence:{background:imageId(matches[0].image.source)}};
        }
        if(oracle.silhouettes[name]!==undefined){var match=oracle.silhouettes[name];var found=backgrounds.filter(function(t){return imageId(t.source)===match.target;});ensure(found.length===1);return {target:nearest(targets,point(found[0])),reason:'Rendered silhouette IoU '+match.iou,evidence:match};}
        if(oracle.semantic.dog[name]!==undefined){var rule=oracle.semantic.dog[name];var sorted=targets.slice();sorted.sort(function(a,b){var x=point(a),y=point(b);return rule.rule==='topmost'?x.y-y.y:rule.rule==='leftmost'?x.x-y.x:y.x-x.x;});return {target:sorted[0],reason:rule.reason,evidence:{rule:rule.rule}};}
        var hole=oracle.holes[name];ensure(hole!==undefined,'Independent visible hole '+name);check(imageId(backgroundImage.source),hole.background);var p=backgroundImage.mapToItem(pageView,backgroundImage.width*hole.center[0],backgroundImage.height*hole.center[1]);return {target:nearest(targets,p),reason:'Visible image hole geometry and edge continuity',evidence:hole};
    }
    property var evidence: ({})
    function keyboardCycle(removeKey){
        keyClick(Qt.Key_Right);keyClick(Qt.Key_Space);keyClick(Qt.Key_Space);wait(600);check(images(spotsContainer).length,1);
        keyClick(Qt.Key_Tab);keyClick(removeKey);wait(600);check(images(spotsContainer).length,0);keyClick(Qt.Key_Tab);
    }
    function test_controls(){
        wait(1500);var total=activity.activityInfo.shortName()==='details'?21:22;check(activity.numberOfLevel,total);check(activity.currentLevel,0);
        var initial=sidebar();ensure(initial.length>=2);drag(initial[0],blanks()[0]);check(images(spotsContainer).length,1);
        icon(bar,'bar_next.svg');check(activity.currentLevel,1);icon(bar,'bar_previous.svg');check(activity.currentLevel,0);wait(300);check(images(spotsContainer).length,0);
        activityBackground.forceActiveFocus();keyboardCycle(Qt.Key_Delete);
        var depth=pageView.depth;icon(bar,'bar_help.svg');tryCompare(pageView,'depth',depth+1,2500);tryCompare(pageView,'busy',false,2000);wait(400);var help=pageView.currentItem;
        check(help.title,activity.activityInfo.title);ensure(help.content.indexOf(activity.activityInfo.manual)>=0);ensure(activity.activityInfo.manual.indexOf('Espaço')>=0);grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-visual-puzzles/.scratch/pt-pt/functional-visual-puzzles/controls-paintings1/help.png');var title=help.title;
        keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth,2500);tryCompare(pageView,'busy',false,2000);wait(400);keyboardCycle(Qt.Key_Backspace);
        evidence={title:title,levels:total,partialRestartByNavigation:true,keyboardDropDelete:true,keyboardAfterHelp:true,helpPortuguese:true,datasets:[]};
        if(total===21){
          for(var choice=0;choice<3;choice++){
            icon(bar,'bar_activity_config.svg');tryCompare(pageView,'depth',depth+1,2500);tryCompare(pageView,'busy',false,2000);wait(400);var panel=pageView.currentItem;
            var checks=all(panel,o=>o.checked!==undefined&&o.indicatorImageHeight!==undefined&&o.text!==undefined);check(checks.length,3,'Three publicly labelled data sets');
            if(!checks[choice].checked)click(checks[choice]);for(var j=0;j<3;j++)if(j!==choice&&checks[j].checked)click(checks[j]);
            var labels=checks.map(o=>({text:String(o.text),checked:o.checked}));check(labels.filter(o=>o.checked).length,1);grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-visual-puzzles/.scratch/pt-pt/functional-visual-puzzles/controls-paintings1/dataset-'+choice+'.png');
            var save=all(panel,o=>o.text!==undefined&&String(o.text)==='Gravar'&&o.clicked!==undefined);check(save.length,1,'Portuguese save button');click(save[0]);tryCompare(pageView,'depth',depth,2500);tryCompare(pageView,'busy',false,2500);wait(800);ensure(activity.numberOfLevel>0&&activity.numberOfLevel<21);check(activity.currentLevel,0);ensure(sidebar().length>=2);evidence.datasets.push({labels:labels,levels:activity.numberOfLevel,frame:{source:String(backgroundImage.source),width:backgroundImage.width,height:backgroundImage.height}});
          }
        }else ensure(all(bar,o=>o.source!==undefined&&String(o.source).endsWith('bar_activity_config.svg')).length===0,'No configuration exposed');
        var pending=sidebar();drag(pending[0],blanks()[0]);check(images(spotsContainer).length,1);grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-visual-puzzles/.scratch/pt-pt/functional-visual-puzzles/controls-paintings1/partial.png');
        ActivityInfoTree.startingActivity='';icon(bar,'bar_home.svg');tryCompare(pageView,'depth',1,2500);tryCompare(pageView,'busy',false,2000);ensure(pageView.currentItem.isMenu);evidence.menuDuringActivity={depth:pageView.depth,busy:pageView.busy,isMenu:pageView.currentItem.isMenu};grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-visual-puzzles/.scratch/pt-pt/functional-visual-puzzles/controls-paintings1/menu.png');
    }
    function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-visual-puzzles/.scratch/pt-pt/functional-visual-puzzles/controls-paintings1/failure.png');console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,activity:activity.activityInfo.shortName(),evidence:evidence}));}
}

    }
}
