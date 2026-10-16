// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 function checkEqual(a,b,m){if(a!==b)console.log("COMPARE_FAILED",a,b,m);compare(a,b,m);}
 function checkTrue(v,m){if(!v)console.log("ASSERT_FAILED",m);verify(v,m);}

 id:campaign
 name:"VisibleLinearArithmeticSearch"
 when:activity.visible
 property var plan:[3]
 property var completed:[]
 property int wins:0
 Connections {target:bonus;function onWin(){campaign.wins++;}}
 function all(root){var result=[root];if(root.children)for(var child of root.children)result=result.concat(all(child));return result;}
 function texts(root){return all(root).filter(child=>child.text!==undefined && child.width>0 && child.height>0);}
 function click(item){var p=item.mapToItem(pageView,item.width/2,item.height/2);checkTrue(p.x>=0&&p.y>=0&&p.x<pageView.width&&p.y<pageView.height,'Real click center inside viewport');mouseClick(item,item.width/2,item.height/2,Qt.LeftButton,Qt.NoModifier,10);wait(25);}
 function drag(source,target){var a=source.mapToItem(pageView,source.width/2,source.height/2),b=target.mapToItem(pageView,target.width/2,target.height/2);verify(a.x>=0&&a.y>=0&&a.x<pageView.width&&a.y<pageView.height&&b.x>=0&&b.y>=0&&b.x<pageView.width&&b.y<pageView.height,'Real drag endpoints inside viewport');mousePress(pageView,a.x,a.y,Qt.LeftButton,Qt.NoModifier,10);for(var i=1;i<=8;i++)mouseMove(pageView,a.x+(b.x-a.x)*i/8,a.y+(b.y-a.y)*i/8,10);wait(80);var painted=source.tile.mapToItem(pageView,source.tile.width/2,source.tile.height/2);mouseMove(pageView,b.x+(b.x-painted.x),b.y+(b.y-painted.y),20);wait(80);mouseRelease(pageView,b.x,b.y,Qt.LeftButton,Qt.NoModifier,10);wait(80);}
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
  function search(acc,remaining,depth){
   if(depth===0)return (avoid?acc!==target:acc===target)?[]:null;
   for(var op of ops)for(var index of remaining){
    var value=rational(acc,op,values[index]);if(value===null || value.d!==1 || value.n<0)continue;
    var tail=search(value.n,remaining.filter(i=>i!==index),depth-1);
    if(tail!==null)return [{b:index,op:op,left:acc,right:values[index],result:value.n}].concat(tail);
   }
   return null;
  }
  for(var i=0;i<values.length;i++){var result=search(values[i],values.map((v,k)=>k).filter(k=>k!==i),ops.length);if(result!==null){result[0].a=i;return result;}}
  return null;
 }

 function adminMode(){
  icon('bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2000);wait(350);
  var combo=all(dialogActivityConfig).find(child=>child.currentText!==undefined&&child.label==='Selecionar o modo');checkTrue(combo!==undefined);
  var current=texts(combo).find(t=>String(t.text)===String(combo.currentText));checkTrue(current!==undefined);click(current);wait(250);
  var choices=texts(dialogActivityConfig).filter(t=>t.visible&&String(t.text)==='Gerir');checkTrue(choices.length>=1);click(choices[choices.length-1]);wait(350);
  var save=texts(dialogActivityConfig).find(t=>t.visible&&String(t.text)==='Gravar');checkTrue(save!==undefined);click(save);tryCompare(dialogActivityConfig,'visible',false,2000);wait(700);
 }
 function test_levels(){
  wait(1000);if(false)adminMode();while(activity.currentLevel<15)icon('bar_next.svg');checkEqual(activity.currentLevel,15);
  for(var offset=0;offset<plan.length;offset++){
   var level=15+offset;checkEqual(activity.currentLevel,level);
   for(var question=0;question<plan[offset];question++){
    wait(80);var numbers=numbersCount(),values=numbers.map(t=>Number(tileLabel(t))),ops=operatorsCount(),target=Number(String(guess.text).match(/-?\d+/g).pop());checkTrue(numbers.length>=2&&numbers.length<=5);checkTrue(ops.length>=1&&ops.length<=4);checkEqual(rowsCount().length,ops.length);
    console.log("VISIBLE_POOL",JSON.stringify(values),target);checkTrue([{"values": [2, 3, 4, 7, 48], "target": 10}, {"values": [1, 2, 5, 10, 18], "target": 4}, {"values": [1, 2, 3, 4, 6], "target": 5}, {"values": [1, 2, 4, 5, 9], "target": 9}].some(q=>JSON.stringify(q.values)===JSON.stringify(values.slice().sort((a,b)=>a-b))&&q.target===target),'Visible puzzle belongs to published second four-operator pool');
    console.log('CHALLENGE_ATTEMPT',level+1,question+1,JSON.stringify(values),target,JSON.stringify(ops));
    var wrong=null,rejected=[];
    if(question===0){
     var bad=chain(values,ops,target,true);
     if(bad!==null){var moves=placeCount(bad,numbers);checkEqual(score.currentSubLevel,question);wrong={steps:bad};clearCount(moves);}
     else {var cells=dropCells(rowsCount()[0]),home=numbers[0].parent;drag(numbers[0],cells.op);checkEqual(numbers[0].parent,home);wrong={typeRejected:true};}
     var invalid=null;
     for(var i=0;i<values.length;i++)for(var j=0;j<values.length;j++)if(i!==j){if(ops.indexOf('-')>=0&&values[i]<values[j])invalid={a:i,b:j,op:'-',left:values[i],right:values[j],reason:'negative'};if(ops.indexOf('/')>=0&&values[j]!==0&&values[i]%values[j]!==0)invalid={a:i,b:j,op:'/',left:values[i],right:values[j],reason:'fraction'};}
     if(invalid!==null){
      var row=rowsCount()[0],cells=dropCells(row),a=numbers[invalid.a],b=numbers[invalid.b],operator=tiles(operatorRow).find(t=>tileLabel(t)===invalid.op),moves=[{tile:a,home:a.parent},{tile:operator,home:operator.parent},{tile:b,home:b.parent}];
      drag(a,cells.a);drag(operator,cells.op);drag(b,cells.b);tryCompare(warningDialog,'visible',true,1000);checkEqual(String(row.endResult.text),'');checkEqual(score.currentSubLevel,question);invalid.message=String(warningDialog.dialogText.text);checkTrue(invalid.message.indexOf('inteiro')>=0);rejected.push(invalid);clearCount(moves);
     }
    }
    var solutionPlan=chain(values,ops,target,false);checkTrue(solutionPlan!==null,'Independent sequential arithmetic solution');placeCount(solutionPlan,numbers);tryCompare(score,'currentSubLevel',question+1,1000);
    var record={level:level+1,question:question+1,mode:false?'admin':'builtin',values:values,target:target,operators:ops,steps:solutionPlan,wrong:wrong,rejected:rejected};if(question===0||question===plan[offset]-1)grabImage(activityBackground).save('__QA_OUTPUT__/level-'+(level+1)+'-'+(question+1)+'.png');
    tryCompare(score,'isWinAnimationPlaying',false,4500);wait(150);completed.push(record);console.log('CHALLENGE_COMPLETED',JSON.stringify(record));
   }
   tryCompare(bonus,'isPlaying',true,1500);tryCompare(activity,'currentLevel',(level+1)%(false?8:17),10000);wait(150);
  }
  checkEqual(wins,plan.length);
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(activityBackground).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_CHALLENGES_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,wins:wins}));}
}
