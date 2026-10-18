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
        color: "#dcecf3"
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
        property bool tux: false
        property int difficulty: 0
        property int generation: 0
        property bool thinking: false
        property string phase: "match"
        property int hints: 0
        property var decision: null
        property var original: []
        property int matchWinner: 0
        readonly property bool accepting: !thinking && phase !== "intro" && phase !== "exerciseDone" && phase !== "reviewDone"
        function lesson() {
            reset();
            phase = "intro";
            feedback = qsTr("Introdução: cada participante pontua pela sua cor, mas pode colocar ambas as cores. Multiplica os dois maiores grupos. Um só grupo vale zero. Juntar grupos do adversário pode baixar a pontuação. Vamos experimentar.");
        }
        function exercise() {
            reset();
            phase = "exercise";
            turn = 1;
            var b = Rules.emptyBoard();
            [30, 39, 54, 60].forEach(function (i) {
                b[i] = 2;
            });
            cells = b;
            chosenColor = 2;
            cursor = 47;
            feedback = qsTr("Exercício didático: as Brancas têm dois grupos de 2, produto 4. Coloca uma branca na ponte ★ e uma negra no canto superior esquerdo. Confirma e observa a união.");
        }
        function hint() {
            if (!accepting || winner)
                return;
            hints = Math.min(3, hints + 1);
            if (hints === 1)
                feedback = qsTr("Pista 1: conta os dois maiores grupos de cada cor. Um grupo sozinho vale zero.");
            else if (hints === 2)
                feedback = qsTr("Pista 2: podes colocar peças do adversário. Uma ponte pode unir os seus dois grupos e reduzir o produto.");
            else {
                if (phase === "exercise") {
                    pending = [
                        {
                            index: 47,
                            color: 2
                        },
                        {
                            index: 0,
                            color: 1
                        }
                    ];
                    cursor = 47;
                } else {
                    var empty = [];
                    for (var i = 0; i < 61; ++i)
                        if (!cells[i])
                            empty.push(i);
                    var suggestion = [];
                    for (var j = 0; j < needed && j < empty.length; ++j)
                        suggestion.push({
                            index: empty[j],
                            color: chosenColor
                        });
                    // In review, make the suggestion differ from the original turn.
                    if (phase === "review" && suggestion.length && suggestion.every(m => original.some(o => o.index === m.index && o.color === m.color)))
                        suggestion[0].color = 3 - suggestion[0].color;
                    pending = suggestion;
                }
                feedback = qsTr("Pista 3: a seleção marcada é uma possibilidade legal. Compara os grupos antes de confirmar; podes corrigi-la.");
            }
        }
        function comparison(b) {
            var a = Rules.summary(b, 1), w = Rules.summary(b, 2);
            return qsTr("● %1 × %2 = %3; ◇ %4 × %5 = %6").arg(a.first).arg(a.second).arg(a.score).arg(w.first).arg(w.second).arg(w.score);
        }
        function review() {
            if (!decision)
                return;
            ++generation;
            thinking = false;
            phase = "review";
            hints = 0;
            cells = decision.board.slice();
            turn = decision.turn;
            player = 1;
            winner = 0;
            pending = [];
            feedback = qsTr("Revisão didática da tua última decisão: resultado da partida, participante %1. A tua jogada deu %2. Experimenta uma alternativa e compara os grupos; esta revisão não altera o resultado.").arg(matchWinner).arg(comparison(Rules.apply(decision.board, decision.turn, original)));
            board.forceActiveFocus();
        }
        WorkerScript {
            id: opponent
            source: "opponent.mjs"
            onMessage: message => {
                if (message.generation !== scene.generation || !scene.thinking)
                    return;
                scene.thinking = false;
                if (scene.player !== 2 || !Rules.apply(scene.cells, scene.turn, message.move))
                    return;
                scene.pending = message.move;
                scene.confirm();
            }
        }
        onStop: {
            ++generation;
            thinking = false;
        }
        function reset() {
            ++generation;
            thinking = false;
            hints = 0;
            phase = "match";
            decision = null;
            original = [];
            matchWinner = 0;
            cells = Rules.emptyBoard();
            pending = [];
            player = 1;
            turn = 0;
            chosenColor = 1;
            cursor = 0;
            winner = 0;
            feedback = "";
            board.forceActiveFocus();
        }
        function choose(index) {
            if (winner || !accepting)
                return;
            cursor = index;
            if (cells[index]) {
                feedback = qsTr("Casa ocupada. Escolhe outra casa.");
                return;
            }
            var next = pending.slice(), existing = -1;
            for (var i = 0; i < next.length; ++i)
                if (next[i].index === index)
                    existing = i;
            if (existing >= 0)
                next.splice(existing, 1);
            else if (next.length < needed)
                next.push({
                    index: index,
                    color: chosenColor
                });
            else {
                feedback = qsTr("Retira uma seleção ou limpa o turno para corrigir.");
                return;
            }
            pending = next;
            feedback = "";
            board.forceActiveFocus();
        }
        function preview(index) {
            for (var i = 0; i < pending.length; ++i)
                if (pending[i].index === index)
                    return pending[i].color;
            return 0;
        }
        function confirm() {
            if (winner || !accepting)
                return;
            var next = Rules.apply(cells, turn, pending);
            if (!next)
                return;
            if (phase === "exercise") {
                if (pending.length !== 2 || !pending.some(m => m.index === 47 && m.color === 2) || !pending.some(m => m.index === 0 && m.color === 1)) {
                    feedback = qsTr("Ainda não é a ponte pedida. Retira as seleções ou usa a terceira pista.");
                    return;
                }
                cells = next;
                pending = [];
                phase = "exerciseDone";
                feedback = qsTr("Certo! As Brancas passaram de 2 × 2 = 4 a 5 × 0 = 0. Unir os dois grupos nem sempre aumenta o produto. Usa Nova partida para jogar.");
                return;
            }
            if (phase === "review") {
                var same = pending.every(m => original.some(o => o.index === m.index && o.color === m.color));
                if (same) {
                    feedback = qsTr("Essa foi a jogada original. Experimenta outra casa ou outra cor.");
                    return;
                }
                var old = Rules.apply(decision.board, decision.turn, original);
                cells = next;
                pending = [];
                phase = "reviewDone";
                feedback = qsTr("Comparação: original %1. Alternativa %2. Compara os dois maiores grupos de cada cor. O vencedor da partida mantém-se: participante %3.").arg(comparison(old)).arg(comparison(next)).arg(matchWinner);
                board.forceActiveFocus();
                return;
            }
            if (tux && player === 1) {
                decision = {
                    board: cells.slice(),
                    turn: turn
                };
                original = pending.slice();
            }
            cells = next;
            pending = [];
            ++turn;
            hints = 0;
            winner = Rules.result(cells);
            if (winner) {
                matchWinner = winner;
                feedback = black.score === white.score ? qsTr("Desempate: vence quem tem menos peças da sua cor. Negras: %1 · Brancas: %2").arg(black.count).arg(white.count) : qsTr("Vence o maior produto dos dois maiores grupos.");
            } else {
                player = 3 - player;
                feedback = "";
                if (tux && player === 2) {
                    thinking = true;
                    opponent.sendMessage({
                        generation: generation,
                        board: cells,
                        turn: turn,
                        difficulty: difficulty
                    });
                }
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
            gameName: qsTr("Produto")
            iconSource: "qrc:/gcompris/src/activities/produto/produto.svg"
            toolItems: [
                Flow {
                    id: choices

                    width: parent.width

                    spacing: 8
                    Repeater {
                        id: colorButtons
                        model: 2
                        BoardGameButton {
                            required property int index
                            selected: scene.chosenColor === index + 1
                            objectName: "produtoColor" + (index + 1)
                            KeyNavigation.tab: index === 0 ? colorButtons.itemAt(1) : confirmButton.enabled ? confirmButton : clearButton.enabled ? clearButton : restartButton
                            focusPolicy: Qt.StrongFocus
                            text: (scene.chosenColor === index + 1 ? "✓ " : "") + (index === 0 ? qsTr("● Negras") : qsTr("◇ Brancas"))
                            enabled: !scene.winner && scene.accepting
                            onClicked: {
                                scene.chosenColor = index + 1;
                                scene.feedback = "";
                            }
                        }
                    }
                },
                Flow {
                    id: controls

                    width: parent.width

                    spacing: 8
                    BoardGameButton {
                        id: confirmButton
                        primaryAction: true
                        objectName: "confirmProduto"
                        KeyNavigation.tab: clearButton.enabled ? clearButton : restartButton
                        focusPolicy: Qt.StrongFocus
                        text: qsTr("Confirmar")
                        enabled: !scene.winner && scene.accepting && scene.pending.length === scene.needed
                        onClicked: scene.confirm()
                    }
                    BoardGameButton {
                        id: clearButton
                        objectName: "clearProduto"
                        KeyNavigation.tab: restartButton
                        focusPolicy: Qt.StrongFocus
                        text: qsTr("Limpar")
                        enabled: !scene.winner && scene.accepting && scene.pending.length > 0
                        onClicked: {
                            scene.pending = [];
                            scene.feedback = "";
                            board.forceActiveFocus();
                        }
                    }
                    BoardGameButton {
                        id: restartButton
                        KeyNavigation.tab: lessonButton
                        objectName: "restartProduto"
                        focusPolicy: Qt.StrongFocus
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
                    wrapMode: Text.WordWrap
                    color: "#183c50"
                    text: scene.feedback || qsTr("Seleciona %1 peça(s) de qualquer cor. Seleção: %2/%1. Toca de novo para retirar; confirma o turno completo.").arg(scene.needed).arg(scene.pending.length)
                },
                BoardGameText {
                    id: scores
                    fontSizeMode: Text.FixedSize

                    width: parent.width
                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WordWrap

                    fontSize: 15
                    color: "#183c50"
                    text: qsTr("● Negras: %1 × %2 = %3 · Peças: %4").arg(scene.black.first).arg(scene.black.second).arg(scene.black.score).arg(scene.black.count) + "\n" + qsTr("◇ Brancas: %1 × %2 = %3 · Peças: %4").arg(scene.white.first).arg(scene.white.second).arg(scene.white.score).arg(scene.white.count)
                },
                Flow {
                    id: learning

                    width: parent.width

                    spacing: 5
                    BoardGameButton {
                        id: lessonButton
                        KeyNavigation.tab: hintButton.enabled ? hintButton : reviewButton.enabled ? reviewButton : modeButton
                        objectName: "produtoLesson"
                        focusPolicy: Qt.StrongFocus
                        text: scene.phase === "intro" ? qsTr("Experimentar") : qsTr("Aprender")
                        onClicked: scene.phase === "intro" ? scene.exercise() : scene.lesson()
                    }
                    BoardGameButton {
                        id: hintButton
                        KeyNavigation.tab: reviewButton.enabled ? reviewButton : modeButton
                        objectName: "produtoHint"
                        focusPolicy: Qt.StrongFocus
                        text: qsTr("Pista %1/3").arg(scene.hints)
                        enabled: scene.accepting && !scene.winner
                        onClicked: scene.hint()
                    }
                    BoardGameButton {
                        id: reviewButton
                        KeyNavigation.tab: modeButton
                        objectName: "produtoReview"
                        focusPolicy: Qt.StrongFocus
                        text: qsTr("Rever decisão")
                        enabled: scene.winner > 0 && scene.decision !== null
                        onClicked: scene.review()
                    }
                },
                Flow {
                    width: parent.width
                    spacing: 8
                    BoardGameButton {
                        id: modeButton
                        KeyNavigation.tab: difficultyButton.visible ? difficultyButton : board
                        objectName: "produtoMode"
                        focusPolicy: Qt.StrongFocus
                        text: scene.tux ? qsTr("Duas pessoas") : qsTr("Contra Tux")
                        onClicked: {
                            scene.tux = !scene.tux;
                            scene.reset();
                        }
                    }
                    BoardGameButton {
                        id: difficultyButton
                        KeyNavigation.tab: board
                        objectName: "produtoDifficulty"
                        focusPolicy: Qt.StrongFocus
                        visible: scene.tux
                        text: scene.difficulty === 0 ? qsTr("Fácil: explora") : scene.difficulty === 1 ? qsTr("Médio: cria grupos") : qsTr("Difícil: compara cores")
                        onClicked: {
                            scene.difficulty = (scene.difficulty + 1) % 3;
                            scene.reset();
                        }
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

            fontSize: 23
            font.bold: true
            color: "#183c50"
            text: (scene.thinking ? qsTr("Tux pensa… · ") : scene.tux && scene.phase === "match" ? qsTr("Contra Tux · ") : "") + (scene.winner === 3 ? qsTr("Empate!") : scene.winner ? qsTr("Venceu o participante %1!").arg(scene.winner) : qsTr("Participante %1 · %2").arg(scene.player).arg(scene.player === 1 ? qsTr("● Negras") : qsTr("◇ Brancas")))
        }
        Item {
            id: area
            parent: gameLayout.boardArea
            anchors.fill: parent

            Item {
                id: board
                objectName: "produtoBoard"
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height * 7 / (9 * 0.8660254))
                height: width * 9 * 0.8660254 / 7
                readonly property real unit: width / 7
                focus: true
                KeyNavigation.tab: scene.accepting && !scene.winner ? colorButtons.itemAt(0) : restartButton
                activeFocusOnTab: true
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Left || event.key === Qt.Key_Up)
                        scene.cursor = Math.max(0, scene.cursor - 1);
                    else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down)
                        scene.cursor = Math.min(60, scene.cursor + 1);
                    else if (event.key === Qt.Key_Space)
                        scene.choose(scene.cursor);
                    else if (event.key === Qt.Key_1)
                        scene.chosenColor = 1;
                    else if (event.key === Qt.Key_2)
                        scene.chosenColor = 2;
                    else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                        scene.confirm();
                    else {
                        event.accepted = false;
                        return;
                    }
                    event.accepted = true;
                }
                Repeater {
                    model: 61
                    Rectangle {
                        required property int index
                        objectName: "produtoCell" + index
                        readonly property int stone: scene.cells[index] || scene.preview(index)
                        readonly property bool selected: scene.preview(index) > 0
                        x: (scene.coords[index].q + 4) * 0.75 * board.unit
                        y: (scene.coords[index].r + scene.coords[index].q / 2 + 4) * 0.8660254 * board.unit
                        width: board.unit
                        height: board.unit * 0.8660254
                        radius: width / 2
                        color: stone === 1 ? "#22333b" : stone === 2 ? "#ffffff" : "#d4e2c8"
                        border.color: selected ? "#b00064" : board.activeFocus && scene.cursor === index ? "#125ca5" : "#52655c"
                        border.width: selected || board.activeFocus && scene.cursor === index ? 4 : 1
                        opacity: selected ? 0.65 : 1
                        BoardGameText {
                            anchors.centerIn: parent
                            color: parent.stone === 1 ? "white" : "#22333b"
                            fontSize: Math.max(12, parent.width * 0.27)
                            text: parent.stone === 1 ? "●" : parent.stone === 2 ? "◇" : scene.phase === "exercise" && index === 47 ? "★" : ""
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: scene.choose(parent.index)
                        }
                        TapHandler {
                            acceptedDevices: PointerDevice.TouchScreen | PointerDevice.TouchPad
                            onTapped: scene.choose(parent.index)
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
