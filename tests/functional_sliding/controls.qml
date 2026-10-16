// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'SlidingKeyboardReloadNavigationHelp'
 when:activity.visible&&items.numberOfLevel>0
 property var evidence: ({})
__VISIBLE__
 function selectedArrow(){var hits=[];for(var d of ['L','R','T','B'])for(var i=0;i<4;i++){var rect=find(arrow(d,i),function(item){return item.border!==undefined&&drawn(item)&&String(item.border.color)==='#ffffff';});if(rect)hits.push({direction:d,index:i});}ensure(hits.length===1,'Visible selected arrow border');return hits[0];}
 function test_controls(){
  wait(1800);compare(items.numberOfLevel,14);var initial=board();evidence={initial:initial,mode:mode,keyboard:[],detour:[],hint:false,reload:false};
  if(mode==='fifteen'){
   var empty=initial.values.indexOf(0),far=0;while(far===empty||neighbors(empty).indexOf(far)>=0)far++;click(tileAt(far));wait(310);ensure(same(board().values,initial.values),'Nonadjacent click leaves board unchanged');evidence.nonadjacentUnchanged=true;
   var adjacent=neighbors(empty).filter(function(cell){var value=initial.values.slice();value[empty]=value[cell];value[cell]=0;return !same(value,target());})[0];evidence.detour.push(slideMove(initial,adjacent,'drag'));evidence.detour.push(slideMove(board(),empty,'key'));ensure(same(board().values,initial.values));
  }else{
   var row=0;while(same(rotateExpected(initial.values,'L',row),target()))row++;evidence.detour.push(rotateMove(initial,'L',row,'click'));var partial=board();ensure(!same(partial.values,initial.values));icon('bar_reload.svg');ensure(same(board().values,initial.values),'Reload restores actual initial board');evidence.reload=true;
   icon('bar_hint.svg');var firstHint=visualHint();icon('bar_hint.svg');ensure(same(board().values,initial.values),'Hint toggle preserves board');var highlights=0;for(var direction of ['L','R','T','B'])for(var index=0;index<4;index++)if(find(arrow(direction,index),function(item){return item.color!==undefined&&String(item.color)==='#804280ff';}))highlights++;compare(highlights,0);icon('bar_hint.svg');compare(visualHint().direction,firstHint.direction);compare(visualHint().index,firstHint.index);evidence.hint=true;
   for(var key of [Qt.Key_Right,Qt.Key_Down,Qt.Key_Left,Qt.Key_Up]){keyClick(key);wait(100);var selected=selectedArrow();evidence.keyboard.push({key:key,selected:selected});ensure(same(board().values,initial.values),'Selection does not move pieces');}
   var selected=selectedArrow();if(same(rotateExpected(initial.values,selected.direction,selected.index),target())){keyClick(Qt.Key_Right);selected=selectedArrow();}
   var move=rotateMove(board(),selected.direction,selected.index,'key');evidence.keyboardMove=move;keyClick(Qt.Key_Return);wait(310);evidence.returnMove={before:move.after,after:board().values,direction:selected.direction,index:selected.index,input:'Return'};ensure(same(evidence.returnMove.after,rotateExpected(move.after,selected.direction,selected.index)),'Return activates selected arrow');icon('bar_reload.svg');ensure(same(board().values,initial.values));
  }
  icon('bar_previous.svg');compare(items.currentLevel,13);icon('bar_next.svg');compare(items.currentLevel,0);icon('bar_next.svg');compare(items.currentLevel,1);var second=board();ensure(second.tiles.every(function(tile){return tile.text==='';}),'Even level hides numbers');icon('bar_previous.svg');compare(items.currentLevel,0);var restarted=board();ensure(!same(restarted.values,target()));evidence.wrap=true;evidence.partialRestart=true;
  var depth=pageView.depth;icon('bar_help.svg');tryCompare(pageView,'depth',depth+1);var help=pageView.currentItem;var title=mode==='fifteen'?'O jogo dos quinze':'O jogo dos dezasseis';compare(help.title,title);ensure(help.content.indexOf(activity.activityInfo.manual)>=0);ensure(help.content.indexOf('Click on')<0);ensure(help.content.indexOf(mode==='fifteen'?'Clica ou arrasta uma peça junto ao espaço vazio para a mover para esse espaço.':'Clica numa seta para deslizar a linha ou a coluna correspondente nessa direção.')>=0);evidence.help={title:String(help.title),content:String(help.content)};grabImage(pageView).save('__QA_OUTPUT__/help.png');keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth);wait(1800);
  if(mode==='fifteen'){var empty=restarted.values.indexOf(0),cell=neighbors(empty).filter(function(candidate){var value=restarted.values.slice();value[empty]=value[candidate];value[candidate]=0;return !same(value,target());})[0];evidence.afterHelp=slideMove(board(),cell,'key');}else{keyClick(Qt.Key_Right);var selected=selectedArrow();evidence.afterHelp=rotateMove(board(),selected.direction,selected.index,'key');}
  evidence.focusAfterHelp=true;var bootstrap=Qt.createQmlObject('import QtQml; import core 1.0; QtObject { function clearStandalone() { ActivityInfoTree.startingActivity = ""; } }',pageView);bootstrap.clearStandalone();bootstrap.destroy();icon('bar_home.svg');tryCompare(pageView,'depth',1,3000);ensure(pageView.currentItem.isMenu,'Actual menu');evidence.menu=true;grabImage(pageView).save('__QA_OUTPUT__/menu.png');
 }
 function cleanupTestCase(){console.log('NATIVE_SLIDING_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
