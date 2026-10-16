// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 id:qa
 name:'VisiblePatternInventory'
 when:activity.visible&&activity.numberOfLevel>0
 property var boards:[]
 function all(root){var out=[];if(!root.visible||root.opacity===0)return out;out.push(root);if(root.children)for(var c of root.children)out=out.concat(all(c));return out;}
 function pose(o){var p=o.mapToItem(pageView,o.width/2,o.height/2);return {x:p.x,y:p.y,width:o.width,height:o.height,visible:o.visible,opacity:o.opacity};}
 function rectangles(root){return all(root).filter(o=>o.color!==undefined&&o.border!==undefined&&o.border.width===1&&o.width>5&&o.height>5).map(o=>({frame:pose(o),color:String(o.color)}));}
 function images(root){return all(root).filter(o=>o.source!==undefined&&o.width>5&&o.height>5).map(o=>({frame:pose(o),source:String(o.source),status:o.status}));}
 function next(){var icons=all(bar).filter(o=>o.source!==undefined&&String(o.source).endsWith('bar_next.svg')&&o.width>5);compare(icons.length,1);var p=pose(icons[0]);mouseClick(pageView,p.x,p.y);wait(250);}
 function test_inventory(){
  wait(1500);var total=activity.numberOfLevel;verify(total>0&&total<250);var name=activity.activityInfo.shortName();
  for(var level=1;level<=total;level++){
   compare(activity.currentLevel,level-1);wait(250);var record={level:level,total:total,title:activity.activityInfo.title};
   if(name==='mosaic'){record.question=images(question);record.answer=images(answer);record.selector=images(selector);verify(record.question.length>0);verify(record.selector.length>0);}
   else {record.question=rectangles(imageArea);record.answer=rectangles(drawingArea);record.palette=images(colorSelector);verify(record.question.length>0);compare(record.question.length,record.answer.length);}
   grabImage(pageView).save('__QA_OUTPUT__/level-'+level+'.png');boards.push(record);next();
  }
  compare(activity.currentLevel,0);
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,activity:activity.activityInfo.shortName(),boards:boards}));}
}
