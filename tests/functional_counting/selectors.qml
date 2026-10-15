// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "CountingDatasetSelectors"
    when: activity.visible && items.numberOfLevel>0
    property var evidence: ({})
__UI_HELPERS__
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
