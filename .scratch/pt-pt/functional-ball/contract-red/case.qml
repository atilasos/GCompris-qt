// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name: 'PublicBallcatchLevelContract'
 when: activity.visible
 property var evidence: ({})
 function test_nine_public_levels(){
  wait(1200);evidence={current:activity.currentLevel,total:activity.numberOfLevel};
  grabImage(pageView).save('__QA_OUTPUT__/contract.png');
  compare(activity.numberOfLevel,9,'Public activity total must match the nine selectable levels');compare(activity.currentLevel,0);
 }
 function cleanupTestCase(){console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
