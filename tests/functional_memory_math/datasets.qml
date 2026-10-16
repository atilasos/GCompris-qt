// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"MathematicalMemoryDatasetSelections"
    when:true
    property var labels: []
    property var selections: []
    function initTestCase(){
        wait(1600);
        if(!activity.visible){keyClick(Qt.Key_Return,Qt.NoModifier,0);tryCompare(activity,"visible",true,2500);}
    }
    function test_portuguese_objectives_and_selected_level_contract(){
        var family=activity.activityInfo.shortName().replace("memory-math-","").replace(/-tux$/,"");
        var count=family==="mult-div"?9:10;
        var prefixes={add:"Tabela de adições do ",minus:"Tabela de subtrações do ",mult:"Tabuada do ",div:"Tabela de divisões do "};
        var all=[];
        for(var folder=1;folder<=count;folder++) {
            all.push(String(folder));
            var dataset=activity.activityInfo.getDataset(String(folder));
            var table=family==="mult-div"?folder+1:folder;
            var expected=(prefixes[family]||"Tabela do ")+table+".";
            compare(dataset.objective,expected,"Portuguese objective for selected table");
            compare(dataset.data.length,1);compare(dataset.data[0].columns,5);compare(dataset.data[0].rows,2);
            labels.push({folder:folder,table:table,objective:dataset.objective});
        }
        for(var chosen of [[String(count)],["1",String(count)],all]) {
            activity.stop();activity.levelFolder=chosen;activity.start();wait(1100);
            compare(items.numberOfLevel,chosen.length);compare(activity.numberOfLevel,chosen.length);
            compare(items.currentLevel,0);compare(cardGrid.count,10);
            compare(items.player1Score.playerScore,0);compare(items.player2Score.playerScore,0);
            selections.push(chosen.slice());
        }
    }
    function cleanupTestCase(){console.log("NATIVE_MEMORY_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,labels:labels,selections:selections}));}
}
