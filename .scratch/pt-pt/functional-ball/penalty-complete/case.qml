// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'PenaltyByDrawnGoalAndProgressBar'
 when:activity.visible&&goal.width>0
 property int targetLevels: 9
 property var levels: []
 property var evidence: ({})
 function ensure(value,message){if(!value){console.log('PENALTY_ASSERT',message,new Error().stack);grabImage(pageView).save('__QA_OUTPUT__/failure.png');}verify(value,message||'');}
 function point(item){var p=item.mapToItem(activityBackground,item.width/2,item.height/2);return {x:p.x,y:p.y,width:item.width,height:item.height,scale:item.scale,rotation:item.rotation,source:item.source!==undefined?String(item.source):null};}
 function click(item,button){var p=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,p.x,p.y,button===undefined?Qt.LeftButton:button,Qt.NoModifier,0);}
 function fill(progress){var child=progress.children[0];ensure(child.color!==undefined&&child.width!==undefined,'Drawn progress fill');return {width:child.width,total:progress.width,height:child.height,color:String(child.color),visible:progress.visible};}
 function bonusResult(good,progress){
  var path=[],bars=[],start=Date.now();while(!bonus.isPlaying&&Date.now()-start<12000){path.push(point(ball));bars.push(fill(progress));wait(20);}
  ensure(bonus.isPlaying,'Natural Bonus');tryVerify(function(){return bonus.opacity>0.5;},1500);var image=String(bonus.source);ensure(image.indexOf(good?'good':'bad')>=0,'Drawn Bonus');return {path:path,bars:bars,bonus:image};
 }
 function test_complete(){
  wait(1300);compare(activity.numberOfLevel,9);compare(activity.currentLevel,0);
  for(var level=1;level<=targetLevels;level++){
   compare(activity.currentLevel,level-1);var zones=[rectLeft,rectTop,rectRight],bars=[progressLeft,progressTop,progressRight],zoneIndex=(level-1)%3,buttonIndex=Math.floor((level-1)/3),buttons=[Qt.LeftButton,Qt.RightButton,Qt.MiddleButton],zone=zones[zoneIndex],progress=bars[zoneIndex],target=point(zone),goalBox=point(goal),goalie=point(player),before=point(ball),button=buttons[buttonIndex];
   ensure(target.x>goalBox.x-goalBox.width/2&&target.x<goalBox.x+goalBox.width/2&&target.y>goalBox.y-goalBox.height/2&&target.y<goalBox.y+goalBox.height/2,'Clicked region lies inside drawn goal');
   var initialText=String(instructionPanel.textItem.text);ensure(initialText.indexOf('lado da baliza')>=0,'Portuguese instruction names goal');
   click(zone,button);var wrong=bonusResult(false,progress);ensure(wrong.bars.some(function(row){return row.visible&&row.color==='#ff0000';}),'One slow click exhausts visible red bar');
   tryCompare(bonus,'isPlaying',false,7000);compare(activity.currentLevel,level-1);wait(300);var repairText=String(instructionPanel.textItem.text);ensure(repairText.indexOf('bola')>=0&&repairText.indexOf('posição original')>=0,'Drawn instruction requests ball return');click(ball,button);wait(700);ensure(Math.abs(point(ball).x-before.x)<1&&Math.abs(point(ball).y-before.y)<1,'Real click returns ball');
   var first=Date.now();click(zone,button);tryVerify(function(){var row=fill(progress);return row.visible&&row.width>1&&row.width<row.total&&row.color==='#00ff00';},1500);var seen=fill(progress),second=Date.now();click(zone,button);var correct=bonusResult(true,progress);ensure(correct.path.length>2,'Visible shot trajectory');var last=correct.path[correct.path.length-1];ensure(Math.abs(last.x-target.x)<3&&Math.abs(last.y-target.y)<3,'Shot reaches centre of chosen visible region');
   levels.push({level:level,zone:zoneIndex,button:buttonIndex,target:target,goal:goalBox,goalie:goalie,before:before,initialText:initialText,wrong:wrong,repairText:repairText,firstClick:first,secondClick:second,stoppedBar:seen,correct:correct});console.log('PENALTY_PROGRESS',level,targetLevels);grabImage(pageView).save('__QA_OUTPUT__/level-'+level+'.png');tryCompare(activity,'currentLevel',level%9,10000);tryCompare(bonus,'isPlaying',false,3000);wait(700);
  }
 }
 function cleanupTestCase(){console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,levels:levels,evidence:evidence}));}
}
