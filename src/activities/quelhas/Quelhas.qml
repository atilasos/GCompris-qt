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
        color: "#dcecf3"
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
        property bool tux: false
        property int difficulty: 0
        property int generation: 0
        property bool thinking: false
        property string phase: "match"
        property int hints: 0
        property var hintMove: []
        property var decision: null
        readonly property bool accepting: !thinking && phase !== "intro" && phase !== "reviewDone"
        function hint() {
            if (!accepting || winner)
                return;
            hints++;
            var options = Rules.options(cells, vertical);
            if (!options.length)
                return;
            var move = options[0];
            if (hints === 1)
                feedback = qsTr("Perde quem faz a última jogada. Tenta conservar uma jogada para o adversário.");
            else if (hints === 2)
                feedback = qsTr("Procura um segmento na linha %1. Observa as opções que restam na outra direção.").arg(Math.floor(move[0] / 10) + 1);
            else {
                hintMove = move;
                feedback = qsTr("Experimenta os extremos assinalados. Esta é uma jogada permitida, não uma garantia de vitória.");
            }
        }
        function lesson() {
            reset();
            phase = "intro";
            feedback = qsTr("Introdução: cada pessoa ocupa segmentos de duas ou mais casas na sua direção. Perde quem faz a última jogada. Quem começa o turno sem jogadas ganha. A troca inicial muda as orientações, não as pessoas.");
        }
        function exercise() {
            reset();
            phase = "exercise";
            var position = Array(100).fill(1);
            position[0] = 0;
            position[10] = 0;
            position[20] = 0;
            position[22] = 0;
            position[23] = 0;
            cells = position;
            feedback = qsTr("Exercício didático preparado: joga da linha 1 à linha 2 da primeira coluna. Deixa o par horizontal para o outro participante. Depois de ele o ocupar, ganhas sem jogar. Seleciona os extremos.");
        }
        function review() {
            if (!decision)
                return;
            generation++;
            thinking = false;
            phase = "review";
            winner = 0;
            cells = decision.cells.slice();
            player = decision.player;
            swapped = decision.swapped;
            moves = decision.moves;
            first = -1;
            last = -1;
            hints = 0;
            hintMove = [];
            feedback = qsTr("Revisão: jogaste da casa %1 à casa %2. Experimenta outro segmento e compara o espaço que deixas.").arg(decision.move[0] + 1).arg(decision.move[decision.move.length - 1] + 1);
            board.forceActiveFocus();
        }
        function requestTux() {
            if (!tux || phase !== "match" || winner || player !== 2)
                return;
            var canSwap = swapAvailable;
            thinking = true;
            feedback = qsTr("Tux está a pensar… Podes consultar a ajuda ou reiniciar.");
            opponent.sendMessage({
                board: cells,
                swapped: swapped,
                swapAvailable: canSwap,
                difficulty: difficulty,
                generation: generation
            });
        }
        WorkerScript {
            id: opponent
            source: "opponent.mjs"
            onMessage: message => {
                if (message.generation !== scene.generation || !scene.thinking || scene.player !== 2 || scene.winner)
                    return;
                scene.thinking = false;
                if (message.swap)
                    scene.swap();
                else if (Rules.legal(scene.cells, message.move || [])) {
                    scene.first = message.move[0];
                    scene.last = message.move[message.move.length - 1];
                    scene.confirm();
                }
            }
        }
        onStop: {
            generation++;
            thinking = false;
        }
        readonly property bool vertical: (player === 1) !== swapped
        readonly property bool swapAvailable: accepting && phase === "match" && !winner && player === 2 && moves === 1 && !swapped
        readonly property var selection: Rules.segment(first, last, vertical)
        readonly property bool validSelection: accepting && !winner && Rules.legal(cells, selection)
        function reset() {
            generation++;
            thinking = false;
            phase = "match";
            hints = 0;
            hintMove = [];
            decision = null;
            cells = Rules.emptyBoard();
            player = 1;
            swapped = false;
            moves = 0;
            first = -1;
            last = -1;
            cursor = 0;
            winner = 0;
            feedback = "";
            board.forceActiveFocus();
        }
        function clear() {
            first = -1;
            last = -1;
            feedback = "";
            board.forceActiveFocus();
        }
        function choose(index) {
            if (winner || !accepting)
                return;
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
            if (!validSelection)
                return;
            if (phase === "review") {
                if (selection.join(",") === decision.move.join(",")) {
                    feedback = qsTr("Escolhe uma alternativa à jogada original.");
                    return;
                }
                var originalPairs = Rules.pairs(Rules.place(decision.cells, decision.move), !vertical);
                var alternativePairs = Rules.pairs(Rules.place(cells, selection), !vertical);
                cells = Rules.place(cells, selection);
                first = -1;
                last = -1;
                phase = "reviewDone";
                feedback = qsTr("Revisão concluída: a decisão original deixava %1 pares livres ao adversário; a alternativa deixa %2. Em misère, retirar a última opção ao adversário faz-te perder. Compara também os turnos seguintes.").arg(originalPairs).arg(alternativePairs);
                return;
            }
            if (phase === "match" && player === 1 && !decision)
                decision = {
                    cells: cells.slice(),
                    player: player,
                    swapped: swapped,
                    moves: moves,
                    move: selection.slice()
                };
            cells = Rules.place(cells, selection);
            moves++;
            hints = 0;
            hintMove = [];
            first = -1;
            last = -1;
            player = 3 - player;
            if (!Rules.hasMove(cells, vertical)) {
                winner = player;
                feedback = qsTr("O participante %1 não tem jogadas na sua orientação. Perde quem faz a última jogada: participante %2.").arg(player).arg(3 - player);
            } else
                feedback = "";
            if (winner) {
                generation++;
                thinking = false;
            }
            requestTux();
            board.forceActiveFocus();
        }
        function swap() {
            if (!swapAvailable)
                return;
            swapped = true;
            player = 1;
            first = -1;
            last = -1;
            feedback = qsTr("Orientações trocadas. A troca consumiu o turno do participante 2; joga o participante 1 na horizontal.");
            if (!Rules.hasMove(cells, vertical))
                winner = player;
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
            gameName: qsTr("Quelhas")
            iconSource: "qrc:/gcompris/src/activities/quelhas/quelhas.svg"
            toolItems: [
                Flow {
                    id: controls

                    width: parent.width

                    spacing: 8
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "swapQuelhas"
                        text: qsTr("Trocar orientações")
                        enabled: scene.swapAvailable
                        onClicked: scene.swap()
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "lessonQuelhas"
                        visible: scene.phase === "intro"
                        text: qsTr("Experimentar")
                        onClicked: scene.exercise()
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "hintQuelhas"
                        text: qsTr("Pista")
                        enabled: scene.accepting && !scene.winner
                        onClicked: scene.hint()
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "reviewQuelhas"
                        text: qsTr("Rever decisão")
                        visible: scene.winner > 0 && scene.phase === "match" && scene.decision !== null
                        onClicked: scene.review()
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        primaryAction: true
                        objectName: "confirmQuelhas"
                        text: qsTr("Confirmar")
                        enabled: scene.validSelection
                        onClicked: scene.confirm()
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "clearQuelhas"
                        text: qsTr("Limpar seleção")
                        enabled: scene.first >= 0 && !scene.winner
                        onClicked: scene.clear()
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "restartQuelhas"
                        text: qsTr("Nova partida")
                        onClicked: scene.reset()
                    }
                },
                BoardGameText {
                    id: instruction
                    fontSizeMode: Text.FixedSize

                    width: parent.width
                    horizontalAlignment: Text.AlignLeft

                    fontSize: 13
                    color: "#183c50"
                    text: scene.feedback || qsTr("Seleciona os dois extremos de um segmento e confirma.")
                    wrapMode: Text.WordWrap
                },
                BoardGameText {
                    id: roles
                    fontSizeMode: Text.FixedSize

                    width: parent.width
                    horizontalAlignment: Text.AlignLeft

                    fontSize: 13
                    color: "#183c50"
                    text: scene.swapped ? qsTr("1 ↔ Horizontal · 2 ↕ Vertical — perde quem faz a última jogada") : qsTr("1 ↕ Vertical · 2 ↔ Horizontal — perde quem faz a última jogada")
                    wrapMode: Text.WordWrap
                },
                Flow {
                    id: modeControls

                    width: parent.width

                    spacing: 6
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "tuxQuelhas"
                        text: scene.tux ? qsTr("Duas pessoas") : qsTr("Contra Tux")
                        onClicked: {
                            scene.tux = !scene.tux;
                            scene.reset();
                        }
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "difficultyQuelhas"
                        visible: scene.tux
                        text: [qsTr("Fácil: ao acaso"), qsTr("Médio: compara espaço"), qsTr("Difícil: troca e antecipa")][scene.difficulty]
                        onClicked: {
                            scene.difficulty = (scene.difficulty + 1) % 3;
                            scene.reset();
                        }
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "learnQuelhas"
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
            text: scene.phase === "intro" ? qsTr("Aprender Quelhas") : scene.phase === "reviewDone" ? qsTr("Compara as duas decisões") : scene.winner ? qsTr("Venceu o participante %1!").arg(scene.winner) : scene.tux && scene.phase === "match" ? (scene.player === 1 ? (scene.vertical ? qsTr("Tu · Vertical ↕") : qsTr("Tu · Horizontal ↔")) : (scene.vertical ? qsTr("Tux · Vertical ↕") : qsTr("Tux · Horizontal ↔"))) : scene.vertical ? qsTr("Participante %1 · Vertical ↕").arg(scene.player) : qsTr("Participante %1 · Horizontal ↔").arg(scene.player)
        }
        Item {
            parent: gameLayout.boardArea
            anchors.fill: parent

            Item {
                id: board
                objectName: "quelhasBoard"
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height)
                height: width
                focus: true
                activeFocusOnTab: true
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Left)
                        scene.cursor = Math.max(0, scene.cursor - 1);
                    else if (event.key === Qt.Key_Right)
                        scene.cursor = Math.min(99, scene.cursor + 1);
                    else if (event.key === Qt.Key_Up)
                        scene.cursor = Math.max(0, scene.cursor - 10);
                    else if (event.key === Qt.Key_Down)
                        scene.cursor = Math.min(99, scene.cursor + 10);
                    else if (event.key === Qt.Key_Space)
                        scene.choose(scene.cursor);
                    else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                        scene.confirm();
                    else if (event.key === Qt.Key_Escape)
                        scene.clear();
                    else {
                        event.accepted = false;
                        return;
                    }
                    event.accepted = true;
                }
                Grid {
                    anchors.fill: parent
                    rows: 10
                    columns: 10
                    Repeater {
                        model: 100
                        Rectangle {
                            required property int index
                            objectName: "quelhasCell" + index
                            width: board.width / 10
                            height: width
                            readonly property bool occupied: scene.cells[index] > 0
                            readonly property bool preview: scene.first === index || scene.last === index || scene.selection.indexOf(index) >= 0
                            color: occupied ? "#183c50" : preview ? (scene.validSelection || scene.last < 0 ? "#c3e5ae" : "#ffc7bc") : "white"
                            border.color: scene.hintMove.indexOf(index) >= 0 ? "#b00064" : board.activeFocus && scene.cursor === index ? "#804100" : "#647986"
                            border.width: scene.hintMove.indexOf(index) >= 0 ? 5 : board.activeFocus && scene.cursor === index ? 4 : 1
                            BoardGameText {
                                anchors.centerIn: parent
                                fontSize: Math.max(12, parent.width * 0.45)
                                text: parent.occupied ? "●" : parent.preview ? (scene.vertical ? "↕" : "↔") : ""
                                color: parent.occupied ? "white" : "#183c50"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: scene.choose(parent.index)
                            }
                            Accessible.role: Accessible.Button
                            Accessible.name: qsTr("Linha %1, coluna %2: %3").arg(Math.floor(index / 10) + 1).arg(index % 10 + 1).arg(occupied ? qsTr("ocupada") : qsTr("vazia"))
                            Accessible.onPressAction: scene.choose(index)
                        }
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
