// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 function assertTrue(value,message){if(!value)console.log('ASSERT_FAILED',message);verify(value,message);}
 function assertEqual(actual,expected,message){if(actual!==expected)console.log('COMPARE_FAILED',actual,expected,message);compare(actual,expected,message);}
 function assertEventually(object,property,value,timeout){try{tryCompare(object,property,value,timeout);}catch(error){console.log('WAIT_FAILED',property,object[property],value);throw error;}}

 name:"GraduatedControlsAndSelection"
 when:activity.visible && ruler.children.length>3
 property var evidence:({})
 function descendants(root) {
  var result=[root];if(root.children)for(var child of root.children)result=result.concat(descendants(child));return result;
 }
 function shownCursor() {
  var candidates=cursor.children.filter(child=>child.width>0 && child.height>0 && child.opacity>0.99);
  assertTrue(candidates.length===1,"One painted cursor");return candidates[0];
 }
 function entered() {
  var text=descendants(shownCursor()).filter(child=>child.text!==undefined);
  assertEqual(text.length,1);return String(text[0].text);
 }
 function line() {
  var marks=ruler.children.filter(child=>child.width>0 && child.height>0).map(child=>{
   var vertical=child.children.filter(rect=>rect.color!==undefined && rect.height>rect.width*2);
   assertTrue(vertical.length===1,"A visible vertical graduation");
   return {x:vertical[0].mapToItem(activityBackground,vertical[0].width/2,0).x};
  }).sort((a,b)=>a.x-b.x);
  assertTrue(marks.length>2);assertTrue(marks[1].x>marks[0].x,"Ruler layout has painted distinct tick positions");
  var x=shownCursor().mapToItem(activityBackground,shownCursor().width/2,0).x;
  var index=-1;for(var i=0;i<marks.length;i++)if(Math.abs(marks[i].x-x)<1)index=i;
  assertTrue(index>=0,"Painted cursor matches a painted tick");
  for(var j=1;j<marks.length;j++)assertTrue(Math.abs((marks[j].x-marks[j-1].x)-(marks[1].x-marks[0].x))<0.02,"Equally spaced ticks");
  return {left:String(leftLimit.text),right:String(rightLimit.text),marks:marks.map(m=>m.x),index:index};
 }
 function pad(label) {
  var matches=descendants(numPad).filter(child=>child.text!==undefined && child.visible && String(child.text)===label);
  assertEqual(matches.length,1,"Displayed keypad label "+label);var text=matches[0];mouseClick(text,text.width/2,text.height/2,Qt.LeftButton,Qt.NoModifier,5);
 }
 function findIcon(root,suffix){return descendants(root).find(child=>child.source!==undefined && String(child.source).endsWith(suffix));}
 function icon(root,suffix){wait(450);var button=findIcon(root,suffix);assertTrue(button!==undefined,suffix);mouseClick(button,button.width/2,button.height/2,Qt.LeftButton,Qt.NoModifier,5);wait(350);}

 function gcd(a,b){a=Math.abs(a);b=Math.abs(b);while(b){var r=a%b;a=b;b=r;}return a;}
 function fraction(n,d){var g=gcd(n,d);return {n:n/g,d:d/g};}
 function numeric(text){var s=String(text).replace(/[\s\u00a0\u202f]/g,'').replace('−','-').replace(',','.');var point=s.indexOf('.');return point<0?fraction(Number(s),1):fraction(Number(s.replace('.','')),Math.pow(10,s.length-point-1));}
 function atTick(view,index){var l=numeric(view.left),r=numeric(view.right),segments=view.marks.length-1;return fraction(l.n*r.d*segments+(r.n*l.d-l.n*r.d)*index,l.d*r.d*segments);}
 function canonical(value){var sign=value.n<0?'-':'',n=Math.abs(value.n),text=sign+Math.floor(n/value.d),remainder=n%value.d;if(remainder)text+=',';for(var i=0;remainder && i<10;i++){remainder*=10;text+=Math.floor(remainder/value.d);remainder%=value.d;}assertTrue(!remainder,'Finite decimal graduated line');return text;}
 function indexFor(view,target){var l=numeric(view.left),r=numeric(view.right),t=numeric(target);var n=(t.n*l.d-l.n*t.d)*r.d*(view.marks.length-1),d=t.d*(r.n*l.d-l.n*r.d);assertEqual(n%d,0,'Requested value is on a visible tick');return n/d;}

 function choices(){return descendants(dialogActivityConfig).filter(child=>child.indicatorImageHeight!==undefined && child.checked!==undefined && child.text!==undefined && child.visible);}
 function save(){var button=descendants(dialogActivityConfig).find(child=>child.clicked!==undefined && child.text==='Gravar' && child.visible);assertTrue(button!==undefined);mouseClick(button,button.width/2,button.height/2,Qt.LeftButton,Qt.NoModifier,5);assertEventually(dialogActivityConfig,'visible',false,2000);wait(800);}
 function test_controls_and_configuration() {
  wait(1200);assertEqual(activity.numberOfLevel,29);assertEqual(activity.currentLevel,13);var read=activity.activityMode==='tick2number';
  var depth=pageView.depth;icon(bar,'bar_help.svg');assertEventually(pageView,'depth',depth+1,2000);wait(400);
  var help=pageView.currentItem;assertEqual(help.title,activity.activityInfo.title);assertTrue(help.content.indexOf('Controlos do teclado')>=0);
  evidence.help={title:String(help.title),content:String(help.content)};grabImage(pageView).save('__QA_OUTPUT__/help.png');keyClick(Qt.Key_Escape);assertEventually(pageView,'depth',depth,2000);wait(700);
  if(read) {
   keyClick(Qt.Key_5);assertEqual(entered(),'5');keyClick(Qt.Key_Comma);assertEqual(entered(),'5');keyClick(Qt.Key_Period);assertEqual(entered(),'5');keyClick(Qt.Key_Backspace);assertEqual(entered(),'');
   pad('7');assertEqual(entered(),'7');keyClick(Qt.Key_Delete);assertEqual(entered(),'');pad('5');
  } else {
   var view=line(),right=view.index+2<view.marks.length-1;
   keyClick(right?Qt.Key_Right:Qt.Key_Left);assertEqual(line().index,view.index+(right?1:-1));
   while(line().index>1)keyClick(Qt.Key_Left);
   keyClick(Qt.Key_Left);assertEqual(line().index,1);mouseClick(leftButton,leftButton.width/2,leftButton.height/2,Qt.LeftButton,Qt.NoModifier,5);assertEqual(line().index,1);
   while(line().index<view.marks.length-2)mouseClick(rightButton,rightButton.width/2,rightButton.height/2,Qt.LeftButton,Qt.NoModifier,5);
   keyClick(Qt.Key_Right);assertEqual(line().index,view.marks.length-2);evidence.bounds={left:1,right:view.marks.length-2,view:view};
  }
  evidence.focusAfterHelp=true;
  icon(bar,'bar_next.svg');assertEqual(activity.currentLevel,14);icon(bar,'bar_previous.svg');assertEqual(activity.currentLevel,13);assertEqual(score.currentSubLevel,0);if(read)assertEqual(entered(),'');evidence.partialRestart=true;
  var view=line(),request=read?canonical(atTick(view,view.index)):String(boxText.text);
  if(read){for(var c of request)pad(c);assertEqual(entered(),request);}
  else {var wanted=indexFor(view,request);while(line().index!==wanted){var right=line().index<wanted;keyClick(right?Qt.Key_Right:Qt.Key_Left);}}
  keyClick(Qt.Key_Return);assertEventually(score,'currentSubLevel',1,1000);assertEventually(score,'isWinAnimationPlaying',false,4000);wait(120);
  icon(bar,'bar_previous.svg');assertEqual(activity.currentLevel,12);assertEqual(score.currentSubLevel,0);icon(bar,'bar_next.svg');assertEqual(activity.currentLevel,13);evidence.previousAfterProgress=true;
  icon(bar,'bar_activity_config.svg');assertEventually(dialogActivityConfig,'visible',true,2000);wait(400);var datasets=choices();assertEqual(datasets.length,10);for(var choice of datasets)assertTrue(choice.checked);
  mouseClick(datasets[0],datasets[0].width/2,datasets[0].height/2,Qt.LeftButton,Qt.NoModifier,5);assertTrue(!datasets[0].checked);save();assertEqual(activity.numberOfLevel,28);assertEqual(score.currentSubLevel,0);
  icon(bar,'bar_activity_config.svg');assertEventually(dialogActivityConfig,'visible',true,2000);wait(400);datasets=choices();assertEqual(datasets.length,10);assertTrue(!datasets[0].checked);evidence.persistedSelection=true;
  grabImage(pageView).save('__QA_OUTPUT__/selection.png');mouseClick(datasets[0],datasets[0].width/2,datasets[0].height/2,Qt.LeftButton,Qt.NoModifier,5);save();assertEqual(activity.numberOfLevel,29);evidence.restoredSelection=true;
  evidence.correctExtra={view:view,request:request};
  ActivityInfoTree.startingActivity='';keyClick(Qt.Key_W,Qt.ControlModifier);assertEventually(pageView,'depth',1,2000);assertTrue(pageView.currentItem.isMenu);evidence.menuByCtrlW=true;grabImage(pageView).save('__QA_OUTPUT__/menu.png');
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_GRADUATED_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
