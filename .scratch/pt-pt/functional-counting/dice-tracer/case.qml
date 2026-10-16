// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "FallingVisibleCounts"
    when: activity.visible && items.numberOfLevel>0
    property var dice: {"qrc:/gcompris/src/activities/smallnumbers/resource/dice3.svg": 3, "qrc:/gcompris/src/activities/smallnumbers/resource/dice7.svg": 7, "qrc:/gcompris/src/activities/smallnumbers/resource/dice1.svg": 1, "qrc:/gcompris/src/activities/smallnumbers/resource/dice4.svg": 4, "qrc:/gcompris/src/activities/smallnumbers/resource/dice9.svg": 9, "qrc:/gcompris/src/activities/smallnumbers/resource/dice8.svg": 8, "qrc:/gcompris/src/activities/smallnumbers/resource/dice5.svg": 5, "qrc:/gcompris/src/activities/smallnumbers/resource/dice0.svg": 0, "qrc:/gcompris/src/activities/smallnumbers/resource/dice6.svg": 6, "qrc:/gcompris/src/activities/smallnumbers/resource/dice2.svg": 2}
    property var observations: []
    function visibleItems() {
        var found=[];
        for(var child of activityBackground.children)
            if(child.wonState!==undefined && !child.wonState && child.opacity===1 && child.y>=0 && child.y+child.height<bar.y)
                found.push(child);
        return found.sort(function(a,b){return b.y-a.y;});
    }
    function diceCount(word) {
        for(var child of word.children)if(child.source!==undefined && dice[String(child.source)]!==undefined) {
            compare(child.status,1);
            return {source:String(child.source),count:dice[String(child.source)]};
        }
        fail("A visible audited die image is required");
    }
    function test_first_level_visible_dice() {
        wait(1600);ApplicationSettings.isVirtualKeyboard=true;
        compare(items.numberOfLevel,9);
        var total=score.numberOfSubLevels;
        for(var round=0;round<total;round++) {
            tryVerify(function(){return visibleItems().length>0;},12000);
            var word=visibleItems()[0],count=diceCount(word),before=score.currentSubLevel;
            textinput.forceActiveFocus();keyClick("#");compare(score.currentSubLevel,before);
            var y=word.y;wait(100);verify(word.y>y,"The original falling animation moves");
            keyClick(String(count.count));tryCompare(score,"currentSubLevel",before+1,1000);
            observations.push(count);
        }
        tryCompare(items,"currentLevel",1,10000);
    }
    function cleanupTestCase(){console.log("NATIVE_COUNTING_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,observations:observations}));}
}
