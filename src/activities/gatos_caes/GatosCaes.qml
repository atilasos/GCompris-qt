// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import "../../core"
import core 1.0
import "gatos_caes.mjs" as Rules

ActivityBase {
    id: activity
    onStart: focus = true
    pageComponent: Rectangle {
        id: scene
        anchors.fill: parent
        color: "#dcecf3"
        signal start
        signal stop
        property var cells: Rules.emptyBoard()
        property int player: 1
        property int winner: 0
        property int cursor: 27
        property bool showLegal: false
        property string feedback: ""
        property bool tux: false
        property int difficulty: 0
        property int generation: 0
        property bool thinking: false
        property string phase: "match"
        property int hints: 0
        property int hintCell: -1
        property var decision: null
        property int originalMove: -1
        readonly property bool accepting: !thinking && phase !== "intro" && phase !== "exerciseDone" && phase !== "reviewDone"
        function mobility(position, who) {
            var count = 0;
            for (var i = 0; i < 64; ++i)
                if (Rules.legal(position, i, who))
                    count++;
            return count;
        }
        function hint() {
            if (!accepting || winner)
                return;
            hints++;
            if (hints === 1) {
                feedback = qsTr("Procura uma casa vazia. Um animal da outra espécie bloqueia os vizinhos na horizontal e na vertical, mas não na diagonal.");
                return;
            }
            for (var i = 0; i < 64; ++i)
                if (Rules.legal(cells, i, player)) {
                    hintCell = i;
                    break;
                }
            if (hints === 2) {
                feedback = qsTr("Procura uma casa permitida na linha %1.").arg(Math.floor(hintCell / 8) + 1);
                hintCell = -1;
                return;
            }
            feedback = qsTr("Experimenta a casa assinalada: linha %1, coluna %2. Que casas reservas para os teus animais?").arg(Math.floor(hintCell / 8) + 1).arg(hintCell % 8 + 1);
        }
        function lesson() {
            reset();
            phase = "intro";
            feedback = qsTr("Introdução: Gatos e Cães não podem ser vizinhos na horizontal ou na vertical. Na diagonal podem! Vence quem deixa o adversário sem casa. Vamos experimentar a vizinhança.");
        }
        function exercise() {
            reset();
            phase = "exercise";
            var position = Rules.emptyBoard();
            position[27] = 1;
            position[20] = 2;
            cells = position;
            feedback = qsTr("Exercício didático de vizinhança: há um Gato e um Cão numa posição preparada. Coloca outro Gato sem tocar no Cão na horizontal ou na vertical. Não é uma partida completa.");
        }
        function review() {
            if (!decision)
                return;
            generation++;
            thinking = false;
            cells = decision.slice();
            player = 1;
            winner = 0;
            phase = "review";
            hints = 0;
            hintCell = -1;
            feedback = qsTr("Revisão: o teu primeiro Gato ficou na linha %1, coluna %2. Experimenta outra abertura e compara as casas disponíveis para Cães.").arg(Math.floor(originalMove / 8) + 1).arg(originalMove % 8 + 1);
        }
        WorkerScript {
            id: opponent
            source: "opponent.mjs"
            onMessage: message => {
                if (message.generation !== scene.generation || !scene.thinking)
                    return;
                scene.thinking = false;
                if (scene.player === 2 && Rules.legal(scene.cells, message.move, 2))
                    scene.choose(message.move);
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
            hintCell = -1;
            decision = null;
            originalMove = -1;
            cells = Rules.emptyBoard();
            player = 1;
            winner = 0;
            cursor = 27;
            feedback = "";
            showLegal = false;
            board.forceActiveFocus();
        }
        function choose(index) {
            if (winner || !accepting)
                return;
            cursor = index;
            if (!Rules.legal(cells, index, player)) {
                feedback = qsTr("Jogada impossível. Escolhe uma casa vazia permitida, sem vizinhos da outra espécie na horizontal ou na vertical.");
                board.forceActiveFocus();
                return;
            }
            if (phase === "review") {
                if (index === originalMove) {
                    feedback = qsTr("Escolhe uma alternativa à jogada original.");
                    return;
                }
                var before = mobility(Rules.place(decision, originalMove, 1), 2);
                var after = mobility(Rules.place(cells, index, 1), 2);
                cells = Rules.place(cells, index, 1);
                phase = "reviewDone";
                feedback = qsTr("Revisão concluída: a abertura original deixava %1 casas para Cães; esta deixa %2. Contagens iguais não garantem finais iguais: observa também a distribuição das casas.").arg(before).arg(after);
                return;
            }
            if (player === 1 && phase === "match" && !decision) {
                decision = cells.slice();
                originalMove = index;
            }
            cells = Rules.place(cells, index, player);
            hints = 0;
            hintCell = -1;
            if (phase === "exercise") {
                phase = "exerciseDone";
                feedback = qsTr("Exercício concluído: colocaste um Gato sem vizinhos Cães na horizontal ou na vertical. Nova partida permite jogar com as regras completas.");
                return;
            }
            var next = 3 - player;
            if (!Rules.hasMove(cells, next)) {
                winner = player;
                feedback = qsTr("O participante %1 ficou sem uma colocação válida.").arg(next);
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
            gameName: qsTr("Gatos & Cães")
            iconSource: "qrc:/gcompris/src/activities/gatos_caes/gatos_caes.svg"
            toolItems: [
                Flow {
                    id: controls

                    width: parent.width

                    spacing: 12
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "lessonNextGatos"
                        visible: scene.phase === "intro"
                        text: qsTr("Experimentar")
                        onClicked: scene.exercise()
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "hintGatos"
                        text: qsTr("Pista")
                        enabled: scene.accepting && !scene.winner
                        onClicked: scene.hint()
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "reviewGatos"
                        visible: scene.winner > 0 && scene.phase === "match" && scene.decision !== null
                        text: qsTr("Rever decisão")
                        onClicked: scene.review()
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "legalGatos"
                        text: scene.showLegal ? qsTr("Ocultar casas permitidas") : qsTr("Mostrar casas permitidas")
                        onClicked: {
                            scene.showLegal = !scene.showLegal;
                            board.forceActiveFocus();
                        }
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "restartGatos"
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
                    text: scene.feedback || (scene.cells.indexOf(scene.player) === -1 ? (scene.player === 1 ? qsTr("O primeiro Gato joga numa das quatro casas centrais.") : qsTr("O primeiro Cão joga fora das quatro casas centrais, sem tocar num Gato na horizontal ou na vertical.")) : qsTr("Coloca numa casa vazia, sem vizinhos da outra espécie na horizontal ou na vertical."))
                },
                Flow {
                    id: modeControls

                    width: parent.width

                    spacing: 6
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "tuxModeGatos"
                        text: scene.tux ? qsTr("Duas pessoas") : qsTr("Contra Tux")
                        onClicked: {
                            scene.tux = !scene.tux;
                            scene.reset();
                        }
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "difficultyGatos"
                        visible: scene.tux
                        text: [qsTr("Fácil: escolhe ao acaso"), qsTr("Médio: reserva casas"), qsTr("Difícil: examina até 12 respostas")][scene.difficulty]
                        onClicked: {
                            scene.difficulty = (scene.difficulty + 1) % 3;
                            scene.reset();
                        }
                    }
                    BoardGameButton {
                        focusPolicy: Qt.StrongFocus
                        objectName: "learnGatos"
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
            text: scene.phase === "intro" ? qsTr("Aprender Gatos & Cães") : scene.phase === "reviewDone" ? qsTr("Compara as aberturas") : scene.winner ? qsTr("Venceu o participante %1!").arg(scene.winner) : scene.tux ? (scene.player === 1 ? qsTr("Tu · Gatos · 1 G") : qsTr("Tux · Cães · 2 C")) : scene.player === 1 ? qsTr("Participante 1 · Gatos") : qsTr("Participante 2 · Cães")
        }
        Item {
            id: playArea
            parent: gameLayout.boardArea
            anchors.fill: parent

            Item {
                id: board
                objectName: "gatosCaesBoard"
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
                    else if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                        scene.choose(scene.cursor);
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
                        model: 64
                        Rectangle {
                            required property int index
                            objectName: "gatosCell" + index
                            width: board.width / 8
                            height: width
                            readonly property int owner: scene.cells[index]
                            readonly property bool allowed: scene.accepting && !scene.winner && Rules.legal(scene.cells, index, scene.player)
                            color: owner === 1 ? "#d7eafa" : owner === 2 ? "#f6dfbf" : scene.showLegal && allowed ? "#c3e5ae" : Rules.central(index) ? "#fff0d6" : "#ffffff"
                            border.color: scene.hintCell === index ? "#b00064" : board.activeFocus && scene.cursor === index ? "#111111" : "#647986"
                            border.width: scene.hintCell === index ? 5 : board.activeFocus && scene.cursor === index ? 4 : 1
                            Image {
                                anchors.centerIn: parent
                                width: parent.width * 0.72
                                height: parent.height * 0.72
                                source: parent.owner === 1 ? "qrc:/gcompris/src/activities/gatos_caes/cat.svg" : parent.owner === 2 ? "qrc:/gcompris/src/activities/gatos_caes/dog.svg" : ""
                                fillMode: Image.PreserveAspectFit
                            }
                            BoardGameText {
                                anchors {
                                    horizontalCenter: parent.horizontalCenter
                                    bottom: parent.bottom
                                    bottomMargin: 2
                                }
                                fontSize: Math.max(12, parent.width * 0.16)
                                text: parent.owner === 1 ? "1 G" : parent.owner === 2 ? "2 C" : scene.showLegal && parent.allowed ? "+" : ""
                                color: "#183c50"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: scene.choose(parent.index)
                            }
                            Accessible.role: Accessible.Button
                            Accessible.name: qsTr("Linha %1, coluna %2: %3").arg(Math.floor(index / 8) + 1).arg(index % 8 + 1).arg(owner === 1 ? qsTr("Gato, participante 1") : owner === 2 ? qsTr("Cão, participante 2") : qsTr("vazia"))
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
