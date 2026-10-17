// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import "../../core"
import core 1.0
import "board.mjs" as Graph
import "y.mjs" as Rules

ActivityBase {
    id: activity
    onStart: focus = true
    pageComponent: Rectangle {
        id: scene
        anchors.fill: parent
        color: "#edf4eb"
        signal start
        signal stop
        property var cells: Array(93).fill(0)
        property int player: 1
        property bool swapped: false
        property int moves: 0
        property int cursor: 0
        property int winner: 0
        property var highlighted: []
        property string feedback: ""
        property bool enlarged: false
        readonly property int currentColor: swapped ? 3 - player : player
        readonly property bool swapAvailable: !winner && moves === 1 && player === 2 && !swapped
        function reset() {
            cells = Array(93).fill(0); player = 1; swapped = false; moves = 0;
            cursor = 0; winner = 0; highlighted = []; feedback = "";
            board.forceActiveFocus();
        }
        function choose(index) {
            if (winner) return;
            cursor = index;
            if (cells[index]) { feedback = qsTr("Intersecção ocupada. Escolhe uma intersecção vazia."); return; }
            var next = cells.slice(); next[index] = currentColor; cells = next; moves++;
            highlighted = Rules.groupAt(cells, index);
            if (Rules.sides(highlighted) === 7) {
                winner = player;
                feedback = qsTr("Um único grupo liga os três lados. O grupo vencedor está assinalado.");
            } else {
                feedback = qsTr("Grupo da última peça: %1 intersecções; %2 lados ligados.").arg(highlighted.length).arg([0,1,1,2,1,2,2,3][Rules.sides(highlighted)]);
                player = 3 - player;
            }
            board.forceActiveFocus();
        }
        function swap() {
            if (!swapAvailable) return;
            swapped = true; player = 1;
            feedback = qsTr("Cores trocadas. A primeira peça mantém-se. A troca consumiu o turno do participante 2; joga o participante 1.");
            board.forceActiveFocus();
        }
        function revealCursor() {
            var node = Graph.nodes[cursor];
            var px = board.originX + node[1] * board.scaleFactor;
            var py = board.margin + node[2] * board.scaleFactor;
            viewport.contentX = Math.max(0, Math.min(viewport.contentWidth - viewport.width, px - viewport.width / 2));
            viewport.contentY = Math.max(0, Math.min(viewport.contentHeight - viewport.height, py - viewport.height / 2));
        }
        Component.onCompleted: { activity.start.connect(start); activity.stop.connect(stop); }
        onStart: reset()
        GCText {
            id: title
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: 6 }
            width: parent.width - 16; horizontalAlignment: Text.AlignHCenter
            fontSize: 23; font.bold: true; color: "#183c50"
            text: scene.winner ? qsTr("Venceu o participante %1!").arg(scene.winner) : qsTr("Participante %1 · %2").arg(scene.player).arg(scene.currentColor === 1 ? qsTr("Azul ●") : qsTr("Vermelho ◆"))
        }
        GCText {
            id: roles
            anchors { top: title.bottom; horizontalCenter: parent.horizontalCenter }
            width: parent.width - 16; horizontalAlignment: Text.AlignHCenter
            fontSize: 13; color: "#183c50"; wrapMode: Text.WordWrap
            text: scene.swapped ? qsTr("1 Vermelho ◆ · 2 Azul ●. Liga os três lados num único grupo.") : qsTr("1 Azul ● · 2 Vermelho ◆. Liga os três lados num único grupo.")
        }
        GCText {
            id: instruction
            anchors { top: roles.bottom; horizontalCenter: parent.horizontalCenter }
            width: parent.width - 16; horizontalAlignment: Text.AlignHCenter
            fontSize: 13; color: "#183c50"; wrapMode: Text.WordWrap
            text: scene.feedback || qsTr("Segue as ligações desenhadas. Intersecções próximas podem não estar ligadas.")
        }
        Flickable {
            id: viewport
            objectName: "yViewport"
            anchors { top: instruction.bottom; bottom: controls.top; left: parent.left; right: parent.right; margins: 6 }
            clip: true
            contentWidth: board.width; contentHeight: board.height
            boundsBehavior: Flickable.StopAtBounds
            Item {
                id: board
                objectName: "yBoard"
                readonly property real margin: 34
                readonly property real originX: (width - 856 * scaleFactor) / 2
                readonly property real scaleFactor: Math.max(0.76, Math.min((viewport.width - 2 * margin) / 856, (viewport.height - 2 * margin) / 847)) * (scene.enlarged ? 1.4 : 1)
                width: Math.max(viewport.width, 856 * scaleFactor + 2 * margin)
                height: Math.max(viewport.height, 847 * scaleFactor + 2 * margin)
                focus: true; activeFocusOnTab: true
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Left || event.key === Qt.Key_Up) scene.cursor = (scene.cursor + 92) % 93;
                    else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down) scene.cursor = (scene.cursor + 1) % 93;
                    else if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) scene.choose(scene.cursor);
                    else { event.accepted = false; return; }
                    scene.revealCursor(); event.accepted = true;
                }
                Canvas {
                    id: connections
                    anchors.fill: parent
                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()
                    Connections { target: scene; function onHighlightedChanged() { connections.requestPaint(); } }
                    onPaint: {
                        var ctx = getContext("2d"); ctx.reset();
                        for (var e = 0; e < Graph.edges.length; e++) {
                            var edge = Graph.edges[e], ai = Rules.indices[edge[0]], bi = Rules.indices[edge[1]];
                            var a = Graph.nodes[ai], b = Graph.nodes[bi];
                            var selected = scene.highlighted.indexOf(ai) >= 0 && scene.highlighted.indexOf(bi) >= 0;
                            ctx.strokeStyle = selected ? "#b24d00" : "#667b80"; ctx.lineWidth = selected ? 4 : 1.5;
                            ctx.beginPath(); ctx.moveTo(board.originX + a[1] * board.scaleFactor, board.margin + a[2] * board.scaleFactor);
                            ctx.lineTo(board.originX + b[1] * board.scaleFactor, board.margin + b[2] * board.scaleFactor); ctx.stroke();
                        }
                    }
                }
                Repeater {
                    model: Graph.nodes
                    Rectangle {
                        required property var modelData
                        required property int index
                        objectName: "yNode" + modelData[0]
                        x: board.originX + modelData[1] * board.scaleFactor - width / 2
                        y: board.margin + modelData[2] * board.scaleFactor - height / 2
                        width: 44; height: 44; radius: 22
                        color: scene.cells[index] === 1 ? "#1769aa" : scene.cells[index] === 2 ? "#a72b35" : "#ffffff"
                        border.color: board.activeFocus && scene.cursor === index ? "#a34c00" : modelData[3] ? "#0e5960" : "#52646a"
                        border.width: board.activeFocus && scene.cursor === index ? 4 : modelData[3] ? 3 : 1
                        GCText { anchors.centerIn: parent; text: scene.cells[index] === 1 ? "●" : scene.cells[index] === 2 ? "◆" : modelData[0]; fontSize: scene.cells[index] ? 20 : 10; color: scene.cells[index] ? "white" : "#183c50" }
                        // Side codes remain visible after occupation as well as on empty nodes.
                        GCText { anchors { horizontalCenter: parent.horizontalCenter; top: parent.bottom; topMargin: -4 } fontSize: 9; font.bold: true; color: "#0e5960"; text: (modelData[3] & 1 ? "S" : "") + (modelData[3] & 2 ? "E" : "") + (modelData[3] & 4 ? "D" : "") }
                        MouseArea { anchors.fill: parent; onClicked: scene.choose(parent.index) }
                        Accessible.role: Accessible.Button
                        Accessible.name: qsTr("Intersecção %1: %2").arg(modelData[0]).arg(scene.cells[index] === 1 ? qsTr("Azul, círculo") : scene.cells[index] === 2 ? qsTr("Vermelho, losango") : qsTr("vazia"))
                        Accessible.onPressAction: scene.choose(index)
                    }
                }
            }
        }
        Flow {
            id: controls
            anchors { bottom: bar.top; horizontalCenter: parent.horizontalCenter; bottomMargin: 4 }
            width: parent.width - 16; spacing: 6
            GCButton { focusPolicy: Qt.StrongFocus; objectName: "swapY"; text: qsTr("Trocar cores"); enabled: scene.swapAvailable; onClicked: scene.swap() }
            GCButton { focusPolicy: Qt.StrongFocus; objectName: "restartY"; text: qsTr("Nova partida"); onClicked: scene.reset() }
            GCButton { focusPolicy: Qt.StrongFocus; objectName: "zoomY"; text: scene.enlarged ? qsTr("Reduzir") : qsTr("Ampliar"); onClicked: { scene.enlarged = !scene.enlarged; scene.revealCursor(); } }
            GCButton { focusPolicy: Qt.StrongFocus; objectName: "helpY"; text: qsTr("Ajuda"); onClicked: activity.displayDialog(dialogHelp) }
            GCText { width: controls.width; fontSize: 11; color: "#183c50"; wrapMode: Text.WordWrap; text: qsTr("S: superior · E: esquerdo · D: direito. Desliza o tabuleiro para ver as margens. Setas: percorrer; Espaço: colocar; Tab: botões.") }
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
