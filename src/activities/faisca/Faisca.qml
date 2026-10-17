// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import "../../core"
import core 1.0
import "faisca.mjs" as Rules

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
        property var reserves: [[5, 5, 5], [5, 5, 5]]
        property int player: 1
        property int mandatory: -1
        property int selected: -1
        property int cursor: 0
        property int distance: 1
        property int direction: 2
        property int winner: 0
        property string feedback: ""
        readonly property var arrows: ["↑", "→", "↓", "←"]
        readonly property bool validSelection: !winner && Rules.legal(cells, reserves[player - 1], selected, mandatory, distance, direction)
        readonly property int endpoint: Rules.destination(selected, distance, direction)
        function reset() {
            cells = Rules.emptyBoard();
            reserves = [[5, 5, 5], [5, 5, 5]];
            player = 1;
            mandatory = -1;
            selected = -1;
            cursor = 0;
            winner = 0;
            distance = 1;
            direction = 2;
            feedback = "";
            board.forceActiveFocus();
        }
        function choose(index) {
            if (winner)
                return;
            cursor = index;
            if (mandatory >= 0 && index !== mandatory) {
                selected = -1;
                feedback = qsTr("Escolhe a casa obrigatória assinalada com ◎.");
            } else {
                selected = index;
                feedback = "";
            }
            board.forceActiveFocus();
        }
        function confirm() {
            if (!validSelection)
                return;
            var position = cells.slice();
            position[selected] = {
                player: player,
                distance: distance,
                direction: direction
            };
            var stock = [reserves[0].slice(), reserves[1].slice()];
            stock[player - 1][distance - 1]--;
            var target = endpoint;
            cells = position;
            reserves = stock;
            mandatory = target;
            selected = -1;
            cursor = target;
            if (!Rules.hasMove(cells, reserves[2 - player], mandatory)) {
                winner = player;
                feedback = qsTr("O participante %1 ficou sem jogada válida.").arg(3 - player);
            } else {
                player = 3 - player;
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
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                topMargin: 8
            }
            width: parent.width - 16
            horizontalAlignment: Text.AlignHCenter
            fontSize: 24
            font.bold: true
            color: "#183c50"
            text: scene.winner ? qsTr("Venceu o participante %1!").arg(scene.winner) : qsTr("Participante %1 · %2").arg(scene.player).arg(scene.player === 1 ? "●" : "◆")
        }
        Row {
            id: stocks
            anchors {
                top: title.bottom
                horizontalCenter: parent.horizontalCenter
            }
            spacing: 16
            Repeater {
                model: 2
                GCText {
                    required property int index
                    objectName: "reserve" + (index + 1)
                    fontSize: 14
                    color: "#183c50"
                    text: qsTr("%1 %2 — 1: %3 · 2: %4 · 3: %5").arg(index + 1).arg(index === 0 ? "●" : "◆").arg(scene.reserves[index][0]).arg(scene.reserves[index][1]).arg(scene.reserves[index][2])
                }
            }
        }
        GCText {
            id: instruction
            anchors {
                top: stocks.bottom
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width - 20
            height: 60
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            fontSize: 14
            color: "#183c50"
            wrapMode: Text.WordWrap
            text: scene.feedback || (scene.selected < 0 ? (scene.mandatory < 0 ? qsTr("Escolhe uma casa para começar, a distância e a direção.") : qsTr("Coloca a seta na casa obrigatória ◎, escolhe a distância e a direção.")) : scene.validSelection ? qsTr("Destino: linha %1, coluna %2. Confirma para colocar a seta.").arg(Math.floor(scene.endpoint / 6) + 1).arg(scene.endpoint % 6 + 1) : qsTr("Destino inválido ou distância sem reserva. Corrige a distância ou a direção."))
        }
        Item {
            id: playArea
            anchors {
                top: instruction.bottom
                bottom: choices.top
                left: parent.left
                right: parent.right
                margins: 8
            }
            Item {
                id: board
                objectName: "faiscaBoard"
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height * 6 / 5)
                height: width * 5 / 6
                focus: true
                activeFocusOnTab: true
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Left)
                        scene.cursor = Math.max(0, scene.cursor - 1);
                    else if (event.key === Qt.Key_Right)
                        scene.cursor = Math.min(29, scene.cursor + 1);
                    else if (event.key === Qt.Key_Up)
                        scene.cursor = Math.max(0, scene.cursor - 6);
                    else if (event.key === Qt.Key_Down)
                        scene.cursor = Math.min(29, scene.cursor + 6);
                    else if (event.key === Qt.Key_Space)
                        scene.choose(scene.cursor);
                    else if (event.key === Qt.Key_1 || event.key === Qt.Key_2 || event.key === Qt.Key_3)
                        scene.distance = event.key - Qt.Key_0;
                    else if (event.key === Qt.Key_W)
                        scene.direction = 0;
                    else if (event.key === Qt.Key_D)
                        scene.direction = 1;
                    else if (event.key === Qt.Key_S)
                        scene.direction = 2;
                    else if (event.key === Qt.Key_A)
                        scene.direction = 3;
                    else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                        scene.confirm();
                    else {
                        event.accepted = false;
                        return;
                    }
                    event.accepted = true;
                }
                Grid {
                    anchors.fill: parent
                    rows: 5
                    columns: 6
                    Repeater {
                        model: 30
                        Rectangle {
                            required property int index
                            objectName: "faiscaCell" + index
                            width: board.width / 6
                            height: width
                            readonly property var piece: scene.cells[index]
                            color: piece ? (piece.player === 1 ? "#175f88" : "#804100") : scene.validSelection && scene.endpoint === index ? "#c3e5ae" : scene.selected === index ? "#fff0ae" : "white"
                            border.color: scene.mandatory === index ? "#b00064" : board.activeFocus && scene.cursor === index ? "#111111" : "#647986"
                            border.width: scene.mandatory === index ? 5 : board.activeFocus && scene.cursor === index ? 4 : 1
                            GCText {
                                anchors.centerIn: parent
                                fontSize: Math.max(12, parent.width * 0.26)
                                color: parent.piece ? "white" : "#183c50"
                                text: parent.piece ? parent.piece.player + " " + scene.arrows[parent.piece.direction] + parent.piece.distance : scene.mandatory === parent.index ? "◎" : scene.selected === parent.index ? scene.arrows[scene.direction] + scene.distance : scene.validSelection && scene.endpoint === parent.index ? "↳" : ""
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: scene.choose(parent.index)
                            }
                            TapHandler {
                                acceptedDevices: PointerDevice.TouchScreen | PointerDevice.TouchPad
                                onTapped: scene.choose(parent.index)
                            }
                            Accessible.role: Accessible.Button
                            Accessible.name: qsTr("Linha %1, coluna %2: %3").arg(Math.floor(index / 6) + 1).arg(index % 6 + 1).arg(piece ? qsTr("participante %1, seta %2, distância %3").arg(piece.player).arg(scene.arrows[piece.direction]).arg(piece.distance) : scene.mandatory === index ? qsTr("casa obrigatória") : qsTr("vazia"))
                            Accessible.onPressAction: scene.choose(index)
                        }
                    }
                }
            }
        }
        Column {
            id: choices
            anchors {
                bottom: controls.top
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 6
            }
            spacing: 4
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 6
                Repeater {
                    model: 3
                    GCButton {
                        required property int index
                        objectName: "distance" + (index + 1)
                        text: (scene.distance === index + 1 ? "✓ " : "") + qsTr("Distância %1").arg(index + 1)
                        enabled: !scene.winner
                        onClicked: {
                            scene.distance = index + 1;
                            scene.feedback = "";
                            board.forceActiveFocus();
                        }
                    }
                }
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 6
                Repeater {
                    model: 4
                    GCButton {
                        required property int index
                        objectName: "direction" + index
                        text: (scene.direction === index ? "✓ " : "") + [qsTr("↑ Cima"), qsTr("→ Direita"), qsTr("↓ Baixo"), qsTr("← Esquerda")][index]
                        enabled: !scene.winner
                        onClicked: {
                            scene.direction = index;
                            scene.feedback = "";
                            board.forceActiveFocus();
                        }
                    }
                }
            }
        }
        Row {
            id: controls
            anchors {
                bottom: bar.top
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 6
            }
            spacing: 12
            GCButton {
                objectName: "confirmFaisca"
                text: qsTr("Confirmar")
                enabled: scene.validSelection
                onClicked: scene.confirm()
            }
            GCButton {
                objectName: "restartFaisca"
                text: qsTr("Nova partida")
                onClicked: scene.reset()
            }
        }
        DialogHelp {
            id: dialogHelp
            onClose: home()
        }
        Bar {
            id: bar
            content: BarEnumContent {
                value: help | home | reload
            }
            onHelpClicked: activity.displayDialog(dialogHelp)
            onHomeClicked: activity.home()
            onReloadClicked: scene.reset()
        }
    }
}
