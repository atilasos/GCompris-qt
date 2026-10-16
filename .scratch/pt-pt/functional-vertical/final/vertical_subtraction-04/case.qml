// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 id:campaign
 name:"VerticalVisibleArithmetic"
 when:activity.visible && numberRepeater.count>0
 property var completed:[]
 property int wins:0
 Connections { target:bonus;function onWin(){campaign.wins++;} }
 function check(value,message){if(!value)console.log("CHECK_FAILED",message);verify(value,message);}
 function equal(actual,expected,message){if(actual!==expected)console.log("COMPARE_FAILED",actual,expected,message);compare(actual,expected,message);}
 function eventually(object,property,value,timeout){try{tryCompare(object,property,value,timeout);}catch(error){console.log("WAIT_FAILED",property,object[property],value);throw error;}}
 function plan(values) {
  var plus=activity.operation===0,compensation=activity.method===0;
  var result=plus?values.reduce((a,b)=>a+b,0):values[0]-values.slice(1).reduce((a,b)=>a+b,0);
  verify(result>=0);var adjustments=[],debt=0,width=Math.max.apply(null,values.map(n=>String(n).length))+1;
  for(var col=0;col<width;col++) {
   var digits=values.map(n=>Math.floor(n/Math.pow(10,col))%10);
   if(plus){debt=Math.floor((digits.reduce((a,b)=>a+b,0)+debt)/10);if(debt)adjustments.push([0,col+1,debt]);}
   else {
    var difference=digits[0]-digits.slice(1).reduce((a,b)=>a+b,0)-debt;
    debt=Math.max(0,Math.ceil(-difference/10));
    if(debt){adjustments.push([0,col,10*debt]);adjustments.push([compensation?values.length-1:0,col+1,compensation?debt:-debt]);}
   }
  }
  return {result:result,adjustments:adjustments};
 }

 function texts(root) {
  var out=[];
  if(root.text!==undefined)out.push(root);
  if(root.children)for(var child of root.children)out=out.concat(texts(child));
  return out;
 }
 function digitText(digit) {
  for(var child of digit.children)if(child.text!==undefined)return String(child.text);
  fail("No displayed digit");return "";
 }
 function shownNumber(line) {
  var str="";
  for(var i=0;i<line.digitRepeater.count;i++)str=digitText(line.digitRepeater.itemAt(i))+str;
  return str?Number(str):0;
 }
 function padChoice(popup,label) {
  wait(40);
  var choices=texts(popup.contentItem).filter(t=>String(t.text)===String(label));
  check(choices.length>0,"Visible popup label "+label);
  var text=choices[0];mouseClick(text,text.width/2,text.height/2,Qt.LeftButton,Qt.NoModifier,5);
  eventually(popup,"visible",false,1000);
 }
 function putDigit(line,col,value) {
  var digit=line.digitRepeater.itemAt(col);check(digit!==null);
  mouseClick(digit,digit.width/2,digit.height/2,Qt.LeftButton,Qt.NoModifier,5);
  eventually(numPad,"visible",true,1000);padChoice(numPad,String(value));
  equal(digitText(digit),String(value));
 }
 function putNumber(line,value) {
  var string=String(value);
  for(var col=0;col<string.length;col++)putDigit(line,col,Number(string[string.length-1-col]));
  equal(shownNumber(line),value);
 }
 function adjust(change) {
  var digit=numberRepeater.itemAt(change[0]).digitRepeater.itemAt(change[1]);
  check(digit!==null,"Carry column exists");
  var tens=change[2]>=10;
  mouseClick(digit,digit.width*(tens?0.25:0.75),digit.height*(tens?0.5:0.8),Qt.LeftButton,Qt.NoModifier,5);
  eventually(miniPad,"visible",true,1000);
  var label=tens?String(change[2]/10):(change[2]>0?"+"+change[2]:String(change[2]));
  padChoice(miniPad,label);
  check(texts(digit).some(t=>t.visible && String(t.text)===label),"Requested carry/borrow is visibly displayed: "+label);
 }
 function solve(sublevel) {
  var prompt=String(instructionPanel.textItem.text),laid=okButton.visible;
  var values=[];
  if(!laid) {
   if(prompt.indexOf(" + ")>=0 || prompt.indexOf(" - ")>=0) {
    var match=prompt.match(/\d+/g);check(match!==null);values=match.map(Number);
   } else {
    check(prompt.indexOf("Escreve")>=0 || prompt.indexOf("Cria")>=0,"Own-operation prompt is Portuguese: "+prompt);
    var own=[[4321,1234,245,12],[1000,1,0,0],[9999,999,99,9],
             [9876,876,76,6],[9000,899,99,9],[8000,7000,999,1],
             [3003,1001,1001,1001],[7777,777,77,7],[5000,2222,1111,1111],[4567,0,56,7]];
    values=own[sublevel];
   }
   equal(values.length,numberRepeater.count);
   for(var n=0;n<values.length;n++)putNumber(numberRepeater.itemAt(n),values[n]);
   mouseClick(readyButton,readyButton.width/2,readyButton.height/2,Qt.LeftButton,Qt.NoModifier,5);
   eventually(okButton,"visible",true,1000);
  }
  values=[];for(var line=0;line<numberRepeater.count;line++)values.push(shownNumber(numberRepeater.itemAt(line)));
  var expected=plan(values);
  for(var change of expected.adjustments)adjust(change);
  if(sublevel===0) {
   putDigit(resultNumber,0,(expected.result%10+1)%10);
   mouseClick(okButton,okButton.width/2,okButton.height/2,Qt.LeftButton,Qt.NoModifier,5);
   eventually(errorRectangle.errorAnimation,"running",true,1000);
   equal(score.currentSubLevel,sublevel);
   eventually(errorRectangle.errorAnimation,"running",false,3000);
  }
  putNumber(resultNumber,expected.result);
  var record={level:activity.currentLevel+1,sublevel:sublevel+1,prompt:prompt,operands:values,
              result:shownNumber(resultNumber),adjustments:expected.adjustments,laid:laid,error:sublevel===0};
  grabImage(activityBackground).save("__QA_OUTPUT__/level-"+(activity.currentLevel+1)+"-"+(sublevel+1)+".png");
  if(sublevel%2===0)keyClick(Qt.Key_Return);
  else mouseClick(okButton,okButton.width/2,okButton.height/2,Qt.LeftButton,Qt.NoModifier,5);
  eventually(score,"currentSubLevel",sublevel+1,1000);
  eventually(score,"isWinAnimationPlaying",false,4000);
  completed.push(record);console.log("VERTICAL_PUZZLE",JSON.stringify(record));
 }
 function test_complete() {
  wait(1000);equal(activity.numberOfLevel,12);
  for(var offset=0;offset<3;offset++) {
   var level=3+offset;equal(activity.currentLevel,level);
   for(var sub=0;sub<10;sub++)solve(sub);
   if(10===10){eventually(bonus,"isPlaying",true,1000);eventually(activity,"currentLevel",(level+1)%12,10000);wait(200);}
  }
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(activityBackground).save("__QA_OUTPUT__/failure.png");console.log("NATIVE_VERTICAL_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,wins:wins}));}
}
