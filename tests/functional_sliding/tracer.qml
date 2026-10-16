// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'VisibleSlidingTracer'
 when:activity.visible&&items.numberOfLevel>0
 property var observations: []
__VISIBLE__
 function test_first_board(){wait(1800);var first=board();grabImage(pageView).save('__QA_OUTPUT__/first.png');if(mode==='fifteen'){var route=plan(first.values);console.log('SLIDING_PLAN',route.length);for(var cell of route){var move=slideMove(first,cell,'click');observations.push(move);first=move.after;}}else{icon('bar_hint.svg');for(var count=0;count<30&&!same(first.values,target());count++){var hint=visualHint(),move=rotateMove(first,hint.direction,hint.index,'click');move.hint=hint;observations.push(move);first=move.after;}}ensure(same(first.values,target()));tryCompare(bonus,'isPlaying',true,1000);tryCompare(items,'currentLevel',1,9000);}
 function cleanupTestCase(){console.log('NATIVE_SLIDING_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,observations:observations}));}
}
