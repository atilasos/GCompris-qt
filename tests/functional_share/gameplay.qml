// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 id:campaign
 name:"VisibleCandyDivision"
 when:activity.visible
 property var plan:__PLAN__
 property var completed:[]
 property var levelsCompleted:[]
 property var attempted:({})
 property int wins:0
 Connections {target:bonus;function onWin(){campaign.wins++;}}
__VISIBLE__
 function countAll(){return view().reduce((sum,b)=>sum+b.count,0);}
 function test_every_question(){
  wait(1000);mode(__EASY__);compare(activity.numberOfLevel,15);
  // Configuration restarts the current curriculum at the configured start level.
  while(activity.currentLevel<__START__)icon(bar,'bar_next.svg');
  compare(activity.currentLevel,__START__);
  for(var offset=0;offset<plan.length;offset++){
   var level=__START__+offset;compare(activity.currentLevel,level);
   for(var question=0;question<plan[offset];question++){
    var instruction=String(instructionPanel.textItem.text);
    verify(instruction.length>10);verify(!/wants|pieces of candy|Place|Then split/.test(instruction));
    attempted={level:level+1,question:question+1,instruction:instruction};console.log('SHARE_ATTEMPT',JSON.stringify(attempted));
    // Exhausting the visible supply reveals quantities without reading counters,
    // models, expectedShare/rest, hidden totals or the teacher Client.
    placeChildren();var initial=view(),wrong=null;
    if(question===0){
     wrong={view:initial,score:score.currentSubLevel};click(okButton);
     tryCompare(errorRectangle.errorAnimation,'running',true,1200);compare(score.currentSubLevel,question);
     var frozen=JSON.stringify(view());click(candyWidget);compare(JSON.stringify(view()),frozen);
     tryCompare(errorRectangle.errorAnimation,'running',false,3500);
     console.log('INPUT_ENABLED_AFTER_ERROR',candyWidget.dragAreaElement.enabled);tryCompare(candyWidget.dragAreaElement,'enabled',true,1000);
     wait(100);
    }
    var targets=boxes();var first=targets.find(b=>candies(b).length<6);verify(first!==undefined);
    var before=candies(first).length;
    drag(candyWidget,first.area,first.area.width/2,first.area.height/2);
    compare(candies(first).length,before+1,'Sidebar drag adds exactly one drawn candy');
    click(candyWidget);var additions=1;
    for(var box of targets){
     while(candies(box).length<6 && candyWidget.element.opacity>0.9){
      var n=candies(box).length;mouseClick(box.area,box.area.width-2,box.area.height-2,Qt.LeftButton,Qt.NoModifier,5);wait(15);
      compare(candies(box).length,n+1);additions++;verify(additions<=36);
     }
    }
    verify(candyWidget.element.opacity<0.9,'Public supply exhaustion');
    var collected=view(),children=collected.filter(b=>b.kind!=='basket').length,total=countAll();
    compare(total,initial.reduce((sum,b)=>sum+b.count,0)+additions);
    var quotient=Math.floor(total/children),remainder=total-quotient*children;
    verify(quotient>=0 && quotient<=6);verify(remainder>=0 && remainder<children);
    var targetCounts=collected.map(b=>b.kind==='basket'?remainder:quotient);
    var transfers=0;
    while(true){
     var current=view(),donor=-1,recipient=-1;
     for(var j=0;j<current.length;j++){if(current[j].count>targetCounts[j])donor=j;if(current[j].count<targetCounts[j])recipient=j;}
     if(donor<0 && recipient<0)break;
     verify(donor>=0 && recipient>=0,'Conserved painted candy supply');
     var donorBefore=current[donor].count,recipientBefore=current[recipient].count;
     var receiver=boxes()[recipient];drag(candies(boxes()[donor])[0],receiver.area,receiver.area.width/2,receiver.area.height/2);
     compare(candies(boxes()[donor]).length,donorBefore-1);compare(candies(receiver).length,recipientBefore+1);compare(countAll(),total);
     transfers++;verify(transfers<=36);
    }
    var finalView=view();for(var k=0;k<finalView.length;k++){compare(finalView[k].count,targetCounts[k]);compare(Number(finalView[k].label),finalView[k].count);}
    if(level===1 && question===4)verify(instruction.indexOf('raparigas já têm')>=0,'PT explicitly explains already received candies');
    if(level===6 && question===2)verify(instruction.indexOf('raparigas já têm')>=0,'PT explains existing candies');
    var record={level:level+1,question:question+1,instruction:instruction,easy:__EASY__,initial:initial,collected:collected,final:finalView,children:children,total:total,quotient:quotient,remainder:remainder,additions:additions,transfers:transfers,wrong:wrong};
    if(question===0 || question===plan[offset]-1)grabImage(activityBackground).save('__QA_OUTPUT__/level-'+(level+1)+'-'+(question+1)+'.png');
    click(okButton);tryCompare(score,'currentSubLevel',question+1,1200);tryCompare(score,'isWinAnimationPlaying',false,4500);wait(120);
    completed.push(record);console.log('SHARE_QUESTION',JSON.stringify(record));
   }
   tryCompare(bonus,'isPlaying',true,1000);tryCompare(activity,'currentLevel',(level+1)%15,10000);wait(200);levelsCompleted.push(level+1);
  }
  compare(wins,plan.length);
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(activityBackground).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_SHARE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,levelsCompleted:levelsCompleted,wins:wins,attempted:attempted}));}
}
