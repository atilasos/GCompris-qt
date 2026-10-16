// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'ActualRenderedPhotoDifferencesInventory'
 when:activity.visible&&activity.numberOfLevel>0
 property var boards:[]
 function all(root){var found=[];if(!root.visible||root.opacity===0)return found;found.push(root);if(root.children)for(var child of root.children)found=found.concat(all(child));return found;}
 function pose(item){var p=item.mapToItem(pageView,item.width/2,item.height/2);return {x:p.x,y:p.y,width:item.width,height:item.height,source:String(item.source)};}
 function test_inventory(){
  wait(1500);var count=activity.numberOfLevel;
  for(var level=0;level<count;level++){
   compare(activity.currentLevel,level);tryCompare(img1,'status',Image.Ready,4000);tryCompare(img2,'status',Image.Ready,4000);wait(1300);
   grabImage(img1).save('__QA_OUTPUT__/level-'+(level+1)+'-left.png');grabImage(img2).save('__QA_OUTPUT__/level-'+(level+1)+'-right.png');grabImage(pageView).save('__QA_OUTPUT__/level-'+(level+1)+'-question.png');
   boards.push({level:level+1,total:count,left:pose(img1),right:pose(img2),instruction:String(instructionPanel.textItem.text)});
   if(level+1<count){var next=all(bar).find(o=>o.source!==undefined&&String(o.source).endsWith('bar_next.svg')&&o.width>5);verify(next!==undefined);var p=pose(next);mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);wait(500);}
  }
 }
 function cleanupTestCase(){console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,boards:boards}));}
}
