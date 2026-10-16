// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 id:campaign
 name:"VisibleTwentyFourSearch"
 when:activity.visible
 property var plan:__PLAN__
 property var completed:[]
 property int wins:0
 Connections {target:bonus;function onWin(){campaign.wins++;}}
__VISIBLE__
__SOLVER__
 function test_levels(){
  wait(1000);while(activity.currentLevel<__START__)icon('bar_next.svg');compare(activity.currentLevel,__START__);verify(String(instructionPanel.textItem.text).indexOf('24')>=0);
  for(var offset=0;offset<plan.length;offset++){
   var level=__START__+offset;compare(activity.currentLevel,level);
   for(var question=0;question<plan[offset];question++){
    var cards=cards24();compare(cards.length,4);verify(cards.every(c=>c.visible));var values=cards.map(value24),ops=ops24();verify(ops.length>=2&&ops.length<=4);var wrong=null,rejected=[];
    console.log('CHALLENGE_ATTEMPT',level+1,question+1,JSON.stringify(values),JSON.stringify(ops));
    if(question===0){
     var invalid=null;
     for(var i=0;i<4;i++)for(var j=0;j<4;j++)if(i!==j){if(ops.indexOf('-')>=0&&values[i]<values[j])invalid={a:i,b:j,op:'-',left:values[i],right:values[j],reason:'negative'};if(ops.indexOf('/')>=0&&values[j]!==0&&values[i]%values[j]!==0)invalid={a:i,b:j,op:'/',left:values[i],right:values[j],reason:'fraction'};}
     if(invalid!==null){operation24(invalid,false,cards);compare(cards.filter(c=>c.visible).length,4);compare(JSON.stringify(cards.map(value24)),JSON.stringify(values));compare(score.currentSubLevel,question);rejected.push(invalid);}
     var bad=combine(values,ops,24,true);verify(bad!==null);for(var step of bad)operation24(step,false,cards);tryCompare(errorRectangle.errorAnimation,'running',true,1000);compare(score.currentSubLevel,question);tryCompare(errorRectangle.errorAnimation,'running',false,3500);wait(100);
     wrong={steps:bad};verify(hintButton.visible);click(hintButton);tryCompare(solutionRect,'opacity',1,1000);verify(!cardsBoard.enabled&&!operators.enabled);wrong.hintShown=true;
     keyClick(Qt.Key_Backspace);tryVerify(()=>cards.filter(c=>c.visible).length===4,10000);wait(300);compare(solutionRect.opacity,0);verify(cardsBoard.enabled&&operators.enabled);compare(JSON.stringify(cards.map(value24)),JSON.stringify(values));wrong.restored=true;
    }
    var solutionPlan=combine(cards.map(value24),ops,24,false);verify(solutionPlan!==null,'Independent integer/rational tree exists');
    for(var step of solutionPlan)operation24(step,question%2===0,cards);
    var finalCards=cards.filter(c=>c.visible);compare(finalCards.length,1);compare(value24(finalCards[0]),24);tryCompare(score,'currentSubLevel',question+1,1500);
    var record={level:level+1,question:question+1,values:values,target:24,operators:ops,steps:solutionPlan,wrong:wrong,rejected:rejected,input:question%2===0?'keyboard':'mouse'};
    if(question===0||question===plan[offset]-1)grabImage(activityBackground).save('__QA_OUTPUT__/level-'+(level+1)+'-'+(question+1)+'.png');
    tryCompare(score,'isWinAnimationPlaying',false,4500);wait(120);completed.push(record);console.log('CHALLENGE_COMPLETED',JSON.stringify(record));
   }
   tryCompare(bonus,'isPlaying',true,1500);tryCompare(activity,'currentLevel',(level+1)%6,10000);wait(150);
  }
  compare(wins,plan.length);
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(activityBackground).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_CHALLENGES_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,wins:wins}));}
}
