// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 id:campaign
 name:"VisibleChildBoxRelations"
 when:activity.visible
 property var completed:[]
 property int wins:0
 Connections {target:bonus;function onWin(){campaign.wins++;}}
__VISIBLE__
 function options(textMode){var grid=textMode?answerViews:positionViews;return grid.contentItem.children.filter(child=>child.selectCurrentItem!==undefined && child.width>0 && child.height>0);}
 function keyboardSelect(grid,target){
  if(grid.currentItem===null)keyClick(Qt.Key_Right);
  var steps=0;
  while(grid.currentItem!==target){
   var before=grid.currentItem;verify(before!==null);var a=before.mapToItem(activityBackground,before.width/2,before.height/2),b=target.mapToItem(activityBackground,target.width/2,target.height/2);
   keyClick(Math.abs(a.y-b.y)>before.height/2?(b.y>a.y?Qt.Key_Down:Qt.Key_Up):(b.x>a.x?Qt.Key_Right:Qt.Key_Left));
   verify(grid.currentItem!==before,'One arrow changes visible selection toward target');verify(++steps<12);
  }
 }
 function test_every_position(){
  wait(1000);compare(activity.numberOfLevel,4);var plan=[6,6,7,7];
  for(var level=0;level<4;level++){
   compare(activity.currentLevel,level);var textMode=level%2===1;
   for(var question=0;question<plan[level];question++){
    wait(100);var candidates=options(textMode);verify(candidates.length>=3);var requested=textMode?picture(currentPosition):String(questionPanel.textItem.text),want=textMode?relation(requested):meaning(requested);
    var visible=candidates.map(child=>textMode?String(child.text):picture(child));var found=[];
    for(var i=0;i<visible.length;i++)if(textMode?matches(want,meaning(visible[i])):matches(relation(visible[i]),want))found.push(i);
    compare(found.length,1,'Exactly one independent visible relation matches');var index=found[0],wrong=null;
    if(question===0){
     var bad=(index+1)%candidates.length;click(candidates[bad]);click(okButton);tryCompare(errorRectangle.errorAnimation,'running',true,1200);compare(score.currentSubLevel,question);wrong={index:bad,choice:visible[bad]};tryCompare(errorRectangle.errorAnimation,'running',false,3500);wait(100);
    }
    var keyboard=question%2===0,grid=textMode?answerViews:positionViews;
    if(keyboard)keyboardSelect(grid,candidates[index]);else click(candidates[index]);
    grabImage(activityBackground).save('__QA_OUTPUT__/position-'+(level+1)+'-'+(question+1)+'.png');
    if(keyboard)keyClick(question%3===0?Qt.Key_Space:Qt.Key_Return);else click(okButton);
    tryCompare(score,'currentSubLevel',question+1,1200);tryCompare(score,'isWinAnimationPlaying',false,4500);wait(120);
    completed.push({level:level+1,question:question+1,mode:textMode?'picture-to-text':'text-to-picture',requested:requested,options:visible,index:index,input:keyboard?'keyboard':'mouse',wrong:wrong});console.log('ORIENTATION_POSITION',JSON.stringify(completed[completed.length-1]));
   }
   tryCompare(bonus,'isPlaying',true,1200);tryCompare(activity,'currentLevel',(level+1)%4,10000);wait(150);
  }
  compare(wins,4);
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(activityBackground).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_ORIENTATION_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,wins:wins}));}
}
