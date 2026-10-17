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
        property bool tux: false
        property int difficulty: 0
        property int generation: 0
        property bool thinking: false
        property string phase: "match"
        property int hints: 0
        property var decision: null
        property var originalMove: null
        readonly property bool accepting: !thinking && phase !== "intro" && phase !== "exerciseDone" && phase !== "reviewDone"
        function lesson() {
            reset();
            phase = "intro";
            feedback = qsTr("Introdução: coloca uma seta numa casa vazia. A distância e a direção indicam a casa onde o adversário terá de jogar. Vence quem o deixa sem opção. Vamos prever um destino.");
        }
        function exercise() {
            reset();
            phase = "exercise";
            mandatory = 2;
            feedback = qsTr("Exercício didático, não uma partida: na casa ◎, escolhe distância 1 e direção para baixo. Prevê a chegada à linha 2, coluna 3, e confirma.");
        }
        function hint() {
            if (!accepting || winner)
                return;
            hints = Math.min(3, hints + 1);
            var options = phase === "exercise" ? [
                {
                    start: 2,
                    distance: 1,
                    direction: 2
                }
            ] : Rules.moves(cells, reserves[player - 1], mandatory);
            if (phase === "review")
                options = options.filter(move => move.start !== originalMove.start || move.distance !== originalMove.distance || move.direction !== originalMove.direction);
            if (!options.length)
                return;
            var move = options[0], end = Rules.destination(move.start, move.distance, move.direction);
            if (hints === 1)
                feedback = qsTr("Conta a distância exata. O destino tem de estar vazio; podes saltar casas ocupadas. Que opções deixas ao adversário?");
            else if (hints === 2)
                feedback = qsTr("Procura uma seta de distância %1 a partir da linha %2, coluna %3.").arg(move.distance).arg(Math.floor(move.start / 6) + 1).arg(move.start % 6 + 1);
            else {
                selected = move.start;
                cursor = move.start;
                distance = move.distance;
                direction = move.direction;
                feedback = qsTr("Observa a previsão: %1%2 chega à linha %3, coluna %4. A pista não confirma a jogada.").arg(arrows[direction]).arg(distance).arg(Math.floor(end / 6) + 1).arg(end % 6 + 1);
            }
        }
        function review() {
            if (!decision)
                return;
            generation++;
            thinking = false;
            phase = "review";
            winner = 0;
            hints = 0;
            cells = decision.cells.slice();
            reserves = [decision.reserves[0].slice(), decision.reserves[1].slice()];
            mandatory = decision.mandatory;
            player = 1;
            selected = -1;
            feedback = qsTr("Revisão da tua primeira decisão: colocaste %1%2 na linha %3, coluna %4. Experimenta outra seta e compara as opções que deixas a Tux.").arg(arrows[originalMove.direction]).arg(originalMove.distance).arg(Math.floor(originalMove.start / 6) + 1).arg(originalMove.start % 6 + 1);
        }
        WorkerScript {
            id: opponent
            source: "opponent.mjs"
            onMessage: message => {
                if (message.generation !== scene.generation || !scene.thinking)
                    return;
                scene.thinking = false;
                var move = message.move;
                if (scene.player === 2 && move && Rules.legal(scene.cells, scene.reserves[1], move.start, scene.mandatory, move.distance, move.direction)) {
                    scene.selected = move.start;
                    scene.distance = move.distance;
                    scene.direction = move.direction;
                    scene.confirm();
                }
            }
        }
        onStop: {
            generation++;
            thinking = false;
        }
        readonly property bool validSelection: accepting && !winner && Rules.legal(cells, reserves[player - 1], selected, mandatory, distance, direction)
        readonly property int endpoint: Rules.destination(selected, distance, direction)
        function reset() {
            generation++;
            thinking = false;
            hints = 0;
            phase = "match";
            decision = null;
            originalMove = null;
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
            if (winner || !accepting)
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
            var move = {
                start: selected,
                distance: distance,
                direction: direction
            };
            if (phase === "exercise" && (selected !== 2 || distance !== 1 || direction !== 2)) {
                feedback = qsTr("Essa seta é legal, mas este exercício pede distância 1 para baixo. Corrige a previsão.");
                return;
            }
            if (phase === "review") {
                if (move.start === originalMove.start && move.distance === originalMove.distance && move.direction === originalMove.direction) {
                    feedback = qsTr("Escolhe uma alternativa à seta original.");
                    return;
                }
                var original = Rules.place(decision.cells, decision.reserves, 1, originalMove);
                var alternative = Rules.place(cells, reserves, 1, move);
                var before = Rules.moves(original.cells, original.reserves[1], original.mandatory).length;
                var after = Rules.moves(alternative.cells, alternative.reserves[1], alternative.mandatory).length;
                cells = alternative.cells;
                reserves = alternative.reserves;
                mandatory = alternative.mandatory;
                selected = -1;
                phase = "reviewDone";
                feedback = qsTr("Revisão concluída: a seta original deixava %1 opções a Tux; esta deixa %2. Menos opções pode ajudar a bloquear, mas considera as reservas e os turnos seguintes.").arg(before).arg(after);
                return;
            }
            if (player === 1 && phase === "match" && !decision) {
                decision = {
                    cells: cells.slice(),
                    reserves: [reserves[0].slice(), reserves[1].slice()],
                    mandatory: mandatory
                };
                originalMove = move;
            }
            var next = Rules.place(cells, reserves, player, move);
            cells = next.cells;
            reserves = next.reserves;
            mandatory = next.mandatory;
            selected = -1;
            cursor = mandatory;
            hints = 0;
            if (phase === "exercise") {
                phase = "exerciseDone";
                feedback = qsTr("Correto! A seta fica na linha 1 e obriga a jogar na linha 2, coluna 3. Usa Nova partida para jogar com as regras CRJM completas.");
                return;
            }
            if (!Rules.hasMove(cells, reserves[2 - player], mandatory)) {
                winner = player;
                generation++;
                feedback = qsTr("O participante %1 ficou sem jogada válida.").arg(3 - player);
            } else {
                player = 3 - player;
                feedback = "";
            }
            if (tux && phase === "match" && !winner && player === 2) {
                thinking = true;
                feedback = qsTr("Tux está a pensar… Podes consultar a ajuda ou reiniciar.");
                opponent.sendMessage({
                    cells: cells,
                    reserves: reserves,
                    mandatory: mandatory,
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
            text: scene.phase === "intro" ? qsTr("Aprender Faísca") : scene.phase === "reviewDone" ? qsTr("Compara as duas decisões") : scene.winner ? qsTr("Venceu o participante %1!").arg(scene.winner) : scene.tux ? (scene.player === 1 ? qsTr("Tu · 1 ●") : qsTr("Tux · 2 ◆")) : qsTr("Participante %1 · %2").arg(scene.player).arg(scene.player === 1 ? "●" : "◆")
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
            height: 80
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            fontSize: 14
            color: "#183c50"
            wrapMode: Text.WordWrap
            text: scene.feedback || (scene.selected < 0 ? (scene.mandatory < 0 ? qsTr("Escolhe uma casa para começar, a distância e a direção.") : qsTr("Coloca a seta na casa obrigatória ◎, escolhe a distância e a direção.")) : scene.validSelection ? qsTr("Destino: linha %1, coluna %2. Confirma para colocar a seta.").arg(Math.floor(scene.endpoint / 6) + 1).arg(scene.endpoint % 6 + 1) : qsTr("Destino inválido ou distância sem reserva. Corrige a distância ou a direção."))
        }
        Flow {
            id: modes
            width: Math.min(parent.width - 16, 820)
            anchors {
                top: instruction.bottom
                horizontalCenter: parent.horizontalCenter
            }
            spacing: 4
            GCButton {
                focusPolicy: Qt.StrongFocus
                objectName: "tuxMode"
                text: scene.tux ? qsTr("Duas pessoas") : qsTr("Contra Tux")
                onClicked: {
                    scene.tux = !scene.tux;
                    scene.reset();
                }
            }
            GCButton {
                focusPolicy: Qt.StrongFocus
                objectName: "difficultyFaisca"
                visible: scene.tux
                text: [qsTr("Fácil: ao acaso"), qsTr("Médio: limita opções"), qsTr("Difícil: antecipa resposta")][scene.difficulty]
                onClicked: {
                    scene.difficulty = (scene.difficulty + 1) % 3;
                    scene.reset();
                }
            }
            GCButton {
                focusPolicy: Qt.StrongFocus
                objectName: "learnFaisca"
                text: qsTr("Aprender")
                onClicked: scene.lesson()
            }
        }
        Item {
            id: playArea
            anchors {
                top: modes.bottom
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
                        focusPolicy: Qt.StrongFocus
                        required property int index
                        objectName: "distance" + (index + 1)
                        text: (scene.distance === index + 1 ? "✓ " : "") + qsTr("Distância %1").arg(index + 1)
                        enabled: scene.accepting && !scene.winner
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
                        focusPolicy: Qt.StrongFocus
                        required property int index
                        objectName: "direction" + index
                        text: (scene.direction === index ? "✓ " : "") + [qsTr("↑ Cima"), qsTr("→ Direita"), qsTr("↓ Baixo"), qsTr("← Esquerda")][index]
                        enabled: scene.accepting && !scene.winner
                        onClicked: {
                            scene.direction = index;
                            scene.feedback = "";
                            board.forceActiveFocus();
                        }
                    }
                }
            }
        }
        Flow {
            id: controls
            width: Math.min(parent.width - 16, 800)
            anchors {
                bottom: bar.top
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 6
            }
            spacing: 6
            GCButton {
                focusPolicy: Qt.StrongFocus
                objectName: "lessonNext"
                visible: scene.phase === "intro"
                text: qsTr("Experimentar")
                onClicked: scene.exercise()
            }
            GCButton {
                focusPolicy: Qt.StrongFocus
                objectName: "hintFaisca"
                text: qsTr("Pista")
                enabled: scene.accepting && !scene.winner
                onClicked: scene.hint()
            }
            GCButton {
                focusPolicy: Qt.StrongFocus
                objectName: "reviewFaisca"
                visible: scene.winner > 0 && scene.phase === "match" && scene.decision !== null
                text: qsTr("Rever decisão")
                onClicked: scene.review()
            }
            GCButton {
                focusPolicy: Qt.StrongFocus
                objectName: "confirmFaisca"
                text: qsTr("Confirmar")
                enabled: scene.validSelection
                onClicked: scene.confirm()
            }
            GCButton {
                focusPolicy: Qt.StrongFocus
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
