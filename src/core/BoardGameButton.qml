// SPDX-FileCopyrightText: NONE
// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Window
import core 1.0

GCButton {
    id: control
    property bool primaryAction: false
    readonly property real windowScale: Math.max(0.9, Math.min(1.4, Math.min(Window.window ? Window.window.width / 1100 : 1, Window.window ? Window.window.height / 740 : 1)))
    width: Math.max(44, (parent.width - (parent.spacing || 0)) / 2)
    height: Math.max(48, 52 * windowScale)
    focusPolicy: Qt.StrongFocus
    padding: 8
    contentItem: BoardGameText {
        text: control.text
        fontSize: 17
        font.bold: control.selected
        color: control.enabled ? (control.primaryAction ? "white" : "#183c50") : "#667680"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
    }
    background: Rectangle {
        radius: 12
        color: control.primaryAction && control.enabled ? "#1475a2" : control.down ? "#bee8f3" : control.selected ? "#cdebf7" : control.enabled ? "#ffffff" : "#e6edf0"
        border.color: control.activeFocus ? "#df790e" : control.selected ? "#1474a4" : "#98b5c4"
        border.width: control.activeFocus || control.selected ? 3 : 1
    }
    // Keep Tab navigation usable when secondary controls need scrolling.
    onActiveFocusChanged: if (activeFocus)
        Qt.callLater(function () {
            var area = control.parent;
            while (area) {
                if (area.objectName === "boardGameToolsViewport") {
                    var point = control.mapToItem(area.contentItem, 0, 0);
                    if (point.y < area.contentY)
                        area.contentY = point.y;
                    else if (point.y + control.height > area.contentY + area.height)
                        area.contentY = point.y + control.height - area.height;
                    return;
                }
                area = area.parent;
            }
        })
}
