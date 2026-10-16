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
        var previous=box.currentIndex;
        for(var step=0;step<Math.abs(index-previous);step++)keyClick(index>previous?Qt.Key_Right:Qt.Key_Left);
        keyClick(Qt.Key_Return);wait(250);compare(box.currentIndex,index);
    }

    function picture(root) {
        if(root.source!==undefined && String(root.source).endsWith('.svg'))return root;
        if(root.children)for(var child of root.children){var found=picture(child);if(found)return found;}
        return null;
    }
    function dragFruit() {
        var image=itemList.itemAt(itemList.count-1);
        var start=image.mapToItem(activityBackground,image.width/2,image.height/2);
        var x=start.x>activityBackground.width-100?start.x-65:start.x+65;
        mousePress(activityBackground,start.x,start.y,Qt.LeftButton,Qt.NoModifier,20);
        mouseMove(activityBackground,start.x+15,start.y+15,20,Qt.LeftButton);
        mouseMove(activityBackground,start.x+30,start.y+30,20,Qt.LeftButton);
        mouseMove(activityBackground,x,start.y+35,40,Qt.LeftButton);
        verify(image.Drag.active,"A real drag owns the intended fruit");
        mouseRelease(activityBackground,x,start.y+35,Qt.LeftButton,Qt.NoModifier,20);
        wait(300);
        var end=image.mapToItem(activityBackground,image.width/2,image.height/2);
        verify(Math.abs(end.x-start.x)+Math.abs(end.y-start.y)>15,"Fruit has been reorganized by input");
        return {source:String(image.source),from:[start.x,start.y],to:[end.x,end.y]};
    }
    function inputAnswer(answer,value,virtualKeys) {
        mouseClick(answer);
        if(virtualKeys) {
            var key=find(keyboard,function(item){return item.specialKey!==undefined && item.text===String(value);});
            verify(key!==null);mouseClick(key);
        } else keyClick(Qt.Key_0+value);
        compare(answer.itemText,String(value));
    }
    function test_all_datasets() {
        wait(2400);
        ApplicationSettings.isVirtualKeyboard=true;
        var panel=openOptions();chooseMode(panel,validationMode-1);saveOptions();
        compare(items.mode,validationMode);compare(items.numberOfLevel,14);
        compare(activity.levelFolder.length,4);
        for(var level=0;level<14;level++) {
            compare(items.currentLevel,level);
            var total=score.numberOfSubLevels;
            for(var round=0;round<total;round++) {
                wait(2300);
                if(instructionPanel.opacity>0)mouseClick(instructionPanel);
                var counts={},pictures=[];
                for(var i=0;i<itemList.count;i++) {
                    var image=itemList.itemAt(i);compare(image.status,1);verify(image.visible);
                    var source=String(image.source);counts[source]=(counts[source]||0)+1;
                    pictures.push(source);
                }
                var drag=dragFruit(),rows=[];
                for(var index=0;index<answerRepeater.count;index++) {
                    var answer=answerRepeater.itemAt(index);
                    inputAnswer(answer,0,false);compare(score.currentSubLevel,round);
                }
                if(validationMode===2) {
                    mouseClick(okButton);compare(score.currentSubLevel,round);
                    for(var index=0;index<answerRepeater.count;index++)compare(answerRepeater.itemAt(index).state,"badAnswer");
                    tryCompare(items,"buttonsBlocked",false,5000);
                }
                for(var index=0;index<answerRepeater.count;index++) {
                    var answer=answerRepeater.itemAt(index),source=String(picture(answer).source);
                    verify(counts[source]>0);
                    inputAnswer(answer,counts[source],(round+index)%2===1);
                    rows.push({source:source,count:counts[source]});
                }
                if(validationMode===2)mouseClick(okButton);
                observations.push({mode:validationMode,level:level+1,round:round+1,pictures:pictures,answers:rows,drag:drag});
                tryCompare(score,"currentSubLevel",round+1);
                if(round+1<total)tryCompare(items,"buttonsBlocked",false,6000);
                else {tryCompare(bonus,"isPlaying",true,6000);tryCompare(items,"currentLevel",(level+1)%14,10000);}
            }
            console.log("COUNTING_LEVEL_COMPLETED",validationMode,level+1);
        }
    }
    function cleanupTestCase(){console.log("NATIVE_COUNTING_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,observations:observations}));}
}
