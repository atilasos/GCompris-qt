// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 id:qa
 name:'DetailsFromVisiblePicturePixels'
 when:activity.visible&&activity.numberOfLevel>0
 property var boards:[]
 property var evidence:({})
 property int wins:0
 property int moves:0
 Connections {target:bonus;function onWin(){qa.wins++;}}
 function check(actual,expected,message){if(actual!==expected){evidence.failure={kind:'comparison',actual:String(actual),expected:String(expected),message:message||'',stack:new Error().stack};console.log('DETAIL_ASSERT',JSON.stringify(evidence.failure));}compare(actual,expected,message||'');}
 function ensure(value,message){if(!value){evidence.failure={kind:'verification',message:message||'',stack:new Error().stack};console.log('DETAIL_ASSERT',JSON.stringify(evidence.failure));}verify(value,message||'');}
 function all(root){var found=[];if(!root.visible||root.opacity===0)return found;found.push(root);if(root.children)for(var child of root.children)found=found.concat(all(child));return found;}
 function pose(item){var p=item.mapToItem(pageView,item.width/2,item.height/2);return {x:p.x,y:p.y,width:item.width,height:item.height,opacity:item.opacity,visible:item.visible,source:item.source!==undefined?String(item.source):null};}
 function images(root){return all(root).filter(o=>o.source!==undefined&&o.status===Image.Ready&&String(o.source).indexOf(String(activity.imagesUrl))===0&&o.width>10&&o.height>10);}
 function sidebar(){return images(availablePieces).filter(o=>pose(o).x>=0&&pose(o).x<pageView.width&&pose(o).y>=0&&pose(o).y<bar.y);}
 function icon(root,suffix){var target=all(root).find(o=>o.source!==undefined&&String(o.source).endsWith(suffix)&&o.width>5);ensure(target!==undefined,'Real drawn icon '+suffix);var p=pose(target);mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);wait(100);}
 function drag(image,target){var a=pose(image),source=String(image.source);ensure(target.x>=0&&target.y>=0&&target.x<pageView.width&&target.y<bar.y);mousePress(pageView,a.x,a.y);mouseMove(pageView,a.x+14,a.y,60);for(var i=1;i<=14;i++)mouseMove(pageView,a.x+(target.x-a.x)*i/14,a.y+(target.y-a.y)*i/14,20);mouseRelease(pageView,target.x,target.y);wait(550);var placed=images(spotsContainer).filter(o=>String(o.source)===source);check(placed.length,1,'Drop accepted through actual pointer path');moves++;return {source:source,from:a,target:target,placed:pose(placed[0])};}
 function answer(image,rule){var source=String(image.source),match=rule.answers[source];ensure(match!==undefined,'Pixel-derived image identity');var p=backgroundImage.mapToItem(pageView,backgroundImage.width*match.center[0],backgroundImage.height*match.center[1]);return {x:p.x,y:p.y,pixelMatch:match};}
 function test_all_details(){
  wait(1500);check(activity.numberOfLevel,21);var file=Qt.createQmlObject('import core 1.0; File {}',this);var oracle=JSON.parse(file.read('__QA_SOURCE__/tests/functional_visual_puzzles/visual-oracle.json')).details;
  for(var level=1;level<=21;level++){
   check(activity.currentLevel,level-1);tryCompare(backgroundImage,'status',Image.Ready,4000);wait(450);var rule=oracle[String(level)];check(String(backgroundImage.source),rule.background);var frame=pose(backgroundImage),beforeWins=wins,first=sidebar();ensure(first.length>=2);var a=first[0],b=first[1],nameA=String(a.source),nameB=String(b.source),targetA=answer(a,rule),targetB=answer(b,rule);ensure(Math.abs(targetA.x-targetB.x)+Math.abs(targetA.y-targetB.y)>2);var placements=[];grabImage(pageView).save('__QA_OUTPUT__/level-'+level+'-question.png');
   var wrongA=drag(a,targetB),wrongB=drag(b,targetA);placements.push({piece:nameA,target:targetA});placements.push({piece:nameB,target:targetB});
   for(var step=0;step<40;step++){
    var remaining=sidebar();if(remaining.length===0)break;var image=remaining[0],source=String(image.source),target=answer(image,rule);placements.push({piece:source,target:target});drag(image,target);ensure(step<39,'Finite piece list');
   }
   check(placements.length,Object.keys(rule.answers).length,'All independently inventoried pieces placed');icon(availablePieces,'bar_ok.svg');wait(180);check(wins,beforeWins);ensure(!bonus.isPlaying);var errors=all(spotsContainer).filter(o=>o.source!==undefined&&String(o.source).endsWith('/error.svg'));ensure(errors.length>=2,'Swapped details visibly rejected');var errorViews=errors.map(pose);grabImage(pageView).save('__QA_OUTPUT__/level-'+level+'-wrong.png');
   var dropped=images(spotsContainer).filter(o=>String(o.source)===nameA);check(dropped.length,1);drag(dropped[0],targetA);var returned=sidebar().filter(o=>String(o.source)===nameB);check(returned.length,1,'Replaced piece returns to visible panel');drag(returned[0],targetB);grabImage(pageView).save('__QA_OUTPUT__/level-'+level+'-answer.png');icon(availablePieces,'bar_ok.svg');tryCompare(bonus,'isPlaying',true,2000);ensure(String(bonus.source).indexOf('good')>=0);var good=String(bonus.source);boards.push({level:level,frame:frame,instruction:String(instructionPanel.textItem.text),placements:placements,wrong:[wrongA,wrongB],errors:errorViews,bonus:good});tryCompare(qa,'wins',beforeWins+1,10000);tryCompare(activity,'currentLevel',level%21,3000);console.log('DETAIL_HEARTBEAT',level,boards.length);
  }
  ActivityInfoTree.startingActivity='';keyClick(Qt.Key_W,Qt.ControlModifier);tryCompare(pageView,'depth',1,2000);tryCompare(pageView,'busy',false,2000);ensure(pageView.currentItem.isMenu);evidence.menuAfterSuccess={depth:pageView.depth,busy:pageView.busy,isMenu:pageView.currentItem.isMenu};grabImage(pageView).save('__QA_OUTPUT__/menu-after-success.png');
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,boards:boards,wins:wins,moves:moves,evidence:evidence}));}
}
