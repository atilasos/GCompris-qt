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
 function test_controls(){
  wait(1000);helpPT('24');var cards=cards24(),values=cards.map(value24),ops=ops24(),steps=combine(values,ops,24,false);verify(steps!==null);operation24(steps[0],true,cards);compare(cards.filter(c=>c.visible).length,3);keyClick(Qt.Key_Delete);tryVerify(()=>cards.filter(c=>c.visible).length===4,3000);compare(JSON.stringify(cards.map(value24)),JSON.stringify(values));evidence.focusAfterHelp=true;evidence.undoDelete=true;
  click(cards[0]);keyClick(Qt.Key_Tab);keyClick(Qt.Key_Right);keyClick(Qt.Key_Return);evidence.tabOperatorSelection=true;icon('bar_next.svg');compare(activity.currentLevel,1);compare(score.currentSubLevel,0);compare(cards24().filter(c=>c.visible).length,4);icon('bar_previous.svg');compare(activity.currentLevel,0);evidence.navigationReset=true;
  config();var rows=choices();compare(rows.length,6);verify(rows.every(c=>c.checked));evidence.datasetLabels=rows.map(c=>String(c.text));click(rows[0]);save();compare(activity.numberOfLevel,5);
  config();rows=choices();verify(!rows[0].checked&&rows.slice(1).every(c=>c.checked));evidence.persistedSelection=true;grabImage(pageView).save('__QA_OUTPUT__/selection.png');click(rows[0]);save();compare(activity.numberOfLevel,6);evidence.restoredSelection=true;
  icon('bar_previous.svg');compare(activity.currentLevel,5);icon('bar_next.svg');compare(activity.currentLevel,0);evidence.wrap=true;evidence.reloadOffered=all(bar).some(c=>c.source!==undefined&&String(c.source).endsWith('bar_reload.svg'));menu();
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_CHALLENGES_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
