// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'VisibleImagePuzzleInventory'
 when:activity.visible&&activity.numberOfLevel>0
 property var boards:[]
 function all(root){var found=[];if(!root.visible||root.opacity===0)return found;found.push(root);if(root.children)for(var child of root.children)found=found.concat(all(child));return found;}
 function pose(item){var p=item.mapToItem(pageView,item.width/2,item.height/2);return {x:p.x,y:p.y,width:item.width,height:item.height,opacity:item.opacity,visible:item.visible,source:item.source!==undefined?String(item.source):null};}
 function click(item){var p=pose(item);verify(p.x>=0&&p.y>=0&&p.x<pageView.width&&p.y<pageView.height);mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);wait(300);}
 function nextIcon(root,suffix){return all(root).find(o=>o.source!==undefined&&String(o.source).endsWith(suffix)&&o.width>5&&o.opacity>0);}
 function sidebar(){return all(availablePieces).filter(o=>o.source!==undefined&&o.status===Image.Ready&&String(o.source).indexOf(String(activity.imagesUrl))===0&&o.width>10&&pose(o).x>=0&&pose(o).x<pageView.width&&pose(o).y>=0&&pose(o).y<bar.y);}
 function test_calibration(){
  wait(1500);var count=activity.numberOfLevel;
  for(var level=0;level<count;level++){
   compare(activity.currentLevel,level);tryCompare(backgroundImage,'status',Image.Ready,4000);wait(400);
   var candidates=sidebar();verify(candidates.length>0);var piece=candidates[0],source=String(piece.source),from=pose(piece);
   var targets=all(spotsContainer).filter(o=>o.radius!==undefined&&o.width>0&&o.width<30);verify(targets.length>0);var target=pose(targets[0]);
   mousePress(pageView,from.x,from.y);mouseMove(pageView,from.x+14,from.y,60);for(var i=1;i<=14;i++)mouseMove(pageView,from.x+(target.x-from.x)*i/14,from.y+(target.y-from.y)*i/14,20);mouseRelease(pageView,target.x,target.y);wait(700);
   var placed=all(spotsContainer).filter(o=>o.source!==undefined&&String(o.source)===source&&o.width>0);compare(placed.length,1);
   boards.push({level:level+1,total:count,frame:pose(backgroundImage),originalSidebar:from,placed:pose(placed[0]),target:target});
   grabImage(pageView).save('__QA_OUTPUT__/level-'+(level+1)+'-calibration.png');
   if(level+1<count){var next=nextIcon(bar,'bar_next.svg');verify(next!==undefined);click(next);}
  }
 }
 function cleanupTestCase(){console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,activity:activity.activityInfo.shortName(),boards:boards}));}
}
