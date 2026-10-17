// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls as QQC2
import "../../core"
import core 1.0
import "nex.mjs" as Rules

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
        property var pending: []
        property var colors: [1, 2]
        property int player: 1
        property int mode: 0
        property int turn: 0
        property int winner: 0
        property int cursor: 0
        property bool swapped: false
        property bool enlarged: false
        property bool exercise: false
        property string feedback: ""
        readonly property int own: colors[player - 1]
        readonly property bool swapAllowed: turn === 1 && player === 2 && !swapped && !winner && !exercise
        property bool tux: false
        property int difficulty: 0
        property int generation: 0
        property bool thinking: false
        property int hints: 0
        property string phase: "match"
        property var decision: null
        property int matchWinner: 0
        readonly property bool accepting: !thinking && phase !== "intro" && phase.indexOf("Done") < 0
        function reset() {
            ++generation;
            thinking = false;
            hints = 0;
            phase = "match";
            decision = null;
            matchWinner = 0;
            cells = Rules.emptyBoard();
            pending = [];
            colors = [1, 2];
            player = 1;
            mode = 0;
            turn = 0;
            winner = 0;
            cursor = 0;
            swapped = false;
            exercise = false;
            feedback = "";
            viewport.contentX = 0;
            viewport.contentY = 0;
            board.forceActiveFocus();
        }
        function choose(i) {
            if (winner || exercise || !accepting || i < 0 || i >= 121)
                return;
            cursor = i;
            var next = pending.slice(), at = next.indexOf(i);
            if (at >= 0) {
                next.splice(at, 1);
                pending = next;
                feedback = "";
                return;
            }
            var expected = mode === 0 ? 0 : (next.length < 2 ? 3 : own);
            if (next.length >= (mode === 0 ? 2 : 3) || cells[i] !== expected) {
                feedback = qsTr("Seleção inválida. Revê a ordem e a cor das peças.");
                return;
            }
            next.push(i);
            pending = next;
            feedback = "";
            board.forceActiveFocus();
        }
        function preview(i) {
            var at = pending.indexOf(i);
            return at < 0 ? cells[i] : (mode === 0 ? (at === 0 ? own : 3) : (at === 2 ? 3 : own));
        }
        function finishRare() {
            var result = Rules.resolveSpecialEnding(cells, own);
            if (!result)
                return;
            cells = result.board;
            pending = [];
            swapped = true;
            winner = result.winner === 3 ? 3 : (colors[0] === result.winner ? 1 : 2);
            feedback = qsTr("Convenção das últimas casas aplicada. O resultado é calculado pelas conexões.");
        }
        function confirm() {
            if (winner || exercise || !accepting)
                return;
            var result = Rules.apply(cells, own, mode, pending);
            if (!result) {
                feedback = qsTr("Completa uma ação válida antes de confirmar.");
                return;
            }
            if (phase.indexOf("lesson") === 0) {
                var expected = phase === "lessonPlace" ? [60, 61] : phase === "lessonReplace" ? [60, 61, 49] : [65, 0];
                var expectedMode = phase === "lessonReplace" ? 1 : 0;
                if (mode !== expectedMode || pending.join(",") !== expected.join(",")) {
                    feedback = qsTr("Experimenta a ação indicada. A terceira pista prepara uma seleção que podes confirmar.");
                    return;
                }
                cells = result;
                pending = [];
                if (phase === "lessonPlace") {
                    phase = "lessonPlaceDone";
                    feedback = qsTr("Colocaste uma peça própria e uma neutra. Usa Continuar para aprender a substituição.");
                } else if (phase === "lessonReplace") {
                    phase = "lessonReplaceDone";
                    feedback = qsTr("Duas neutras tornaram-se tuas e uma tua ficou neutra. São três mudanças numa só ação. Continua para ligar as margens.");
                } else {
                    phase = "exerciseDone";
                    feedback = qsTr("Ligação completa! A cadeia negra alcança N e S. Este exercício didático não é uma partida CRJM. Usa Nova partida para jogar.");
                }
                return;
            }
            if (phase === "review") {
                if (mode === decision.mode && pending.join(",") === decision.selection.join(",")) {
                    feedback = qsTr("Essa foi a decisão original. Experimenta uma alternativa.");
                    return;
                }
                var old = Rules.apply(decision.board, own, decision.mode, decision.selection);
                cells = result;
                pending = [];
                phase = "reviewDone";
                feedback = qsTr("Comparação: %1 Original: %2 Alternativa: %3 O resultado da partida mantém-se: participante %4.").arg(decision.mode === mode ? qsTr("Mudaste as casas escolhidas.") : qsTr("Mudaste o tipo de ação.")).arg(consequence(old, own)).arg(consequence(result, own)).arg(matchWinner);
                return;
            }
            if (tux && player === 1)
                decision = {
                    board: cells.slice(),
                    colors: colors.slice(),
                    player: player,
                    turn: turn,
                    mode: mode,
                    selection: pending.slice()
                };
            cells = result;
            pending = [];
            feedback = "";
            ++turn;
            hints = 0;
            if (Rules.connected(cells, own)) {
                winner = player;
                feedback = qsTr("Ligaste as duas margens com uma cadeia da tua cor!");
            } else {
                player = 3 - player;
                finishRare();
            }
            if (winner)
                matchWinner = winner;
            else if (tux && player === 2 && phase === "match")
                requestTux();
            board.forceActiveFocus();
        }
        function swap() {
            if (!swapAllowed || thinking || phase !== "match")
                return;
            colors = [colors[1], colors[0]];
            swapped = true;
            player = 1;
            pending = [];
            ++turn;
            feedback = qsTr("Cores e margens trocadas. Agora joga o participante 1.");
            board.forceActiveFocus();
        }
        function prepareFinal(kind) {
            reset();
            exercise = true;
            var next = [];
            for (var i = 0; i < 121; ++i)
                next.push(i % 11 === 5 ? 2 : 1);
            next[60] = kind === 1 ? 3 : 0;
            if (kind === 2)
                next[59] = 3;
            cells = next;
            feedback = kind === 0 ? qsTr("Exercício: resta uma casa vazia e nenhuma neutra. Ocupa-a com a cor de quem joga.") : kind === 1 ? qsTr("Exercício: resta uma neutra e nenhuma vazia. Converte-a na cor de quem joga.") : qsTr("Exercício: resta uma vazia e uma neutra. A vazia recebe a tua cor e a neutra a do adversário.");
        }
        function requestTux() {
            thinking = true;
            pending = [];
            opponent.sendMessage({
                generation: ++generation,
                board: cells.slice(),
                own: own,
                difficulty: difficulty,
                swap: swapAllowed
            });
        }
        WorkerScript {
            id: opponent
            source: "opponent.mjs"
            onMessage: message => {
                if (message.generation !== scene.generation || !scene.thinking || scene.player !== 2)
                    return;
                scene.thinking = false;
                if (message.swap) {
                    scene.swap();
                    return;
                }
                var action = message.action;
                if (!action || !Rules.apply(scene.cells, scene.own, action.mode, action.selection))
                    return;
                scene.mode = action.mode;
                scene.pending = action.selection;
                scene.confirm();
            }
        }
        onStop: {
            ++generation;
            thinking = false;
        }
        function lesson() {
            reset();
            phase = "intro";
            feedback = qsTr("Introdução: liga as tuas duas margens por vizinhas. Cada turno coloca uma peça tua e uma neutra OU converte duas neutras em tuas e uma tua em neutra. Confirma sempre a ação completa. Vamos experimentar três passos.");
        }
        function continueLesson() {
            resetLessonBoard();
            if (phase === "intro") {
                phase = "lessonPlace";
                feedback = qsTr("Exercício 1 — colocação: escolhe a estrela central, depois a estrela à sua direita. Confirma a tua peça e a neutra juntas.");
            } else if (phase === "lessonPlaceDone") {
                phase = "lessonReplace";
                mode = 1;
                var b = Rules.emptyBoard();
                b[60] = 3;
                b[61] = 3;
                b[49] = 1;
                cells = b;
                feedback = qsTr("Exercício 2 — substituição: escolhe as duas + centrais, depois a tua ● acima à esquerda. Confirma as três mudanças.");
            } else {
                phase = "lessonConnect";
                var c = Rules.emptyBoard();
                for (var i = 55; i < 65; ++i)
                    c[i] = 1;
                cells = c;
                feedback = qsTr("Exercício 3 — conexão: falta a estrela na margem S. Escolhe-a para a tua peça e o canto O para a neutra. Confirma para ligar N a S.");
            }
            var lessonGeneration = generation;
            Qt.callLater(function () {
                if (scene.generation === lessonGeneration)
                    scene.reveal(scene.phase === "lessonConnect" ? 65 : 60);
            });
        }
        function reveal(i) {
            cursor = i;
            var x = (Math.floor(i / 11) + i % 11) * board.unit + board.originX;
            var y = (i % 11 - Math.floor(i / 11) + 10) * board.unit * 0.5 + board.originY;
            viewport.contentX = Math.max(0, Math.min(board.width - viewport.width, x - viewport.width / 2));
            viewport.contentY = Math.max(0, Math.min(board.height - viewport.height, y - viewport.height / 2));
        }
        function resetLessonBoard() {
            ++generation;
            thinking = false;
            hints = 0;
            cells = Rules.emptyBoard();
            pending = [];
            mode = 0;
        }
        function hint() {
            if (winner || thinking || !accepting || phase.indexOf("Done") >= 0)
                return;
            hints = Math.min(3, hints + 1);
            if (hints === 1)
                feedback = qsTr("Pista 1: identifica as tuas margens e procura uma cadeia da tua cor. As neutras ainda não contam para a ligação.");
            else if (hints === 2)
                feedback = qsTr("Pista 2: podes colocar em duas vazias ou substituir duas neutras e uma tua. Uma neutra perto da cadeia pode ajudar num próximo turno.");
            else {
                var action = null;
                if (phase === "lessonPlace")
                    action = {
                        mode: 0,
                        selection: [60, 61]
                    };
                else if (phase === "lessonReplace")
                    action = {
                        mode: 1,
                        selection: [60, 61, 49]
                    };
                else if (phase === "lessonConnect")
                    action = {
                        mode: 0,
                        selection: [65, 0]
                    };
                else {
                    var options = Rules.candidates(cells, own, 1);
                    for (var a of options)
                        if (phase !== "review" || a.mode !== decision.mode || a.selection.join(",") !== decision.selection.join(",")) {
                            action = a;
                            break;
                        }
                }
                if (action) {
                    mode = action.mode;
                    pending = action.selection;
                    var hintGeneration = generation, first = action.selection[0];
                    Qt.callLater(function () {
                        if (scene.generation === hintGeneration && scene.pending.length)
                            scene.reveal(first);
                    });
                }
                feedback = qsTr("Pista 3: a seleção marcada é uma ação completa e legal. Observa a previsão antes de confirmar; podes alterá-la.");
            }
        }
        function consequence(b, color) {
            var distance = Rules.distance(b, color);
            return distance === 0 ? qsTr("Já existe uma ligação entre as margens.") : distance === 999 ? qsTr("O adversário bloqueia todas as rotas.") : qsTr("A rota mais curta precisa de conquistar %1 casa(s). Vazias e neutras ainda não são tuas.").arg(distance);
        }
        function review() {
            if (!decision || !winner)
                return;
            ++generation;
            thinking = false;
            phase = "review";
            hints = 0;
            winner = 0;
            cells = decision.board.slice();
            colors = decision.colors.slice();
            player = decision.player;
            turn = decision.turn;
            pending = [];
            mode = decision.mode;
            exercise = false;
            feedback = qsTr("Revisão didática da tua última decisão real. A jogada original: %1 Experimenta outras casas ou outro tipo de ação e confirma para comparar. O resultado da partida fica guardado.").arg(consequence(Rules.apply(cells, own, decision.mode, decision.selection), own));
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
            gameName: qsTr("Nex")
            iconSource: "qrc:/gcompris/src/activities/nex/nex.svg"
            toolItems: [
                Flow {
                    id: modeRow

                    width: parent.width

                    spacing: 5
                    BoardGameButton {
                        id: placeButton
                        KeyNavigation.tab: replaceButton
                        selected: scene.mode === 0
                        objectName: "placeNex"
                        focusPolicy: Qt.StrongFocus
                        text: qsTr("Colocar")
                        enabled: !scene.winner && !scene.exercise && scene.accepting
                        onClicked: {
                            scene.mode = 0;
                            scene.pending = [];
                            scene.feedback = "";
                        }
                    }
                    BoardGameButton {
                        id: replaceButton
                        KeyNavigation.tab: swapButton.enabled ? swapButton : zoomButton
                        selected: scene.mode === 1
                        objectName: "replaceNex"
                        focusPolicy: Qt.StrongFocus
                        text: qsTr("Substituir")
                        enabled: !scene.winner && !scene.exercise && scene.accepting
                        onClicked: {
                            scene.mode = 1;
                            scene.pending = [];
                            scene.feedback = "";
                        }
                    }
                    BoardGameButton {
                        id: swapButton
                        KeyNavigation.tab: zoomButton
                        objectName: "swapNex"
                        focusPolicy: Qt.StrongFocus
                        text: qsTr("Trocar")
                        enabled: scene.swapAllowed && !scene.thinking
                        onClicked: scene.swap()
                    }
                    BoardGameButton {
                        id: zoomButton
                        KeyNavigation.tab: confirmButton.enabled ? confirmButton : clearButton.enabled ? clearButton : restartButton
                        objectName: "zoomNex"
                        focusPolicy: Qt.StrongFocus
                        text: scene.enlarged ? qsTr("Reduzir") : qsTr("Ampliar")
                        onClicked: {
                            scene.enlarged = !scene.enlarged;
                            scene.reveal(scene.cursor);
                        }
                    }
                },
                Flow {
                    id: actions

                    width: parent.width

                    spacing: 5
                    BoardGameButton {
                        id: confirmButton
                        KeyNavigation.tab: clearButton.enabled ? clearButton : restartButton
                        primaryAction: true
                        objectName: "confirmNex"
                        focusPolicy: Qt.StrongFocus
                        text: qsTr("Confirmar")
                        enabled: !scene.winner && !scene.exercise && scene.accepting && scene.pending.length === (scene.mode === 0 ? 2 : 3)
                        onClicked: scene.confirm()
                    }
                    BoardGameButton {
                        id: clearButton
                        KeyNavigation.tab: restartButton
                        objectName: "clearNex"
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
                        KeyNavigation.tab: finalButtons.firstButton
                        objectName: "restartNex"
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

                    fontSize: 13
                    wrapMode: Text.WordWrap
                    color: "#183c50"
                    text: scene.feedback || (scene.mode === 0 ? qsTr("Colocar: escolhe duas vazias, primeiro a tua peça, depois +. Seleção: %1/2. Amplia para selecionar com mais precisão.") : qsTr("Substituir: escolhe duas +, depois uma tua. Seleção: %1/3. Amplia para selecionar com mais precisão.")).arg(scene.pending.length)
                },
                BoardGameText {
                    id: ownership
                    fontSizeMode: Text.FixedSize

                    width: parent.width
                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WordWrap

                    fontSize: 13
                    color: "#183c50"
                    text: (scene.tux ? qsTr("Tu = participante 1 · Tux = participante 2") + "\n" : "") + qsTr("P1: %1 · P2: %2 · Neutras: +").arg(scene.colors[0] === 1 ? qsTr("● N ↔ S") : qsTr("◇ O ↔ E")).arg(scene.colors[1] === 1 ? qsTr("● N ↔ S") : qsTr("◇ O ↔ E"))
                },
                Flow {
                    id: learning

                    width: parent.width

                    spacing: 4
                    BoardGameButton {
                        id: lessonButton
                        KeyNavigation.tab: continueButton.enabled ? continueButton : hintButton.enabled ? hintButton : reviewButton.enabled ? reviewButton : tuxButton
                        objectName: "lessonNex"
                        focusPolicy: Qt.StrongFocus
                        text: qsTr("Aprender")
                        onClicked: scene.lesson()
                    }
                    BoardGameButton {
                        id: continueButton
                        KeyNavigation.tab: hintButton.enabled ? hintButton : tuxButton
                        objectName: "continueNex"
                        focusPolicy: Qt.StrongFocus
                        text: qsTr("Continuar")
                        enabled: scene.phase === "intro" || scene.phase === "lessonPlaceDone" || scene.phase === "lessonReplaceDone"
                        onClicked: scene.continueLesson()
                    }
                    BoardGameButton {
                        id: hintButton
                        KeyNavigation.tab: reviewButton.enabled ? reviewButton : tuxButton
                        objectName: "hintNex"
                        focusPolicy: Qt.StrongFocus
                        text: qsTr("Pista %1/3").arg(scene.hints)
                        enabled: !scene.winner && scene.accepting && scene.phase.indexOf("Done") < 0
                        onClicked: scene.hint()
                    }
                    BoardGameButton {
                        id: reviewButton
                        KeyNavigation.tab: tuxButton
                        objectName: "reviewNex"
                        focusPolicy: Qt.StrongFocus
                        text: qsTr("Rever decisão")
                        enabled: scene.winner > 0 && scene.decision !== null
                        onClicked: scene.review()
                    }
                },
                Flow {
                    id: modes

                    width: parent.width

                    spacing: 4
                    BoardGameButton {
                        id: tuxButton
                        KeyNavigation.tab: difficultyButton.visible ? difficultyButton : board
                        objectName: "tuxNex"
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
                        objectName: "difficultyNex"
                        focusPolicy: Qt.StrongFocus
                        visible: scene.tux
                        text: scene.difficulty === 0 ? qsTr("Fácil: explora") : scene.difficulty === 1 ? qsTr("Médio: encurta rota") : qsTr("Difícil: bloqueia")
                        onClicked: {
                            scene.difficulty = (scene.difficulty + 1) % 3;
                            scene.reset();
                        }
                    }
                },
                Flow {
                    id: exercises

                    width: parent.width

                    spacing: 4
                    Repeater {
                        id: finalButtons
                        property Item firstButton: null
                        onItemAdded: (index, item) => {
                            if (index === 0)
                                firstButton = item;
                        }
                        onItemRemoved: (index, item) => {
                            if (firstButton === item)
                                firstButton = null;
                        }
                        model: 3
                        BoardGameButton {
                            required property int index
                            KeyNavigation.tab: index < 2 ? finalButtons.itemAt(index + 1) : resolveButton.enabled ? resolveButton : lessonButton
                            objectName: "finalNex" + index
                            focusPolicy: Qt.StrongFocus
                            text: qsTr("Final %1").arg(index + 1)
                            onClicked: scene.prepareFinal(index)
                        }
                    }
                    BoardGameButton {
                        id: resolveButton
                        KeyNavigation.tab: lessonButton
                        objectName: "resolveNex"
                        focusPolicy: Qt.StrongFocus
                        text: qsTr("Aplicar regra")
                        enabled: scene.exercise && !scene.winner
                        onClicked: scene.finishRare()
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

            fontSize: 21
            wrapMode: Text.WordWrap
            font.bold: true
            color: "#183c50"
            text: (scene.thinking ? qsTr("Tux pensa… · ") : scene.tux && scene.phase === "match" ? qsTr("Contra Tux · ") : "") + (scene.winner === 3 ? qsTr("Empate!") : scene.winner ? qsTr("Venceu o participante %1!").arg(scene.winner) : qsTr("Participante %1 · %2").arg(scene.player).arg(scene.own === 1 ? qsTr("● Negras · N ↔ S") : qsTr("◇ Brancas · O ↔ E")))
        }
        Flickable {
            id: viewport
            parent: gameLayout.boardArea
            anchors.fill: parent
            objectName: "nexViewport"

            QQC2.ScrollBar.vertical: QQC2.ScrollBar {
                policy: QQC2.ScrollBar.AsNeeded
            }
            QQC2.ScrollBar.horizontal: QQC2.ScrollBar {
                policy: QQC2.ScrollBar.AsNeeded
            }
            clip: true
            contentWidth: board.width
            contentHeight: board.height
            boundsBehavior: Flickable.StopAtBounds
            Item {
                id: board
                objectName: "nexBoard"
                width: scene.enlarged ? Math.max(viewport.width, 1200) : viewport.width
                height: scene.enlarged ? Math.max(viewport.height, 760) : viewport.height
                readonly property real unit: Math.min((width - 28) / 21, (height - 34) / 11.5)
                readonly property real originX: (width - 21 * unit) / 2
                readonly property real originY: (height - 11 * unit) / 2
                focus: true
                activeFocusOnTab: true
                KeyNavigation.tab: placeButton.enabled ? placeButton : zoomButton
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Left)
                        scene.cursor = Math.max(0, scene.cursor - 11);
                    else if (event.key === Qt.Key_Right)
                        scene.cursor = Math.min(120, scene.cursor + 11);
                    else if (event.key === Qt.Key_Up)
                        scene.cursor = Math.max(0, scene.cursor - 1);
                    else if (event.key === Qt.Key_Down)
                        scene.cursor = Math.min(120, scene.cursor + 1);
                    else if (event.key === Qt.Key_Space)
                        scene.choose(scene.cursor);
                    else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                        scene.confirm();
                    else {
                        event.accepted = false;
                        return;
                    }
                    event.accepted = true;
                    scene.reveal(scene.cursor);
                }
                Canvas {
                    id: marginsCanvas
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d"), u = board.unit;
                        ctx.reset();
                        ctx.lineWidth = 5;
                        function edge(x1, y1, x2, y2, color) {
                            ctx.strokeStyle = color;
                            ctx.beginPath();
                            ctx.moveTo(x1 * u + board.originX + 6, y1 * u + board.originY + 3);
                            ctx.lineTo(x2 * u + board.originX + 6, y2 * u + board.originY + 3);
                            ctx.stroke();
                        }
                        edge(0, 5, 10, 0, "#22333b");
                        edge(10, 10.8, 20.8, 5.4, "#22333b");
                        edge(0, 5.8, 10, 10.8, "#597eb9");
                        edge(10.8, 0, 20.8, 5, "#597eb9");
                    }
                    Connections {
                        target: board
                        function onUnitChanged() {
                            marginsCanvas.requestPaint();
                        }
                        function onOriginXChanged() {
                            marginsCanvas.requestPaint();
                        }
                        function onOriginYChanged() {
                            marginsCanvas.requestPaint();
                        }
                    }
                }
                Repeater {
                    model: 121
                    Rectangle {
                        required property int index
                        objectName: "nexCell" + index
                        readonly property int stone: scene.preview(index)
                        readonly property bool selected: scene.pending.indexOf(index) >= 0
                        x: (Math.floor(index / 11) + index % 11) * board.unit + board.originX
                        y: (index % 11 - Math.floor(index / 11) + 10) * board.unit * 0.5 + board.originY
                        width: board.unit * 0.95
                        height: board.unit * 0.95
                        radius: height / 2
                        color: stone === 1 ? "#22333b" : stone === 2 ? "white" : stone === 3 ? "#e9be57" : "#d4e2c8"
                        border.color: selected ? "#b00064" : board.activeFocus && scene.cursor === index ? "#125ca5" : "#52655c"
                        border.width: selected || board.activeFocus && scene.cursor === index ? 4 : 1
                        opacity: selected ? 0.65 : 1
                        BoardGameText {
                            anchors.centerIn: parent
                            fontSize: 14
                            color: parent.stone === 1 ? "white" : "#22333b"
                            text: parent.stone === 1 ? "●" : parent.stone === 2 ? "◇" : parent.stone === 3 ? "+" : (scene.phase === "lessonPlace" && (index === 60 || index === 61)) || (scene.phase === "lessonConnect" && (index === 65 || index === 0)) ? "★" : ""
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
                Repeater {
                    model: [
                        {
                            s: "● N",
                            x: 5,
                            y: 2
                        },
                        {
                            s: "◇ E",
                            x: 16,
                            y: 2
                        },
                        {
                            s: "● S",
                            x: 16,
                            y: 8.5
                        },
                        {
                            s: "◇ O",
                            x: 5,
                            y: 8.5
                        }
                    ]
                    BoardGameText {
                        required property var modelData
                        text: modelData.s
                        color: "#183c50"
                        fontSize: 12
                        x: modelData.x * board.unit + board.originX - 4
                        y: modelData.y * board.unit + board.originY - 17
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
