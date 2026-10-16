// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 when:activity.visible
 property var evidence:({})
__VISIBLE__
__SOLVER__
 function choices(){return all(dialogActivityConfig).filter(c=>c.indicatorImageHeight!==undefined&&c.checked!==undefined&&c.text!==undefined&&c.visible);}
 function save(){var button=texts(dialogActivityConfig).find(c=>c.visible&&String(c.text)==='Gravar');verify(button!==undefined);click(button);tryCompare(dialogActivityConfig,'visible',false,2000);wait(700);}
 function config(){icon('bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2000);wait(350);}
 function helpPT(word){var depth=pageView.depth;icon('bar_help.svg');tryCompare(pageView,'depth',depth+1,2000);wait(300);var help=pageView.currentItem;verify(help.content.indexOf(word)>=0);evidence.help={title:String(help.title),content:String(help.content)};grabImage(pageView).save('__QA_OUTPUT__/help.png');keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth,2000);wait(500);}
 function menu(){ActivityInfoTree.startingActivity='';keyClick(Qt.Key_W,Qt.ControlModifier);tryCompare(pageView,'depth',1,2000);verify(pageView.currentItem.isMenu);evidence.menu=true;grabImage(pageView).save('__QA_OUTPUT__/menu.png');}
 function mode(text){var combo=all(dialogActivityConfig).find(c=>c.currentText!==undefined&&c.label==='Selecionar o modo');verify(combo!==undefined);click(texts(combo).find(t=>String(t.text)===String(combo.currentText)));wait(250);var options=texts(dialogActivityConfig).filter(t=>t.visible&&String(t.text)===text);verify(options.length>=1);click(options[options.length-1]);wait(350);}
 function editorRow(){var row=all(dialogActivityConfig).find(c=>c.level===0&&c.refreshAllTiles!==undefined);verify(row!==undefined);return row;}
 function operatorBox(row,label){var text=texts(row).find(t=>String(t.text)===label);verify(text!==undefined);return text.parent;}
 function test_controls(){
  wait(1000);helpPT('Arrasta');var values=numbersCount().map(t=>Number(tileLabel(t)));var before=JSON.stringify(values);keyClick(Qt.Key_Right);keyClick(Qt.Key_Return);compare(JSON.stringify(numbersCount().map(t=>Number(tileLabel(t)))),before);evidence.unsupportedKeys=true;
  var numbers=numbersCount(),cells=dropCells(rowsCount()[0]);drag(numbers[0],cells.a);compare(numbers[0].parent,cells.a);evidence.focusAfterHelp=true;icon('bar_next.svg');compare(activity.currentLevel,1);compare(score.currentSubLevel,0);verify(rowsCount().every(r=>String(r.endResult.text)===''));icon('bar_previous.svg');compare(activity.currentLevel,0);evidence.navigationReset=true;
  config();var rows=choices();compare(rows.length,4);evidence.datasetLabels=rows.map(c=>String(c.text));click(rows[0]);save();compare(activity.numberOfLevel,13);config();rows=choices();verify(!rows[0].checked&&rows.slice(1).every(c=>c.checked));evidence.persistedSelection=true;click(rows[0]);save();compare(activity.numberOfLevel,17);
  config();mode('Gerir');var row=editorRow(),plus=operatorBox(row,'+'),minus=operatorBox(row,'-');compare(plus.state,'selected');click(plus);compare(plus.state,'selected');evidence.emptyOperatorsRefused=true;click(minus);compare(minus.state,'selected');save();compare(activity.numberOfLevel,8);compare(JSON.stringify(operatorsCount().slice().sort()),JSON.stringify(['+','-']));
  config();row=editorRow();compare(operatorBox(row,'+').state,'selected');compare(operatorBox(row,'-').state,'selected');evidence.persistedEditor=true;grabImage(pageView).save('__QA_OUTPUT__/editor.png');save();
  var created=[];for(var q=0;q<4;q++){var tilesNow=numbersCount(),v=tilesNow.map(t=>Number(tileLabel(t))),ops=operatorsCount(),target=Number(String(guess.text).match(/-?\d+/g).pop()),steps=chain(v,ops,target,false);verify(steps!==null);placeCount(steps,tilesNow);tryCompare(score,'currentSubLevel',q+1,1000);tryCompare(score,'isWinAnimationPlaying',false,4500);wait(150);created.push({values:v,target:target,operators:ops,steps:steps});}tryCompare(bonus,'isPlaying',true,1500);tryCompare(activity,'currentLevel',1,10000);evidence.editedPuzzles=created;
  config();row=editorRow();click(operatorBox(row,'-'));compare(operatorBox(row,'+').state,'selected');compare(operatorBox(row,'-').state,'notselected');mode('Incorporado');save();compare(activity.numberOfLevel,17);evidence.restoredEditor=true;
  icon('bar_previous.svg');compare(activity.currentLevel,0);icon('bar_previous.svg');compare(activity.currentLevel,16);icon('bar_next.svg');compare(activity.currentLevel,0);evidence.wrap=true;evidence.reloadOffered=all(bar).some(c=>c.source!==undefined&&String(c.source).endsWith('bar_reload.svg'));menu();
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_CHALLENGES_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
