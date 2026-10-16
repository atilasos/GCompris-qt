// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 id:qa
 name:'PublicPaintingCaptions'
 when:activity.visible&&activity.numberOfLevel>0
 property var records:[]
 property var mismatches:[]
 function all(root){var found=[];if(!root.visible||root.opacity===0)return found;found.push(root);if(root.children)for(var child of root.children)found=found.concat(all(child));return found;}
 function next(){var icons=all(bar).filter(o=>o.source!==undefined&&String(o.source).endsWith('bar_next.svg')&&o.width>5);compare(icons.length,1);var p=icons[0].mapToItem(pageView,icons[0].width/2,icons[0].height/2);mouseClick(pageView,p.x,p.y);wait(200);}
 function test_captions(){
  wait(1500);var file=Qt.createQmlObject('import core 1.0; File {}',this);var expected=JSON.parse(file.read('__QA_SOURCE__/tests/functional_visual_puzzles/expected-titles.json'))[activity.activityInfo.shortName()];var total=activity.activityInfo.shortName()==='details'?21:22;compare(activity.numberOfLevel,total);
  for(var level=1;level<=total;level++){
   compare(activity.currentLevel,level-1);tryCompare(backgroundImage,'status',Image.Ready,3000);var text=String(instructionPanel.textItem.text);records.push({level:level,text:text});if(expected[String(level)]!==undefined){if(text!==expected[String(level)])mismatches.push({level:level,observed:text,expected:expected[String(level)]});grabImage(pageView).save('__QA_OUTPUT__/caption-'+level+'.png');}next();
  }
  compare(activity.currentLevel,0);compare(mismatches.length,0,'All corrected visible captions match researched PT text');
 }
 function cleanupTestCase(){console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,records:records,mismatches:mismatches}));}
}
