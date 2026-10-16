// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:"SharingControls"
 when:activity.visible
 property var evidence:({})
__VISIBLE__
 function textButton(label){var item=all(dialogActivityConfig).find(child=>child.clicked!==undefined && child.text===label && child.visible);verify(item!==undefined,label);click(item);wait(300);}
 function datasets(){textButton('Conjunto de dados');return all(dialogActivityConfig).filter(child=>child.indicatorImageHeight!==undefined && child.checked!==undefined && child.text!==undefined && child.visible && child.text.indexOf('Máximo')===0);}
 function test_controls(){
  wait(1000);mode(__EASY__);compare(activity.numberOfLevel,15);compare(activity.currentLevel,0);
  var depth=pageView.depth;icon(bar,'bar_help.svg');tryCompare(pageView,'depth',depth+1,2000);wait(400);
  var help=pageView.currentItem;verify(help.content.indexOf('Segue as instruções')>=0);verify(help.content.indexOf('frasco de doces')>=0);
  evidence.help={title:String(help.title),content:String(help.content)};grabImage(pageView).save('__QA_OUTPUT__/help.png');keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth,2000);wait(650);
  drag(girlWidget,grid,grid.width/2,grid.height/2);compare(boxes().length,1);evidence.focusAfterHelp=true;
  icon(bar,'bar_reload.svg');compare(boxes().length,0);compare(score.currentSubLevel,0);evidence.partialRestart=true;
  placeChildren();var drawn=boxes();compare(drawn.length,2);
  for(var child of drawn){var before=candies(child).length;drag(candyWidget,child.area,child.area.width/2,child.area.height/2);compare(candies(child).length,before+1);}
  compare(view().reduce((n,b)=>n+b.count,0),2);evidence.extraQuestion={instruction:String(instructionPanel.textItem.text),view:view()};click(okButton);tryCompare(score,'currentSubLevel',1,1200);tryCompare(score,'isWinAnimationPlaying',false,4500);wait(150);
  icon(bar,'bar_previous.svg');compare(activity.currentLevel,14);compare(score.currentSubLevel,0);icon(bar,'bar_next.svg');compare(activity.currentLevel,0);evidence.navigationAfterProgress=true;
  icon(bar,'bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2000);wait(400);compare(counters().checked,__EASY__);var choices=datasets();compare(choices.length,3);for(var choice of choices)verify(choice.checked);
  click(choices[0]);verify(!choices[0].checked);save();compare(activity.numberOfLevel,10);compare(score.currentSubLevel,0);
  icon(bar,'bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2000);wait(400);compare(counters().checked,__EASY__);choices=datasets();compare(choices.length,3);verify(!choices[0].checked);evidence.persistedModeAndDataset=true;grabImage(pageView).save('__QA_OUTPUT__/selection.png');
  click(choices[0]);save();compare(activity.numberOfLevel,15);evidence.restoredSelection=true;
  icon(activityBackground,'bar_hint.svg');verify(instructionPanel.opacity<0.1);icon(activityBackground,'bar_hint.svg');verify(instructionPanel.opacity>0.9);evidence.hintToggle=true;
  keyClick(Qt.Key_Left);keyClick(Qt.Key_Right);keyClick(Qt.Key_5);compare(boxes().length,0);compare(score.currentSubLevel,0);evidence.unsupportedKeysNoMutation=true;
  ActivityInfoTree.startingActivity='';keyClick(Qt.Key_W,Qt.ControlModifier);tryCompare(pageView,'depth',1,2000);verify(pageView.currentItem.isMenu);evidence.menu=true;grabImage(pageView).save('__QA_OUTPUT__/menu.png');
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_SHARE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
