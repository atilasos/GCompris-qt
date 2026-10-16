// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 id:campaign
 name:"VisibleLinearArithmeticSearch"
 when:activity.visible
 property var plan:__PLAN__
 property var completed:[]
 property int wins:0
 Connections {target:bonus;function onWin(){campaign.wins++;}}
__VISIBLE__
__SOLVER__
 function adminMode(){
  icon('bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2000);wait(350);
  var combo=all(dialogActivityConfig).find(child=>child.currentText!==undefined&&child.label==='Selecionar o modo');verify(combo!==undefined);
  var current=texts(combo).find(t=>String(t.text)===String(combo.currentText));verify(current!==undefined);click(current);wait(250);
  var choices=texts(dialogActivityConfig).filter(t=>t.visible&&String(t.text)==='Gerir');verify(choices.length>=1);click(choices[choices.length-1]);wait(350);
  var save=texts(dialogActivityConfig).find(t=>t.visible&&String(t.text)==='Gravar');verify(save!==undefined);click(save);tryCompare(dialogActivityConfig,'visible',false,2000);wait(700);
 }
 function test_levels(){
  wait(1000);if(__ADMIN__)adminMode();while(activity.currentLevel<__START__)icon('bar_next.svg');compare(activity.currentLevel,__START__);
  for(var offset=0;offset<plan.length;offset++){
   var level=__START__+offset;compare(activity.currentLevel,level);
   for(var question=0;question<plan[offset];question++){
    wait(80);var numbers=numbersCount(),values=numbers.map(t=>Number(tileLabel(t))),ops=operatorsCount(),target=Number(String(guess.text).match(/-?\d+/g).pop());verify(numbers.length>=2&&numbers.length<=5);verify(ops.length>=1&&ops.length<=4);compare(rowsCount().length,ops.length);
    console.log('CHALLENGE_ATTEMPT',level+1,question+1,JSON.stringify(values),target,JSON.stringify(ops));
    var wrong=null,rejected=[];
    if(question===0){
     var bad=chain(values,ops,target,true);
     if(bad!==null){var moves=placeCount(bad,numbers);compare(score.currentSubLevel,question);wrong={steps:bad};clearCount(moves);}
     else {var cells=dropCells(rowsCount()[0]),home=numbers[0].parent;drag(numbers[0],cells.op);compare(numbers[0].parent,home);wrong={typeRejected:true};}
     var invalid=null;
     for(var i=0;i<values.length;i++)for(var j=0;j<values.length;j++)if(i!==j){if(ops.indexOf('-')>=0&&values[i]<values[j])invalid={a:i,b:j,op:'-',left:values[i],right:values[j],reason:'negative'};if(ops.indexOf('/')>=0&&values[j]!==0&&values[i]%values[j]!==0)invalid={a:i,b:j,op:'/',left:values[i],right:values[j],reason:'fraction'};}
     if(invalid!==null){
      var row=rowsCount()[0],cells=dropCells(row),a=numbers[invalid.a],b=numbers[invalid.b],operator=tiles(operatorRow).find(t=>tileLabel(t)===invalid.op),moves=[{tile:a,home:a.parent},{tile:operator,home:operator.parent},{tile:b,home:b.parent}];
      drag(a,cells.a);drag(operator,cells.op);drag(b,cells.b);tryCompare(warningDialog,'visible',true,1000);compare(String(row.endResult.text),'');compare(score.currentSubLevel,question);invalid.message=String(warningDialog.dialogText.text);verify(invalid.message.indexOf('inteiro')>=0);rejected.push(invalid);clearCount(moves);
     }
    }
    var solutionPlan=chain(values,ops,target,false);verify(solutionPlan!==null,'Independent sequential arithmetic solution');placeCount(solutionPlan,numbers);tryCompare(score,'currentSubLevel',question+1,1000);
    var record={level:level+1,question:question+1,mode:__ADMIN__?'admin':'builtin',values:values,target:target,operators:ops,steps:solutionPlan,wrong:wrong,rejected:rejected};if(question===0||question===plan[offset]-1)grabImage(activityBackground).save('__QA_OUTPUT__/level-'+(level+1)+'-'+(question+1)+'.png');
    tryCompare(score,'isWinAnimationPlaying',false,4500);wait(150);completed.push(record);console.log('CHALLENGE_COMPLETED',JSON.stringify(record));
   }
   tryCompare(bonus,'isPlaying',true,1500);tryCompare(activity,'currentLevel',(level+1)%(__ADMIN__?8:17),10000);wait(150);
  }
  compare(wins,plan.length);
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(activityBackground).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_CHALLENGES_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,wins:wins}));}
}
