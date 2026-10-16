// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'VisibleAlignmentTracer'
 when:activity.visible&&repeater.count>0
 property var games: []
__VISIBLE__
 function test_one_match(){wait(1800);var record=fresh(1);record.scoresBefore=scores();record.moves=[];var route=gravity?[0,1,0,1,0,1,0]:[0,3,1,4,2];for(var i=0;i<route.length;i++)record.moves.push(move(route[i],'click',i===0));games.push(finish(record));grabImage(pageView).save('__QA_OUTPUT__/final.png');}
 function cleanupTestCase(){console.log('NATIVE_ALIGNMENT_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,games:games}));}
}
