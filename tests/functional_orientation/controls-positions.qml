// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:"PositionControlsAndDatasets"
 when:activity.visible
 property var evidence:({})
__VISIBLE__
 function choices(){return all(dialogActivityConfig).filter(child=>child.indicatorImageHeight!==undefined && child.checked!==undefined && child.text!==undefined && child.visible);}
 function save(){var button=all(dialogActivityConfig).find(child=>child.clicked!==undefined && child.text==='Gravar' && child.visible);verify(button!==undefined);click(button);tryCompare(dialogActivityConfig,'visible',false,2000);wait(600);}
 function test_controls(){
  wait(1000);compare(activity.numberOfLevel,4);var depth=pageView.depth;icon('bar_help.svg');tryCompare(pageView,'depth',depth+1,2000);wait(300);var help=pageView.currentItem;verify(help.content.indexOf('caixa')>=0 && help.content.indexOf('teclado')>=0);evidence.help={title:String(help.title),content:String(help.content)};grabImage(pageView).save('__QA_OUTPUT__/help.png');keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth,2000);wait(500);
  keyClick(Qt.Key_Right);verify(positionViews.currentItem!==null);evidence.focusAfterHelp=true;
  icon('bar_next.svg');compare(activity.currentLevel,1);compare(score.currentSubLevel,0);keyClick(Qt.Key_Right);verify(answerViews.currentItem!==null);icon('bar_previous.svg');compare(activity.currentLevel,0);compare(positionViews.currentItem,null);evidence.navigationReset=true;
  icon('bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2000);wait(350);var rows=choices();compare(rows.length,2);verify(rows[0].checked && rows[1].checked);evidence.datasetLabels=rows.map(row=>String(row.text));click(rows[0]);verify(!rows[0].checked);save();compare(activity.numberOfLevel,2);
  icon('bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2000);wait(350);rows=choices();compare(rows.length,2);verify(!rows[0].checked && rows[1].checked);evidence.persistedSelection=true;grabImage(pageView).save('__QA_OUTPUT__/selection.png');click(rows[0]);save();compare(activity.numberOfLevel,4);evidence.restoredSelection=true;
  icon('bar_previous.svg');compare(activity.currentLevel,3);icon('bar_next.svg');compare(activity.currentLevel,0);evidence.wrap=true;
  evidence.reloadOffered=all(bar).some(child=>child.source!==undefined && String(child.source).endsWith('bar_reload.svg'));
  ActivityInfoTree.startingActivity='';keyClick(Qt.Key_W,Qt.ControlModifier);tryCompare(pageView,'depth',1,2000);verify(pageView.currentItem.isMenu);evidence.menu=true;grabImage(pageView).save('__QA_OUTPUT__/menu.png');
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_ORIENTATION_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
