// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 id:qa
 name:'PhotoDifferencesFromActualRenderedPixels'
 when:activity.visible&&activity.numberOfLevel>0
 property var levels:[]
 property var evidence:({})
 property int wins:0
 Connections {target:bonus;function onWin(){qa.wins++;}}
 function all(root){var found=[];if(!root.visible||root.opacity===0)return found;found.push(root);if(root.children)for(var child of root.children)found=found.concat(all(child));return found;}
 function pose(item){var p=item.mapToItem(pageView,item.width/2,item.height/2);return {x:p.x,y:p.y,width:item.width,height:item.height,opacity:item.opacity,visible:item.visible,source:item.source!==undefined?String(item.source):null};}
 function scoreView(){var text=all(score).filter(o=>o.text!==undefined&&/^\d+\s*\/\s*\d+$/.test(String(o.text))).map(o=>String(o.text));check(text.length,1,'One painted progress fraction');var split=text[0].split('/');return {text:text[0],found:Number(split[0]),total:Number(split[1])};}
 function clickPixel(pixel,size){var p=img1.mapToItem(pageView,(pixel[0]+0.5)*img1.width/size[0],(pixel[1]+0.5)*img1.height/size[1]);ensure(p.x>=0&&p.y>=0&&p.x<pageView.width&&p.y<pageView.height);mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);return {x:p.x,y:p.y};}
 function wrongMarks(){return all(img1).filter(o=>o.source!==undefined&&String(o.source).endsWith('/cross.svg')&&o.opacity>0.1);}
 function paintedCircles(){return all(img1).filter(o=>o.radius!==undefined&&o.border!==undefined&&o.border.width>0&&o.width>=30&&o.width===o.height&&o.opacity>0.9).map(pose);}
 function icon(suffix){var found=all(bar).filter(o=>o.source!==undefined&&String(o.source).endsWith(suffix)&&o.width>5);check(found.length,1,suffix);var p=pose(found[0]);mouseClick(pageView,p.x,p.y);wait(150);}
 function check(a,b,message){if(a!==b)evidence.failure={message:message||'',actual:String(a),expected:String(b),stack:new Error().stack};compare(a,b,message||'');}
 function ensure(v,message){if(!v)evidence.failure={message:message||'',stack:new Error().stack};verify(v,message||'');}
 function test_public_controls(){
  wait(1500);check(activity.numberOfLevel,10);tryCompare(img1,'status',Image.Ready,3000);tryCompare(img2,'status',Image.Ready,3000);
  var file=Qt.createQmlObject('import core 1.0; File {}',this),rule=JSON.parse(file.read('__QA_SOURCE__/tests/functional_visual_puzzles/visual-oracle.json')).photo_hunter['1'];
  var initial=scoreView();clickPixel(rule.candidates[0].pixel,rule.image_size);wait(200);check(scoreView().found,1);ensure(!bonus.isPlaying);grabImage(pageView).save('__QA_OUTPUT__/partial.png');
  icon('bar_next.svg');check(activity.currentLevel,1);icon('bar_previous.svg');check(activity.currentLevel,0);wait(500);check(scoreView().found,0);
  var depth=pageView.depth;icon('bar_help.svg');tryCompare(pageView,'depth',depth+1,2500);tryCompare(pageView,'busy',false,2500);var help=pageView.currentItem;check(help.title,activity.activityInfo.title);ensure(help.content.indexOf(activity.activityInfo.manual)>=0);ensure(activity.activityInfo.manual.indexOf('diferenças')>=0);evidence.help={title:help.title,manual:activity.activityInfo.manual};grabImage(pageView).save('__QA_OUTPUT__/help.png');keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth,2500);tryCompare(pageView,'busy',false,2500);wait(350);
  icon('bar_hint.svg');tryCompare(slider,'enabled',true,1500);ensure(slider.opacity>0.9);tryVerify(()=>Math.abs(pose(img1).x-pose(img2).x)<1&&Math.abs(pose(img1).y-pose(img2).y)<1,2000);var a=pose(img1),b=pose(img2);ensure(Math.abs(a.x-b.x)<1&&Math.abs(a.y-b.y)<1,'Hint visibly overlays the two images');var before={value:slider.value,opacity:img2.opacity,instruction:String(instructionPanel.textItem.text),frame:a};
  var p=slider.mapToItem(pageView,slider.width*0.08,slider.height/2),q=slider.mapToItem(pageView,slider.width*0.92,slider.height/2);mousePress(pageView,p.x,p.y);for(var i=1;i<=12;i++)mouseMove(pageView,p.x+(q.x-p.x)*i/12,p.y,30);mouseRelease(pageView,q.x,q.y);wait(250);ensure(slider.value>0.7);ensure(img2.opacity<0.3);evidence.hint={before:before,after:{value:slider.value,opacity:img2.opacity,instruction:String(instructionPanel.textItem.text)}};grabImage(pageView).save('__QA_OUTPUT__/hint.png');icon('bar_hint.svg');tryCompare(slider,'enabled',false,1500);tryVerify(()=>Math.abs(pose(img1).x-pose(img2).x)>300,2000);check(scoreView().found,0);
  clickPixel(rule.candidates[0].pixel,rule.image_size);wait(200);check(scoreView().found,1);evidence.partialRestart=true;evidence.mouseAfterHelp=true;
  ActivityInfoTree.startingActivity='';icon('bar_home.svg');tryCompare(pageView,'depth',1,2500);tryCompare(pageView,'busy',false,2500);ensure(pageView.currentItem.isMenu);evidence.menuDuringActivity={depth:pageView.depth,busy:pageView.busy,isMenu:pageView.currentItem.isMenu};grabImage(pageView).save('__QA_OUTPUT__/menu.png');
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
