// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import "../../core"
import core 1.0
import "dominorio.mjs" as Rules

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
        property int selected: -1
        property int cursor: 0
        property int winner: 0
        property string feedback: ""
        property bool tux: false
        property int difficulty: 0
        property int generation: 0
        property bool thinking: false
        property int hints: 0
        property string phase: "match"
        property var decision: null
        property int originalMove: -1
        property int hintCell: -1
        readonly property bool accepting: !thinking && phase !== "intro" && phase !== "reviewDone"
        function mobility(position, who) {
            var count = 0;
            for (var i = 0; i < 64; ++i)
                if (Rules.legal(position, i, who))
                    ++count;
            return count;
        }
        function hint() {
            if (!accepting || winner)
                return;
            hints++;
            if (hints === 1)
                feedback = player === 1 ? qsTr("Procura duas casas vazias na vertical. Que espaço deixas ao adversário?") : qsTr("Procura duas casas vazias na horizontal. Que espaço deixas ao adversário?");
            else {
                for (var i = 0; i < 64; ++i)
                    if (Rules.legal(cells, i, player)) {
                        hintCell = i;
                        break;
                    }
                if (hints === 2) {
                    feedback = qsTr("Há uma jogada possível a começar na linha %1. Procura nessa linha.").arg(Math.floor(hintCell / 8) + 1);
                    hintCell = -1;
                    return;
                }
                feedback = qsTr("Experimenta a casa assinalada: linha %1, coluna %2. Observa a previsão antes de confirmar.").arg(Math.floor(hintCell / 8) + 1).arg(hintCell % 8 + 1);
            }
        }
        function lesson() {
            reset();
            phase = "intro";
            feedback = qsTr("Introdução: tu colocas duas casas na vertical ↕; Tux coloca na horizontal ↔. Vence quem deixa o adversário sem jogada. Vamos experimentar um final preparado.");
        }
        function exercise() {
            reset();
            phase = "exercise";
            var position = Array(64).fill(2);
            position[0] = 0;
            position[8] = 0;
            cells = position;
            feedback = qsTr("Exercício didático: posição preparada, não uma partida completa. Coloca o último dominó vertical para bloquear Tux.");
        }
        function review() {
            if (!decision)
                return;
            generation++;
            thinking = false;
            cells = decision.slice();
            player = 1;
            winner = 0;
            selected = -1;
            phase = "review";
            hints = 0;
            hintCell = -1;
            feedback = qsTr("Revisão: a tua primeira jogada foi na linha %1, coluna %2. Experimenta outra e compara as opções horizontais que deixa.").arg(Math.floor(originalMove / 8) + 1).arg(originalMove % 8 + 1);
        }
        WorkerScript {
            id: opponent
            source: "opponent.mjs"
            onMessage: message => {
                if (message.generation !== scene.generation || !scene.thinking)
                    return;
                scene.thinking = false;
                if (scene.player === 2 && Rules.legal(scene.cells, message.move, 2)) {
                    scene.selected = message.move;
                    scene.confirm();
                }
            }
        }
        onStop: {
            generation++;
            thinking = false;
        }
        readonly property bool validSelection: accepting && !winner && Rules.legal(cells, selected, player)
        function reset() {
            generation++;
            thinking = false;
            hints = 0;
            hintCell = -1;
            phase = "match";
            decision = null;
            originalMove = -1;
            cells = Rules.emptyBoard();
            player = 1;
            selected = -1;
            cursor = 0;
            winner = 0;
            feedback = "";
            board.forceActiveFocus();
        }
        function choose(index) {
            if (winner || !accepting)
                return;
            cursor = index;
            selected = index;
            feedback = validSelection ? qsTr("Confirma para colocar o dominó.") : qsTr("Jogada impossível. Escolhe duas casas vazias na tua direção.");
            board.forceActiveFocus();
        }
        function confirm() {
            if (!validSelection)
                return;
            if (phase === "review") {
                if (selected === originalMove) {
                    feedback = qsTr("Escolhe uma alternativa à jogada original.");
                    return;
                }
                var originalOptions = mobility(Rules.place(decision, originalMove, 1), 2);
                var alternativeOptions = mobility(Rules.place(cells, selected, 1), 2);
                cells = Rules.place(cells, selected, 1);
                selected = -1;
                phase = "reviewDone";
                feedback = qsTr("Revisão concluída: a jogada original deixava %1 opções horizontais; esta deixa %2. Menos opções pode ajudar a bloquear, mas observa também os turnos seguintes.").arg(originalOptions).arg(alternativeOptions);
                return;
            }
            if (player === 1 && phase === "match" && !decision) {
                decision = cells.slice();
                originalMove = selected;
            }
            cells = Rules.place(cells, selected, player);
            hints = 0;
            hintCell = -1;
            selected = -1;
            var next = 3 - player;
            if (!Rules.hasMove(cells, next)) {
                winner = player;
                feedback = qsTr("O participante %1 ficou sem uma jogada válida.").arg(next);
            } else {
                player = next;
                feedback = "";
            }
            if (tux && phase === "match" && !winner && player === 2) {
                thinking = true;
                feedback = qsTr("Tux está a pensar… Podes consultar a ajuda ou reiniciar.");
                opponent.sendMessage({
                    board: cells,
                    difficulty: difficulty,
                    generation: generation
                });
            }
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
            gameName: qsTr("Dominório")
            iconSource: "qrc:/gcompris/src/activities/dominorio/dominorio.svg"
            toolItems: [
                Flow {
                    id: controls

                    width: parent.width

                    spacing: 12
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "lessonNext"
                        visible: scene.phase === "intro"
                        text: qsTr("Experimentar")
                        onClicked: scene.exercise()
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "hintDomino"
                        text: qsTr("Pista")
                        enabled: scene.accepting && !scene.winner
                        onClicked: scene.hint()
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "reviewDomino"
                        visible: scene.winner > 0 && scene.phase === "match" && scene.decision !== null
                        text: qsTr("Rever decisão")
                        onClicked: scene.review()
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        primaryAction: true
                        objectName: "confirmDomino"
                        text: qsTr("Confirmar")
                        enabled: scene.validSelection
                        onClicked: scene.confirm()
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "restartDomino"
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
                    text: scene.feedback || qsTr("Seleciona a primeira casa, observa a previsão e confirma.")
                    wrapMode: Text.WordWrap
                },
                Flow {
                    id: modeControls

                    width: parent.width

                    spacing: 6
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "tuxMode"
                        text: scene.tux ? qsTr("Duas pessoas") : qsTr("Contra Tux")
                        onClicked: {
                            scene.tux = !scene.tux;
                            scene.reset();
                        }
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "difficultyDomino"
                        visible: scene.tux
                        text: [qsTr("Fácil: escolhe ao acaso"), qsTr("Médio: limita opções"), qsTr("Difícil: antecipa resposta")][scene.difficulty]
                        onClicked: {
                            scene.difficulty = (scene.difficulty + 1) % 3;
                            scene.reset();
                        }
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "learnDomino"
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
            text: scene.phase === "reviewDone" ? qsTr("Compara as duas decisões") : scene.phase === "intro" ? qsTr("Aprender Dominório") : scene.winner ? qsTr("Venceu o participante %1!").arg(scene.winner) : scene.tux ? (scene.player === 1 ? qsTr("Tu · Vertical ↕") : qsTr("Tux · Horizontal ↔")) : scene.player === 1 ? qsTr("Participante 1 · Vertical ↕") : qsTr("Participante 2 · Horizontal ↔")
        }
        Item {
            id: playArea
            parent: gameLayout.boardArea
            anchors.fill: parent

            Item {
                id: board
                objectName: "dominorioBoard"
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height)
                height: width
                focus: true
                activeFocusOnTab: true
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Left)
                        scene.cursor = Math.max(0, scene.cursor - 1);
                    else if (event.key === Qt.Key_Right)
                        scene.cursor = Math.min(63, scene.cursor + 1);
                    else if (event.key === Qt.Key_Up)
                        scene.cursor = Math.max(0, scene.cursor - 8);
                    else if (event.key === Qt.Key_Down)
                        scene.cursor = Math.min(63, scene.cursor + 8);
                    else if (event.key === Qt.Key_Space)
                        scene.choose(scene.cursor);
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
                    rows: 8
                    columns: 8
                    Repeater {
                        id: squares
                        model: 64
                        Rectangle {
                            required property int index
                            objectName: "dominoCell" + index
                            width: board.width / 8
                            height: width
                            readonly property int owner: scene.cells[index]
                            readonly property bool preview: scene.selected === index || (scene.validSelection && Rules.secondCell(scene.selected, scene.player) === index)
                            color: owner === 1 ? "#175f88" : owner === 2 ? "#804100" : preview ? (scene.validSelection ? "#c3e5ae" : "#ffc7bc") : "#ffffff"
                            border.color: scene.hintCell === index ? "#b00064" : board.activeFocus && scene.cursor === index ? "#111111" : "#647986"
                            border.width: scene.hintCell === index ? 5 : board.activeFocus && scene.cursor === index ? 4 : 1
                            BoardGameText {
                                anchors.centerIn: parent
                                fontSize: Math.max(12, parent.width * 0.34)
                                text: parent.owner === 1 ? "1 ↕" : parent.owner === 2 ? "2 ↔" : parent.preview && scene.validSelection ? (scene.player === 1 ? "↕" : "↔") : ""
                                color: parent.owner ? "white" : "#183c50"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: scene.choose(parent.index)
                            }
                            Accessible.role: Accessible.Button
                            Accessible.name: qsTr("Linha %1, coluna %2: %3").arg(Math.floor(index / 8) + 1).arg(index % 8 + 1).arg(owner ? qsTr("participante %1").arg(owner) : qsTr("vazia"))
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
