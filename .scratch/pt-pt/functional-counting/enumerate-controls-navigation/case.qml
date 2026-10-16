// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "CountingFruitControls"
    when: activity.visible && items.numberOfLevel>0
    property var evidence: []
    function checked(actual,expected,message) {
        if(actual!==expected)console.log("COUNTING_ASSERT",JSON.stringify({actual:actual,expected:expected,message:message}),new Error().stack);
        compare(actual,expected,message||"");
    }
    function ensure(value,message) {
        if(!value)console.log("COUNTING_ASSERT",message||"",new Error().stack);
        verify(value,message||"");
    }
    function awaiting(object,key,value,timeout) {
        try {tryCompare(object,key,value,timeout||6000);}
        catch(error){console.log("COUNTING_WAIT",key,String(object[key]),String(value),new Error().stack);throw error;}
    }
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

    function dragFruit() {
        var image=itemList.itemAt(itemList.count-1);
        var start=image.mapToItem(activityBackground,image.width/2,image.height/2);
        var x=start.x>activityBackground.width-100?start.x-65:start.x+65;
        mousePress(activityBackground,start.x,start.y,Qt.LeftButton,Qt.NoModifier,20);
        mouseMove(activityBackground,start.x+15,start.y+15,20,Qt.LeftButton);
        mouseMove(activityBackground,start.x+30,start.y+30,20,Qt.LeftButton);
        mouseMove(activityBackground,x,start.y+35,40,Qt.LeftButton);
        ensure(image.Drag.active,"A real drag owns the intended fruit");
        mouseRelease(activityBackground,x,start.y+35,Qt.LeftButton,Qt.NoModifier,20);
        wait(300);
        var end=image.mapToItem(activityBackground,image.width/2,image.height/2);
        ensure(Math.abs(end.x-start.x)+Math.abs(end.y-start.y)>15,"Fruit has been reorganized by input");
        return {source:String(image.source),from:[start.x,start.y],to:[end.x,end.y]};
    }

    function test_controls_and_physical_focus_with_both_preferences() {
        wait(2400);checked(items.numberOfLevel,14);checked(activity.levelFolder.length,4);
        checked(activity.activityInfo.title,"Contagem dos itens");
        while(items.currentLevel<4) {clickIcon(bar,"bar_next.svg");}
        wait(2400);var initial=items.currentLevel;ensure(answerRepeater.count>=2);
        clickIcon(bar,"bar_next.svg");checked(items.currentLevel,(initial+1)%14);
        clickIcon(bar,"bar_previous.svg");checked(items.currentLevel,initial);
        for(var visualKeys of [false,true]) {
            ApplicationSettings.isVirtualKeyboard=visualKeys;wait(500);
            var depth=pageView.depth;clickIcon(bar,"bar_help.svg");awaiting(pageView,"depth",depth+1);wait(600);
            var help=pageView.currentItem;checked(help.title,"Contagem dos itens");
            ensure(help.content.indexOf(activity.activityInfo.description)>=0);
            grabImage(pageView).save("__QA_OUTPUT__/help-"+visualKeys+".png");
            clickIcon(help,"cancel.svg");awaiting(pageView,"depth",depth);wait(500);
            keyClick(Qt.Key_Down);checked(answerRepeater.currentIndex,1);
            keyClick(Qt.Key_Up);checked(answerRepeater.currentIndex,0);
            keyClick(Qt.Key_0);checked(answerRepeater.itemAt(0).itemText,"0");checked(score.currentSubLevel,0);
            if(instructionPanel.opacity>0){mouseClick(instructionPanel);awaiting(instructionPanel,"opacity",0);}
            var drag=dragFruit();
            var panel=openOptions();saveOptions();checked(items.currentLevel,0);checked(score.currentSubLevel,0);
            while(items.currentLevel<initial)clickIcon(bar,"bar_next.svg");wait(2400);
            for(var index=0;index<answerRepeater.count;index++)checked(answerRepeater.itemAt(index).itemText,"?");
            evidence.push({visualKeyboard:visualKeys,helpFocus:true,restartPartialAnswerAndDrag:true,drag:drag});
        }
        ActivityInfoTree.startingActivity="";clickIcon(bar,"bar_home.svg");awaiting(pageView,"depth",1);ensure(pageView.currentItem.isMenu);
    }
    function cleanupTestCase(){if(qtest_results.failCount>0)grabImage(activityBackground).save("__QA_OUTPUT__/failure.png");console.log("NATIVE_COUNTING_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
