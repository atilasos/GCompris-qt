// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import "../../core"
import core 1.0
import "dominorio.js" as Rules

ActivityBase {
    id: activity
    onStart: focus = true
    onStop: {}

    pageComponent: Rectangle {
        id: scene
        anchors.fill: parent
        color: "#edf4eb"
        signal start
        signal stop
        property var cells: Rules.emptyBoard()
        property int player: 1
        property int selected: -1
        property int cursor: 0
        property int winner: 0
        property string feedback: ""
        readonly property bool validSelection: !winner && Rules.legal(cells, selected, player)
        function reset() {
            cells = Rules.emptyBoard(); player = 1; selected = -1;
            cursor = 0; winner = 0; feedback = "";
            board.forceActiveFocus();
        }
        function choose(index) {
            if (winner) return;
            cursor = index;
            selected = index;
            feedback = validSelection ? qsTr("Confirma para colocar o dominó.") : qsTr("Jogada impossível. Escolhe duas casas vazias na tua direção.");
            board.forceActiveFocus();
        }
        function confirm() {
            if (!validSelection) return;
            cells = Rules.place(cells, selected, player);
            selected = -1;
            var next = 3 - player;
            if (!Rules.hasMove(cells, next)) {
                winner = player;
                feedback = qsTr("O participante %1 ficou sem uma jogada válida.").arg(next);
            } else {
                player = next;
                feedback = "";
            }
            board.forceActiveFocus();
        }
        Component.onCompleted: {
            activity.start.connect(start);
            activity.stop.connect(stop);
        }
        onStart: reset()

        GCText {
            id: title
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: 8 }
            width: parent.width - 24
            horizontalAlignment: Text.AlignHCenter
            fontSize: 24
            font.bold: true
            color: "#183c50"
            text: scene.winner ? qsTr("Venceu o participante %1!").arg(scene.winner) :
                  scene.player === 1 ? qsTr("Participante 1 · Vertical ↕") : qsTr("Participante 2 · Horizontal ↔")
        }
        GCText {
            id: instruction
            anchors { top: title.bottom; horizontalCenter: parent.horizontalCenter }
            width: parent.width - 20
            horizontalAlignment: Text.AlignHCenter
            fontSize: 14
            color: "#183c50"
            text: scene.feedback || qsTr("Seleciona a primeira casa, observa a previsão e confirma.")
            wrapMode: Text.WordWrap
        }
        Item {
            id: playArea
            anchors { top: instruction.bottom; bottom: controls.top; left: parent.left; right: parent.right; margins: 8 }
            Item {
                id: board
                objectName: "dominorioBoard"
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height)
                height: width
                focus: true
                activeFocusOnTab: true
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Left) scene.cursor = Math.max(0, scene.cursor - 1);
                    else if (event.key === Qt.Key_Right) scene.cursor = Math.min(63, scene.cursor + 1);
                    else if (event.key === Qt.Key_Up) scene.cursor = Math.max(0, scene.cursor - 8);
                    else if (event.key === Qt.Key_Down) scene.cursor = Math.min(63, scene.cursor + 8);
                    else if (event.key === Qt.Key_Space) scene.choose(scene.cursor);
                    else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) scene.confirm();
                    else { event.accepted = false; return; }
                    event.accepted = true;
                }
                Grid {
                    anchors.fill: parent
                    rows: 8; columns: 8
                    Repeater {
                        id: squares
                        model: 64
                        Rectangle {
                            required property int index
                            objectName: "dominoCell" + index
                            width: board.width / 8; height: width
                            readonly property int owner: scene.cells[index]
                            readonly property bool preview: scene.selected === index ||
                                (scene.validSelection && Rules.secondCell(scene.selected, scene.player) === index)
                            color: owner === 1 ? "#175f88" : owner === 2 ? "#804100" :
                                   preview ? (scene.validSelection ? "#c3e5ae" : "#ffc7bc") : "#ffffff"
                            border.color: board.activeFocus && scene.cursor === index ? "#111111" : "#647986"
                            border.width: board.activeFocus && scene.cursor === index ? 4 : 1
                            GCText {
                                anchors.centerIn: parent
                                fontSize: Math.max(12, parent.width * 0.34)
                                text: parent.owner === 1 ? "1 ↕" : parent.owner === 2 ? "2 ↔" : parent.preview && scene.validSelection ? (scene.player === 1 ? "↕" : "↔") : ""
                                color: parent.owner ? "white" : "#183c50"
                            }
                            MouseArea { anchors.fill: parent; onClicked: scene.choose(parent.index) }
                            Accessible.role: Accessible.Button
                            Accessible.name: qsTr("Linha %1, coluna %2: %3").arg(Math.floor(index / 8) + 1).arg(index % 8 + 1).arg(owner ? qsTr("participante %1").arg(owner) : qsTr("vazia"))
                            Accessible.onPressAction: scene.choose(index)
                        }
                    }
                }
            }
        }
        Row {
            id: controls
            anchors { bottom: bar.top; horizontalCenter: parent.horizontalCenter; bottomMargin: 6 }
            spacing: 12
            GCButton {
                objectName: "confirmDomino"
                text: qsTr("Confirmar")
                enabled: scene.validSelection
                onClicked: scene.confirm()
            }
            GCButton {
                objectName: "restartDomino"
                text: qsTr("Nova partida")
                onClicked: scene.reset()
            }
        }
        DialogHelp { id: dialogHelp; onClose: home() }
        Bar {
            id: bar
            content: BarEnumContent { value: help | home | reload }
            onHelpClicked: activity.displayDialog(dialogHelp)
            onHomeClicked: activity.home()
            onReloadClicked: scene.reset()
        }
    }
}
