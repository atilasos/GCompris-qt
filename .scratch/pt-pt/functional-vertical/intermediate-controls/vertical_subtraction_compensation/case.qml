// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:"VerticalPortugueseControls"
 when:activity.visible && numberRepeater.count>0
 property var evidence:({})
 function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var value=find(child,predicate);if(value)return value;}return null;}
 function icon(root,suffix){wait(400);var button=find(root,function(item){return item.source!==undefined && String(item.source).endsWith(suffix);});verify(button!==null,suffix);mouseClick(button,button.width/2,button.height/2,Qt.LeftButton,Qt.NoModifier,5);wait(500);}
 function textButton(root,text){var button=find(root,function(item){return item.clicked!==undefined && item.text===text && item.visible;});verify(button!==null,text);mouseClick(button,button.width/2,button.height/2,Qt.LeftButton,Qt.NoModifier,5);}
 function choices(root,values){if(root.indicatorImageHeight!==undefined && root.checked!==undefined && root.text!==undefined && root.visible)values.push(root);if(root.children)for(var child of root.children)choices(child,values);}
 function test_help_focus_restart_selection_persistence_and_menu() {
  wait(1200);compare(activity.numberOfLevel,12);
  icon(bar,'bar_next.svg');compare(activity.currentLevel,1);
  icon(bar,'bar_previous.svg');compare(activity.currentLevel,0);compare(score.currentSubLevel,0);
  var depth=pageView.depth;icon(bar,'bar_help.svg');tryCompare(pageView,'depth',depth+1,2000);wait(500);
  var help=pageView.currentItem;compare(help.title,activity.activityInfo.title);verify(help.content.indexOf(activity.activityInfo.description)>=0);
  verify(help.content.indexOf('In a vertical')<0);verify(help.content.indexOf('In vertical')<0);verify(help.title.indexOf('Vertical')<0);
  grabImage(pageView).save('__QA_OUTPUT__/help.png');keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth,2000);wait(400);
  keyClick(Qt.Key_Return);tryCompare(errorRectangle.errorAnimation,'running',true,1000);tryCompare(errorRectangle.errorAnimation,'running',false,3000);compare(score.currentSubLevel,0);
  icon(bar,'bar_next.svg');icon(bar,'bar_previous.svg');compare(activity.currentLevel,0);compare(score.currentSubLevel,0);
  icon(bar,'bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2000);wait(400);
  var datasets=[];choices(dialogActivityConfig,datasets);compare(datasets.length,12);for(var choice of datasets)verify(choice.checked);
  mouseClick(datasets[0],datasets[0].width/2,datasets[0].height/2,Qt.LeftButton,Qt.NoModifier,5);verify(!datasets[0].checked);
  grabImage(pageView).save('__QA_OUTPUT__/selection.png');textButton(dialogActivityConfig,'Gravar');tryCompare(dialogActivityConfig,'visible',false,2000);wait(1000);compare(activity.numberOfLevel,11);
  icon(bar,'bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2000);wait(400);datasets=[];choices(dialogActivityConfig,datasets);compare(datasets.length,12);verify(!datasets[0].checked);
  mouseClick(datasets[0],datasets[0].width/2,datasets[0].height/2,Qt.LeftButton,Qt.NoModifier,5);textButton(dialogActivityConfig,'Gravar');tryCompare(dialogActivityConfig,'visible',false,2000);wait(1000);compare(activity.numberOfLevel,12);
  evidence={help:true,focusAfterHelp:true,wrongAnswer:true,navigation:true,restart:true,datasetChoices:12,persistedSelection:true,restoredSelection:true};
  ActivityInfoTree.startingActivity='';icon(bar,'bar_home.svg');tryCompare(pageView,'depth',1,2000);verify(pageView.currentItem.isMenu);evidence.menu=true;grabImage(pageView).save('__QA_OUTPUT__/menu.png');
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_VERTICAL_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
