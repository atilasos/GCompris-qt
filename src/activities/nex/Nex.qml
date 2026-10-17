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
        color: "#edf4eb"
        signal start
        signal stop
        property var cells: Rules.emptyBoard()
        property var pending: []
        property var colors: [1,2]
        property int player: 1
        property int mode: 0
        property int turn: 0
        property int winner: 0
        property int cursor: 0
        property bool swapped: false
        property bool enlarged: false
        property bool exercise: false
        property string feedback: ""
        readonly property int own: colors[player-1]
        readonly property bool swapAllowed: turn===1 && player===2 && !swapped && !winner && !exercise
        function reset() {
            cells=Rules.emptyBoard(); pending=[]; colors=[1,2]; player=1; mode=0; turn=0; winner=0;
            cursor=0;swapped=false;exercise=false;feedback="";viewport.contentX=0;viewport.contentY=0;board.forceActiveFocus();
        }
        function choose(i) {
            if(winner || exercise || i<0 || i>=121) return;
            cursor=i;
            var next=pending.slice(), at=next.indexOf(i);
            if(at>=0) { next.splice(at,1); pending=next;feedback="";return; }
            var expected=mode===0?0:(next.length<2?3:own);
            if(next.length >= (mode===0?2:3) || cells[i]!==expected) {
                feedback=qsTr("Seleção inválida. Revê a ordem e a cor das peças.");return;
            }
            next.push(i);pending=next;feedback="";board.forceActiveFocus();
        }
        function preview(i) {
            var at=pending.indexOf(i);
            return at<0?cells[i]:(mode===0?(at===0?own:3):(at===2?3:own));
        }
        function finishRare() {
            var result=Rules.rare(cells,own);
            if(!result) return;
            cells=result.board;pending=[];swapped=true;
            winner=result.winner===3?3:(colors[0]===result.winner?1:2);
            feedback=qsTr("Convenção das últimas casas aplicada. O resultado é calculado pelas conexões.");
        }
        function confirm() {
            if(winner || exercise) return;
            var result=Rules.apply(cells,own,mode,pending);
            if(!result) { feedback=qsTr("Completa uma ação válida antes de confirmar.");return; }
            cells=result;pending=[];feedback="";++turn;
            if(Rules.connected(cells,own)) {winner=player;feedback=qsTr("Ligaste as duas margens com uma cadeia da tua cor!");}
            else { player=3-player;finishRare(); }
            board.forceActiveFocus();
        }
        function swap() {
            if(!swapAllowed) return;
            colors=[colors[1],colors[0]];swapped=true;player=1;pending=[];++turn;
            feedback=qsTr("Cores e margens trocadas. Agora joga o participante 1.");board.forceActiveFocus();
        }
        function prepareFinal(kind) {
            reset();exercise=true;
            var next=[];
            for(var i=0;i<121;++i) next.push(i%11===5?2:1);
            next[60]=kind===1?3:0;
            if(kind===2) next[59]=3;
            cells=next;
            feedback=kind===0?qsTr("Exercício: resta uma casa vazia e nenhuma neutra. Ocupa-a com a cor de quem joga."):kind===1?qsTr("Exercício: resta uma neutra e nenhuma vazia. Converte-a na cor de quem joga."):qsTr("Exercício: resta uma vazia e uma neutra. A vazia recebe a tua cor e a neutra a do adversário.");
        }
        Component.onCompleted: { activity.start.connect(start);activity.stop.connect(stop); }
        onStart: reset()
        GCText {
            id: title
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: 5 }
            width: parent.width-8
            horizontalAlignment: Text.AlignHCenter
            fontSize: 21
            font.bold: true
            color: "#183c50"
            text: scene.winner===3?qsTr("Empate!"):scene.winner?qsTr("Venceu o participante %1!").arg(scene.winner):qsTr("Participante %1 · %2").arg(scene.player).arg(scene.own===1?qsTr("● Negras · N ↔ S"):qsTr("◇ Brancas · O ↔ E"))
        }
        GCText {
            id: ownership
            anchors { top: title.bottom; horizontalCenter: parent.horizontalCenter }
            width: parent.width-10
            horizontalAlignment: Text.AlignHCenter
            fontSize: 13
            color: "#183c50"
            text: qsTr("P1: %1 · P2: %2 · Neutras: +").arg(scene.colors[0]===1?qsTr("● N ↔ S"):qsTr("◇ O ↔ E")).arg(scene.colors[1]===1?qsTr("● N ↔ S"):qsTr("◇ O ↔ E"))
        }
        GCText {
            id: instruction
            anchors { top: ownership.bottom; horizontalCenter: parent.horizontalCenter }
            width: parent.width-12;height:60
            fontSize:13;wrapMode:Text.WordWrap;horizontalAlignment:Text.AlignHCenter;verticalAlignment:Text.AlignVCenter;color:"#183c50"
            text:scene.feedback || (scene.mode===0?qsTr("Colocar: escolhe duas vazias, primeiro a tua peça, depois +. Seleção: %1/2. Desliza para ver todo o tabuleiro."):qsTr("Substituir: escolhe duas +, depois uma tua. Seleção: %1/3. Desliza para ver todo o tabuleiro.")).arg(scene.pending.length)
        }
        Flickable {
            id: viewport
            objectName:"nexViewport"
            anchors { top:instruction.bottom;bottom:modeRow.top;left:parent.left;right:parent.right;margins:4 }
            QQC2.ScrollBar.vertical: QQC2.ScrollBar { policy:QQC2.ScrollBar.AsNeeded }
            QQC2.ScrollBar.horizontal: QQC2.ScrollBar { policy:QQC2.ScrollBar.AsNeeded }
            clip:true
            contentWidth:board.width;contentHeight:board.height
            boundsBehavior:Flickable.StopAtBounds
            Item {
                id: board
                objectName:"nexBoard"
                width:Math.max(viewport.width,scene.enlarged?1400:1000)
                height:Math.max(viewport.height,scene.enlarged?900:610)
                readonly property real unit:Math.min((width-28)/21,(height-34)/11.5)
                focus:true;activeFocusOnTab:true
                Keys.onPressed:event=>{
                    if(event.key===Qt.Key_Left)scene.cursor=Math.max(0,scene.cursor-11);
                    else if(event.key===Qt.Key_Right)scene.cursor=Math.min(120,scene.cursor+11);
                    else if(event.key===Qt.Key_Up)scene.cursor=Math.max(0,scene.cursor-1);
                    else if(event.key===Qt.Key_Down)scene.cursor=Math.min(120,scene.cursor+1);
                    else if(event.key===Qt.Key_Space)scene.choose(scene.cursor);
                    else if(event.key===Qt.Key_Return||event.key===Qt.Key_Enter)scene.confirm();
                    else {event.accepted=false;return;}
                    event.accepted=true;
                    var cellX=(Math.floor(scene.cursor/11)+scene.cursor%11)*board.unit+14;
                    var cellY=(scene.cursor%11-Math.floor(scene.cursor/11)+10)*board.unit*0.5+17;
                    viewport.contentX=Math.max(0,Math.min(board.width-viewport.width,cellX-viewport.width/2));
                    viewport.contentY=Math.max(0,Math.min(board.height-viewport.height,cellY-viewport.height/2));
                }
                Canvas {
                    id: marginsCanvas
                    anchors.fill:parent
                    onPaint: {
                        var ctx=getContext("2d"),u=board.unit;
                        ctx.reset();ctx.lineWidth=5;
                        function edge(x1,y1,x2,y2,color) {ctx.strokeStyle=color;ctx.beginPath();ctx.moveTo(x1*u+20,y1*u+20);ctx.lineTo(x2*u+20,y2*u+20);ctx.stroke();}
                        edge(0,5,10,0,"#22333b");edge(10,10.8,20.8,5.4,"#22333b");
                        edge(0,5.8,10,10.8,"#597eb9");edge(10.8,0,20.8,5,"#597eb9");
                    }
                    Connections {target:board;function onUnitChanged(){marginsCanvas.requestPaint();}}
                }
                Repeater {
                    model:121
                    Rectangle {
                        required property int index
                        objectName:"nexCell"+index
                        readonly property int stone:scene.preview(index)
                        readonly property bool selected:scene.pending.indexOf(index)>=0
                        x:(Math.floor(index/11)+index%11)*board.unit+14
                        y:(index%11-Math.floor(index/11)+10)*board.unit*0.5+17
                        width:board.unit*0.95;height:board.unit*0.95
                        radius:height/2
                        color:stone===1?"#22333b":stone===2?"white":stone===3?"#e9be57":"#d4e2c8"
                        border.color:selected?"#b00064":board.activeFocus&&scene.cursor===index?"#125ca5":"#52655c"
                        border.width:selected||board.activeFocus&&scene.cursor===index?4:1
                        opacity:selected?0.65:1
                        GCText { anchors.centerIn:parent;fontSize:14;color:parent.stone===1?"white":"#22333b";text:parent.stone===1?"●":parent.stone===2?"◇":parent.stone===3?"+":"" }
                        MouseArea { anchors.fill:parent;onClicked:scene.choose(parent.index) }
                        TapHandler { acceptedDevices:PointerDevice.TouchScreen|PointerDevice.TouchPad;onTapped:scene.choose(parent.index) }
                    }
                }
                Repeater {
                    model:[{s:"● N",x:5,y:2},{s:"◇ E",x:16,y:2},{s:"● S",x:16,y:8.5},{s:"◇ O",x:5,y:8.5}]
                    GCText { required property var modelData;text:modelData.s;color:"#183c50";fontSize:12;x:modelData.x*board.unit+10;y:modelData.y*board.unit }
                }
            }
        }
        Row {
            id:modeRow
            anchors { bottom:actions.top;horizontalCenter:parent.horizontalCenter;bottomMargin:4 }
            spacing:5
            GCButton { objectName:"placeNex";focusPolicy:Qt.StrongFocus;text:qsTr("Colocar");enabled:!scene.winner&&!scene.exercise;onClicked:{scene.mode=0;scene.pending=[];scene.feedback="";} }
            GCButton { objectName:"replaceNex";focusPolicy:Qt.StrongFocus;text:qsTr("Substituir");enabled:!scene.winner&&!scene.exercise;onClicked:{scene.mode=1;scene.pending=[];scene.feedback="";} }
            GCButton { objectName:"swapNex";focusPolicy:Qt.StrongFocus;text:qsTr("Trocar");enabled:scene.swapAllowed;onClicked:scene.swap() }
            GCButton { objectName:"zoomNex";focusPolicy:Qt.StrongFocus;text:scene.enlarged?qsTr("Reduzir"):qsTr("Ampliar");onClicked:scene.enlarged=!scene.enlarged }
        }
        Row {
            id:actions
            anchors { bottom:exercises.top;horizontalCenter:parent.horizontalCenter;bottomMargin:4 }
            spacing:5
            GCButton { objectName:"confirmNex";focusPolicy:Qt.StrongFocus;text:qsTr("Confirmar");enabled:!scene.winner&&!scene.exercise&&scene.pending.length===(scene.mode===0?2:3);onClicked:scene.confirm() }
            GCButton { objectName:"clearNex";focusPolicy:Qt.StrongFocus;text:qsTr("Limpar");enabled:!scene.winner&&scene.pending.length>0;onClicked:{scene.pending=[];scene.feedback="";board.forceActiveFocus();} }
            GCButton { objectName:"restartNex";focusPolicy:Qt.StrongFocus;text:qsTr("Nova partida");onClicked:scene.reset() }
        }
        Row {
            id:exercises
            anchors { bottom:bar.top;horizontalCenter:parent.horizontalCenter;bottomMargin:4 }
            spacing:4
            Repeater {
                model:3
                GCButton { required property int index;objectName:"finalNex"+index;focusPolicy:Qt.StrongFocus;text:qsTr("Final %1").arg(index+1);onClicked:scene.prepareFinal(index) }
            }
            GCButton { objectName:"resolveNex";focusPolicy:Qt.StrongFocus;text:qsTr("Aplicar regra");enabled:scene.exercise&&!scene.winner;onClicked:scene.finishRare() }
        }
        DialogHelp { id:dialogHelp;onClose:home() }
        Bar {
            id:bar
            content:BarEnumContent { value:help|home|reload }
            onHelpClicked:activity.displayDialog(dialogHelp)
            onHomeClicked:activity.home()
            onReloadClicked:scene.reset()
        }
    }
}
