import QtTest
/* GCompris - guesscount.qml
 *
 * SPDX-FileCopyrightText: 2016 RAHUL YADAV <rahulyadav170923@gmail.com>
 *
 * Authors:
 *   Pascal Georges <pascal.georges1@free.fr> (GTK+ version)
 *   RAHUL YADAV <rahulyadav170923@gmail.com> (Qt Quick port)
 *
 *   SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import core 1.0
import "../../core"
import "guesscount.js" as Activity
import "dataset.js" as Data

ActivityBase {
    id: activity

    onStart: focus = true
    onStop: {}
    property bool needRestart: true

     onActivityNextLevel: {
         Activity.nextLevel()
    }

    pageComponent: Image {
        id: activityBackground
        anchors.fill: parent
        source: Activity.baseUrl + "/backgroundW01.svg"
        signal start
        signal stop

        Component.onCompleted: {
            dialogActivityConfig.initialize()
            activity.start.connect(start)
            activity.stop.connect(stop)
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if(warningDialog.visible)
                    warningDialog.visible = false
            }
        }

        // Add here the QML items you need to access in javascript
        QtObject {
            id: items
            property Item main: activity.main
            property alias activityBackground: activityBackground
            property int currentLevel: activity.currentLevel
            onCurrentLevelChanged: activity.currentLevel = currentLevel
            property int numberOfLevel: 0
            onNumberOfLevelChanged: activity.numberOfLevel = numberOfLevel
            property alias bonus: bonus
            property alias score: score
            property alias operatorRow: operatorRow
            property alias operandRow: operandRow
            property var data
            readonly property var levels: activity.datasets
            property int result: 0
            property alias warningDialog: warningDialog
            property alias goodAnswerSound: goodAnswerSound
            property bool clearOperations: false
            property bool solved: false
            property var levelArr: Data.defaultOperators
            property string mode: "builtin"
            property int currentlevel
        }

        onStart: if (activity.needRestart) {
                     Activity.start(items);
                     activity.needRestart = false;
                 }
                 else
                     Activity.initLevel();
        onStop: { Activity.stop() }


        GCSoundEffect {
            id: goodAnswerSound
            source: "qrc:/gcompris/src/core/resource/sounds/completetask.wav"
        }

        JsonParser {
            id: parser
            onError: (msg) => console.error("Guesscount: Error parsing JSON: " + msg);
        }

        Loader {
            id: admin
            active: false
            sourceComponent: Column {
                spacing: GCStyle.baseMargins
                width: parent.width
                height: parent.height

                Repeater {
                    id:levels
                    model: 8
                    Admin {
                        id:level
                        level: modelData+1
                        width: parent.width
                        height: parent.height
                        data: items.data
                    }
                }
            }
        }

        Item {
            id: top
            z: 10
            height: score.height
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: GCStyle.baseMargins
            }
            Score {
                id: score
                anchors.left: parent.left
                anchors.right: undefined
                anchors.top: undefined
                anchors.bottom: undefined
                anchors.margins: 0
                anchors.verticalCenter: parent.verticalCenter
                radius: GCStyle.halfMargins
                currentSubLevel: 0
                onStop: Activity.nextSubLevel()

            }
            Rectangle {
                id: guessLabel
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.left: score.right
                anchors.leftMargin: GCStyle.baseMargins
                radius: GCStyle.halfMargins
                border.color: "orange"
                border.width: GCStyle.midBorder
                color: GCStyle.paperWhite
                GCText {
                    id: guess
                    anchors.centerIn: parent
                    width: parent.width - 2 * GCStyle.baseMargins
                    height: parent.height - GCStyle.baseMargins
                    fontSizeMode: Text.Fit
                    minimumPointSize: 7
                    fontSize: mediumSize
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("Guesscount: %1").arg(items.result)
                }
            }
        }

        Column {
            id: col
            spacing: GCStyle.halfMargins
            anchors.top: top.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: GCStyle.baseMargins
            anchors.bottomMargin: bar.height * 1.2
            OperatorRow {
                id: operatorRow
                width: parent.width
                height: Math.min(GCStyle.bigButtonHeight,
                                 parent.height / 6 - GCStyle.halfMargins)
                mode: items.mode
            }
            OperandRow {
                id: operandRow
                width: parent.width
                height: operatorRow.height
            }
            Repeater {
                id: repeat
                model: operatorRow.repeater.model.length
                delegate: OperationRow {
                    id: operationRow
                    width: col.width
                    height: operatorRow.height
                    property alias operationRow: operationRow
                    noOfRows: operatorRow.repeater.model.length
                    rowNo: modelData
                    guesscount: items.result
                    prevText: ""
                    prevComplete: prevText != "" ? true : false
                    reparent: items.clearOperations
                    onTextChanged: {
                        if(index + 1 < repeat.count) {
                            repeat.itemAt(index + 1).prevText = text
                        }
                    }
                }
            }
        }

        DialogHelp {
            id: dialogHelp
            onClose: home()
        }

        DialogChooseLevel {
            id: dialogActivityConfig
            currentActivity: activity.activityInfo
            onSaveData: {
                levelFolder = dialogActivityConfig.chosenLevels
                currentActivity.currentLevels = dialogActivityConfig.chosenLevels
                activity.needRestart = true
            }
            onClose: {
                if(Activity.configDone(items.levelArr)){
                    Activity.initLevel()
                    home()
                }
            }
            onLoadData: {
                if(activityData && activityData["mode"]) {
                    items.mode = activityData["mode"]
                    if(activityData["levelArr"] === undefined) {
                        items.levelArr = activityData["levelArr"]

                    }
                    if(activityData["levelArr"]) {
                        items.levelArr = activityData["levelArr"]
                    }
                }
                else {
                    items.mode = "builtin"
                    items.levelArr = Activity.defaultOperators
                }
            }
            onStartActivity: {
                activityBackground.stop()
                activityBackground.start()
            }
        }

        Bar {
            id: bar
            level: items.currentLevel + 1
            content: BarEnumContent { value: help | home | level | activityConfig }
            onHelpClicked: {
                displayDialog(dialogHelp)
            }
            onPreviousLevelClicked: {
                Activity.previousLevel()
            }
            onNextLevelClicked: {
                Activity.nextLevel()
            }
            onActivityConfigClicked: {
                displayDialog(dialogActivityConfig)
            }
            onHomeClicked: activity.home()
        }

        Bonus {
            id: bonus
            Component.onCompleted: win.connect(activity.nextLevel)
        }

        Rectangle {
            id: warningDialog
            width: Math.min(300 * ApplicationInfo.ratio, col.width)
            height: GCStyle.bigButtonHeight
            visible: false
            color: GCStyle.darkBg
            radius: GCStyle.halfMargins
            border.color: GCStyle.whiteBorder
            border.width: GCStyle.midBorder
            property alias dialogText: dialogText
            anchors.centerIn: col
            GCText {
                id: dialogText
                anchors.centerIn: parent
                fontSize: regularSize
                fontSizeMode: Text.Fit
                color: GCStyle.whiteText
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                width: parent.width - GCStyle.baseMargins * 2
                height: parent.height - GCStyle.baseMargins * 2
                wrapMode: TextEdit.WordWrap
            }
            states: [
                State {
                    when: warningDialog.visible
                    PropertyChanges {
                        top {
                            opacity: 0.5
                        }
                    }
                    PropertyChanges {
                        col {
                            opacity: 0.5
                        }
                    }
                },
                State {
                    when: !warningDialog.visible
                    PropertyChanges {
                        top {
                            opacity: 1
                        }
                    }
                    PropertyChanges {
                        col {
                            opacity: 1
                        }
                    }
                }
            ]
        }
// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 function checkEqual(actual,expected,message){if(actual!==expected)console.log('COMPARE_FAILED',actual,expected,message);compare(actual,expected,message);}
 function checkTrue(value,message){if(!value)console.log('ASSERT_FAILED',message);verify(value,message);}

 when:activity.visible
 property var evidence:({})
 function all(root){var result=[root];if(root.children)for(var child of root.children)result=result.concat(all(child));return result;}
 function texts(root){return all(root).filter(child=>child.text!==undefined && child.width>0 && child.height>0);}
 function click(item){var p=item.mapToItem(pageView,item.width/2,item.height/2);checkTrue(p.x>=0&&p.y>=0&&p.x<pageView.width&&p.y<pageView.height,'Real click center inside viewport');mouseClick(item,item.width/2,item.height/2,Qt.LeftButton,Qt.NoModifier,10);wait(25);}
 function drag(source,target){var a=source.mapToItem(pageView,source.width/2,source.height/2),b=target.mapToItem(pageView,target.width/2,target.height/2);checkTrue(a.x>=0&&a.y>=0&&a.x<pageView.width&&a.y<pageView.height&&b.x>=0&&b.y>=0&&b.x<pageView.width&&b.y<pageView.height,'Real drag endpoints inside viewport');mousePress(pageView,a.x,a.y,Qt.LeftButton,Qt.NoModifier,10);for(var i=1;i<=8;i++)mouseMove(pageView,a.x+(b.x-a.x)*i/8,a.y+(b.y-a.y)*i/8,10);wait(80);var painted=source.tile.mapToItem(pageView,source.tile.width/2,source.tile.height/2);mouseMove(pageView,b.x+(b.x-painted.x),b.y+(b.y-painted.y),20);wait(80);mouseRelease(pageView,b.x,b.y,Qt.LeftButton,Qt.NoModifier,10);wait(80);}
 function icon(suffix){wait(400);var item=all(bar).find(child=>child.source!==undefined&&String(child.source).endsWith(suffix));checkTrue(item!==undefined,suffix);click(item);wait(350);}
 function cards24(){return cardsBoard.contentItem.children.filter(child=>child.width>0&&child.height>0&&texts(child).length===1).sort((a,b)=>a.y===b.y?a.x-b.x:a.y-b.y);}
 function value24(card){return Number(texts(card)[0].text);}
 function ops24(){return texts(operators).filter(text=>text.visible).map(text=>String(text.text).replace('−','-').replace('×','*').replace('÷','/'));}
 function operation24(step,keyboard,cards){
  checkTrue(cards[step.a].visible && cards[step.b].visible);checkEqual(value24(cards[step.a]),step.left);checkEqual(value24(cards[step.b]),step.right);click(cards[step.a]);
  if(keyboard){keyClick({'+':Qt.Key_Plus,'-':Qt.Key_Minus,'*':Qt.Key_Asterisk,'/':Qt.Key_Slash}[step.op]);var n=0;while(cardsBoard.currentItem!==cards[step.b]){keyClick(Qt.Key_Right);checkTrue(++n<=4);}keyClick(Qt.Key_Return);}
  else {var symbol={'+':'+','-':'−','*':'×','/':'÷'}[step.op],label=texts(operators).find(t=>t.visible&&String(t.text)===symbol);checkTrue(label!==undefined);click(label);click(cards[step.b]);}
  tryCompare(animationCard,'visible',false,6000);wait(60);
 }
 function undo24(cards,allSteps){var guard=0;while(cards.filter(card=>card.visible).length<4){checkTrue(cancelButton.visible);click(cancelButton);tryCompare(animationCard,'visible',false,6000);wait(70);checkTrue(++guard<=4);}checkEqual(cards.filter(c=>c.visible).length,4);}
 function tiles(root){return all(root).filter(child=>child.tile!==undefined&&child.acceptedButtons!==undefined&&child.width>0&&child.height>0);}
 function tileLabel(tile){var labels=texts(tile.tile);checkEqual(labels.length,1);return String(labels[0].text);}
 function rowsCount(){return col.children.filter(child=>child.endResult!==undefined && child.width>0);}
 function dropCells(row){var cells=row.children.filter(child=>child.type!==undefined);var loader=row.children.find(child=>child.item!==undefined);return {a:loader.item,op:cells.find(c=>c.type==='operators'),b:cells.find(c=>c.type==='operands')};}
 function numbersCount(){return tiles(operandRow).sort((a,b)=>a.mapToItem(operandRow,0,0).x-b.mapToItem(operandRow,0,0).x);}
 function operatorsCount(){return tiles(operatorRow).map(tile=>tileLabel(tile));}
 function placeCount(plan,numbers){
  var rows=rowsCount();checkEqual(rows.length,plan.length);var moves=[];
  for(var i=0;i<plan.length;i++){
   var step=plan[i],cells=dropCells(rows[i]);
   if(i===0){moves.push({tile:numbers[step.a],home:numbers[step.a].parent});drag(numbers[step.a],cells.a);checkEqual(numbers[step.a].parent,cells.a);}
   var operator=tiles(operatorRow).find(tile=>tileLabel(tile)===step.op);checkTrue(operator!==undefined);moves.push({tile:operator,home:operator.parent});drag(operator,cells.op);checkEqual(operator.parent,cells.op);
   moves.push({tile:numbers[step.b],home:numbers[step.b].parent});drag(numbers[step.b],cells.b);checkEqual(numbers[step.b].parent,cells.b);
   if(!warningDialog.visible)checkEqual(String(rows[i].endResult.text),String(step.result),'Painted row arithmetic');
  }
  return moves;
 }
 function clearCount(moves){if(warningDialog.visible){click(warningDialog);tryCompare(warningDialog,'visible',false,1500);}for(var i=moves.length-1;i>=0;i--){var move=moves[i];if(move.tile!==null&&move.tile.parent!==move.home)drag(move.tile,move.home);}wait(80);for(var row of rowsCount())checkEqual(String(row.endResult.text),'');}

 function rational(a,op,b){var n,d;if(op==='+'){n=a+b;d=1;}else if(op==='-'){n=a-b;d=1;}else if(op==='*'){n=a*b;d=1;}else {if(b===0)return null;n=a;d=b;}var x=Math.abs(n),y=Math.abs(d);while(y){var t=x%y;x=y;y=t;}if(d<0){n=-n;d=-d;}return {n:n/(x||1),d:d/(x||1)};}
 function combine(values,ops,target,avoid){
  var failed=({});
  function search(state){
   if(state.length===1)return (avoid?state[0].value!==target:state[0].value===target)?[]:null;
   var key=state.map(v=>v.value).sort((a,b)=>a-b).join(',');if(failed[key])return null;
   for(var i=0;i<state.length;i++)for(var j=0;j<state.length;j++)if(i!==j)for(var op of ops){
    if((op==='+'||op==='*') && i>j)continue;
    var a=state[i],b=state[j],result=rational(a.value,op,b.value);if(result===null || result.d!==1 || result.n<0)continue;
    var rest=state.filter((v,k)=>k!==i&&k!==j);rest.push({value:result.n,slot:b.slot});var tail=search(rest);
    if(tail!==null)return [{a:a.slot,b:b.slot,op:op,left:a.value,right:b.value,result:result.n}].concat(tail);
   }
   failed[key]=true;return null;
  }
  return search(values.map((v,i)=>({value:v,slot:i})));
 }
 function chain(values,ops,target,avoid){
  function search(acc,remaining,depth){
   if(depth===0)return (avoid?acc!==target:acc===target)?[]:null;
   for(var op of ops)for(var index of remaining){
    var value=rational(acc,op,values[index]);if(value===null || value.d!==1 || value.n<0)continue;
    var tail=search(value.n,remaining.filter(i=>i!==index),depth-1);
    if(tail!==null)return [{b:index,op:op,left:acc,right:values[index],result:value.n}].concat(tail);
   }
   return null;
  }
  for(var i=0;i<values.length;i++){var result=search(values[i],values.map((v,k)=>k).filter(k=>k!==i),ops.length);if(result!==null){result[0].a=i;return result;}}
  return null;
 }

 function choices(){return all(dialogActivityConfig).filter(c=>c.indicatorImageHeight!==undefined&&c.checked!==undefined&&c.text!==undefined&&c.visible);}
 function save(){var button=texts(dialogActivityConfig).find(c=>c.visible&&String(c.text)==='Gravar');checkTrue(button!==undefined);click(button);tryCompare(dialogActivityConfig,'visible',false,2000);wait(700);}
 function config(){icon('bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2000);wait(350);}
 function helpPT(word){var depth=pageView.depth;icon('bar_help.svg');tryCompare(pageView,'depth',depth+1,2000);wait(300);var help=pageView.currentItem;checkTrue(help.content.indexOf(word)>=0);evidence.help={title:String(help.title),content:String(help.content)};grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-arithmetic-challenges/.scratch/pt-pt/functional-challenges/native/controls-count-complete/help.png');keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth,2000);wait(500);}
 function menu(){ActivityInfoTree.startingActivity='';keyClick(Qt.Key_W,Qt.ControlModifier);tryCompare(pageView,'depth',1,2000);checkTrue(pageView.currentItem.isMenu);evidence.menu=true;grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-arithmetic-challenges/.scratch/pt-pt/functional-challenges/native/controls-count-complete/menu.png');}
 function mode(text){var combo=all(dialogActivityConfig).find(c=>c.currentText!==undefined&&c.label==='Selecionar o modo');checkTrue(combo!==undefined);click(texts(combo).find(t=>String(t.text)===String(combo.currentText)));wait(250);var options=texts(dialogActivityConfig).filter(t=>t.visible&&String(t.text)===text);checkTrue(options.length>=1);click(options[options.length-1]);wait(350);}
 function datasetsTab(){var button=texts(dialogActivityConfig).find(t=>t.visible&&String(t.text)==='Conjunto de dados');checkTrue(button!==undefined);click(button);wait(300);}
 function editorRow(){var row=all(dialogActivityConfig).find(c=>c.level===0&&c.refreshAllTiles!==undefined);checkTrue(row!==undefined);return row;}
 function operatorBox(row,label){var text=texts(row).find(t=>String(t.text)===label);checkTrue(text!==undefined);return text.parent;}
 function test_controls(){
  wait(1000);helpPT('Arrasta');var values=numbersCount().map(t=>Number(tileLabel(t)));var before=JSON.stringify(values);keyClick(Qt.Key_Right);keyClick(Qt.Key_Return);checkEqual(JSON.stringify(numbersCount().map(t=>Number(tileLabel(t)))),before);evidence.unsupportedKeys=true;
  var numbers=numbersCount(),cells=dropCells(rowsCount()[0]);drag(numbers[0],cells.a);checkEqual(numbers[0].parent,cells.a);evidence.focusAfterHelp=true;icon('bar_next.svg');checkEqual(activity.currentLevel,1);checkEqual(score.currentSubLevel,0);checkTrue(rowsCount().every(r=>String(r.endResult.text)===''));icon('bar_previous.svg');checkEqual(activity.currentLevel,0);evidence.navigationReset=true;
  config();datasetsTab();var rows=choices();checkEqual(rows.length,4);evidence.datasetLabels=rows.map(c=>String(c.text));click(rows[0]);save();checkEqual(activity.numberOfLevel,13);config();datasetsTab();rows=choices();checkTrue(!rows[0].checked&&rows.slice(1).every(c=>c.checked));evidence.persistedSelection=true;click(rows[0]);save();checkEqual(activity.numberOfLevel,17);
  config();mode('Gerir');var row=editorRow(),plus=operatorBox(row,'+'),minus=operatorBox(row,'-');checkEqual(plus.state,'selected');click(plus);checkEqual(plus.state,'selected');evidence.emptyOperatorsRefused=true;click(minus);checkEqual(minus.state,'selected');save();checkEqual(activity.numberOfLevel,8);checkEqual(JSON.stringify(operatorsCount().slice().sort()),JSON.stringify(['+','-']));
  config();row=editorRow();checkEqual(operatorBox(row,'+').state,'selected');checkEqual(operatorBox(row,'-').state,'selected');evidence.persistedEditor=true;grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-arithmetic-challenges/.scratch/pt-pt/functional-challenges/native/controls-count-complete/editor.png');save();
  var created=[];for(var q=0;q<4;q++){var tilesNow=numbersCount(),v=tilesNow.map(t=>Number(tileLabel(t))),ops=operatorsCount(),target=Number(String(guess.text).match(/-?\d+/g).pop()),steps=chain(v,ops,target,false);checkTrue(steps!==null);placeCount(steps,tilesNow);tryCompare(score,'currentSubLevel',q+1,1000);tryCompare(score,'isWinAnimationPlaying',false,4500);wait(150);created.push({values:v,target:target,operators:ops,steps:steps});}tryCompare(bonus,'isPlaying',true,1500);tryCompare(activity,'currentLevel',1,10000);evidence.editedPuzzles=created;
  config();row=editorRow();click(operatorBox(row,'-'));checkEqual(operatorBox(row,'+').state,'selected');checkEqual(operatorBox(row,'-').state,'notselected');mode('Incorporado');save();checkEqual(activity.numberOfLevel,17);evidence.restoredEditor=true;
  checkEqual(activity.currentLevel,0);icon('bar_previous.svg');checkEqual(activity.currentLevel,16);icon('bar_next.svg');checkEqual(activity.currentLevel,0);evidence.wrap=true;evidence.reloadOffered=all(bar).some(c=>c.source!==undefined&&String(c.source).endsWith('bar_reload.svg'));menu();
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-arithmetic-challenges/.scratch/pt-pt/functional-challenges/native/controls-count-complete/failure.png');console.log('NATIVE_CHALLENGES_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}

    }
}
