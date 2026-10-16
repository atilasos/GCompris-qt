// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name: 'NoActivityLevels'
 when: activity.visible
 property var evidence: ({})
 function test_mode_has_no_selector(){wait(1800);evidence={total:activity.numberOfLevel,current:activity.currentLevel,selector:!!(bar.content.value & bar.content.level)};grabImage(pageView).save('__QA_OUTPUT__/no-selector.png');compare(evidence.selector,false);compare(evidence.total,0);}
 function cleanupTestCase(){console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
