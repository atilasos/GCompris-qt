// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:"MouseControlsAndReload"
 when:activity.visible
 property var evidence:({})
__VISIBLE__
 function test_controls(){
  wait(1000);var depth=pageView.depth;icon('bar_help.svg');tryCompare(pageView,'depth',depth+1,2000);wait(300);var help=pageView.currentItem;verify(help.content.indexOf('peixe')>=0 && help.content.indexOf('macaco')>=0);evidence.help={title:String(help.title),content:String(help.content)};grabImage(pageView).save('__QA_OUTPUT__/help.png');keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth,2000);wait(500);
  var before=animals().length,card=animals()[0],kind=String(animalImage(card).source).split('/').pop();click(card,kind==='fish.svg'?Qt.LeftButton:Qt.RightButton);tryCompare(card,'visible',false,1500);compare(animals().length,before-1);evidence.focusAfterHelp=true;evidence.partialAnimal=kind;
  icon('bar_reload.svg');compare(activity.currentLevel,0);compare(animals().length,5);evidence.partialReload=true;
  icon('bar_next.svg');compare(activity.currentLevel,1);compare(animals().length,7);icon('bar_previous.svg');compare(activity.currentLevel,0);compare(animals().length,5);evidence.navigationReset=true;
  icon('bar_previous.svg');compare(activity.currentLevel,2);compare(animals().length,10);icon('bar_next.svg');compare(activity.currentLevel,0);evidence.wrap=true;
  var counts=animals().length;keyClick(Qt.Key_Right);keyClick(Qt.Key_Left);keyClick(Qt.Key_Return);compare(animals().length,counts);evidence.unsupportedKeys=true;
  evidence.configurationOffered=all(bar).some(child=>child.source!==undefined && String(child.source).endsWith('bar_activity_config.svg'));
  ActivityInfoTree.startingActivity='';keyClick(Qt.Key_W,Qt.ControlModifier);tryCompare(pageView,'depth',1,2000);verify(pageView.currentItem.isMenu);evidence.menu=true;grabImage(pageView).save('__QA_OUTPUT__/menu.png');
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_ORIENTATION_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
