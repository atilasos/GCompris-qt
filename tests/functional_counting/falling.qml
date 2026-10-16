// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "FallingVisibleCounts"
    when: activity.visible && items.numberOfLevel>0
    property var dice: __DICE_COUNTS__
    property var observations: []
    property int levelLimit: __LEVEL_LIMIT__
    property bool visualPreference: __VISUAL_PREFERENCE__
__COUNT_READERS__
__UI_HELPERS__
    function enterCount(value,virtualKeys) {
        if(virtualKeys && visualPreference) {
            var button=find(keyboard,function(item){return item.specialKey!==undefined && item.text===String(value);});
            verify(button!==null,"A visible digit key exists");mouseClick(button);
        } else {textinput.forceActiveFocus();keyClick(String(value));}
    }
    function test_all_levels_and_representations() {
        wait(1600);ApplicationSettings.isVirtualKeyboard=visualPreference;
        compare(items.numberOfLevel,9);compare(activity.levelFolder.length,8);
        var modes=activity.activityName==="smallnumbers"?["dice"]:(__REPRESENTATION__==="all"?["dot","number","roman","image"]:[__REPRESENTATION__]);
        for(var modeIndex=0;modeIndex<modes.length;modeIndex++) {
            if(modes[modeIndex]!=="dice") {
                var panel=openOptions();chooseMode(panel,["dot","number","roman","image"].indexOf(modes[modeIndex]));saveOptions();
                compare(activity.dominoMode,modes[modeIndex]);
            }
            for(var level=0;level<(levelLimit>0?levelLimit:9);level++) {
                compare(items.currentLevel,level);
                var total=score.numberOfSubLevels;
                for(var round=0;round<total;round++) {
                    tryVerify(function(){return visibleItems().length>0;},15000);
                    var word=visibleItems()[0];
                    var count=activity.activityName==="smallnumbers"?diceCount(word):dominoCount(word);
                    var before=score.currentSubLevel;
                    textinput.forceActiveFocus();keyClick("#");compare(score.currentSubLevel,before);
                    var y=word.y;wait(100);verify(word.y>y,"The original falling animation moves");
                    enterCount(count.count,round%2===1);tryCompare(score,"currentSubLevel",before+1,1000);
                    observations.push({mode:modes[modeIndex],level:level+1,round:round+1,visual:count,virtualKeys:visualPreference&&round%2===1});
                    if(round===0)grabImage(activityBackground).save("__QA_OUTPUT__/"+modes[modeIndex]+"-level-"+(level+1)+".png");
                }
                tryCompare(items,"currentLevel",(level+1)%9,10000);
                console.log("COUNTING_FALLING_LEVEL",modes[modeIndex],level+1);
            }
        }
    }
    function cleanupTestCase(){console.log("NATIVE_COUNTING_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,observations:observations}));}
}
