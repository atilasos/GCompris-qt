// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:'PlaneActualPointerInterception'
    when:activity.visible&&plane.visible
    property var evidence: ({})
__MOVEMENT__
    function test_capture_the_first_visible_zero(){wait(1500);evidence=capture('0',false);}
    function cleanupTestCase(){console.log('NATIVE_PLANE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
