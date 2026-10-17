// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import "../../core"
import core 1.0
import "quelhas.mjs" as Rules

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
        property bool swapped: false
        property int moves: 0
        property int first: -1
        property int last: -1
        property int cursor: 0
        property int winner: 0
        property string feedback: ""
        readonly property bool vertical: (player === 1) !== swapped
        readonly property bool swapAvailable: !winner && player === 2 && moves === 1 && !swapped
        readonly property var selection: Rules.segment(first, last, vertical)
        readonly property bool validSelection: !winner && Rules.legal(cells, selection)
        function reset() {
            cells = Rules.emptyBoard(); player = 1; swapped = false; moves = 0;
            first = -1; last = -1; cursor = 0; winner = 0; feedback = "";
            board.forceActiveFocus();
        }
        function clear() {
            first = -1; last = -1; feedback = ""; board.forceActiveFocus();
        }
        function choose(index) {
            if (winner) return;
            cursor = index;
            if (first < 0) {
                first = index;
                feedback = qsTr("Seleciona o outro extremo do segmento.");
            } else {
                last = index;
                feedback = validSelection ? qsTr("Segmento de %1 casas. Confirma ou corrige o segundo extremo.").arg(selection.length) : qsTr("Segmento inválido: usa pelo menos duas casas vazias na tua direção. Corrige o extremo ou limpa a seleção.");
            }
            board.forceActiveFocus();
        }
        function confirm() {
            if (!validSelection) return;
            cells = Rules.place(cells, selection); moves++;
            first = -1; last = -1;
            player = 3 - player;
            if (!Rules.hasMove(cells, vertical)) {
                winner = player;
                feedback = qsTr("O participante %1 não tem jogadas na sua orientação. Perde quem faz a última jogada: participante %2.").arg(player).arg(3 - player);
            } else feedback = "";
            board.forceActiveFocus();
        }
        function swap() {
            if (!swapAvailable) return;
            swapped = true; player = 1; first = -1; last = -1;
            feedback = qsTr("Orientações trocadas. A troca consumiu o turno do participante 2; joga o participante 1 na horizontal.");
            if (!Rules.hasMove(cells, vertical)) winner = player;
            board.forceActiveFocus();
        }
        Component.onCompleted: { activity.start.connect(start); activity.stop.connect(stop); }
        onStart: reset()
        GCText {
            id: title
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: 8 }
            width: parent.width - 20
            horizontalAlignment: Text.AlignHCenter
            fontSize: 24; font.bold: true; color: "#183c50"
            text: scene.winner ? qsTr("Venceu o participante %1!").arg(scene.winner) : scene.vertical ? qsTr("Participante %1 · Vertical ↕").arg(scene.player) : qsTr("Participante %1 · Horizontal ↔").arg(scene.player)
        }
        GCText {
            id: roles
            anchors { top: title.bottom; horizontalCenter: parent.horizontalCenter }
            width: parent.width - 20
            horizontalAlignment: Text.AlignHCenter
            fontSize: 13; color: "#183c50"
            text: scene.swapped ? qsTr("1 ↔ Horizontal · 2 ↕ Vertical — perde quem faz a última jogada") : qsTr("1 ↕ Vertical · 2 ↔ Horizontal — perde quem faz a última jogada")
            wrapMode: Text.WordWrap
        }
        GCText {
            id: instruction
            anchors { top: roles.bottom; horizontalCenter: parent.horizontalCenter }
            width: parent.width - 20
            horizontalAlignment: Text.AlignHCenter
            fontSize: 13; color: "#183c50"
            text: scene.feedback || qsTr("Seleciona os dois extremos de um segmento e confirma.")
            wrapMode: Text.WordWrap
        }
        Item {
            anchors { top: instruction.bottom; bottom: controls.top; left: parent.left; right: parent.right; margins: 8 }
            Item {
                id: board
                objectName: "quelhasBoard"
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height); height: width
                focus: true; activeFocusOnTab: true
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Left) scene.cursor = Math.max(0, scene.cursor - 1);
                    else if (event.key === Qt.Key_Right) scene.cursor = Math.min(99, scene.cursor + 1);
                    else if (event.key === Qt.Key_Up) scene.cursor = Math.max(0, scene.cursor - 10);
                    else if (event.key === Qt.Key_Down) scene.cursor = Math.min(99, scene.cursor + 10);
                    else if (event.key === Qt.Key_Space) scene.choose(scene.cursor);
                    else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) scene.confirm();
                    else if (event.key === Qt.Key_Escape) scene.clear();
                    else { event.accepted = false; return; }
                    event.accepted = true;
                }
                Grid {
                    anchors.fill: parent
                    rows: 10; columns: 10
                    Repeater {
                        model: 100
                        Rectangle {
                            required property int index
                            objectName: "quelhasCell" + index
                            width: board.width / 10; height: width
                            readonly property bool occupied: scene.cells[index] > 0
                            readonly property bool preview: scene.first === index || scene.last === index || scene.selection.indexOf(index) >= 0
                            color: occupied ? "#183c50" : preview ? (scene.validSelection || scene.last < 0 ? "#c3e5ae" : "#ffc7bc") : "white"
                            border.color: board.activeFocus && scene.cursor === index ? "#804100" : "#647986"
                            border.width: board.activeFocus && scene.cursor === index ? 4 : 1
                            GCText {
                                anchors.centerIn: parent
                                fontSize: Math.max(12, parent.width * 0.45)
                                text: parent.occupied ? "●" : parent.preview ? (scene.vertical ? "↕" : "↔") : ""
                                color: parent.occupied ? "white" : "#183c50"
                            }
                            MouseArea { anchors.fill: parent; onClicked: scene.choose(parent.index) }
                            Accessible.role: Accessible.Button
                            Accessible.name: qsTr("Linha %1, coluna %2: %3").arg(Math.floor(index / 10) + 1).arg(index % 10 + 1).arg(occupied ? qsTr("ocupada") : qsTr("vazia"))
                            Accessible.onPressAction: scene.choose(index)
                        }
                    }
                }
            }
        }
        Flow {
            id: controls
            width: Math.min(parent.width - 16, 760)
            anchors { bottom: bar.top; horizontalCenter: parent.horizontalCenter; bottomMargin: 6 }
            spacing: 8
            GCButton { focusPolicy: Qt.StrongFocus; objectName: "swapQuelhas"; text: qsTr("Trocar orientações"); enabled: scene.swapAvailable; onClicked: scene.swap() }
            GCButton { focusPolicy: Qt.StrongFocus; objectName: "confirmQuelhas"; text: qsTr("Confirmar"); enabled: scene.validSelection; onClicked: scene.confirm() }
            GCButton { focusPolicy: Qt.StrongFocus; objectName: "clearQuelhas"; text: qsTr("Limpar seleção"); enabled: scene.first >= 0 && !scene.winner; onClicked: scene.clear() }
            GCButton { focusPolicy: Qt.StrongFocus; objectName: "restartQuelhas"; text: qsTr("Nova partida"); onClicked: scene.reset() }
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
