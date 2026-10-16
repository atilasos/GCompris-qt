// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'PublicAlignmentLevelContract'
 when:activity.visible&&repeater.count>0
 property var evidence: ({})
__VISIBLE__
 function test_public_levels(){wait(1800);var expected=humanBoth?(gravity?1:0):(gravity?6:5);evidence={publicLevels:activity.numberOfLevel,engineLevels:items.numberOfLevel,expected:expected,level:bar.level,previous:find(bar,function(item){return item.source!==undefined&&String(item.source).endsWith('/bar_previous.svg')&&drawn(item);})!==null,next:find(bar,function(item){return item.source!==undefined&&String(item.source).endsWith('/bar_next.svg')&&drawn(item);})!==null};compare(evidence.publicLevels,expected,'Public count matches exposed selector');compare(evidence.previous,!humanBoth);compare(evidence.next,!humanBoth);}
 function cleanupTestCase(){console.log('NATIVE_ALIGNMENT_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
