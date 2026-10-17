// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import "../../core"
import core 1.0
import "gatos_caes.mjs" as Rules

ActivityBase {
    id: activity
    onStart: focus = true
    pageComponent: Rectangle {
        id: scene
        anchors.fill: parent
        color: "#edf4eb"
        signal start
        signal stop
        property var cells: Rules.emptyBoard()
        property int player: 1
        property int winner: 0
        property int cursor: 27
        property bool showLegal: false
        property string feedback: ""
        function reset() {
            cells = Rules.emptyBoard(); player = 1; winner = 0;
            cursor = 27; feedback = ""; showLegal = false;
            board.forceActiveFocus();
        }
        function choose(index) {
            if (winner) return;
            cursor = index;
            if (!Rules.legal(cells, index, player)) {
                feedback = qsTr("Jogada impossível. Escolhe uma casa vazia permitida, sem vizinhos da outra espécie na horizontal ou na vertical.");
                board.forceActiveFocus(); return;
            }
            cells = Rules.place(cells, index, player);
            var next = 3 - player;
            if (!Rules.hasMove(cells, next)) {
                winner = player;
                feedback = qsTr("O participante %1 ficou sem uma colocação válida.").arg(next);
            } else { player = next; feedback = ""; }
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
            fontSize: 24; font.bold: true; color: "#183c50"
            text: scene.winner ? qsTr("Venceu o participante %1!").arg(scene.winner) : scene.player === 1 ? qsTr("Participante 1 · Gatos") : qsTr("Participante 2 · Cães")
        }
        GCText {
            id: instruction
            anchors { top: title.bottom; horizontalCenter: parent.horizontalCenter }
            width: parent.width - 20
            horizontalAlignment: Text.AlignHCenter
            fontSize: 14; color: "#183c50"; wrapMode: Text.WordWrap
            text: scene.feedback || (scene.cells.indexOf(scene.player) === -1 ? (scene.player === 1 ? qsTr("O primeiro Gato joga numa das quatro casas centrais.") : qsTr("O primeiro Cão joga fora das quatro casas centrais, sem tocar num Gato na horizontal ou na vertical.")) : qsTr("Coloca numa casa vazia, sem vizinhos da outra espécie na horizontal ou na vertical."))
        }
        Item {
            id: playArea
            anchors { top: instruction.bottom; bottom: controls.top; left: parent.left; right: parent.right; margins: 8 }
            Item {
                id: board
                objectName: "gatosCaesBoard"
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height); height: width
                focus: true; activeFocusOnTab: true
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Left) scene.cursor = Math.max(0, scene.cursor - 1);
                    else if (event.key === Qt.Key_Right) scene.cursor = Math.min(63, scene.cursor + 1);
                    else if (event.key === Qt.Key_Up) scene.cursor = Math.max(0, scene.cursor - 8);
                    else if (event.key === Qt.Key_Down) scene.cursor = Math.min(63, scene.cursor + 8);
                    else if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) scene.choose(scene.cursor);
                    else { event.accepted = false; return; }
                    event.accepted = true;
                }
                Grid {
                    anchors.fill: parent; rows: 8; columns: 8
                    Repeater {
                        model: 64
                        Rectangle {
                            required property int index
                            objectName: "gatosCell" + index
                            width: board.width / 8; height: width
                            readonly property int owner: scene.cells[index]
                            readonly property bool allowed: !scene.winner && Rules.legal(scene.cells, index, scene.player)
                            color: owner === 1 ? "#175f88" : owner === 2 ? "#804100" : scene.showLegal && allowed ? "#c3e5ae" : Rules.central(index) ? "#fff0d6" : "#ffffff"
                            border.color: board.activeFocus && scene.cursor === index ? "#111111" : "#647986"
                            border.width: board.activeFocus && scene.cursor === index ? 4 : 1
                            GCText {
                                anchors.centerIn: parent
                                fontSize: Math.max(12, parent.width * 0.28)
                                text: parent.owner === 1 ? "1 G" : parent.owner === 2 ? "2 C" : scene.showLegal && parent.allowed ? "+" : ""
                                color: parent.owner ? "white" : "#183c50"
                            }
                            MouseArea { anchors.fill: parent; onClicked: scene.choose(parent.index) }
                            Accessible.role: Accessible.Button
                            Accessible.name: qsTr("Linha %1, coluna %2: %3").arg(Math.floor(index / 8) + 1).arg(index % 8 + 1).arg(owner === 1 ? qsTr("Gato, participante 1") : owner === 2 ? qsTr("Cão, participante 2") : qsTr("vazia"))
                            Accessible.onPressAction: scene.choose(index)
                        }
                    }
                }
            }
        }
        Flow {
            id: controls
            width: Math.min(parent.width - 16, 650)
            anchors { bottom: bar.top; horizontalCenter: parent.horizontalCenter; bottomMargin: 6 }
            spacing: 12
            GCButton { objectName: "legalGatos"; text: scene.showLegal ? qsTr("Ocultar casas permitidas") : qsTr("Mostrar casas permitidas"); onClicked: { scene.showLegal = !scene.showLegal; board.forceActiveFocus(); } }
            GCButton { objectName: "restartGatos"; text: qsTr("Nova partida"); onClicked: scene.reset() }
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
