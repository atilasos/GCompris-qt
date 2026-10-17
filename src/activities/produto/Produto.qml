// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import "../../core"
import core 1.0
import "produto.mjs" as Rules

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
        readonly property var coords: Rules.coordinates()
        property var pending: []
        property int player: 1
        property int chosenColor: 1
        property int cursor: 0
        property int turn: 0
        property int winner: 0
        property string feedback: ""
        readonly property int needed: turn === 0 ? 1 : 2
        readonly property var black: Rules.summary(cells, 1)
        readonly property var white: Rules.summary(cells, 2)
        function reset() {
            cells = Rules.emptyBoard(); pending = []; player = 1; turn = 0;
            chosenColor = 1; cursor = 0; winner = 0; feedback = "";
            board.forceActiveFocus();
        }
        function choose(index) {
            if (winner) return;
            cursor = index;
            if (cells[index]) { feedback = qsTr("Casa ocupada. Escolhe outra casa."); return; }
            var next = pending.slice(), existing = -1;
            for (var i = 0; i < next.length; ++i) if (next[i].index === index) existing = i;
            if (existing >= 0) next.splice(existing, 1);
            else if (next.length < needed) next.push({index:index, color:chosenColor});
            else { feedback = qsTr("Retira uma seleção ou limpa o turno para corrigir."); return; }
            pending = next; feedback = ""; board.forceActiveFocus();
        }
        function preview(index) {
            for (var i = 0; i < pending.length; ++i) if (pending[i].index === index) return pending[i].color;
            return 0;
        }
        function confirm() {
            if (winner || pending.length !== needed) return;
            var next = cells.slice();
            for (var i = 0; i < pending.length; ++i) {
                if (next[pending[i].index]) return;
                next[pending[i].index] = pending[i].color;
            }
            cells = next; pending = []; ++turn; winner = Rules.result(cells);
            if (winner) feedback = black.score === white.score ? qsTr("Desempate: vence quem tem menos peças da sua cor. Negras: %1 · Brancas: %2").arg(black.count).arg(white.count) : qsTr("Vence o maior produto dos dois maiores grupos.");
            else { player = 3-player; feedback = ""; }
            board.forceActiveFocus();
        }
        Component.onCompleted: { activity.start.connect(start); activity.stop.connect(stop); }
        onStart: reset()
        GCText {
            id: title
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: 8 }
            width: parent.width - 12
            horizontalAlignment: Text.AlignHCenter
            fontSize: 23
            font.bold: true
            color: "#183c50"
            text: scene.winner === 3 ? qsTr("Empate!") : scene.winner ? qsTr("Venceu o participante %1!").arg(scene.winner) : qsTr("Participante %1 · %2").arg(scene.player).arg(scene.player === 1 ? qsTr("● Negras") : qsTr("◇ Brancas"))
        }
        GCText {
            id: scores
            anchors { top: title.bottom; horizontalCenter: parent.horizontalCenter }
            width: parent.width-12
            horizontalAlignment: Text.AlignHCenter
            fontSize: 15
            color: "#183c50"
            text: qsTr("● Negras: %1 × %2 = %3 · Peças: %4").arg(scene.black.first).arg(scene.black.second).arg(scene.black.score).arg(scene.black.count) + "\n" + qsTr("◇ Brancas: %1 × %2 = %3 · Peças: %4").arg(scene.white.first).arg(scene.white.second).arg(scene.white.score).arg(scene.white.count)
        }
        GCText {
            id: instruction
            anchors { top: scores.bottom; horizontalCenter: parent.horizontalCenter }
            width: parent.width-16
            height: 64
            fontSize: 14
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: "#183c50"
            text: scene.feedback || qsTr("Seleciona %1 peça(s) de qualquer cor. Seleção: %2/%1. Toca de novo para retirar; confirma o turno completo.").arg(scene.needed).arg(scene.pending.length)
        }
        Item {
            id: area
            anchors { top: instruction.bottom; bottom: choices.top; left: parent.left; right: parent.right; margins: 6 }
            Item {
                id: board
                objectName: "produtoBoard"
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height * 7 / (9 * 0.8660254))
                height: width * 9 * 0.8660254 / 7
                readonly property real unit: width / 7
                focus: true
                activeFocusOnTab: true
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Left || event.key === Qt.Key_Up) scene.cursor = Math.max(0, scene.cursor-1);
                    else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down) scene.cursor = Math.min(60, scene.cursor+1);
                    else if (event.key === Qt.Key_Space) scene.choose(scene.cursor);
                    else if (event.key === Qt.Key_1) scene.chosenColor = 1;
                    else if (event.key === Qt.Key_2) scene.chosenColor = 2;
                    else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) scene.confirm();
                    else { event.accepted = false; return; }
                    event.accepted = true;
                }
                Repeater {
                    model: 61
                    Rectangle {
                        required property int index
                        objectName: "produtoCell" + index
                        readonly property int stone: scene.cells[index] || scene.preview(index)
                        readonly property bool selected: scene.preview(index) > 0
                        x: (scene.coords[index].q+4)*0.75*board.unit
                        y: (scene.coords[index].r+scene.coords[index].q/2+4)*0.8660254*board.unit
                        width: board.unit
                        height: board.unit*0.8660254
                        radius: width/2
                        color: stone === 1 ? "#22333b" : stone === 2 ? "#ffffff" : "#d4e2c8"
                        border.color: selected ? "#b00064" : board.activeFocus && scene.cursor === index ? "#125ca5" : "#52655c"
                        border.width: selected || board.activeFocus && scene.cursor === index ? 4 : 1
                        opacity: selected ? 0.65 : 1
                        GCText {
                            anchors.centerIn: parent
                            color: parent.stone === 1 ? "white" : "#22333b"
                            fontSize: Math.max(12, parent.width*0.27)
                            text: parent.stone === 1 ? "●" : parent.stone === 2 ? "◇" : ""
                        }
                        MouseArea { anchors.fill: parent; onClicked: scene.choose(parent.index) }
                        TapHandler {
                            acceptedDevices: PointerDevice.TouchScreen | PointerDevice.TouchPad
                            onTapped: scene.choose(parent.index)
                        }
                    }
                }
            }
        }
        Row {
            id: choices
            anchors { bottom: controls.top; horizontalCenter: parent.horizontalCenter; bottomMargin: 5 }
            spacing: 8
            Repeater {
                model: 2
                GCButton {
                    required property int index
                    objectName: "produtoColor"+(index+1)
                    focusPolicy: Qt.StrongFocus
                    text: (scene.chosenColor === index+1 ? "✓ " : "") + (index === 0 ? qsTr("● Negras") : qsTr("◇ Brancas"))
                    enabled: !scene.winner
                    onClicked: { scene.chosenColor = index+1; scene.feedback = ""; }
                }
            }
        }
        Row {
            id: controls
            anchors { bottom: bar.top; horizontalCenter: parent.horizontalCenter; bottomMargin: 6 }
            spacing: 8
            GCButton {
                objectName: "confirmProduto"
                focusPolicy: Qt.StrongFocus
                text: qsTr("Confirmar")
                enabled: !scene.winner && scene.pending.length === scene.needed
                onClicked: scene.confirm()
            }
            GCButton {
                objectName: "clearProduto"
                focusPolicy: Qt.StrongFocus
                text: qsTr("Limpar")
                enabled: !scene.winner && scene.pending.length > 0
                onClicked: { scene.pending = []; scene.feedback = ""; board.forceActiveFocus(); }
            }
            GCButton {
                objectName: "restartProduto"
                focusPolicy: Qt.StrongFocus
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
