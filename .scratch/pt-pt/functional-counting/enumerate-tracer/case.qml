// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "CountDrawnFruit"
    when: activity.visible && items.numberOfLevel > 0
    property var observations: []
    function picture(root) {
        if(root.source!==undefined && String(root.source).endsWith('.svg'))return root;
        if(root.children)for(var child of root.children){var found=picture(child);if(found)return found;}
        return null;
    }
    function test_visible_fruit_first_level() {
        wait(2400);
        compare(items.numberOfLevel,14);
        for(var round=0;round<score.numberOfSubLevels;round++) {
            var counts={};
            for(var i=0;i<itemList.count;i++) {
                var image=itemList.itemAt(i);compare(image.status,1);verify(image.visible);
                var source=String(image.source);counts[source]=(counts[source]||0)+1;
            }
            var rows=[];
            for(var index=0;index<answerRepeater.count;index++) {
                var answer=answerRepeater.itemAt(index),source=String(picture(answer).source);
                mouseClick(answer);keyClick(Qt.Key_0);
                compare(score.currentSubLevel,round);
                mouseClick(answer);keyClick(Qt.Key_0+counts[source]);
                rows.push({source:source,count:counts[source]});
            }
            observations.push(rows);
            tryCompare(score,"currentSubLevel",round+1);
            if(round+1<score.numberOfSubLevels) {tryCompare(items,"buttonsBlocked",false,6000);wait(2300);}
        }
        tryCompare(items,"currentLevel",1,10000);
    }
    function cleanupTestCase(){console.log("NATIVE_COUNTING_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,observations:observations}));}
}
