// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'FullGravityBoardBeforeDraw'
 when:activity.visible&&repeater.count>0
 property var evidence: ({moves:[]})
__VISIBLE__
 function test_full_board_draw(){wait(1800);var initial=fresh(__STARTER__);evidence.initial=initial;evidence.scoresBefore=scores();var route=__DRAW_ROUTE__;for(var i=0;i<route.length;i++){
  ensure(result(snapshot().values)===-1,'Independent unfinished board before drop');var step=move(route[i],'click',false);evidence.moves.push(step);if(i>=37&&i<41){wait(650);evidence.lastNonterminal={pieces:count(step.after),bonusOpacity:bonus.opacity,bonusSource:String(bonus.source)};ensure(bonus.opacity===0,'No premature Bonus with '+(42-count(step.after))+' empty cells');}
 }evidence.final=snapshot();compare(result(evidence.final.values),0);tryVerify(function(){return bonus.opacity>0.5;},2500);ensure(String(bonus.source).endsWith('/flower_bad.svg'));ensure(same(scores(),evidence.scoresBefore));evidence.complete=true;grabImage(pageView).save('__QA_OUTPUT__/draw.png');tryCompare(bonus,'isPlaying',false,8000);var before=snapshot().values;input(0,'click');wait(250);ensure(same(snapshot().values,before));}
 function cleanupTestCase(){console.log('NATIVE_ALIGNMENT_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
