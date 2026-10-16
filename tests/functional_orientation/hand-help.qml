// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:"HandHelpDistinguishesScreenButtonsFromMouseButtons"
 when:activity.visible
 property var semantics:__SEMANTICS__
 property var evidence:({})
__VISIBLE__
 function test_manual(){
  wait(900);readyHand();var skipped=0;
  while(semantics[hand().image].side!=='right'){
   var scoreBefore=score.currentSubLevel;keyClick(Qt.Key_Left);tryCompare(score,'currentSubLevel',scoreBefore+1,1200);tryCompare(score,'isWinAnimationPlaying',false,4500);readyHand();verify(++skipped<4);
  }
  var before=score.currentSubLevel;click(rightButton,Qt.RightButton);compare(score.currentSubLevel,before);evidence.physicalRightIgnored=true;evidence.stimulus=hand();click(rightButton,Qt.LeftButton);tryCompare(score,'currentSubLevel',before+1,1200);tryCompare(score,'isWinAnimationPlaying',false,4500);wait(150);evidence.screenAnswerWorks=true;
  var depth=pageView.depth;icon('bar_help.svg');tryCompare(pageView,'depth',depth+1,2000);wait(350);var help=pageView.currentItem;evidence.help=String(help.content);grabImage(pageView).save('__QA_OUTPUT__/help.png');
  verify(help.content.indexOf('no ecrã')>=0 && help.content.indexOf('«Mão esquerda»')>=0 && help.content.indexOf('«Mão direita»')>=0,'PT manual names the two displayed answers rather than physical mouse buttons');
  keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth,2000);wait(450);ActivityInfoTree.startingActivity='';keyClick(Qt.Key_W,Qt.ControlModifier);tryCompare(pageView,'depth',1,2000);verify(pageView.currentItem.isMenu);evidence.menu=true;
 }
 function cleanupTestCase(){console.log('NATIVE_ORIENTATION_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
