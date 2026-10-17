// SPDX-FileCopyrightText: NONE
// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls.Basic as Controls

// Presentation only: each activity owns its rules, state and controls.
Item {
    id: layout
    property Item focusTarget
    property string gameName
    property url iconSource
    property alias headerArea: headerArea
    property alias boardArea: boardArea
    property alias toolItems: tools.data
    readonly property bool wide: width >= 760 && width > height * 1.2
    readonly property real panelSize: wide ? Math.min(360, Math.max(270, width * 0.24)) : Math.min(200, height * 0.27)
    readonly property real headerHeight: Math.max(54, Math.min(78, height * 0.10))

    Rectangle {
        id: header
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 10
        }
        height: layout.headerHeight
        radius: 18
        color: "#ffffff"
        Image {
            x: 12
            anchors.verticalCenter: parent.verticalCenter
            width: 42
            height: 42
            source: layout.iconSource
            sourceSize.width: 80
        }
        BoardGameText {
            x: 66
            width: parent.width * 0.22
            height: parent.height
            text: layout.gameName
            fontSize: 19
            font.bold: true
            color: "#17668b"
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
        }
        Item {
            id: headerArea
            x: parent.width * 0.31
            width: parent.width * 0.67 - 10
            height: parent.height
        }
    }
    Rectangle {
        id: boardCard
        x: 10
        y: header.y + header.height + 10
        width: layout.wide ? layout.width - layout.panelSize - 30 : layout.width - 20
        height: layout.wide ? layout.height - y - 10 : layout.height - y - layout.panelSize - 20
        radius: 20
        color: "#f9fcfd"
        border.color: "#bad2dc"
        Item {
            id: boardArea
            anchors.fill: parent
            anchors.margins: 14
        }
    }
    Rectangle {
        x: layout.wide ? boardCard.x + boardCard.width + 10 : 10
        y: layout.wide ? boardCard.y : boardCard.y + boardCard.height + 10
        width: layout.wide ? layout.panelSize : layout.width - 20
        height: layout.wide ? boardCard.height : layout.panelSize
        radius: 18
        color: "#e8f2f7"
        Flickable {
            id: toolsViewport
            objectName: "boardGameToolsViewport"
            anchors.fill: parent
            anchors.margins: 12
            clip: true
            contentWidth: width
            contentHeight: tools.height
            boundsBehavior: Flickable.StopAtBounds
            Controls.ScrollBar.vertical: Controls.ScrollBar {
                policy: Controls.ScrollBar.AsNeeded
                active: true
            }
            Column {
                id: tools
                width: toolsViewport.width - 8
                spacing: 10
            }
        }
    }
    Connections {
        target: layout.focusTarget
        function onActiveFocusChanged() {
            if (layout.focusTarget.activeFocus)
                toolsViewport.contentY = 0;
        }
    }
}
