// SPDX-License-Identifier: GPL-3.0-or-later
// Follow-up of task20: the application/sequence contract, not a gameplay rerun.
TestCase {
    name:"WordsgameLevelContract"
    when:items.numberOfLevel>0 && activity.visible
    function test_public_level_count(){wait(1600);compare(items.numberOfLevel,3);compare(activity.numberOfLevel,3);}
    function cleanupTestCase(){console.log("NATIVE_MEMORY_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,activityLevels:activity.numberOfLevel,gameLevels:items.numberOfLevel}));}
}
