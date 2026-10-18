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
        color: "#dcecf3"
        signal start
        signal stop
        property var cells: Rules.emptyBoard()
        property int player: 1
        property int winner: 0
        property int captured: 0
        property int cursor: 0
        property bool inspecting: false
        property var selected: ({
                stones: [],
                liberties: []
            })
        property string feedback: ""
        property bool tux: false
        property int difficulty: 0
        property bool thinking: false
        property int generation: 0
        property string phase: "match"
        property int hints: 0
        property int hintPoint: -1
        property var decision: null
        readonly property bool accepting: !thinking && phase !== "intro" && phase !== "reviewDone"
        function reset() {
            generation++;
            thinking = false;
            phase = "match";
            hints = 0;
            hintPoint = -1;
            decision = null;
            cells = Rules.emptyBoard();
            player = 1;
            winner = 0;
            captured = 0;
            cursor = 0;
            inspecting = false;
            selected = {
                stones: [],
                liberties: []
            };
            feedback = "";
            board.forceActiveFocus();
        }
        function lesson() {
            reset();
            phase = "intro";
            feedback = qsTr("Introdução: um grupo liga pedras na horizontal e vertical. Cada interseção vazia junto do grupo é uma liberdade. Retira a última liberdade ao adversário: a primeira captura ganha. As diagonais não ligam pedras.");
        }
        function exercise() {
            reset();
            phase = "exercise";
            var position = Rules.emptyBoard();
            position[0] = 2;
            position[9] = 1;
            cells = position;
            feedback = qsTr("Exercício didático preparado: a pedra branca no canto tem uma liberdade. Usa Grupo e liberdades para a observar; depois volta a jogar e faz a primeira captura com as Pretas.");
        }
        function hint() {
            if (!accepting || winner)
                return;
            hints++;
            var target = -1;
            for (var i = 0; i < 81; ++i) {
                var move = Rules.place(cells, player, i);
                if (!move.error && (target < 0 || move.captured.length))
                    target = i;
                if (!move.error && move.captured.length)
                    break;
            }
            if (hints === 1)
                feedback = qsTr("Conta as liberdades dos grupos adversários. Um grupo com uma só liberdade pode ser capturado.");
            else if (hints === 2)
                feedback = qsTr("Observa a linha %1. Confirma as liberdades antes de colocar a pedra.").arg(Math.floor(target / 9) + 1);
            else {
                hintPoint = target;
                feedback = qsTr("Experimenta a interseção assinalada com ?. É uma jogada legal; só ganha se retirar a última liberdade de um grupo adversário.");
            }
        }
        function review() {
            if (!decision)
                return;
            generation++;
            thinking = false;
            phase = "review";
            winner = 0;
            captured = 0;
            cells = decision.cells.slice();
            player = 1;
            inspecting = false;
            selected = {
                stones: [],
                liberties: []
            };
            hints = 0;
            hintPoint = -1;
            feedback = qsTr("Revisão: jogaste na linha %1, coluna %2. Experimenta outra interseção e compara as liberdades do grupo formado.").arg(Math.floor(decision.index / 9) + 1).arg(decision.index % 9 + 1);
            board.forceActiveFocus();
        }
        function requestTux() {
            if (!tux || phase !== "match" || winner || player !== 2)
                return;
            thinking = true;
            feedback = qsTr("Tux está a pensar… Podes consultar a ajuda ou reiniciar.");
            opponent.sendMessage({
                board: cells,
                difficulty: difficulty,
                generation: generation
            });
        }
        WorkerScript {
            id: opponent
            source: "opponent.mjs"
            onMessage: message => {
                if (message.generation !== scene.generation || !scene.thinking || scene.player !== 2 || scene.winner || scene.phase !== "match")
                    return;
                scene.thinking = false;
                if (message.index >= 0)
                    scene.place(message.index);
            }
        }
        onStop: {
            generation++;
            thinking = false;
        }
        function place(index) {
            const move = Rules.place(cells, player, index);
            if (move.error) {
                feedback = move.error === "suicide" ? qsTr("Suicídio: o grupo ficaria sem liberdades e não capturaria pedras. Escolhe outra interseção.") : qsTr("Esta interseção está ocupada. Escolhe outra.");
                return;
            }
            if (phase === "review") {
                if (index === decision.index) {
                    feedback = qsTr("Escolhe uma alternativa à jogada original.");
                    return;
                }
                var original = Rules.place(decision.cells, 1, decision.index);
                var before = Rules.group(original.board, decision.index).liberties.length;
                var after = Rules.group(move.board, index).liberties.length;
                cells = move.board;
                phase = "reviewDone";
                feedback = qsTr("Revisão concluída: o grupo da jogada original tinha %1 liberdades e capturava %2 pedra(s); a alternativa tem %3 liberdades e captura %4. Mais liberdades dão espaço para respirar, mas observa também as ameaças adversárias.").arg(before).arg(original.captured.length).arg(after).arg(move.captured.length);
                return;
            }
            if (phase === "match" && player === 1 && !decision)
                decision = {
                    cells: cells.slice(),
                    index: index
                };
            cells = move.board;
            feedback = "";
            hints = 0;
            hintPoint = -1;
            selected = {
                stones: [],
                liberties: []
            };
            if (move.captured.length) {
                winner = player;
                captured = move.captured.length;
                generation++;
                thinking = false;
            } else
                player = 3 - player;
            requestTux();
        }
        function choose(index) {
            cursor = index;
            if (inspecting) {
                selected = Rules.group(cells, index);
                feedback = selected.stones.length ? qsTr("%1 pedras · %2 liberdades").arg(selected.stones.length).arg(selected.liberties.length) : qsTr("Toca numa pedra para ver o seu grupo.");
            } else if (!winner && accepting)
                place(index);
            board.forceActiveFocus();
        }
        Component.onCompleted: {
            activity.start.connect(start);
            activity.stop.connect(stop);
        }
        onStart: reset()
        BoardGameLayout {
            id: gameLayout
            focusTarget: board
            anchors.fill: parent
            anchors.bottomMargin: bar.height * bar.scale + 6
            gameName: qsTr("Atari Go")
            iconSource: "qrc:/gcompris/src/activities/atari_go/atari_go.svg"
            toolItems: [
                Flow {
                    id: controls

                    width: parent.width

                    spacing: 8
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        selected: scene.inspecting
                        objectName: "inspectAtari"
                        text: scene.inspecting ? qsTr("Voltar a jogar") : qsTr("Grupo e liberdades")
                        onClicked: {
                            scene.inspecting = !scene.inspecting;
                            scene.selected = {
                                stones: [],
                                liberties: []
                            };
                            scene.feedback = "";
                        }
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "lessonAtari"
                        visible: scene.phase === "intro"
                        text: qsTr("Experimentar")
                        onClicked: scene.exercise()
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "hintAtari"
                        text: qsTr("Pista")
                        enabled: scene.accepting && !scene.winner
                        onClicked: scene.hint()
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "reviewAtari"
                        text: qsTr("Rever decisão")
                        visible: scene.winner > 0 && scene.phase === "match" && scene.decision !== null
                        onClicked: scene.review()
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "restartAtari"
                        text: qsTr("Nova partida")
                        onClicked: scene.reset()
                    }
                },
                BoardGameText {
                    id: instruction
                    fontSizeMode: Text.FixedSize

                    width: parent.width
                    horizontalAlignment: Text.AlignLeft

                    fontSize: 14
                    color: "#183c50"
                    wrapMode: Text.WordWrap
                    text: scene.feedback || (scene.winner ? qsTr("Primeira captura: %1 pedra(s). A partida terminou.").arg(scene.captured) : scene.inspecting ? qsTr("Toca numa pedra para ver o seu grupo e as liberdades (+).") : qsTr("Coloca uma pedra numa interseção. Vence quem faz a primeira captura."))
                },
                Flow {
                    id: modes

                    width: parent.width

                    spacing: 6
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "tuxAtari"
                        text: scene.tux ? qsTr("Duas pessoas") : qsTr("Contra Tux")
                        onClicked: {
                            scene.tux = !scene.tux;
                            scene.reset();
                        }
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "difficultyAtari"
                        visible: scene.tux
                        text: [qsTr("Fácil: ao acaso"), qsTr("Médio: captura e liberdades"), qsTr("Difícil: antecipa capturas")][scene.difficulty]
                        onClicked: {
                            scene.difficulty = (scene.difficulty + 1) % 3;
                            scene.reset();
                        }
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "learnAtari"
                        text: qsTr("Aprender")
                        onClicked: scene.lesson()
                    }
                }
            ]
        }
        BoardGameText {
            id: title
            parent: gameLayout.headerArea
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            fontSize: 24
            font.bold: true
            color: "#183c50"
            text: scene.phase === "intro" ? qsTr("Aprender Atari Go") : scene.phase === "reviewDone" ? qsTr("Compara as duas decisões") : scene.tux && scene.phase === "match" && !scene.winner ? (scene.player === 1 ? qsTr("Tu · Pretas ●") : qsTr("Tux · Brancas ○")) : scene.winner ? (scene.winner === 1 ? qsTr("Venceram as Pretas ●!") : qsTr("Venceram as Brancas ○!")) : scene.player === 1 ? qsTr("Pretas ● · Participante 1") : qsTr("Brancas ○ · Participante 2")
        }
        Item {
            parent: gameLayout.boardArea
            anchors.fill: parent

            Rectangle {
                id: board
                objectName: "atariBoard"
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height)
                height: width
                color: "#e8c58b"
                focus: true
                activeFocusOnTab: true
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Left)
                        scene.cursor = Math.max(0, scene.cursor - 1);
                    else if (event.key === Qt.Key_Right)
                        scene.cursor = Math.min(80, scene.cursor + 1);
                    else if (event.key === Qt.Key_Up)
                        scene.cursor = Math.max(0, scene.cursor - 9);
                    else if (event.key === Qt.Key_Down)
                        scene.cursor = Math.min(80, scene.cursor + 9);
                    else if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                        scene.choose(scene.cursor);
                    else {
                        event.accepted = false;
                        return;
                    }
                    event.accepted = true;
                }
                Repeater {
                    model: 9
                    Item {
                        required property int index
                        anchors.fill: parent
                        Rectangle {
                            x: board.width / 18
                            y: (index + 0.5) * board.height / 9
                            width: board.width * 8 / 9
                            height: 1
                            color: "#694c26"
                        }
                        Rectangle {
                            y: board.height / 18
                            x: (index + 0.5) * board.width / 9
                            height: board.height * 8 / 9
                            width: 1
                            color: "#694c26"
                        }
                    }
                }
                Repeater {
                    model: 81
                    Item {
                        required property int index
                        objectName: "atariPoint" + index
                        x: index % 9 * width
                        y: Math.floor(index / 9) * height
                        width: board.width / 9
                        height: width
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width * 0.86
                            height: width
                            radius: width / 2
                            color: scene.cells[index] === 1 ? "#17212a" : "#fffdf5"
                            visible: scene.cells[index] > 0
                            border.width: scene.selected.stones.indexOf(index) >= 0 ? 4 : 1
                            border.color: scene.selected.stones.indexOf(index) >= 0 ? "#005d87" : "#17212a"
                            BoardGameText {
                                anchors.centerIn: parent
                                fontSize: Math.max(14, parent.width * 0.43)
                                color: scene.cells[index] === 1 ? "white" : "#17212a"
                                text: scene.cells[index] === 1 ? "●" : scene.cells[index] === 2 ? "○" : ""
                            }
                        }
                        BoardGameText {
                            anchors.centerIn: parent
                            visible: scene.selected.liberties.indexOf(index) >= 0
                            text: "+"
                            color: "#00577c"
                            font.bold: true
                            fontSize: 22
                        }
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 2
                            color: "transparent"
                            border.color: "#804100"
                            border.width: 3
                            visible: board.activeFocus && scene.cursor === index
                        }
                        BoardGameText {
                            anchors.centerIn: parent
                            text: "?"
                            font.bold: true
                            color: "#b00064"
                            visible: scene.hintPoint === index
                            fontSize: 24
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: scene.choose(parent.index)
                        }
                        Accessible.role: Accessible.Button
                        Accessible.name: qsTr("Linha %1, coluna %2: %3").arg(Math.floor(index / 9) + 1).arg(index % 9 + 1).arg(scene.cells[index] === 1 ? qsTr("Preta") : scene.cells[index] === 2 ? qsTr("Branca") : qsTr("vazia"))
                        Accessible.onPressAction: scene.choose(index)
                    }
                }
            }
        }
        DialogHelp {
            id: dialogHelp
            onClose: home()
        }
        Bar {
            id: bar
            scale: Math.min(1, Math.max(56, Math.min(96, scene.width * 0.1, scene.height * 0.1)) / buttonSize)
            transformOrigin: Item.BottomLeft
            content: BarEnumContent {
                value: help | home | reload
            }
            onHelpClicked: activity.displayDialog(dialogHelp)
            onHomeClicked: activity.home()
            onReloadClicked: scene.reset()
        }
    }
}
