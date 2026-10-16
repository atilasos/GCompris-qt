TestCase {
    name: "AdjacentPublicLevelContract"
    when: activity.visible && bar.level>0
    function test_publicLevels(){wait(1000);console.log("ADJACENT_LEVEL_CONTRACT",activity.numberOfLevel,activity.currentLevel,bar.level);compare(activity.numberOfLevel,25);compare(activity.currentLevel,bar.level-1);}
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,levels:activity.numberOfLevel,current:activity.currentLevel,displayed:bar.level}));}
}
