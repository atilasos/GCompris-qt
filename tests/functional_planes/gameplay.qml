// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:'NaturalFlightAcrossFourSequenceLevels'
    when:activity.visible&&items.numberOfLevel>0
    property var expectedLevels: __LEVELS__
    property var observations: []
    property var tutorialPages: []
__MOVEMENT__
__TUTORIAL__
__OBSERVE__
    function test_all_four_visible_sequences(){
        wait(1400);tutorialPages=tutorial();compare(items.numberOfLevel,4);compare(items.currentLevel,0);
        for(var level=0;level<4;level++){
            wait(1200);compare(items.currentLevel,level);compare(score.visible,level<2);
            visibleCloudHistory=[];capturedClouds=[];currentExpected=expectedLevels[level];observedLevel=level+1;
            while(capturedClouds.length<currentExpected.length)pursueNextVisibleCloud();
            var accepted=capturedClouds.slice();
            tryCompare(bonus,'isPlaying',true,2000);
            observations.push({level:level+1,indicationVisible:level<2,captures:accepted,bonus:true});
            tryCompare(items,'currentLevel',(level+1)%4,10000);tryCompare(bonus,'isPlaying',false,4000);
        }
        compare(items.currentLevel,0);
    }
    function cleanupTestCase(){console.log('NATIVE_PLANE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,observations:observations,tutorial:tutorialPages}));}
}
