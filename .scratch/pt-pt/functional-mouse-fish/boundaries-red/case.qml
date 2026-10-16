// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"DuckArrowLimits"
    when:activity.visible
    property var positions: []
    function test_continuous_arrows_keep_the_whole_duck_inside() {
        wait(1600);
        for(var arrow of [arrowsArea.rightArrow,arrowsArea.downArrow,arrowsArea.leftArrow,arrowsArea.upArrow]) {
            mousePress(arrow,arrow.width/2,arrow.height/2,Qt.LeftButton,Qt.NoModifier,0);
            wait(1800);mouseRelease(arrow,arrow.width/2,arrow.height/2,Qt.LeftButton,Qt.NoModifier,0);
            var row={x:mainArea.mainDuckX,y:mainArea.mainDuckY,maxX:mainArea.rightDirectionLimit,maxY:mainArea.downDirectionLimit};positions.push(row);
            console.log("DUCK_LIMIT",JSON.stringify(row));
            verify(row.x>=0&&row.x<=row.maxX&&row.y>=0&&row.y<=row.maxY,"Whole duck remains within its play area");
        }
        grabImage(activityBackground).save("__QA_OUTPUT__/duck-boundaries.png");
    }
    function cleanupTestCase(){console.log("NATIVE_MOUSE_FISH_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,positions:positions}));}
}
