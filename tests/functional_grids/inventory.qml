TestCase {
 name:'OfferedGridDatasetsAndVisibleGeometry'
 when:activity.visible&&boardItem.width>0
 property var evidence: ({datasets:[],records:[]})
__VISIBLE__
 function test_inventory(){wait(1900);openConfig();var boxes=configBoxes();ensure(boxes.length>0);evidence.datasets=boxes.map(function(item){return {label:String(item.text),checked:item.checked};});grabImage(pageView).save('__QA_OUTPUT__/datasets.png');var count=boxes.length;var cancel=find(dialogActivityConfig,function(item){return item.text==='Cancelar'&&item.clicked!==undefined&&drawn(item);});ensure(cancel!==null);click(cancel);tryCompare(dialogActivityConfig,'visible',false);for(var dataset=0;dataset<count;dataset++){var selected=chooseDataset(dataset);var number=activity.numberOfLevel;ensure(number>0);for(var level=1;level<=number;level++){compare(bar.level,level);var current=screen();current.dataset=dataset+1;current.selection=selected;evidence.records.push(current);grabImage(pageView).save('__QA_OUTPUT__/dataset-'+(dataset+1)+'-level-'+level+'.png');console.log('GRIDS_INVENTORY',arithmetic?'calcudoku':'sudoku',dataset+1,count,level,number,current.size,current.score);icon('bar_next.svg');}compare(bar.level,1);}}
 function cleanupTestCase(){console.log('NATIVE_GRIDS_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
