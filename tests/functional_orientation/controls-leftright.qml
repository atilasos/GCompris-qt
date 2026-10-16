// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:"HandControls"
 when:activity.visible
 property var semantics:__SEMANTICS__
 property var evidence:({})
__VISIBLE__
 function test_controls(){
  wait(900);readyHand();var depth=pageView.depth;icon('bar_help.svg');tryCompare(pageView,'depth',depth+1,2000);wait(300);var help=pageView.currentItem;verify(help.content.indexOf('mão esquerda')>=0 && help.content.indexOf('mão direita')>=0);evidence.help={title:String(help.title),content:String(help.content)};grabImage(pageView).save('__QA_OUTPUT__/help.png');keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth,2000);wait(500);readyHand();
  var shown=hand(),side=semantics[shown.image].side;keyClick(side==='left'?Qt.Key_Left:Qt.Key_Right);tryCompare(score,'currentSubLevel',1,1000);tryCompare(score,'isWinAnimationPlaying',false,4500);wait(150);evidence.focusAfterHelp=true;evidence.extra={stimulus:shown,side:side};
  icon('bar_next.svg');compare(activity.currentLevel,1);compare(score.currentSubLevel,0);icon('bar_previous.svg');compare(activity.currentLevel,0);compare(score.currentSubLevel,0);readyHand();evidence.navigationReset=true;
  icon('bar_previous.svg');compare(activity.currentLevel,5);icon('bar_next.svg');compare(activity.currentLevel,0);evidence.wrap=true;
  evidence.reloadOffered=findReload();evidence.configurationOffered=false;
  ActivityInfoTree.startingActivity='';keyClick(Qt.Key_W,Qt.ControlModifier);tryCompare(pageView,'depth',1,2000);verify(pageView.currentItem.isMenu);evidence.menu=true;grabImage(pageView).save('__QA_OUTPUT__/menu.png');
 }
 function findReload(){return all(bar).some(child=>child.source!==undefined && String(child.source).endsWith('bar_reload.svg'));}
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_ORIENTATION_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
