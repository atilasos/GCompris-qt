// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'FifteenPartialRestartByNavigation'
 when:activity.visible&&items.numberOfLevel>0
 property var evidence: ({})
__VISIBLE__
 function misplaced(values){var total=0;for(var i=0;i<16;i++)if(values[i]!==0&&values[i]!==i+1)total++;return total;}
 function test_partial_restart(){wait(1800);var initial=board();compare(items.currentLevel,0);compare(misplaced(initial.values),2);var empty=initial.values.indexOf(0),cell=neighbors(empty).filter(function(candidate){var value=initial.values.slice();value[empty]=value[candidate];value[candidate]=0;return misplaced(value)>2;})[0];ensure(cell!==undefined);var move=slideMove(initial,cell,'click');ensure(misplaced(move.after)>2);ensure(!same(move.after,target()));icon('bar_next.svg');compare(items.currentLevel,1);icon('bar_previous.svg');compare(items.currentLevel,0);var reset=board();compare(misplaced(reset.values),2);ensure(!same(reset.values,move.after),'Navigation discards actual partial board');evidence={initial:initial,partial:move,reset:reset,partialRestart:true};}
 function cleanupTestCase(){console.log('NATIVE_SLIDING_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
