// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 id:campaign
 name:"VisibleRationalGraduations"
 when:activity.visible && ruler.children.length>3
 function assertTrue(value,message){if(!value)console.log('ASSERT_FAILED',message);verify(value,message);}
 function assertEqual(actual,expected,message){if(actual!==expected)console.log('COMPARE_FAILED',actual,expected,message);compare(actual,expected,message);}
 function assertEventually(object,property,value,timeout){try{tryCompare(object,property,value,timeout);}catch(error){console.log('WAIT_FAILED',property,object[property],value);throw error;}}
 property var plan:[10, 10, 10, 10, 15, 10]
 property int startLevel:12
 property var completed:[]
 property var levelsCompleted:[]
 property int wins:0
 property var attempted:({})
 property var failures:[]
 function checked(value,message){if(!value)console.log("ASSERT_FAILED",message);assertTrue(value,message);}
 function equal(actual,expected,message){if(actual!==expected)console.log("COMPARE_FAILED",actual,expected,message);assertEqual(actual,expected,message);}
 function eventually(object,property,value,timeout){try{assertEventually(object,property,value,timeout);}catch(error){console.log("WAIT_FAILED",property,object[property],value);throw error;}}
 Connections {target:bonus;function onWin(){campaign.wins++;}}
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

 function type(text,pointer,period) {
  if(pointer)pad('C');else keyClick(Qt.Key_Delete);
  assertEqual(entered(),'');var prefix='';
  for(var c of text){if(pointer)pad(c);else keyClick(c===','?(period?Qt.Key_Period:Qt.Key_Comma):Qt.Key_0+Number(c));prefix+=c;if(entered()!==prefix)console.log('GRADUATED_INPUT_MISMATCH',prefix,entered());assertEqual(entered(),prefix);}
 }
 function moveTo(index,pointer) {
  var before=line();assertTrue(index>=1 && index<before.marks.length-1);
  while(before.index!==index) {
   var right=before.index<index;
   if(pointer){var button=right?rightButton:leftButton;mouseClick(button,button.width/2,button.height/2,Qt.LeftButton,Qt.NoModifier,5);}
   else keyClick(right?Qt.Key_Right:Qt.Key_Left);
   var after=line();if(after.index!==before.index+(right?1:-1))console.log('GRADUATED_STEP_MISMATCH',before.index,after.index);assertEqual(after.index,before.index+(right?1:-1));before=after;
  }
 }
 function confirm(pointer){if(pointer)mouseClick(okButton,okButton.width/2,okButton.height/2,Qt.LeftButton,Qt.NoModifier,5);else keyClick(Qt.Key_Return);}
 function test_complete_all_questions() {
  wait(1200);equal(activity.numberOfLevel,29);assertEqual(activity.currentLevel,startLevel);
  assertTrue(String(instructionPanel.textItem.text).indexOf('Find')<0);assertTrue(String(instructionPanel.textItem.text).indexOf('Place')<0);
  for(var offset=0;offset<plan.length;offset++) {
   var level=startLevel+offset;assertEqual(activity.currentLevel,level);
   for(var question=0;question<plan[offset];question++) {
    var view=line(),read=activity.activityMode==='tick2number',pointer=question%2===1;
    var request=read?canonical(atTick(view,view.index)):String(boxText.text);
    var wanted=read?view.index:indexFor(view,request);
    attempted={level:level+1,question:question+1,view:view,request:request};console.log("GRADUATED_ATTEMPT",JSON.stringify(attempted));
    var wrong=null;
    if(question===0) {
     if(read){var chars=request.split('');chars[chars.length-1]=String((Number(chars[chars.length-1])+1)%10);var bad=chars.join('');type(bad,false,false);wrong={input:entered()};}
     else {var badIndex=wanted===1?2:wanted-1;moveTo(badIndex,false);wrong={index:line().index};}
     confirm(false);assertEventually(errorRectangle.errorAnimation,'running',true,1000);assertEqual(score.currentSubLevel,question);
     if(read){var frozen=entered();keyClick(Qt.Key_9);pad('9');assertEqual(entered(),frozen);}
     else {var frozen=line().index;keyClick(Qt.Key_Right);mouseClick(rightButton,rightButton.width/2,rightButton.height/2,Qt.LeftButton,Qt.NoModifier,5);assertEqual(line().index,frozen);}
     assertEventually(errorRectangle.errorAnimation,'running',false,3000);
    }
    if(read){type(request,pointer,question%3===0);if(question===0){keyClick(Qt.Key_Backspace);assertEqual(entered(),request.slice(0,-1));var c=request[request.length-1];keyClick(c===','?Qt.Key_Comma:Qt.Key_0+Number(c));assertEqual(entered(),request);}}
    else moveTo(wanted,pointer);
    var response=read?entered():line().index;
    var record={level:level+1,question:question+1,view:view,request:request,response:response,wrong:wrong,input:pointer?'pointer':'keyboard'};
    if(question===0 || question===plan[offset]-1)grabImage(activityBackground).save('__QA_OUTPUT__/level-'+(level+1)+'-'+(question+1)+'.png');
    confirm(pointer);eventually(score,'currentSubLevel',question+1,1000);eventually(score,'isWinAnimationPlaying',false,4000);wait(120);
    completed.push(record);console.log('GRADUATED_QUESTION',JSON.stringify(record));
   }
   assertEventually(bonus,'isPlaying',true,1000);assertEventually(activity,'currentLevel',(level+1)%29,10000);wait(200);levelsCompleted.push(level+1);
  }
  assertEqual(wins,plan.length);
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(activityBackground).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_GRADUATED_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,levelsCompleted:levelsCompleted,wins:wins,attempted:attempted}));}
}
