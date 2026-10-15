// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "InstructionPanelDragReadiness"
    when: activity.visible && items.numberOfLevel>0
    property bool waitForPanel: true
    property var evidence: ({})
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

    function candidate() {
        var origin=instructionPanel.mapToItem(activityBackground,0,0);
        for(var index=itemList.count-1;index>=0;index--) {
            var image=itemList.itemAt(index),point=image.mapToItem(activityBackground,image.width/2,image.height/2);
            if(point.x<origin.x || point.x>origin.x+instructionPanel.width || point.y<origin.y || point.y>origin.y+instructionPanel.height)continue;
            var topmost=true;
            for(var other=index+1;other<itemList.count;other++) {
                var cover=itemList.itemAt(other),corner=cover.mapToItem(activityBackground,0,0);
                if(point.x>corner.x && point.x<corner.x+cover.width && point.y>corner.y && point.y<corner.y+cover.height)topmost=false;
            }
            if(topmost)return image;
        }
        return null;
    }
    function test_wait_for_the_real_panel_to_release_pointer_input() {
        wait(2400);var image=candidate();
        for(var attempt=0;image===null && attempt<15;attempt++) {
            clickIcon(bar,"bar_next.svg");clickIcon(bar,"bar_previous.svg");wait(2400);image=candidate();
        }
        verify(image!==null,"A naturally generated fruit lies under the instruction panel");
        var point=image.mapToItem(activityBackground,image.width/2,image.height/2);
        mouseClick(instructionPanel);
        if(waitForPanel)tryCompare(instructionPanel,"opacity",0,1000);
        var opacity=instructionPanel.opacity;
        mousePress(activityBackground,point.x,point.y,Qt.LeftButton,Qt.NoModifier,20);
        mouseMove(activityBackground,point.x+15,point.y+15,20,Qt.LeftButton);
        mouseMove(activityBackground,point.x+30,point.y+30,20,Qt.LeftButton);
        mouseMove(activityBackground,point.x+60,point.y+60,40,Qt.LeftButton);
        evidence={waitForPanel:waitForPanel,panelOpacityAtPress:opacity,point:[point.x,point.y],dragActive:image.Drag.active};
        console.log("COUNTING_PANEL_DRAG",JSON.stringify(evidence));
        var active=image.Drag.active;
        mouseRelease(activityBackground,point.x+60,point.y+60,Qt.LeftButton,Qt.NoModifier,20);
        verify(active,"The fruit must receive the drag after hiding the instruction");
    }
    function cleanupTestCase(){grabImage(activityBackground).save("__QA_OUTPUT__/panel-drag.png");console.log("NATIVE_COUNTING_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
