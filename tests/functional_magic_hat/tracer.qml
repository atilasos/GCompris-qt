// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:'VisibleStarsAcrossHatPhases'
    when:activity.visible&&items.numberOfLevel>0
    property var evidence: ({})
__VISIBLE__
    function test_real_hat_stars_wrong_then_repaired(){wait(1800);evidence=onePuzzle(1);tryCompare(items,'currentLevel',1,9000);}
    function cleanupTestCase(){console.log('NATIVE_MAGIC_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
