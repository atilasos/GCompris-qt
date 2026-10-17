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
        color: "#dcecf3"
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
        property bool tux: false
        property int difficulty: 0
        property bool thinking: false
        property int generation: 0
        property string phase: "match"
        property int hints: 0
        property int hintPoint: -1
        property var decision: null
        function lesson() {
            reset();
            phase = "intro";
            feedback = qsTr("Introdução: segue as linhas, une peças da tua cor e liga S, E e D num único grupo. Três grupos separados não bastam. Os cantos tocam em dois lados. A troca inicial muda as cores dos participantes.");
        }
        function exercise() {
            reset();
            phase = "exercise";
            var prepared = cells.slice();
            for (var id of ["A1", "B1", "C1", "D3", "E3", "E4", "E5", "E6", "E7", "D8", "C7", "B8"])
                prepared[Rules.indices[id]] = 1;
            cells = prepared;
            feedback = qsTr("Exercício didático preparado: completa o grupo Azul ● para ligar os três lados. Segue as linhas até ao lado direito; a proximidade não cria ligações.");
        }
        function hint() {
            if (winner || thinking || phase === "intro" || phase === "reviewDone")
                return;
            hints++;
            var best = -1, score = -1;
            for (var i = 0; i < 93; i++)
                if (!cells[i]) {
                    var next = cells.slice();
                    next[i] = currentColor;
                    var group = Rules.groupAt(next, i), sides = Rules.sides(group);
                    var value = [0, 1, 1, 2, 1, 2, 2, 3][sides] * 100 + group.length;
                    if (value > score) {
                        score = value;
                        best = i;
                    }
                }
            if (hints === 1)
                feedback = qsTr("Procura um grupo que possa tocar nos três lados. Grupos separados não somam os seus lados.");
            else if (hints === 2)
                feedback = qsTr("Observa a faixa %1 e segue as linhas até ao teu grupo.").arg(Graph.nodes[best][0].charAt(0));
            else {
                hintPoint = best;
                feedback = qsTr("A intersecção %1 está assinalada com ?. Une o teu grupo e compara os lados que alcança.").arg(Graph.nodes[best][0]);
            }
        }
        function review() {
            if (!decision)
                return;
            generation++;
            thinking = false;
            phase = "review";
            cells = decision.cells.slice();
            swapped = decision.swapped;
            player = 1;
            winner = 0;
            highlighted = [];
            hints = 0;
            hintPoint = -1;
            feedback = qsTr("Revisão da tua decisão em %1: experimenta outra intersecção vazia. Compara o tamanho do grupo e os lados ligados.").arg(Graph.nodes[decision.index][0]);
            board.forceActiveFocus();
        }
        function requestTux() {
            if (!tux || phase !== "match" || winner || player !== 2)
                return;
            thinking = true;
            feedback = qsTr("Tux está a pensar… Podes consultar a ajuda ou reiniciar.");
            opponent.sendMessage({
                cells: cells,
                color: currentColor,
                difficulty: difficulty,
                swap: swapAvailable,
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
                if (message.swap)
                    scene.swap();
                else if (message.index >= 0)
                    scene.place(message.index);
            }
        }
        onStop: {
            generation++;
            thinking = false;
        }
        function reset() {
            generation++;
            thinking = false;
            phase = "match";
            hints = 0;
            hintPoint = -1;
            decision = null;
            cells = Array(93).fill(0);
            player = 1;
            swapped = false;
            moves = 0;
            cursor = 0;
            winner = 0;
            highlighted = [];
            feedback = "";
            board.forceActiveFocus();
        }
        function choose(index) {
            if (winner || thinking || phase === "intro" || phase === "reviewDone")
                return;
            cursor = index;
            place(index);
        }
        function place(index) {
            if (cells[index]) {
                feedback = qsTr("Intersecção ocupada. Escolhe uma intersecção vazia.");
                return;
            }
            var next = cells.slice();
            next[index] = currentColor;
            if (phase === "review") {
                if (index === decision.index) {
                    feedback = qsTr("Escolhe uma alternativa à decisão original.");
                    return;
                }
                var original = cells.slice();
                original[decision.index] = currentColor;
                var first = Rules.groupAt(original, decision.index), alternative = Rules.groupAt(next, index);
                cells = next;
                highlighted = alternative;
                phase = "reviewDone";
                feedback = qsTr("Revisão concluída: a jogada original unia %1 peças e %2 lados; a alternativa une %3 peças e %4 lados. Unir grupos pode aproximar-te dos três lados; ocupar outro canto pode deixar grupos separados. Segue as linhas antes de decidir.").arg(first.length).arg([0, 1, 1, 2, 1, 2, 2, 3][Rules.sides(first)]).arg(alternative.length).arg([0, 1, 1, 2, 1, 2, 2, 3][Rules.sides(alternative)]);
                return;
            }
            if (phase === "match" && player === 1 && !decision)
                decision = {
                    cells: cells.slice(),
                    index: index,
                    swapped: swapped
                };
            cells = next;
            moves++;
            hints = 0;
            hintPoint = -1;
            highlighted = Rules.groupAt(cells, index);
            if (Rules.sides(highlighted) === 7) {
                winner = player;
                generation++;
                thinking = false;
                feedback = qsTr("Um único grupo liga os três lados. O grupo vencedor está assinalado.");
            } else {
                feedback = qsTr("Grupo da última peça: %1 intersecções; %2 lados ligados.").arg(highlighted.length).arg([0, 1, 1, 2, 1, 2, 2, 3][Rules.sides(highlighted)]);
                player = 3 - player;
            }
            board.forceActiveFocus();
            requestTux();
        }
        function swap() {
            if (!swapAvailable)
                return;
            swapped = true;
            player = 1;
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
            gameName: qsTr("Y")
            iconSource: "qrc:/gcompris/src/activities/y/y.svg"
            toolItems: [
                Flow {
                    id: controls

                    width: parent.width

                    spacing: 6
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "exerciseY"
                        visible: scene.phase === "intro"
                        text: qsTr("Experimentar exercício")
                        onClicked: scene.exercise()
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "hintY"
                        visible: scene.tux || scene.phase !== "match"
                        enabled: !scene.thinking && !scene.winner && scene.phase !== "intro" && scene.phase !== "reviewDone"
                        text: qsTr("Pista")
                        onClicked: scene.hint()
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "reviewY"
                        visible: scene.winner && scene.decision !== null
                        text: qsTr("Rever decisão")
                        onClicked: scene.review()
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "swapY"
                        text: qsTr("Trocar cores")
                        enabled: scene.swapAvailable && !scene.thinking && scene.phase === "match" && !scene.tux
                        onClicked: scene.swap()
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "restartY"
                        text: qsTr("Nova partida")
                        onClicked: scene.reset()
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "zoomY"
                        text: scene.enlarged ? qsTr("Reduzir") : qsTr("Ampliar")
                        onClicked: {
                            scene.enlarged = !scene.enlarged;
                            scene.revealCursor();
                        }
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "helpY"
                        text: qsTr("Ajuda")
                        onClicked: activity.displayDialog(dialogHelp)
                    }
                    BoardGameText {
                        width: controls.width
                        fontSize: 11
                        color: "#183c50"
                        wrapMode: Text.WordWrap
                        text: qsTr("S: superior · E: esquerdo · D: direito. Usa Ampliar para alvos maiores e desliza o tabuleiro ampliado. Setas: percorrer; Espaço: colocar; Tab: botões.")
                    }
                },
                BoardGameText {
                    id: instruction
                    fontSizeMode: Text.FixedSize

                    width: parent.width
                    horizontalAlignment: Text.AlignLeft

                    fontSize: 13
                    color: "#183c50"
                    wrapMode: Text.WordWrap
                    text: scene.feedback || qsTr("Segue as ligações desenhadas. Intersecções próximas podem não estar ligadas.")
                },
                BoardGameText {
                    id: roles
                    fontSizeMode: Text.FixedSize

                    width: parent.width
                    horizontalAlignment: Text.AlignLeft

                    fontSize: 13
                    color: "#183c50"
                    wrapMode: Text.WordWrap
                    text: scene.swapped ? qsTr("1 Vermelho ◆ · 2 Azul ●. Liga os três lados num único grupo.") : qsTr("1 Azul ● · 2 Vermelho ◆. Liga os três lados num único grupo.")
                },
                Flow {
                    id: modes

                    width: parent.width

                    spacing: 6
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "tuxY"
                        text: scene.tux ? qsTr("Duas pessoas") : qsTr("Contra Tux")
                        onClicked: {
                            scene.tux = !scene.tux;
                            scene.reset();
                        }
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "difficultyY"
                        visible: scene.tux
                        text: [qsTr("Fácil: ao acaso"), qsTr("Médio: une grupos"), qsTr("Difícil: une e bloqueia")][scene.difficulty]
                        onClicked: {
                            scene.difficulty = (scene.difficulty + 1) % 3;
                            scene.reset();
                        }
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "learnY"
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

            fontSize: 23
            font.bold: true
            color: "#183c50"
            text: scene.phase === "intro" ? qsTr("Aprender Y") : scene.winner ? (scene.tux && scene.phase === "match" ? (scene.winner === 1 ? qsTr("Venceste!") : qsTr("Venceu Tux!")) : qsTr("Venceu o participante %1!").arg(scene.winner)) : scene.tux && scene.phase === "match" ? (scene.player === 1 ? qsTr("Tu · %1") : qsTr("Tux · %1")).arg(scene.currentColor === 1 ? qsTr("Azul ●") : qsTr("Vermelho ◆")) : qsTr("Participante %1 · %2").arg(scene.player).arg(scene.currentColor === 1 ? qsTr("Azul ●") : qsTr("Vermelho ◆"))
        }
        Flickable {
            id: viewport
            parent: gameLayout.boardArea
            anchors.fill: parent
            objectName: "yViewport"

            clip: true
            contentWidth: board.width
            contentHeight: board.height
            boundsBehavior: Flickable.StopAtBounds
            Item {
                id: board
                objectName: "yBoard"
                readonly property real margin: 34
                readonly property real originX: (width - 856 * scaleFactor) / 2
                readonly property real scaleFactor: scene.enlarged ? Math.max(0.95, Math.min((viewport.width - 2 * margin) / 856, (viewport.height - 2 * margin) / 847) * 1.4) : Math.max(0.25, Math.min((viewport.width - 2 * margin) / 856, (viewport.height - 2 * margin) / 847))
                width: Math.max(viewport.width, 856 * scaleFactor + 2 * margin)
                height: Math.max(viewport.height, 847 * scaleFactor + 2 * margin)
                focus: true
                activeFocusOnTab: true
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Left || event.key === Qt.Key_Up)
                        scene.cursor = (scene.cursor + 92) % 93;
                    else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down)
                        scene.cursor = (scene.cursor + 1) % 93;
                    else if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                        scene.choose(scene.cursor);
                    else {
                        event.accepted = false;
                        return;
                    }
                    scene.revealCursor();
                    event.accepted = true;
                }
                Canvas {
                    id: connections
                    anchors.fill: parent
                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()
                    Connections {
                        target: scene
                        function onHighlightedChanged() {
                            connections.requestPaint();
                        }
                    }
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();
                        for (var e = 0; e < Graph.edges.length; e++) {
                            var edge = Graph.edges[e], ai = Rules.indices[edge[0]], bi = Rules.indices[edge[1]];
                            var a = Graph.nodes[ai], b = Graph.nodes[bi];
                            var selected = scene.highlighted.indexOf(ai) >= 0 && scene.highlighted.indexOf(bi) >= 0;
                            ctx.strokeStyle = selected ? "#b24d00" : "#667b80";
                            ctx.lineWidth = selected ? 4 : 1.5;
                            ctx.beginPath();
                            ctx.moveTo(board.originX + a[1] * board.scaleFactor, board.margin + a[2] * board.scaleFactor);
                            ctx.lineTo(board.originX + b[1] * board.scaleFactor, board.margin + b[2] * board.scaleFactor);
                            ctx.stroke();
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
                        width: Math.min(44, 52 * board.scaleFactor)
                        height: width
                        radius: width / 2
                        color: scene.cells[index] === 1 ? "#1769aa" : scene.cells[index] === 2 ? "#a72b35" : "#ffffff"
                        border.color: board.activeFocus && scene.cursor === index ? "#a34c00" : modelData[3] ? "#0e5960" : "#52646a"
                        border.width: board.activeFocus && scene.cursor === index ? 4 : modelData[3] ? 3 : 1
                        BoardGameText {
                            anchors.centerIn: parent
                            text: scene.hintPoint === index ? "?" : scene.cells[index] === 1 ? "●" : scene.cells[index] === 2 ? "◆" : board.activeFocus && scene.cursor === index ? modelData[0] : ""
                            fontSize: Math.max(10, parent.width * 0.45)
                            color: scene.cells[index] ? "white" : "#183c50"
                        }
                        // Side codes remain visible after occupation as well as on empty nodes.
                        BoardGameText {
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                top: parent.bottom
                                topMargin: -4
                            }
                            fontSize: 9
                            font.bold: true
                            color: "#0e5960"
                            text: (modelData[3] & 1 ? "S" : "") + (modelData[3] & 2 ? "E" : "") + (modelData[3] & 4 ? "D" : "")
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: scene.choose(parent.index)
                        }
                        Accessible.role: Accessible.Button
                        Accessible.name: qsTr("Intersecção %1: %2").arg(modelData[0]).arg(scene.cells[index] === 1 ? qsTr("Azul, círculo") : scene.cells[index] === 2 ? qsTr("Vermelho, losango") : qsTr("vazia"))
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
