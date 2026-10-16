// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name: 'CatchByVisibleTrajectoryAndRealInputs'
 when: activity.visible
 property int targetLevels: 9
 property bool useHands: true
 property var levels: []
 property var evidence: ({})
 function ensure(value,message){if(!value){console.log('BALL_ASSERT',message,new Error().stack);grabImage(pageView).save('__QA_OUTPUT__/failure.png');}verify(value,message||'');}
 function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var hit=find(child,predicate);if(hit)return hit;}return null;}
 function click(item){ensure(item!==null);var p=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);}
 function point(item){var p=item.mapToItem(activityBackground,item.width/2,item.height/2);return {x:p.x,y:p.y,width:item.width,height:item.height,scale:item.scale,rotation:item.rotation,source:String(item.source)};}
 function input(left){var now=Date.now();if(useHands)click(left?leftHand:rightHand);else keyClick(left?Qt.Key_Left:Qt.Key_Right,Qt.NoModifier,0);return {side:left?'left':'right',timestamp:now,kind:useHands?'mouse-on-hand':'arrow-key'};}
 function feedback(good){
  var samples=[],start=Date.now();
  while(!bonus.isPlaying&&Date.now()-start<12000){samples.push(point(ball));wait(20);}
  ensure(bonus.isPlaying,'Natural Bonus appears');tryVerify(function(){return bonus.opacity>0.5;},1500);var image=String(bonus.source);ensure(image.indexOf(good?'good':'bad')>=0,'Drawn Bonus matches real input');
  return {path:samples,bonus:image};
 }
 function test_complete(){
  wait(1200);compare(activity.numberOfLevel,9);compare(activity.currentLevel,0);ensure(message.visible,'Intro shown');
  var intro=find(message,function(o){return o.visible&&o.text!==undefined&&String(o.text).indexOf('linha reta')>=0;});ensure(intro!==null,'Portuguese drawn introduction');evidence.intro=String(intro.text);keyClick(Qt.Key_Return);tryCompare(message,'visible',false,2000);wait(300);
  for(var level=1;level<=targetLevels;level++){
   compare(activity.currentLevel,level-1);tryVerify(function(){return tux.opacity>0.9;},1500);var target=point(tux),before=point(ball);ensure(Math.abs(before.x-target.x)<1,'Ball initially aligned with Tux');
   var wrongInput=input(level%2===1),wrong=feedback(false);ensure(wrong.path.length>3,'Visible failing trajectory');var lastWrong=wrong.path[wrong.path.length-1];ensure(Math.abs(lastWrong.x-target.x)>target.width/2,'Miss passes beside Tux');
   tryCompare(bonus,'isPlaying',false,7000);compare(activity.currentLevel,level-1);wait(350);ensure(Math.abs(point(ball).x-before.x)<1&&Math.abs(point(ball).y-before.y)<1,'Natural failure repair resets visible ball');
   var inputs=[input(true),input(false)],correct=feedback(true);ensure(correct.path.length>3,'Visible straight trajectory');
   for(var sample of correct.path)ensure(Math.abs(sample.x-before.x)<1,'Synchronized ball stays in a straight line');ensure(correct.path[correct.path.length-1].y<before.y-20,'Ball moves towards Tux');
   levels.push({level:level,target:target,before:before,wrongInput:wrongInput,wrong:wrong,inputs:inputs,correct:correct});console.log('BALL_PROGRESS',level,targetLevels,useHands);grabImage(pageView).save('__QA_OUTPUT__/level-'+level+'.png');
   tryCompare(activity,'currentLevel',level%9,10000);tryCompare(bonus,'isPlaying',false,3000);wait(350);
  }
 }
 function cleanupTestCase(){console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,levels:levels,evidence:evidence}));}
}
