// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'AllAlignmentLevelsAndTerminalOutcomes'
 when:activity.visible&&repeater.count>0
 property var games: []
__VISIBLE__
 function scenarios(){var list=[],routes=gravity?[[0,1,0,1,0,1,0],[0,6,1,6,2,5,3],[0,1,1,2,4,2,2,3,4,3,5,3,3],[6,5,5,4,2,4,4,3,2,3,1,3,3]]:[[0,3,1,4,2],[0,1,3,2,6],[0,1,4,2,8],[2,0,4,1,6]];for(var orientation=0;orientation<4;orientation++)for(var starter=1;starter<=2;starter++)list.push({orientation:orientation,starter:starter,route:routes[orientation],draw:false});for(var starter=1;starter<=2;starter++)list.push({orientation:'draw',starter:starter,route:gravity?__DRAW_ROUTE__:[0,1,2,4,3,5,7,6,8],draw:true});return list;}
 function test_all_games(){
  wait(1800);var levels=humanBoth?1:gravity?6:5;if(!humanBoth)compare(items.numberOfLevel,levels);
  if(humanBoth){for(var scenario of scenarios()){
   var record=fresh(scenario.starter);record.level=1;record.scenario=scenario;record.scoresBefore=scores();record.moves=[];
   for(var i=0;i<scenario.route.length;i++){ensure(result(snapshot().values)===-1,'No early result in planned legal route');record.moves.push(move(scenario.route[i],gravity&&i%3===1?'key':'click',i===0));}
   record=finish(record);compare(record.outcome,scenario.draw?0:scenario.starter);games.push(record);console.log('ALIGN_PROGRESS',gravity?'align4':'tic',games.length,10,record.outcome);grabImage(pageView).save('__QA_OUTPUT__/game-'+games.length+'.png');
  }}else{for(var level=0;level<levels;level++){
   compare(items.currentLevel,level);for(var starter=1;starter<=2;starter++){
    var record=fresh(starter);record.level=level+1;record.scoresBefore=scores();record.moves=[];
    for(var round=0;round<22&&result(snapshot().values)===-1;round++){
     compare(turn(),1,'Human turn shown');var selected=choose(snapshot().values);var human=move(selected,gravity&&round%2===1?'key':'click',round===0);record.moves.push(human);if(result(human.after)!==-1)break;if(round===0){var attempted=legal(human.after)[0];input(attempted,'click');record.attemptedDuringAI=attempted;}record.moves.push(aiMove(human.after));console.log('ALIGN_HEARTBEAT',gravity?'align4':'tic',level+1,starter,count(snapshot().values));
    }
    games.push(finish(record));console.log('ALIGN_PROGRESS',gravity?'align4':'tic',level+1,levels,starter,record.outcome);grabImage(pageView).save('__QA_OUTPUT__/level-'+(level+1)+'-starter-'+starter+'.png');
   }
   if(level+1<levels){icon('bar_next.svg');compare(items.currentLevel,level+1);}
  }}
 }
 function cleanupTestCase(){console.log('NATIVE_ALIGNMENT_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,games:games}));}
}
