// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name: 'VisibleLightsByIndependentElimination'
 when: activity.visible && grid.width>0
 property int targetLevels: 1
 property var boards: []
 property var evidence: ({})
 function ensure(value,message){if(!value){console.log('LIGHT_ASSERT',message,new Error().stack);grabImage(pageView).save('__QA_OUTPUT__/failure.png');}verify(value,message||'');}
 function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var hit=find(child,predicate);if(hit)return hit;}return null;}
 function click(item){ensure(item!==null,'Visible control');var p=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);wait(45);}
 function icon(root,suffix){wait(1700);click(find(root,function(o){return o.visible&&o.source!==undefined&&String(o.source).endsWith(suffix);}));}
 function windows(){
  var images=[];
  function walk(item){
   if(item.visible&&item.opacity>0.9&&item.source!==undefined&&/lightsoff\/resource\/(?:on|off)\.svg$/.test(String(item.source))){
    tryCompare(item,'status',1,2000);var point=item.mapToItem(grid,item.width/2,item.height/2);
    ensure(point.x>=0&&point.y>=0&&point.x<=grid.width&&point.y<=grid.height,'Window centre inside board');
    images.push({item:item,x:point.x,y:point.y,width:item.width,height:item.height,source:String(item.source)});
   }
   if(item.children)for(var child of item.children)walk(child);
  }
  walk(grid);images.sort(function(a,b){return Math.abs(a.y-b.y)>1?a.y-b.y:a.x-b.x;});
  var size=Math.sqrt(images.length);ensure(Number.isInteger(size)&&size>=5&&size<=9,'Square visible board');
  for(var i=0;i<images.length;i++){var tile=images[i];ensure(Math.abs(tile.x-(i%size+0.5)*grid.cellWidth)<1&&Math.abs(tile.y-(Math.floor(i/size)+0.5)*grid.cellHeight)<1,'Row-major drawn geometry');}
  return images;
 }
 function state(){return windows().map(function(o){return o.source.endsWith('/on.svg')?1:0;});}
 function equal(a,b,message){compare(JSON.stringify(a),JSON.stringify(b),message||'Visible board');}
 function toggle(board,size,index){var result=board.slice(),r=Math.floor(index/size),c=index%size;for(var pair of [[r,c],[r-1,c],[r+1,c],[r,c-1],[r,c+1]])if(pair[0]>=0&&pair[0]<size&&pair[1]>=0&&pair[1]<size)result[pair[0]*size+pair[1]]=1-result[pair[0]*size+pair[1]];return result;}
 function solution(board,size){
  var count=board.length,matrix=[],pivots=[];
  for(var row=0;row<count;row++){var cells=[];for(var col=0;col<count;col++){var r=Math.floor(row/size),c=row%size,rr=Math.floor(col/size),cc=col%size;cells.push(Math.abs(r-rr)+Math.abs(c-cc)<=1?1:0);}cells.push(board[row]);matrix.push(cells);}
  for(var column=0;column<count;column++){
   var pivot=-1;for(var candidate=pivots.length;candidate<count;candidate++)if(matrix[candidate][column]){pivot=candidate;break;}
   if(pivot<0)continue;var at=pivots.length,swap=matrix[at];matrix[at]=matrix[pivot];matrix[pivot]=swap;
   for(var other=0;other<count;other++)if(other!==at&&matrix[other][column])for(var k=column;k<=count;k++)matrix[other][k]^=matrix[at][k];
   pivots.push(column);
  }
  for(var check=pivots.length;check<count;check++)ensure(matrix[check][count]===0,'Solvable observed board');
  var result=[];for(var p=0;p<pivots.length;p++)if(matrix[p][count])result.push(pivots[p]);return result;
 }
 function press(index,before,size){var expected=toggle(before,size,index);click(windows()[index].item);equal(state(),expected,'Cross toggle for real click');return expected;}
 function puzzle(level){
  wait(300);var before=state(),size=Math.sqrt(before.length);ensure(before.some(function(v){return v===1;}),'New puzzle is not already solved');
  var candidate=0;while(toggle(before,size,candidate).every(function(v){return v===0;}))candidate++;
  var changed=press(candidate,before,size);compare(activity.currentLevel,level-1);ensure(!bonus.isPlaying,'A nonwinning move stays in puzzle');
  var restored=press(candidate,changed,size);equal(restored,before,'Same click repairs nonwinning move');
  var answer=solution(before,size),steps=[],current=before;ensure(answer.length>0,'Nonempty independent solution');
  for(var index of answer){current=press(index,current,size);steps.push({cell:index,after:current});}
  ensure(current.every(function(v){return v===0;}),'All drawn lights off');
  tryCompare(bonus,'isPlaying',true,2500);tryVerify(function(){return bonus.opacity>0.5;},1500);var feedback=String(bonus.source);ensure(feedback.indexOf('good')>=0,'Natural good Bonus');
  return {level:level,size:size,before:before,probe:{cell:candidate,changed:changed,restored:restored},moves:steps,bonus:feedback};
 }
 function boxes(){var result=[];function walk(item){if(item.visible&&item.indicatorImageHeight!==undefined&&item.checked!==undefined)result.push(item);if(item.children)for(var child of item.children)walk(child);}walk(dialogActivityConfig);return result;}
 function openConfig(){icon(bar,'bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2500);wait(800);compare(boxes().length,9);}
 function saveConfig(){dialogActivityConfig.forceActiveFocus();keyClick(Qt.Key_Return);tryCompare(dialogActivityConfig,'visible',false,2500);wait(350);}
 function test_controls(){
  wait(1500);compare(activity.activityInfo.title,'Apaga as luzes');var original=state();compare(original.length,25);
  keyClick(Qt.Key_Right);compare(grid.currentIndex,1);keyClick(Qt.Key_Down);compare(grid.currentIndex,6);keyClick(Qt.Key_Up);compare(grid.currentIndex,1);keyClick(Qt.Key_Left);compare(grid.currentIndex,0);
  ensure(activityBackground.keyNavigationVisible,'Visible keyboard highlight');keyClick(Qt.Key_Space);wait(100);equal(state(),toggle(original,5,0),'Space toggles highlighted window');keyClick(Qt.Key_Return);wait(100);equal(state(),original,'Return repairs keyboard move');evidence.keyboard=true;
  var hinted=function(){return windows().filter(function(row){return row.item.parent.color.a>0.05;}).length;};compare(hinted(),0);click(tux);ensure(hinted()>0,'Hint actually draws colored window borders');click(tux);compare(hinted(),0);evidence.hint=true;
  var changed=press(0,original,5);ensure(JSON.stringify(changed)!==JSON.stringify(original));icon(bar,'bar_reload.svg');wait(300);equal(state(),original,'Reload restores fixed puzzle');evidence.restart=true;
  icon(bar,'bar_next.svg');compare(activity.currentLevel,1);icon(bar,'bar_previous.svg');compare(activity.currentLevel,0);equal(state(),original);icon(bar,'bar_previous.svg');compare(activity.currentLevel,98);compare(state().length,81);ensure(state().some(function(v){return v===1;}));icon(bar,'bar_next.svg');compare(activity.currentLevel,0);evidence.navigation=true;
  openConfig();var last=boxes()[8];ensure(last.checked);var label=String(last.text);click(last);ensure(!last.checked);saveConfig();compare(activity.numberOfLevel,89);
  openConfig();last=boxes()[8];compare(String(last.text),label);ensure(!last.checked);click(last);saveConfig();compare(activity.numberOfLevel,99);evidence.configurationSameProcess=true;
  var depth=pageView.depth;icon(bar,'bar_help.svg');tryCompare(pageView,'depth',depth+1,2500);wait(700);var help=pageView.currentItem;compare(help.title,'Apaga as luzes');ensure(help.content.indexOf('Desliga todas as luzes.')>=0,'Portuguese help');grabImage(pageView).save('__QA_OUTPUT__/help.png');keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth,2500);wait(350);
  var before=state();keyClick(Qt.Key_Space);wait(100);equal(state(),toggle(before,5,grid.currentIndex),'Keyboard focus after Escape without force or click');keyClick(Qt.Key_Return);wait(100);equal(state(),before);evidence.helpAndFocus=true;
  ActivityInfoTree.startingActivity='';icon(bar,'bar_home.svg');tryCompare(pageView,'depth',1,2500);ensure(pageView.currentItem.isMenu,'Menu');evidence.menu=true;
 }
 function cleanupTestCase(){console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,boards:boards,evidence:evidence}));}
}
