// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"MovingFishPublicLevels"
    when:activity.visible
    function test_public_levels() {
        wait(1600);
        console.log("FISH_LEVELS",JSON.stringify({publicLevels:activity.numberOfLevel,privateLevels:Activity.levelProperty.length,fishCount:score.numberOfSubLevels}));
        compare(activity.numberOfLevel,6);
    }
    function cleanupTestCase(){console.log("NATIVE_MOUSE_FISH_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount}));}
}
