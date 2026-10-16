// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:'FractionRenderingProbe'
    when:true
    property var evidence: ({})
    function walk(item,result) {
        if(item.pieSeries!==undefined) {
            var slices=[];for(var i=0;i<item.pieSeries.count;i++){var slice=item.pieSeries.at(i);slices.push({color:String(slice.color),value:slice.value,percentage:slice.percentage,startAngle:slice.startAngle,angleSpan:slice.angleSpan});}
            result.push({width:item.width,height:item.height,plotArea:item.plotArea,startAngle:item.pieSeries.startAngle,endAngle:item.pieSeries.endAngle,slices:slices});
        }
        if(item.children)for(var child of item.children)walk(child,result);
    }
    function test_chart_and_labels(){
        wait(1800);if(!activity.visible){keyClick(Qt.Key_Return);tryCompare(activity,'visible',true,2500);wait(1100);}
        var charts=[];walk(chartDisplay,charts);
        evidence={levels:activity.numberOfLevel,mode:activity.mode,instruction:items.instructionItem.text,charts:charts,levelFolder:activity.levelFolder,sublevels:score.numberOfSubLevels};
        console.log('FRACTION_PROBE',JSON.stringify(evidence));grabImage(activityBackground).save('__QA_OUTPUT__/chart.png');
        verify(charts.length>0);verify(charts[0].slices.length>0);
    }
    function cleanupTestCase(){console.log('NATIVE_FRACTIONS_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
