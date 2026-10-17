// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import "../../core"
import core 1.0
import "atari_go.mjs" as Rules

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
        property int winner: 0
        property int captured: 0
        property int cursor: 0
        property bool inspecting: false
        property var selected: ({stones: [], liberties: []})
        property string feedback: ""
        function reset() {
            cells = Rules.emptyBoard(); player = 1; winner = 0; captured = 0;
            cursor = 0; inspecting = false; selected = {stones: [], liberties: []};
            feedback = ""; board.forceActiveFocus();
        }
        function choose(index) {
            cursor = index;
            if (inspecting) {
                selected = Rules.group(cells, index);
                feedback = selected.stones.length ? qsTr("%1 pedras · %2 liberdades").arg(selected.stones.length).arg(selected.liberties.length) : qsTr("Toca numa pedra para ver o seu grupo.");
            } else if (!winner) {
                const move = Rules.place(cells, player, index);
                if (move.error) feedback = move.error === "suicide" ? qsTr("Suicídio: o grupo ficaria sem liberdades e não capturaria pedras. Escolhe outra interseção.") : qsTr("Esta interseção está ocupada. Escolhe outra.");
                else {
                    cells = move.board; feedback = "";
                    if (move.captured.length) { winner = player; captured = move.captured.length; }
                    else player = 3 - player;
                }
            }
            board.forceActiveFocus();
        }
        Component.onCompleted: { activity.start.connect(start); activity.stop.connect(stop); }
        onStart: reset()
        GCText {
            id: title
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: 8 }
            width: parent.width - 20; horizontalAlignment: Text.AlignHCenter
            fontSize: 24; font.bold: true; color: "#183c50"
            text: scene.winner ? (scene.winner === 1 ? qsTr("Venceram as Pretas ●!") : qsTr("Venceram as Brancas ○!")) : scene.player === 1 ? qsTr("Pretas ● · Participante 1") : qsTr("Brancas ○ · Participante 2")
        }
        GCText {
            id: instruction
            anchors { top: title.bottom; horizontalCenter: parent.horizontalCenter }
            width: parent.width - 20; horizontalAlignment: Text.AlignHCenter
            fontSize: 14; color: "#183c50"; wrapMode: Text.WordWrap
            text: scene.feedback || (scene.winner ? qsTr("Primeira captura: %1 pedra(s). A partida terminou.").arg(scene.captured) : scene.inspecting ? qsTr("Toca numa pedra para ver o seu grupo e as liberdades (+).") : qsTr("Coloca uma pedra numa interseção. Vence quem faz a primeira captura."))
        }
        Item {
            anchors { top: instruction.bottom; bottom: controls.top; left: parent.left; right: parent.right; margins: 10 }
            Rectangle {
                id: board
                objectName: "atariBoard"
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height); height: width
                color: "#e8c58b"
                focus: true; activeFocusOnTab: true
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Left) scene.cursor = Math.max(0, scene.cursor - 1);
                    else if (event.key === Qt.Key_Right) scene.cursor = Math.min(80, scene.cursor + 1);
                    else if (event.key === Qt.Key_Up) scene.cursor = Math.max(0, scene.cursor - 9);
                    else if (event.key === Qt.Key_Down) scene.cursor = Math.min(80, scene.cursor + 9);
                    else if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) scene.choose(scene.cursor);
                    else { event.accepted = false; return; }
                    event.accepted = true;
                }
                Repeater {
                    model: 9
                    Item {
                        required property int index
                        anchors.fill: parent
                        Rectangle { x: board.width/18; y: (index+0.5)*board.height/9; width: board.width*8/9; height: 1; color: "#694c26" }
                        Rectangle { y: board.height/18; x: (index+0.5)*board.width/9; height: board.height*8/9; width: 1; color: "#694c26" }
                    }
                }
                Repeater {
                    model: 81
                    Item {
                        required property int index
                        objectName: "atariPoint" + index
                        x: index%9 * width; y: Math.floor(index/9)*height
                        width: board.width/9; height: width
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width * 0.86; height: width; radius: width/2
                            color: scene.cells[index] === 1 ? "#17212a" : "#fffdf5"
                            visible: scene.cells[index] > 0
                            border.width: scene.selected.stones.indexOf(index) >= 0 ? 4 : 1
                            border.color: scene.selected.stones.indexOf(index) >= 0 ? "#005d87" : "#17212a"
                            GCText { anchors.centerIn: parent; fontSize: Math.max(14,parent.width*0.43); color: scene.cells[index] === 1 ? "white" : "#17212a"; text: scene.cells[index] === 1 ? "●" : scene.cells[index] === 2 ? "○" : "" }
                        }
                        GCText { anchors.centerIn: parent; visible: scene.selected.liberties.indexOf(index) >= 0; text: "+"; color: "#00577c"; font.bold: true; fontSize: 22 }
                        Rectangle { anchors.fill: parent; anchors.margins: 2; color: "transparent"; border.color: "#804100"; border.width: 3; visible: board.activeFocus && scene.cursor === index }
                        MouseArea { anchors.fill: parent; onClicked: scene.choose(parent.index) }
                        Accessible.role: Accessible.Button
                        Accessible.name: qsTr("Linha %1, coluna %2: %3").arg(Math.floor(index/9)+1).arg(index%9+1).arg(scene.cells[index] === 1 ? qsTr("Preta") : scene.cells[index] === 2 ? qsTr("Branca") : qsTr("vazia"))
                        Accessible.onPressAction: scene.choose(index)
                    }
                }
            }
        }
        Flow {
            id: controls
            width: Math.min(parent.width - 16, 600)
            anchors { bottom: bar.top; horizontalCenter: parent.horizontalCenter; bottomMargin: 8 }
            spacing: 8
            GCButton {
                focusPolicy: Qt.StrongFocus; objectName: "inspectAtari"
                text: scene.inspecting ? qsTr("Voltar a jogar") : qsTr("Grupo e liberdades")
                onClicked: { scene.inspecting = !scene.inspecting; scene.selected = {stones: [], liberties: []}; scene.feedback = ""; }
            }
            GCButton { focusPolicy: Qt.StrongFocus; objectName: "restartAtari"; text: qsTr("Nova partida"); onClicked: scene.reset() }
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
