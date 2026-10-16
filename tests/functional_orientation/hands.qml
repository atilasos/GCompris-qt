// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 id:campaign
 name:"AnatomicalHandsAndRotations"
 when:activity.visible
 property var semantics:__SEMANTICS__
 property var completed:[]
 property int wins:0
 Connections {target:bonus;function onWin(){campaign.wins++;}}
__VISIBLE__
 function test_all_hands(){
  wait(900);compare(leftButton.textLabel,'Mão esquerda');compare(rightButton.textLabel,'Mão direita');
  var plan=[4,8,4,4,8,4];
  for(var level=0;level<6;level++){
   compare(activity.currentLevel,level);
   for(var question=0;question<plan[level];question++){
    readyHand();var stimulus=hand();verify(semantics[stimulus.image]!==undefined);verify(!stimulus.mirror);
    var side=semantics[stimulus.image].side,correct=side==='left'?leftButton:rightButton,wrong=side==='left'?rightButton:leftButton;
    if(question===0){click(wrong);compare(score.currentSubLevel,question);wait(120);var shown=all(wrong).find(child=>child.color!==undefined);verify(String(shown.color)!==String(wrong.normalStateColor));readyHand();compare(hand().image,stimulus.image);compare(hand().rotation,stimulus.rotation);}
    grabImage(activityBackground).save('__QA_OUTPUT__/hand-'+(level+1)+'-'+(question+1)+'.png');
    if(question%2===0)keyClick(side==='left'?Qt.Key_Left:Qt.Key_Right);else click(correct);
    tryCompare(score,'currentSubLevel',question+1,1200);tryCompare(score,'isWinAnimationPlaying',false,4500);wait(100);
    completed.push({level:level+1,question:question+1,stimulus:stimulus,side:side,input:question%2===0?'keyboard':'mouse',wrong_repaired:question===0});console.log('ORIENTATION_HAND',JSON.stringify(completed[completed.length-1]));
   }
   tryCompare(bonus,'isPlaying',true,1500);tryCompare(activity,'currentLevel',(level+1)%6,10000);wait(150);
  }
  compare(wins,6);
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(activityBackground).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_ORIENTATION_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,wins:wins}));}
}
