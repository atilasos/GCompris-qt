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
 function scoreView(){var text=all(score).filter(o=>o.text!==undefined&&/^\d+\s*\/\s*\d+$/.test(String(o.text))).map(o=>String(o.text));compare(text.length,1,'One painted progress fraction');var split=text[0].split('/');return {text:text[0],found:Number(split[0]),total:Number(split[1])};}
 function clickPixel(pixel,size){var p=img1.mapToItem(pageView,(pixel[0]+0.5)*img1.width/size[0],(pixel[1]+0.5)*img1.height/size[1]);verify(p.x>=0&&p.y>=0&&p.x<pageView.width&&p.y<pageView.height);mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);return {x:p.x,y:p.y};}
 function wrongMarks(){return all(img1).filter(o=>o.source!==undefined&&String(o.source).endsWith('/cross.svg')&&o.opacity>0.1);}
 function paintedCircles(){return all(img1).filter(o=>o.radius!==undefined&&o.border!==undefined&&o.border.width>0&&o.width>=30&&o.width===o.height&&o.opacity>0.9).map(pose);}
 function test_all_photos(){
  wait(1500);compare(activity.numberOfLevel,10);var file=Qt.createQmlObject('import core 1.0; File {}',this);var oracle=JSON.parse(file.read('__QA_SOURCE__/tests/functional_visual_puzzles/visual-oracle.json')).photo_hunter;
  for(var level=1;level<=10;level++){
   compare(activity.currentLevel,level-1);tryCompare(img1,'status',Image.Ready,3000);tryCompare(img2,'status',Image.Ready,3000);wait(1300);var initial=scoreView(),rule=oracle[String(level)],beforeWins=wins;verify(initial.total>0&&initial.found===0);verify(rule.candidates.length>=initial.total);var frame=pose(img1);
   grabImage(pageView).save('__QA_OUTPUT__/level-'+level+'-question.png');var wrong=clickPixel(rule.wrong_pixel,rule.image_size);tryVerify(()=>wrongMarks().length>0,1500);var wrongView={point:wrong,mark:pose(wrongMarks()[0]),score:scoreView()};compare(wrongView.score.found,0);verify(!bonus.isPlaying);grabImage(pageView).save('__QA_OUTPUT__/level-'+level+'-wrong.png');wait(900);
   var attempts=[];
   for(var candidate of rule.candidates){
    var before=scoreView();if(before.found===before.total)break;var point=clickPixel(candidate.pixel,rule.image_size);wait(180);var after=scoreView();verify(after.found===before.found||after.found===before.found+1,'Click on a visible pixel difference repairs or revisits one marked region');verify(wrongMarks().length===0,'Pixel-derived candidate does not produce an incorrect marker');attempts.push({candidate:candidate,point:point,before:before,after:after,circles:paintedCircles()});
   }
   var complete=scoreView();compare(complete.found,complete.total,'All visually advertised differences found');tryCompare(bonus,'isPlaying',true,2000);verify(String(bonus.source).indexOf('good')>=0);var good=String(bonus.source);grabImage(pageView).save('__QA_OUTPUT__/level-'+level+'-success.png');levels.push({level:level,frame:frame,initial:initial,wrong:wrongView,attempts:attempts,complete:complete,bonus:good});tryCompare(qa,'wins',beforeWins+1,10000);tryCompare(activity,'currentLevel',level%10,3000);console.log('PHOTO_HEARTBEAT',level,levels.length);
  }
  ActivityInfoTree.startingActivity='';keyClick(Qt.Key_W,Qt.ControlModifier);tryCompare(pageView,'depth',1,2000);tryCompare(pageView,'busy',false,2000);verify(pageView.currentItem.isMenu);evidence.menuAfterSuccess={depth:pageView.depth,busy:pageView.busy,isMenu:pageView.currentItem.isMenu};grabImage(pageView).save('__QA_OUTPUT__/menu-after-success.png');
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,levels:levels,wins:wins,evidence:evidence}));}
}
