// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "CountingDatasetSelectors"
    when: activity.visible && items.numberOfLevel>0
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

    function collect(root,result) {
        if(root.indicatorImageHeight!==undefined && root.checked!==undefined && root.text!==undefined && root.visible)result.push(root);
        if(root.children)for(var child of root.children)collect(child,result);
    }
    function showDatasets() {
        clickIcon(bar,"bar_activity_config.svg");tryCompare(dialogActivityConfig,"visible",true);wait(600);
        clickText(dialogActivityConfig,"Conjunto de dados");wait(300);
        var choices=[];collect(dialogActivityConfig,choices);
        return choices;
    }
    function scrollThrough(choices) {
        var flick=find(dialogActivityConfig,function(item){return item.contentY!==undefined && item.flickableDirection!==undefined;});verify(flick!==null);
        var seen={};
        for(var attempt=0;attempt<12;attempt++) {
            for(var index=0;index<choices.length;index++) {
                var point=choices[index].mapToItem(flick,choices[index].width/2,choices[index].height/2);
                if(point.y>0 && point.y<flick.height)seen[index]=true;
            }
            var down=find(dialogActivityConfig,function(item){return item.source!==undefined && String(item.source).endsWith('/scroll_down.svg') && item.rotation===0 && item.visible;});
            if(down===null)break;
            mouseClick(down);wait(700);
        }
        compare(Object.keys(seen).length,choices.length,"Every dataset entry appeared inside the viewport");
    }
    function test_dataset_identifiers_are_not_runtime_level_indices() {
        wait(1600);
        var fruits=activity.activityInfo.shortName()==="enumerate";
        var expected=fruits?4:8,full=fruits?14:9,withoutLast=fruits?10:8;
        compare(activity.levelFolder.length,expected);compare(items.numberOfLevel,full);
        var choices=showDatasets();compare(choices.length,expected);
        var labels=[];for(var choice of choices){verify(choice.checked);verify(choice.text.length>0);labels.push(choice.text);}
        grabImage(pageView).save("__QA_OUTPUT__/datasets-top.png");scrollThrough(choices);
        grabImage(pageView).save("__QA_OUTPUT__/datasets-bottom.png");
        mouseClick(choices[choices.length-1]);verify(!choices[choices.length-1].checked);
        saveOptions();compare(activity.levelFolder.length,expected-1);compare(items.numberOfLevel,withoutLast);
        choices=showDatasets();compare(choices.length,expected);scrollThrough(choices);
        verify(!choices[choices.length-1].checked);mouseClick(choices[choices.length-1]);saveOptions();
        compare(activity.levelFolder.length,expected);compare(items.numberOfLevel,full);
        evidence={datasetLabels:labels,datasetIdentifiers:expected,runtimeLevels:full,runtimeWithoutLast:withoutLast,restored:true};
    }
    function cleanupTestCase(){if(qtest_results.failCount>0)grabImage(pageView).save("__QA_OUTPUT__/failure.png");console.log("NATIVE_COUNTING_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
