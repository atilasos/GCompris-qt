// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"LetterInWordPublicLevelCount"
    when:activity.visible
    function test_public_level_count() {
        wait(1800);
        console.log("LETTER_CONTEXT",JSON.stringify({external:ApplicationSettings.useExternalWordset(),locale:items.locale,levels:activity.numberOfLevel,engineLevels:Activity.maxLevel,mode:items.currentMode,question:items.question,case:items.currentLetterCase,words:wordsModel.count}));
        compare(activity.numberOfLevel,23);
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount}));}
}
