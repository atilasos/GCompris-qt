// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:"GraduatedControlsAndSelection"
 when:activity.visible && ruler.children.length>3
 property var evidence:({})
__VISIBLE__
__ORACLE__
 function choices(){return descendants(dialogActivityConfig).filter(child=>child.indicatorImageHeight!==undefined && child.checked!==undefined && child.text!==undefined && child.visible);}
 function save(){var button=descendants(dialogActivityConfig).find(child=>child.clicked!==undefined && child.text==='Gravar' && child.visible);verify(button!==undefined);mouseClick(button,button.width/2,button.height/2,Qt.LeftButton,Qt.NoModifier,5);tryCompare(dialogActivityConfig,'visible',false,2000);wait(800);}
 function test_controls_and_configuration() {
  wait(1200);compare(activity.numberOfLevel,29);compare(activity.currentLevel,13);var read=activity.activityMode==='tick2number';
  var depth=pageView.depth;icon(bar,'bar_help.svg');tryCompare(pageView,'depth',depth+1,2000);wait(400);
  var help=pageView.currentItem;compare(help.title,activity.activityInfo.title);verify(help.content.indexOf('Controlos do teclado')>=0);
  evidence.help={title:String(help.title),content:String(help.content)};grabImage(pageView).save('__QA_OUTPUT__/help.png');keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth,2000);wait(700);
  if(read) {
   keyClick(Qt.Key_5);compare(entered(),'5');keyClick(Qt.Key_Comma);compare(entered(),'5');keyClick(Qt.Key_Period);compare(entered(),'5');keyClick(Qt.Key_Backspace);compare(entered(),'');
   pad('7');compare(entered(),'7');keyClick(Qt.Key_Delete);compare(entered(),'');pad('5');
  } else {
   var view=line(),right=view.index+2<view.marks.length-1;
   keyClick(right?Qt.Key_Right:Qt.Key_Left);compare(line().index,view.index+(right?1:-1));
   while(line().index>1)keyClick(Qt.Key_Left);
   keyClick(Qt.Key_Left);compare(line().index,1);mouseClick(leftButton,leftButton.width/2,leftButton.height/2,Qt.LeftButton,Qt.NoModifier,5);compare(line().index,1);
   while(line().index<view.marks.length-2)mouseClick(rightButton,rightButton.width/2,rightButton.height/2,Qt.LeftButton,Qt.NoModifier,5);
   keyClick(Qt.Key_Right);compare(line().index,view.marks.length-2);evidence.bounds={left:1,right:view.marks.length-2,view:view};
  }
  evidence.focusAfterHelp=true;
  icon(bar,'bar_next.svg');compare(activity.currentLevel,14);icon(bar,'bar_previous.svg');compare(activity.currentLevel,13);compare(score.currentSubLevel,0);if(read)compare(entered(),'');evidence.partialRestart=true;
  var view=line(),request=read?canonical(atTick(view,view.index)):String(boxText.text);
  if(read){for(var c of request)pad(c);compare(entered(),request);}
  else {var wanted=indexFor(view,request);while(line().index!==wanted){var right=line().index<wanted;keyClick(right?Qt.Key_Right:Qt.Key_Left);}}
  keyClick(Qt.Key_Return);tryCompare(score,'currentSubLevel',1,1000);tryCompare(score,'isWinAnimationPlaying',false,4000);wait(120);
  icon(bar,'bar_previous.svg');compare(activity.currentLevel,12);compare(score.currentSubLevel,0);icon(bar,'bar_next.svg');compare(activity.currentLevel,13);evidence.previousAfterProgress=true;
  icon(bar,'bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2000);wait(400);var datasets=choices();compare(datasets.length,10);for(var choice of datasets)verify(choice.checked);
  mouseClick(datasets[0],datasets[0].width/2,datasets[0].height/2,Qt.LeftButton,Qt.NoModifier,5);verify(!datasets[0].checked);save();compare(activity.numberOfLevel,28);compare(score.currentSubLevel,0);
  icon(bar,'bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2000);wait(400);datasets=choices();compare(datasets.length,10);verify(!datasets[0].checked);evidence.persistedSelection=true;
  grabImage(pageView).save('__QA_OUTPUT__/selection.png');mouseClick(datasets[0],datasets[0].width/2,datasets[0].height/2,Qt.LeftButton,Qt.NoModifier,5);save();compare(activity.numberOfLevel,29);evidence.restoredSelection=true;
  evidence.correctExtra={view:view,request:request};
  ActivityInfoTree.startingActivity='';keyClick(Qt.Key_W,Qt.ControlModifier);tryCompare(pageView,'depth',1,2000);verify(pageView.currentItem.isMenu);evidence.menuByCtrlW=true;grabImage(pageView).save('__QA_OUTPUT__/menu.png');
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_GRADUATED_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
