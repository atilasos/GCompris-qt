// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: 'ErasePublicLevelContract'
    when: true
    function test_original_metadata() {
        wait(1800);
        console.log('ERASE_PUBLIC_LEVELS',activity.numberOfLevel,items.numberOfLevel,repeater.count,activity.type);
        compare(activity.numberOfLevel,6);
        compare(items.numberOfLevel,6);
        compare(repeater.count,25);
        tryCompare(activityBackground,'status',Image.Ready,2500);
    }
    function cleanupTestCase(){console.log('NATIVE_ERASE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,publicLevels:activity.numberOfLevel,privateLevels:items.numberOfLevel,blocks:repeater.count,type:activity.type}));}
}
