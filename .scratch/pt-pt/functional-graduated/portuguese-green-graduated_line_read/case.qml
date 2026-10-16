// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:"GraduatedPortugueseMeaning"
 when:activity.visible && ruler.children.length>3
 function assertTrue(value,message){if(!value)console.log('ASSERT_FAILED',message);verify(value,message);}
 function assertEqual(actual,expected,message){if(actual!==expected)console.log('COMPARE_FAILED',actual,expected,message);compare(actual,expected,message);}
 function assertEventually(object,property,value,timeout){try{tryCompare(object,property,value,timeout);}catch(error){console.log('WAIT_FAILED',property,object[property],value);throw error;}}
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

 function test_instruction_help_and_dataset_labels() {
  wait(1200);evidence.instruction=String(instructionPanel.textItem.text);
  grabImage(pageView).save('__QA_OUTPUT__/instruction.png');var depth=pageView.depth;
  icon(bar,'bar_help.svg');assertEventually(pageView,'depth',depth+1,2000);wait(400);
  evidence.help=String(pageView.currentItem.content);evidence.title=String(pageView.currentItem.title);grabImage(pageView).save('__QA_OUTPUT__/help.png');
  keyClick(Qt.Key_Escape);assertEventually(pageView,'depth',depth,2000);wait(300);
  icon(bar,'bar_activity_config.svg');assertEventually(dialogActivityConfig,'visible',true,2000);wait(500);
  evidence.datasets=descendants(dialogActivityConfig).filter(child=>child.checked!==undefined && child.text!==undefined).map(child=>String(child.text));
  grabImage(pageView).save('__QA_OUTPUT__/datasets.png');keyClick(Qt.Key_Escape);assertEventually(pageView,'depth',depth,2000);wait(300);
  console.log('GRADUATED_PORTUGUESE',JSON.stringify(evidence));
  if(activity.activityMode==='tick2number') {
   assertEqual(evidence.instruction,'Encontra o número indicado.');
   assertTrue(evidence.help.indexOf('Delete: limpar a resposta')>=0);
  } else assertTrue(evidence.help.indexOf('Setas Esquerda e Direita: mover o cursor')>=0);
  assertTrue(evidence.datasets.some(text=>text.indexOf('0 e 20')>=0));
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_GRADUATED_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
