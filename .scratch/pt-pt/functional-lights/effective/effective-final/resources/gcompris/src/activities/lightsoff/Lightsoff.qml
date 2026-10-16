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
TestCase {
    name: "OriginalClockQrcResources"
    when: activity.visible
    property var copied: []
    function test_resources(){
        var reader=Qt.createQmlObject('import core 1.0; File {}',this);
        for(var file of ["src/activities/ballcatch/resource/tux.svg", "src/activities/family/resource/background.svg", "src/activities/lightsoff/ActivityInfo.qml", "src/activities/lightsoff/lightsoff.js", "src/activities/lightsoff/lightsoff.svg", "src/activities/lightsoff/resource/1/Data.qml", "src/activities/lightsoff/resource/2/Data.qml", "src/activities/lightsoff/resource/3/Data.qml", "src/activities/lightsoff/resource/4/Data.qml", "src/activities/lightsoff/resource/5/Data.qml", "src/activities/lightsoff/resource/6/Data.qml", "src/activities/lightsoff/resource/7/Data.qml", "src/activities/lightsoff/resource/8/Data.qml", "src/activities/lightsoff/resource/9/Data.qml", "src/activities/lightsoff/resource/back.svg", "src/activities/lightsoff/resource/grass.svg", "src/activities/lightsoff/resource/off.svg", "src/activities/lightsoff/resource/on.svg", "src/activities/menu/resource/all.svg", "src/core/resource/sounds/completetask.wav", "src/core/resource/sounds/crash.wav", "src/core/resource/sounds/scroll.wav"]){
            var source="qrc:/gcompris/"+file,target="file:///home/proteu/Projetos/GCompris-qt-worktrees/pt-lights-off/.scratch/pt-pt/functional-lights/effective-final/resources/"+file;
            verify(reader.mkpath(target.slice(0,target.lastIndexOf("/"))));verify(reader.copy(source,target),file);
            if(file.endsWith(".svg")){
                var image=Qt.createQmlObject('import QtQuick; Image { asynchronous:false }',this);image.source=source;
                tryCompare(image,"status",Image.Ready);image.destroy();
            }
            copied.push(file);
        }
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,resources:copied}));}
}

    }
}
