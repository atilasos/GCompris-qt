// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 function checkEqual(actual,expected,message){if(actual!==expected)console.log('COMPARE_FAILED',actual,expected,message);compare(actual,expected,message);}
 function checkTrue(value,message){if(!value)console.log('ASSERT_FAILED',message);verify(value,message);}

 name:"SharingControls"
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

 function textButton(label){var item=all(dialogActivityConfig).find(child=>child.clicked!==undefined && child.text===label && child.visible);checkTrue(item!==undefined,label);click(item);wait(300);}
 function datasets(){textButton('Conjunto de dados');return all(dialogActivityConfig).filter(child=>child.indicatorImageHeight!==undefined && child.checked!==undefined && child.text!==undefined && child.visible && child.text.indexOf('Máximo')===0);}
 function test_controls(){
  wait(1000);mode(true);checkEqual(activity.numberOfLevel,15);checkEqual(activity.currentLevel,0);
  var depth=pageView.depth;icon(bar,'bar_help.svg');tryCompare(pageView,'depth',depth+1,2000);wait(400);
  var help=pageView.currentItem;checkTrue(help.content.indexOf('Segue as instruções')>=0);checkTrue(help.content.indexOf('frasco de doces')>=0);
  evidence.help={title:String(help.title),content:String(help.content)};grabImage(pageView).save('__QA_OUTPUT__/help.png');keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth,2000);wait(650);
  drag(girlWidget,grid,grid.width/2,grid.height/2);checkEqual(boxes().length,1);evidence.focusAfterHelp=true;
  icon(bar,'bar_reload.svg');checkEqual(boxes().length,0);checkEqual(score.currentSubLevel,0);evidence.partialRestart=true;
  placeChildren();var drawn=boxes();checkEqual(drawn.length,2);
  for(var child of drawn){var before=candies(child).length;drag(candyWidget,child.area,child.area.width/2,child.area.height/2);checkEqual(candies(child).length,before+1);}
  checkEqual(view().reduce((n,b)=>n+b.count,0),2);evidence.extraQuestion={instruction:String(instructionPanel.textItem.text),view:view()};click(okButton);tryCompare(score,'currentSubLevel',1,1200);tryCompare(score,'isWinAnimationPlaying',false,4500);wait(150);
  icon(bar,'bar_previous.svg');checkEqual(activity.currentLevel,14);checkEqual(score.currentSubLevel,0);icon(bar,'bar_next.svg');checkEqual(activity.currentLevel,0);evidence.navigationAfterProgress=true;
  icon(bar,'bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2000);wait(400);checkEqual(counters().checked,true);var choices=datasets();checkEqual(choices.length,3);for(var choice of choices)checkTrue(choice.checked);
  click(choices[0]);checkTrue(!choices[0].checked);save();checkEqual(activity.numberOfLevel,10);checkEqual(score.currentSubLevel,0);
  icon(bar,'bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2000);wait(400);checkEqual(counters().checked,true);choices=datasets();checkEqual(choices.length,3);checkTrue(!choices[0].checked);evidence.persistedModeAndDataset=true;grabImage(pageView).save('__QA_OUTPUT__/selection.png');
  click(choices[0]);save();checkEqual(activity.numberOfLevel,15);evidence.restoredSelection=true;
  icon(activityBackground,'bar_hint.svg');checkTrue(instructionPanel.opacity<0.1);icon(activityBackground,'bar_hint.svg');checkTrue(instructionPanel.opacity>0.9);evidence.hintToggle=true;
  keyClick(Qt.Key_Left);keyClick(Qt.Key_Right);keyClick(Qt.Key_5);checkEqual(boxes().length,0);checkEqual(score.currentSubLevel,0);evidence.unsupportedKeysNoMutation=true;
  ActivityInfoTree.startingActivity='';keyClick(Qt.Key_W,Qt.ControlModifier);tryCompare(pageView,'depth',1,2000);checkTrue(pageView.currentItem.isMenu);evidence.menu=true;grabImage(pageView).save('__QA_OUTPUT__/menu.png');
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_SHARE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
