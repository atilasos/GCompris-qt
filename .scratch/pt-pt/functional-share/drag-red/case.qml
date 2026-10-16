// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 function checkEqual(actual,expected,message){if(actual!==expected)console.log('COMPARE_FAILED',actual,expected,message);compare(actual,expected,message);}
 function checkTrue(value,message){if(!value)console.log('ASSERT_FAILED',message);verify(value,message);}

 name:"HiddenCounterSidebarCoordinates"
 when:activity.visible
 property var evidence:({})
 function all(root){var rows=[root];if(root.children)for(var child of root.children)rows=rows.concat(all(child));return rows;}
 function boxes(){return dropAreas.children.filter(child=>child.childImage!==undefined && child.width>0);}
 function candies(box){return all(box.area).filter(child=>child.source!==undefined && String(child.source).endsWith('/candy.svg') && child.width>0);}
 function view(){return boxes().map(box=>({kind:String(box.childImage.source).split('/').pop().replace('.svg',''),count:candies(box).length,label:String(box.candyCount.text)}));}
 function drag(source,target,x,y){
  var a=source.mapToItem(activityBackground,source.width/2,source.height/2),b=target.mapToItem(activityBackground,x,y);
  mousePress(activityBackground,a.x,a.y,Qt.LeftButton,Qt.NoModifier,10);
  for(var i=1;i<=8;i++)mouseMove(activityBackground,a.x+(b.x-a.x)*i/8,a.y+(b.y-a.y)*i/8,10);
  mouseRelease(activityBackground,b.x,b.y,Qt.LeftButton,Qt.NoModifier,10);wait(40);
 }
 function click(item){mouseClick(item,item.width/2,item.height/2,Qt.LeftButton,Qt.NoModifier,10);wait(30);}
 function findIcon(root,suffix){return all(root).find(child=>child.source!==undefined && String(child.source).endsWith(suffix));}
 function icon(root,suffix){wait(450);var item=findIcon(root,suffix);checkTrue(item!==undefined,suffix);click(item);wait(350);}
 function counters(){return all(dialogActivityConfig).find(child=>child.indicatorImageHeight!==undefined && child.text==='Mostrar os contadores');}
 function save(){var item=all(dialogActivityConfig).find(child=>child.clicked!==undefined && child.text==='Gravar' && child.visible);checkTrue(item!==undefined);click(item);tryCompare(dialogActivityConfig,'visible',false,2000);wait(700);}
 function mode(easy){
  icon(bar,'bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2000);wait(400);
  var choice=counters();checkTrue(choice!==undefined);if(choice.checked!==easy)click(choice);checkEqual(choice.checked,easy);save();
 }
 function placeChildren(){
  for(var widget of [girlWidget,boyWidget])if(widget.visible){var limit=0;while(widget.element.opacity>0.9 && limit++<6)drag(widget,grid,grid.width/2,grid.height/2);checkTrue(limit<=6);}
  checkTrue(boxes().length>=2 && boxes().length<=6);
  if(basketWidget.visible && basketWidget.element.opacity>0.9)drag(basketWidget,grid,grid.width/2,grid.height/2);
 }

 function test_drag_after_next_question(){
  wait(1000);mode(false);placeChildren();checkEqual(boxes().length,2);
  var box=boxes()[1],before=candies(box).length;
  evidence={instruction:String(instructionPanel.textItem.text),before:view(),sourcePosition:candyWidget.mapToItem(activityBackground,0,0),destination:box.area.mapToItem(activityBackground,box.area.width/2,box.area.height/2)};
  drag(candyWidget,box.area,box.area.width/2,box.area.height/2);
  evidence.after=view();grabImage(activityBackground).save('__QA_OUTPUT__/after.png');
  checkEqual(candies(box).length,before+1,'One sidebar candy dragged to painted destination');
 }
 function cleanupTestCase(){console.log('NATIVE_SHARE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
