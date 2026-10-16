// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 id:qa
 name:'PaletteColorsFromActualPointerPainting'
 when:activity.visible&&activity.numberOfLevel>0
 property var samples:[]
 property var visited:[]
 property int wins:0
 property var failure:({})
 Connections {target:bonus;function onWin(){qa.wins++;}}
 function all(root){var out=[];if(!root.visible||root.opacity===0)return out;out.push(root);if(root.children)for(var c of root.children)out=out.concat(all(c));return out;}
 function pose(o){var p=o.mapToItem(pageView,o.width/2,o.height/2);return {x:p.x,y:p.y,width:o.width,height:o.height};}
 function rects(root){return all(root).filter(o=>o.color!==undefined&&o.border!==undefined&&o.border.width>0&&o.width>5&&o.height>5);}
 function click(o){var p=pose(o);ensure(p.x>=0&&p.y>=0&&p.x<pageView.width&&p.y<pageView.height);mouseClick(pageView,p.x,p.y);wait(350);return p;}
 function next(){var icons=all(bar).filter(o=>o.source!==undefined&&String(o.source).endsWith('bar_next.svg')&&o.width>5);check(icons.length,1);click(icons[0]);}
 function check(a,b,message){if(a!==b)failure={message:message||'',actual:String(a),expected:String(b),stack:new Error().stack};compare(a,b,message||'');}
 function ensure(v,message){if(!v)failure={message:message||'',stack:new Error().stack};verify(v,message||'');}
 function test_calibrate(){
  wait(1500);var file=Qt.createQmlObject('import core 1.0; File {}',this),expected=JSON.parse(file.read('__QA_SOURCE__/tests/functional_patterns/palette-inventory.json'))[activity.activityInfo.shortName()].sources;ensure(expected.length>1);var total=activity.numberOfLevel;
  for(var level=1;level<=total&&samples.length<expected.length;level++){
   check(activity.currentLevel,level-1);var cells=rects(drawingArea);cells.sort((a,b)=>pose(a).y-pose(b).y||pose(a).x-pose(b).x);ensure(cells.length>1);var cell=cells[0],blank=String(cell.color),question=rects(imageArea);ensure(question.filter(o=>String(o.color)!==blank).length>=2,'Neutral one-cell calibration cannot complete this visible pattern');
   var icons=all(colorSelector).filter(o=>o.source!==undefined&&o.status===Image.Ready&&String(o.source).startsWith('qrc:/gcompris/src/activities/redraw/resource/')&&o.width>5);visited.push({level:level,icons:icons.map(o=>({source:String(o.source),frame:pose(o)}))});
   for(var icon of icons){var source=String(icon.source);if(samples.some(s=>s.id===source))continue;ensure(expected.indexOf(source)>=0);var before={frame:pose(cell),color:String(cell.color)},selection=click(icon),paint=click(cell);var after={frame:pose(cell),color:String(cell.color)};samples.push({id:source,signature:after.color,level:level,before:before,selection:selection,paint:paint,after:after});check(wins,0);grabImage(pageView).save('__QA_OUTPUT__/sample-'+samples.length+'.png');}
   if(samples.length<expected.length)next();
  }
  check(samples.length,expected.length);check(wins,0);ActivityInfoTree.startingActivity='';keyClick(Qt.Key_W,Qt.ControlModifier);tryCompare(pageView,'depth',1,2000);tryCompare(pageView,'busy',false,2000);ensure(pageView.currentItem.isMenu);
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,activity:activity.activityInfo.shortName(),samples:samples,visited:visited,wins:wins,failure:failure}));}
}
