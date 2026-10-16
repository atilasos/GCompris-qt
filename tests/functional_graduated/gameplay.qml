// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 id:campaign
 name:"VisibleRationalGraduations"
 when:activity.visible && ruler.children.length>3
 property var plan:__PLAN__
 property int startLevel:__START__
 property var completed:[]
 property var levelsCompleted:[]
 property int wins:0
 property var attempted:({})
 property var failures:[]
 function checked(value,message){if(!value)console.log("ASSERT_FAILED",message);verify(value,message);}
 function equal(actual,expected,message){if(actual!==expected)console.log("COMPARE_FAILED",actual,expected,message);compare(actual,expected,message);}
 function eventually(object,property,value,timeout){try{tryCompare(object,property,value,timeout);}catch(error){console.log("WAIT_FAILED",property,object[property],value);throw error;}}
 Connections {target:bonus;function onWin(){campaign.wins++;}}
__VISIBLE__
__ORACLE__
 function type(text,pointer,period) {
  if(pointer)pad('C');else keyClick(Qt.Key_Delete);
  compare(entered(),'');var prefix='';
  for(var c of text){if(pointer)pad(c);else keyClick(c===','?(period?Qt.Key_Period:Qt.Key_Comma):Qt.Key_0+Number(c));prefix+=c;if(entered()!==prefix)console.log('GRADUATED_INPUT_MISMATCH',prefix,entered());compare(entered(),prefix);}
 }
 function moveTo(index,pointer) {
  var before=line();verify(index>=1 && index<before.marks.length-1);
  while(before.index!==index) {
   var right=before.index<index;
   if(pointer){var button=right?rightButton:leftButton;mouseClick(button,button.width/2,button.height/2,Qt.LeftButton,Qt.NoModifier,5);}
   else keyClick(right?Qt.Key_Right:Qt.Key_Left);
   var after=line();if(after.index!==before.index+(right?1:-1))console.log('GRADUATED_STEP_MISMATCH',before.index,after.index);compare(after.index,before.index+(right?1:-1));before=after;
  }
 }
 function confirm(pointer){if(pointer)mouseClick(okButton,okButton.width/2,okButton.height/2,Qt.LeftButton,Qt.NoModifier,5);else keyClick(Qt.Key_Return);}
 function test_complete_all_questions() {
  wait(1200);equal(activity.numberOfLevel,29);compare(activity.currentLevel,startLevel);
  verify(String(instructionPanel.textItem.text).indexOf('Find')<0);verify(String(instructionPanel.textItem.text).indexOf('Place')<0);
  for(var offset=0;offset<plan.length;offset++) {
   var level=startLevel+offset;compare(activity.currentLevel,level);
   for(var question=0;question<plan[offset];question++) {
    var view=line(),read=activity.activityMode==='tick2number',pointer=question%2===1;
    var request=read?canonical(atTick(view,view.index)):String(boxText.text);
    var wanted=read?view.index:indexFor(view,request);
    attempted={level:level+1,question:question+1,view:view,request:request};console.log("GRADUATED_ATTEMPT",JSON.stringify(attempted));
    var wrong=null;
    if(question===0) {
     if(read){var chars=request.split('');chars[chars.length-1]=String((Number(chars[chars.length-1])+1)%10);var bad=chars.join('');type(bad,false,false);wrong={input:entered()};}
     else {var badIndex=wanted===1?2:wanted-1;moveTo(badIndex,false);wrong={index:line().index};}
     confirm(false);tryCompare(errorRectangle.errorAnimation,'running',true,1000);compare(score.currentSubLevel,question);
     if(read){var frozen=entered();keyClick(Qt.Key_9);pad('9');compare(entered(),frozen);}
     else {var frozen=line().index;keyClick(Qt.Key_Right);mouseClick(rightButton,rightButton.width/2,rightButton.height/2,Qt.LeftButton,Qt.NoModifier,5);compare(line().index,frozen);}
     tryCompare(errorRectangle.errorAnimation,'running',false,3000);
    }
    if(read){type(request,pointer,question%3===0);if(question===0){keyClick(Qt.Key_Backspace);compare(entered(),request.slice(0,-1));var c=request[request.length-1];keyClick(c===','?Qt.Key_Comma:Qt.Key_0+Number(c));compare(entered(),request);}}
    else moveTo(wanted,pointer);
    var response=read?entered():line().index;
    var record={level:level+1,question:question+1,view:view,request:request,response:response,wrong:wrong,input:pointer?'pointer':'keyboard'};
    if(question===0 || question===plan[offset]-1)grabImage(activityBackground).save('__QA_OUTPUT__/level-'+(level+1)+'-'+(question+1)+'.png');
    confirm(pointer);eventually(score,'currentSubLevel',question+1,1000);eventually(score,'isWinAnimationPlaying',false,4000);wait(120);
    completed.push(record);console.log('GRADUATED_QUESTION',JSON.stringify(record));
   }
   tryCompare(bonus,'isPlaying',true,1000);tryCompare(activity,'currentLevel',(level+1)%29,10000);wait(200);levelsCompleted.push(level+1);
  }
  compare(wins,plan.length);
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(activityBackground).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_GRADUATED_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,levelsCompleted:levelsCompleted,wins:wins,attempted:attempted}));}
}
