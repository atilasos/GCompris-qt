/* GCompris - DialogWorkLog.qml
 *
 * SPDX-FileCopyrightText: 2026 GCompris contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import QtQuick.Controls.Basic
import core 1.0

Rectangle {
    id: dialog
    objectName: "workLogDialog"
    visible: false
    color: GCStyle.configBg
    property bool isDialog: true
    property bool confirming: false
    signal close
    signal start
    signal stop
    signal pause
    signal play

    function activityInfo(activityId) {
        var catalogue = ActivityInfoTree.menuTreeFull;
        for (var i = 0; i < catalogue.length; ++i)
            if (catalogue[i].name === activityId) return catalogue[i];
        return null;
    }
    onStart: {
        confirming = false;
        closeButton.forceActiveFocus();
    }
    Keys.onEscapePressed: {
        if (confirming) {
            confirming = false;
            clearButton.forceActiveFocus();
        } else close();
    }
    Keys.onReleased: (event) => {
        if (event.key === Qt.Key_Back) {
            close();
            event.accepted = true;
        }
    }

    Column {
        id: heading
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: GCStyle.baseMargins }
        spacing: GCStyle.halfMargins
        BoardGameText {
            objectName: "workLogTitle"
            width: parent.width
            text: qsTr("O meu trabalho")
            fontSize: 28
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
        BoardGameText {
            objectName: "workLogInstruction"
            width: parent.width
            text: qsTr("Copia para o teu plano o que fizeste e escreve como correu.")
            fontSize: 19
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
    }

    Rectangle {
        anchors { top: heading.bottom; bottom: footer.top; left: parent.left; right: parent.right; margins: GCStyle.baseMargins }
        radius: GCStyle.halfMargins
        color: GCStyle.lightBg
        border.color: entries.activeFocus ? GCStyle.focusColor : GCStyle.whiteBorder
        border.width: GCStyle.midBorder

        ListView {
            id: entries
            objectName: "workLogEntries"
            anchors { fill: parent; margins: GCStyle.baseMargins }
            clip: true
            spacing: GCStyle.baseMargins
            model: WorkLog.entries
            boundsBehavior: Flickable.StopAtBounds
            activeFocusOnTab: !dialog.confirming
            enabled: !dialog.confirming
            ScrollBar.vertical: ScrollBar { }
            KeyNavigation.tab: clearButton.enabled ? clearButton : closeButton
            KeyNavigation.backtab: closeButton
            Keys.onDownPressed: contentY = Math.min(Math.max(0, contentHeight - height), contentY + height / 3)
            Keys.onUpPressed: contentY = Math.max(0, contentY - height / 3)
            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_PageDown) {
                    contentY = Math.min(Math.max(0, contentHeight - height), contentY + height);
                    event.accepted = true;
                } else if (event.key === Qt.Key_PageUp) {
                    contentY = Math.max(0, contentY - height);
                    event.accepted = true;
                }
            }
            delegate: Column {
                id: entry
                required property var modelData
                required property int index
                readonly property var info: dialog.activityInfo(modelData.activityId)
                objectName: "workLogEntry" + index
                width: entries.width - GCStyle.baseMargins
                spacing: GCStyle.halfMargins
                BoardGameText {
                    objectName: "workLogActivityTitle"
                    width: parent.width
                    text: entry.info ? entry.info.title : ""
                    fontSize: 22
                    font.bold: true
                    wrapMode: Text.WordWrap
                }
                BoardGameText {
                    objectName: "workLogGoal"
                    width: parent.width
                    text: entry.info ? entry.info.goal : ""
                    fontSize: 19
                    textFormat: Text.StyledText
                    wrapMode: Text.WordWrap
                }
                BoardGameText {
                    objectName: "workLogRounds"
                    width: parent.width
                    text: qsTr("Rondas concluídas: %1").arg(entry.modelData.hasRounds ? entry.modelData.rounds : qsTr("—"))
                    fontSize: 19
                    wrapMode: Text.WordWrap
                }
                Rectangle { width: parent.width; height: GCStyle.thinnestBorder; color: GCStyle.darkBorder }
            }
        }
        BoardGameText {
            objectName: "workLogEmpty"
            anchors { centerIn: parent; margins: GCStyle.baseMargins }
            width: parent.width - 2 * GCStyle.baseMargins
            visible: entries.count === 0
            text: qsTr("Ainda não há atividades nesta sessão. Escolhe uma no menu!")
            fontSize: 22
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
    }

    Column {
        id: footer
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right; margins: GCStyle.baseMargins }
        spacing: GCStyle.halfMargins
        BoardGameText {
            objectName: "workLogConfirmation"
            width: parent.width
            visible: dialog.confirming
            text: qsTr("Já copiaste para o teu plano? Queres apagar esta lista?")
            fontSize: 19
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
        Row {
            width: parent.width
            spacing: GCStyle.baseMargins
            visible: !dialog.confirming
            BoardGameButton {
                id: clearButton
                objectName: "workLogClear"
                text: qsTr("Começar de novo")
                enabled: entries.count > 0
                KeyNavigation.tab: closeButton
                KeyNavigation.backtab: entries
                onClicked: {
                    dialog.confirming = true;
                    cancelButton.forceActiveFocus();
                }
            }
            BoardGameButton {
                id: closeButton
                objectName: "workLogClose"
                text: qsTr("Fechar")
                KeyNavigation.tab: entries
                KeyNavigation.backtab: clearButton.enabled ? clearButton : entries
                onClicked: dialog.close()
            }
        }
        Row {
            width: parent.width
            spacing: GCStyle.baseMargins
            visible: dialog.confirming
            BoardGameButton {
                id: cancelButton
                objectName: "workLogCancel"
                text: qsTr("Voltar")
                KeyNavigation.tab: confirmButton
                KeyNavigation.backtab: confirmButton
                onClicked: {
                    dialog.confirming = false;
                    clearButton.forceActiveFocus();
                }
            }
            BoardGameButton {
                id: confirmButton
                objectName: "workLogConfirm"
                text: qsTr("Apagar a lista")
                KeyNavigation.tab: cancelButton
                KeyNavigation.backtab: cancelButton
                onClicked: {
                    WorkLog.clear();
                    dialog.confirming = false;
                    closeButton.forceActiveFocus();
                }
            }
        }
    }
}
