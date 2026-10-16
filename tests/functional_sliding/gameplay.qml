// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'AllSlidingPuzzleLevels'
 when:activity.visible&&items.numberOfLevel>0
 property var levels: []
__VISIBLE__
 function test_all_levels(){
  wait(1800);compare(items.numberOfLevel,14);compare(items.currentLevel,0);
  for(var level=0;level<14;level++){
   compare(items.currentLevel,level);var initial=board(),record={level:level+1,initial:initial,detour:[],moves:[],assisted:mode==='sixteen'};grabImage(pageView).save('__QA_OUTPUT__/level-'+(level+1)+'.png');ensure(!same(initial.values,target()),'Initial puzzle is unsolved');
   if(mode==='fifteen'){
    var empty=initial.values.indexOf(0),cell=neighbors(empty).filter(function(candidate){var test=initial.values.slice();test[empty]=test[candidate];test[candidate]=0;return !same(test,target());})[0];
    record.detour.push(slideMove(initial,cell,'click'));record.detour.push(slideMove(board(),empty,'key'));ensure(same(board().values,initial.values),'Independent inverse restores partial move');
    var route=plan(initial.values);ensure(route.length>0);record.planLength=route.length;console.log('SLIDING_PLAN',level+1,route.length);
    for(var step=0;step<route.length;step++){record.moves.push(slideMove(board(),route[step],['click','key','drag'][step%3]));if(step%25===0)console.log('SLIDING_HEARTBEAT',mode,level+1,step,route.length);}
   }else{
    var row=0;while(same(rotateExpected(initial.values,'L',row),target()))row++;record.detour.push(rotateMove(initial,'L',row,'click'));record.detour.push(rotateMove(board(),'R',row,'click'));ensure(same(board().values,initial.values),'Inverse restores row');icon('bar_hint.svg');
    for(var count=0;count<100&&!same(board().values,target());count++){var hint=visualHint(),move=rotateMove(board(),hint.direction,hint.index,'click');move.hint=hint;record.moves.push(move);}
    ensure(record.moves.length>0&&record.moves.length<100,'Finite visible hint route');
   }
   record.final=board();ensure(same(record.final.values,target()),'Independent final full ordering');tryCompare(bonus,'isPlaying',true,1000);tryVerify(function(){return bonus.opacity>0.5;},2000);record.goodBonus=String(bonus.source);ensure(record.goodBonus.endsWith('/flower_good.svg'));levels.push(record);console.log('SLIDING_PROGRESS',mode,level+1,14,record.moves.length);
   tryCompare(items,'currentLevel',(level+1)%14,9000);tryCompare(bonus,'isPlaying',false,4000);wait(500);
  }
 }
 function cleanupTestCase(){console.log('NATIVE_SLIDING_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,levels:levels}));}
}
