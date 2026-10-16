// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 id:qa
 name:'VisiblePolygonTutorialInventory'
 when:activity.visible&&activity.numberOfLevel>0
 property var boards:[]
 function all(root){var out=[];if(!root.visible||root.opacity===0)return out;out.push(root);if(root.children)for(var c of root.children)out=out.concat(all(c));return out;}
 function pose(o){var p=o.mapToItem(pageView,o.width/2,o.height/2);return {x:p.x,y:p.y,width:o.width,height:o.height};}
 function texts(root){return all(root).filter(o=>o.text!==undefined&&String(o.text).length>0).map(o=>({text:String(o.text),frame:pose(o)}));}
 function buttons(root){return all(root).filter(o=>o.clicked!==undefined&&o.text!==undefined&&o.width>20&&o.height>15);}
 function click(o){var p=pose(o);mouseClick(pageView,p.x,p.y);wait(250);}
 function next(){var icons=all(bar).filter(o=>o.source!==undefined&&String(o.source).endsWith('bar_next.svg')&&o.width>5);compare(icons.length,1);click(icons[0]);}
 function test_inventory(){
  wait(1500);var total=activity.numberOfLevel;verify(total>0&&total<100);
  for(var level=1;level<=total;level++){
   compare(activity.currentLevel,level-1);wait(300);var pages=[];
   for(var page=0;tutorialInstruction.visible&&page<15;page++){
    var bs=buttons(tutorialInstruction);verify(bs.length>0);pages.push({texts:texts(tutorialInstruction),buttons:bs.map(o=>({text:String(o.text),frame:pose(o)})),illustration:String(tutorialImage.source)});grabImage(pageView).save('__QA_OUTPUT__/level-'+level+'-intro-'+page+'.png');var advance=bs.find(o=>['Seguinte','Próximo','Next'].indexOf(String(o.text))>=0);if(advance!==undefined)click(advance);else {bs.sort((a,b)=>pose(a).x-pose(b).x);click(bs[bs.length-1]);}
   }
   verify(!tutorialInstruction.visible,'Finite introduction completed through visible buttons');boards.push({level:level,total:total,pages:pages,instruction:String(instructionPanel.textItem.text),grid:pose(sceneGrid),texts:texts(activityBackground)});grabImage(pageView).save('__QA_OUTPUT__/level-'+level+'-question.png');next();
  }
  compare(activity.currentLevel,0);
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,boards:boards}));}
}
