// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 function checkEqual(actual,expected,message){if(actual!==expected)console.log('COMPARE_FAILED',actual,expected,message);compare(actual,expected,message);}
 function checkTrue(value,message){if(!value)console.log('ASSERT_FAILED',message);verify(value,message);}

 id:campaign
 name:"VisibleCandyDivision"
 when:activity.visible
 property var plan:[5]
 property var completed:[]
 property var levelsCompleted:[]
 property var attempted:({})
 property int wins:0
 Connections {target:bonus;function onWin(){campaign.wins++;}}
 function all(root){var rows=[root];if(root.children)for(var child of root.children)rows=rows.concat(all(child));return rows;}
 function boxes(){return dropAreas.children.filter(child=>child.childImage!==undefined && child.width>0);}
 function candies(box){return all(box.area).filter(child=>child.source!==undefined && String(child.source).endsWith('/candy.svg') && child.width>0);}
 function view(){return boxes().map(box=>({kind:String(box.childImage.source).split('/').pop().replace('.svg',''),count:candies(box).length,label:String(box.candyCount.text)}));}
 function drag(source,target,x,y){
  var a=source.mapToItem(activityBackground,source.width/2,source.height/2),b=target.mapToItem(activityBackground,x,y);
  mousePress(activityBackground,a.x,a.y,Qt.LeftButton,Qt.NoModifier,10);
  for(var i=1;i<=8;i++)mouseMove(activityBackground,a.x+(b.x-a.x)*i/8,a.y+(b.y-a.y)*i/8,10);
  mouseRelease(activityBackground,b.x,b.y,Qt.LeftButton,Qt.NoModifier,10);wait(40);
 }
 function click(item){mouseClick(item,item.width/2,item.height/2,Qt.LeftButton,Qt.NoModifier,10);wait(30);}
 function findIcon(root,suffix){return all(root).find(child=>child.source!==undefined && String(child.source).endsWith(suffix));}
 function icon(root,suffix){wait(450);var item=findIcon(root,suffix);checkTrue(item!==undefined,suffix);click(item);wait(350);}
 function counters(){return all(dialogActivityConfig).find(child=>child.indicatorImageHeight!==undefined && child.text==='Mostrar os contadores');}
 function save(){var item=all(dialogActivityConfig).find(child=>child.clicked!==undefined && child.text==='Gravar' && child.visible);checkTrue(item!==undefined);click(item);tryCompare(dialogActivityConfig,'visible',false,2000);wait(700);}
 function mode(easy){
  icon(bar,'bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2000);wait(400);
  var choice=counters();checkTrue(choice!==undefined);if(choice.checked!==easy)click(choice);checkEqual(choice.checked,easy);save();
 }
 function placeChildren(){
  for(var widget of [girlWidget,boyWidget])if(widget.visible){var limit=0;while(widget.element.opacity>0.9 && limit++<6)drag(widget,grid,grid.width/2,grid.height/2);checkTrue(limit<=6);}
  checkTrue(boxes().length>=2 && boxes().length<=6);
  if(basketWidget.visible && basketWidget.element.opacity>0.9)drag(basketWidget,grid,grid.width/2,grid.height/2);
 }

 function countAll(){return view().reduce((sum,b)=>sum+b.count,0);}
 function test_every_question(){
  wait(1000);mode(true);checkEqual(activity.numberOfLevel,15);
  // Configuration restarts the current curriculum at the configured start level.
  while(activity.currentLevel<1)icon(bar,'bar_next.svg');
  checkEqual(activity.currentLevel,1);
  for(var offset=0;offset<plan.length;offset++){
   var level=1+offset;checkEqual(activity.currentLevel,level);
   for(var question=0;question<plan[offset];question++){
    var instruction=String(instructionPanel.textItem.text);
    checkTrue(instruction.length>10);checkTrue(!/wants|pieces of candy|Place|Then split/.test(instruction));
    attempted={level:level+1,question:question+1,instruction:instruction};console.log('SHARE_ATTEMPT',JSON.stringify(attempted));
    // Exhausting the visible supply reveals quantities without reading counters,
    // models, expectedShare/rest, hidden totals or the teacher Client.
    placeChildren();var initial=view(),wrong=null;
    if(question===0){
     wrong={view:initial,score:score.currentSubLevel};click(okButton);
     tryCompare(errorRectangle.errorAnimation,'running',true,1200);checkEqual(score.currentSubLevel,question);
     var frozen=JSON.stringify(view());click(candyWidget);checkEqual(JSON.stringify(view()),frozen);
     tryCompare(errorRectangle.errorAnimation,'running',false,3500);
    }
    var targets=boxes();var first=targets.find(b=>candies(b).length<6);checkTrue(first!==undefined);
    var before=candies(first).length;
    drag(candyWidget,first.area,first.area.width/2,first.area.height/2);
    checkEqual(candies(first).length,before+1,'Sidebar drag adds exactly one drawn candy');
    click(candyWidget);var additions=1;
    for(var box of targets){
     while(candies(box).length<6 && candyWidget.element.opacity>0.9){
      var n=candies(box).length;mouseClick(box.area,box.area.width-2,box.area.height-2,Qt.LeftButton,Qt.NoModifier,5);wait(15);
      checkEqual(candies(box).length,n+1);additions++;checkTrue(additions<=36);
     }
    }
    checkTrue(candyWidget.element.opacity<0.9,'Public supply exhaustion');
    var collected=view(),children=collected.filter(b=>b.kind!=='basket').length,total=countAll();
    checkEqual(total,initial.reduce((sum,b)=>sum+b.count,0)+additions);
    var quotient=Math.floor(total/children),remainder=total-quotient*children;
    checkTrue(quotient>=0 && quotient<=6);checkTrue(remainder>=0 && remainder<children);
    var targetCounts=collected.map(b=>b.kind==='basket'?remainder:quotient);
    var transfers=0;
    while(true){
     var current=view(),donor=-1,recipient=-1;
     for(var j=0;j<current.length;j++){if(current[j].count>targetCounts[j])donor=j;if(current[j].count<targetCounts[j])recipient=j;}
     if(donor<0 && recipient<0)break;
     checkTrue(donor>=0 && recipient>=0,'Conserved painted candy supply');
     var donorBefore=current[donor].count,recipientBefore=current[recipient].count;
     var receiver=boxes()[recipient];drag(candies(boxes()[donor])[0],receiver.area,receiver.area.width/2,receiver.area.height/2);
     checkEqual(candies(boxes()[donor]).length,donorBefore-1);checkEqual(candies(receiver).length,recipientBefore+1);checkEqual(countAll(),total);
     transfers++;checkTrue(transfers<=36);
    }
    var finalView=view();for(var k=0;k<finalView.length;k++){checkEqual(finalView[k].count,targetCounts[k]);checkEqual(Number(finalView[k].label),finalView[k].count);}
    if(level===1 && question===4)checkTrue(instruction.indexOf('raparigas já têm')>=0,'PT explicitly explains already received candies');
    if(level===6 && question===2)checkTrue(instruction.indexOf('raparigas já têm')>=0,'PT explains existing candies');
    var record={level:level+1,question:question+1,instruction:instruction,easy:true,initial:initial,collected:collected,final:finalView,children:children,total:total,quotient:quotient,remainder:remainder,additions:additions,transfers:transfers,wrong:wrong};
    if(question===0 || question===plan[offset]-1)grabImage(activityBackground).save('__QA_OUTPUT__/level-'+(level+1)+'-'+(question+1)+'.png');
    click(okButton);tryCompare(score,'currentSubLevel',question+1,1200);tryCompare(score,'isWinAnimationPlaying',false,4500);wait(120);
    completed.push(record);console.log('SHARE_QUESTION',JSON.stringify(record));
   }
   tryCompare(bonus,'isPlaying',true,1000);tryCompare(activity,'currentLevel',(level+1)%15,10000);wait(200);levelsCompleted.push(level+1);
  }
  checkEqual(wins,plan.length);
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(activityBackground).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_SHARE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,levelsCompleted:levelsCompleted,wins:wins,attempted:attempted}));}
}
