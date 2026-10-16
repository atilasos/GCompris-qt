// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "CountDrawnFruit"
    when: activity.visible && items.numberOfLevel > 0
    property var observations: []
    property int validationMode: 2
    function find(root,predicate) {
        if(predicate(root))return root;
        if(root.children)for(var child of root.children){var result=find(child,predicate);if(result)return result;}
        return null;
    }
    function clickIcon(root,suffix) {
        wait(400);
        var button=find(root,function(item){return item.source!==undefined && String(item.source).endsWith(suffix);});
        verify(button!==null,"Icon "+suffix);mouseClick(button);
    }
    function clickText(root,text) {
        var button=find(root,function(item){return item.clicked!==undefined && item.text===text && item.visible;});
        verify(button!==null,"Button "+text);mouseClick(button);
    }
    function openOptions() {
        clickIcon(bar,"bar_activity_config.svg");tryCompare(dialogActivityConfig,"visible",true);wait(600);
        clickText(dialogActivityConfig,"Opções");wait(300);
        return find(dialogActivityConfig,function(item){return item.modeBox!==undefined || item.speedSlider!==undefined;});
    }
    function saveOptions() {
        clickText(dialogActivityConfig,"Gravar");tryCompare(dialogActivityConfig,"visible",false);wait(2400);
    }
    function chooseMode(panel,index) {
        verify(panel!==null);
        var box=panel.modeBox;
        var label=find(box,function(item){return item.text!==undefined && item.text===box.currentText && item.visible;});
        verify(label!==null);mouseClick(label);wait(200);
        keyClick(Qt.Key_Home);for(var step=0;step<index;step++)keyClick(Qt.Key_Right);
        keyClick(Qt.Key_Return);wait(250);compare(box.currentIndex,index);
    }

    function picture(root) {
        if(root.source!==undefined && String(root.source).endsWith('.svg'))return root;
        if(root.children)for(var child of root.children){var found=picture(child);if(found)return found;}
        return null;
    }
    function test_visible_fruit_first_level() {
        wait(2400);
        var panel=openOptions();chooseMode(panel,validationMode-1);saveOptions();
        compare(items.mode,validationMode);
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
            if(validationMode===2)mouseClick(okButton);
            observations.push(rows);
            tryCompare(score,"currentSubLevel",round+1);
            if(round+1<score.numberOfSubLevels) {tryCompare(items,"buttonsBlocked",false,6000);wait(2300);}
        }
        tryCompare(items,"currentLevel",1,10000);
    }
    function cleanupTestCase(){console.log("NATIVE_COUNTING_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,observations:observations}));}
}
