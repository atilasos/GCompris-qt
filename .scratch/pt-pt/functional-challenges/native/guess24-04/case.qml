// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 function checkEqual(actual,expected,message){if(actual!==expected)console.log('COMPARE_FAILED',actual,expected,message);compare(actual,expected,message);}
 function checkTrue(value,message){if(!value)console.log('ASSERT_FAILED',message);verify(value,message);}

 id:campaign
 name:"VisibleTwentyFourSearch"
 when:activity.visible
 property var plan:[20]
 property var completed:[]
 property int wins:0
 Connections {target:bonus;function onWin(){campaign.wins++;}}
 function all(root){var result=[root];if(root.children)for(var child of root.children)result=result.concat(all(child));return result;}
 function texts(root){return all(root).filter(child=>child.text!==undefined && child.width>0 && child.height>0);}
 function click(item){var p=item.mapToItem(pageView,item.width/2,item.height/2);checkTrue(p.x>=0&&p.y>=0&&p.x<pageView.width&&p.y<pageView.height,'Real click center inside viewport');mouseClick(item,item.width/2,item.height/2,Qt.LeftButton,Qt.NoModifier,10);wait(25);}
 function drag(source,target){var a=source.mapToItem(pageView,source.width/2,source.height/2),b=target.mapToItem(pageView,target.width/2,target.height/2);checkTrue(a.x>=0&&a.y>=0&&a.x<pageView.width&&a.y<pageView.height&&b.x>=0&&b.y>=0&&b.x<pageView.width&&b.y<pageView.height,'Real drag endpoints inside viewport');mousePress(pageView,a.x,a.y,Qt.LeftButton,Qt.NoModifier,10);for(var i=1;i<=8;i++)mouseMove(pageView,a.x+(b.x-a.x)*i/8,a.y+(b.y-a.y)*i/8,10);wait(120);mouseRelease(pageView,b.x,b.y,Qt.LeftButton,Qt.NoModifier,10);wait(80);}
 function icon(suffix){wait(400);var item=all(bar).find(child=>child.source!==undefined&&String(child.source).endsWith(suffix));checkTrue(item!==undefined,suffix);click(item);wait(350);}
 function cards24(){return cardsBoard.contentItem.children.filter(child=>child.width>0&&child.height>0&&texts(child).length===1).sort((a,b)=>a.y===b.y?a.x-b.x:a.y-b.y);}
 function value24(card){return Number(texts(card)[0].text);}
 function ops24(){return texts(operators).filter(text=>text.visible).map(text=>String(text.text).replace('−','-').replace('×','*').replace('÷','/'));}
 function operation24(step,keyboard,cards){
  checkTrue(cards[step.a].visible && cards[step.b].visible);checkEqual(value24(cards[step.a]),step.left);checkEqual(value24(cards[step.b]),step.right);click(cards[step.a]);
  if(keyboard){keyClick({'+':Qt.Key_Plus,'-':Qt.Key_Minus,'*':Qt.Key_Asterisk,'/':Qt.Key_Slash}[step.op]);var n=0;while(cardsBoard.currentItem!==cards[step.b]){keyClick(Qt.Key_Right);checkTrue(++n<=4);}keyClick(Qt.Key_Return);}
  else {var symbol={'+':'+','-':'−','*':'×','/':'÷'}[step.op],label=texts(operators).find(t=>t.visible&&String(t.text)===symbol);checkTrue(label!==undefined);click(label);click(cards[step.b]);}
  tryCompare(animationCard,'visible',false,6000);wait(60);
 }
 function undo24(cards,allSteps){var guard=0;while(cards.filter(card=>card.visible).length<4){checkTrue(cancelButton.visible);click(cancelButton);tryCompare(animationCard,'visible',false,6000);wait(70);checkTrue(++guard<=4);}checkEqual(cards.filter(c=>c.visible).length,4);}
 function tiles(root){return all(root).filter(child=>child.tile!==undefined&&child.acceptedButtons!==undefined&&child.width>0&&child.height>0);}
 function tileLabel(tile){var labels=texts(tile.tile);checkEqual(labels.length,1);return String(labels[0].text);}
 function rowsCount(){return col.children.filter(child=>child.endResult!==undefined && child.width>0);}
 function dropCells(row){var cells=row.children.filter(child=>child.type!==undefined);var loader=row.children.find(child=>child.item!==undefined);return {a:loader.item,op:cells.find(c=>c.type==='operators'),b:cells.find(c=>c.type==='operands')};}
 function numbersCount(){return tiles(operandRow).sort((a,b)=>a.mapToItem(operandRow,0,0).x-b.mapToItem(operandRow,0,0).x);}
 function operatorsCount(){return tiles(operatorRow).map(tile=>tileLabel(tile));}
 function placeCount(plan,numbers){
  var rows=rowsCount();checkEqual(rows.length,plan.length);var moves=[];
  for(var i=0;i<plan.length;i++){
   var step=plan[i],cells=dropCells(rows[i]);
   if(i===0){moves.push({tile:numbers[step.a],home:numbers[step.a].parent});drag(numbers[step.a],cells.a);checkEqual(numbers[step.a].parent,cells.a);}
   var operator=tiles(operatorRow).find(tile=>tileLabel(tile)===step.op);checkTrue(operator!==undefined);moves.push({tile:operator,home:operator.parent});drag(operator,cells.op);checkEqual(operator.parent,cells.op);
   moves.push({tile:numbers[step.b],home:numbers[step.b].parent});drag(numbers[step.b],cells.b);checkEqual(numbers[step.b].parent,cells.b);
   if(!warningDialog.visible)checkEqual(String(rows[i].endResult.text),String(step.result),'Painted row arithmetic');
  }
  return moves;
 }
 function clearCount(moves){if(warningDialog.visible){click(warningDialog);tryCompare(warningDialog,'visible',false,1500);}for(var i=moves.length-1;i>=0;i--){var move=moves[i];if(move.tile!==null&&move.tile.parent!==move.home)drag(move.tile,move.home);}wait(80);for(var row of rowsCount())checkEqual(String(row.endResult.text),'');}

 function rational(a,op,b){var n,d;if(op==='+'){n=a+b;d=1;}else if(op==='-'){n=a-b;d=1;}else if(op==='*'){n=a*b;d=1;}else {if(b===0)return null;n=a;d=b;}var x=Math.abs(n),y=Math.abs(d);while(y){var t=x%y;x=y;y=t;}if(d<0){n=-n;d=-d;}return {n:n/(x||1),d:d/(x||1)};}
 function combine(values,ops,target,avoid){
  var failed=({});
  function search(state){
   if(state.length===1)return (avoid?state[0].value!==target:state[0].value===target)?[]:null;
   var key=state.map(v=>v.value).sort((a,b)=>a-b).join(',');if(failed[key])return null;
   for(var i=0;i<state.length;i++)for(var j=0;j<state.length;j++)if(i!==j)for(var op of ops){
    if((op==='+'||op==='*') && i>j)continue;
    var a=state[i],b=state[j],result=rational(a.value,op,b.value);if(result===null || result.d!==1 || result.n<0)continue;
    var rest=state.filter((v,k)=>k!==i&&k!==j);rest.push({value:result.n,slot:b.slot});var tail=search(rest);
    if(tail!==null)return [{a:a.slot,b:b.slot,op:op,left:a.value,right:b.value,result:result.n}].concat(tail);
   }
   failed[key]=true;return null;
  }
  return search(values.map((v,i)=>({value:v,slot:i})));
 }
 function chain(values,ops,target,avoid){
  function search(acc,remaining,left){
   if(left.length===0)return (avoid?acc!==target:acc===target)?[]:null;
   for(var oi=0;oi<left.length;oi++)for(var index of remaining){
    var op=left[oi],value=rational(acc,op,values[index]);if(value===null || value.d!==1 || value.n<0)continue;
    var tail=search(value.n,remaining.filter(i=>i!==index),left.filter((v,i)=>i!==oi));
    if(tail!==null)return [{b:index,op:op,left:acc,right:values[index],result:value.n}].concat(tail);
   }
   return null;
  }
  for(var i=0;i<values.length;i++){var result=search(values[i],values.map((v,k)=>k).filter(k=>k!==i),ops);if(result!==null){result[0].a=i;return result;}}
  return null;
 }

 function test_levels(){
  wait(1000);while(activity.currentLevel<3)icon('bar_next.svg');checkEqual(activity.currentLevel,3);checkTrue(String(instructionPanel.textItem.text).indexOf('24')>=0);
  for(var offset=0;offset<plan.length;offset++){
   var level=3+offset;checkEqual(activity.currentLevel,level);
   for(var question=0;question<plan[offset];question++){
    var cards=cards24();checkEqual(cards.length,4);checkTrue(cards.every(c=>c.visible));var values=cards.map(value24),ops=ops24();checkTrue(ops.length>=2&&ops.length<=4);var wrong=null,rejected=[];
    console.log('CHALLENGE_ATTEMPT',level+1,question+1,JSON.stringify(values),JSON.stringify(ops));
    if(question===0){
     var invalid=null;
     for(var i=0;i<4;i++)for(var j=0;j<4;j++)if(i!==j){if(ops.indexOf('-')>=0&&values[i]<values[j])invalid={a:i,b:j,op:'-',left:values[i],right:values[j],reason:'negative'};if(ops.indexOf('/')>=0&&values[j]!==0&&values[i]%values[j]!==0)invalid={a:i,b:j,op:'/',left:values[i],right:values[j],reason:'fraction'};}
     if(invalid!==null){operation24(invalid,false,cards);checkEqual(cards.filter(c=>c.visible).length,4);checkEqual(JSON.stringify(cards.map(value24)),JSON.stringify(values));checkEqual(score.currentSubLevel,question);rejected.push(invalid);}
     var bad=combine(values,ops,24,true);checkTrue(bad!==null);for(var step of bad)operation24(step,false,cards);tryCompare(errorRectangle.errorAnimation,'running',true,1000);checkEqual(score.currentSubLevel,question);tryCompare(errorRectangle.errorAnimation,'running',false,3500);wait(100);
     wrong={steps:bad};checkTrue(hintButton.visible);click(hintButton);tryCompare(solutionRect,'opacity',1,1000);checkTrue(!cardsBoard.enabled&&!operators.enabled);wrong.hintShown=true;
     keyClick(Qt.Key_Backspace);tryVerify(()=>cards.filter(c=>c.visible).length===4,10000);wait(300);checkEqual(solutionRect.opacity,0);checkTrue(cardsBoard.enabled&&operators.enabled);checkEqual(JSON.stringify(cards.map(value24)),JSON.stringify(values));wrong.restored=true;
    }
    var solutionPlan=combine(cards.map(value24),ops,24,false);checkTrue(solutionPlan!==null,'Independent integer/rational tree exists');
    for(var step of solutionPlan)operation24(step,question%2===0,cards);
    var finalCards=cards.filter(c=>c.visible);checkEqual(finalCards.length,1);checkEqual(value24(finalCards[0]),24);tryCompare(score,'currentSubLevel',question+1,1500);
    var record={level:level+1,question:question+1,values:values,target:24,operators:ops,steps:solutionPlan,wrong:wrong,rejected:rejected,input:question%2===0?'keyboard':'mouse'};
    if(question===0||question===plan[offset]-1)grabImage(activityBackground).save('__QA_OUTPUT__/level-'+(level+1)+'-'+(question+1)+'.png');
    tryCompare(score,'isWinAnimationPlaying',false,4500);wait(120);completed.push(record);console.log('CHALLENGE_COMPLETED',JSON.stringify(record));
   }
   tryCompare(bonus,'isPlaying',true,1500);tryCompare(activity,'currentLevel',(level+1)%6,10000);wait(150);
  }
  checkEqual(wins,plan.length);
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(activityBackground).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_CHALLENGES_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,wins:wins}));}
}
