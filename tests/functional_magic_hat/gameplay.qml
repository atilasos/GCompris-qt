// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:'AllVisibleMagicHatLevels'
    when:activity.visible&&items.numberOfLevel>0
    property var observations: []
__VISIBLE__
    function test_every_level_wrong_repair_and_natural_bonus(){
        wait(1800);compare(items.numberOfLevel,41);compare(items.currentLevel,0);
        for(var level=0;level<41;level++){
            compare(items.currentLevel,level);observations.push(onePuzzle(level+1));console.log('MAGIC_PROGRESS',mode,level+1,41);
            tryCompare(items,'currentLevel',(level+1)%41,9000);tryCompare(bonus,'isPlaying',false,4000);
        }
    }
    function cleanupTestCase(){console.log('NATIVE_MAGIC_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,observations:observations}));}
}
