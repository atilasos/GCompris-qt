TestCase {
 name:'FamilyVisibleInventory'
 when:activity.visible&&nodeRepeater.count>0
 property var records: []
__VISIBLE__
 function test_visible_inventory(){wait(1900);compare(activity.numberOfLevel,18);for(var i=0;i<18;i++){compare(bar.level,i+1);records.push(screen());grabImage(pageView).save('__QA_OUTPUT__/level-'+(i+1)+'.png');icon('bar_next.svg');}compare(bar.level,1);}
 function cleanupTestCase(){console.log('NATIVE_FAMILY_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,records:records}));}
}
