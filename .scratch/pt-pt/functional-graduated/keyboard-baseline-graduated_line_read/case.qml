// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:"SinglePhysicalGraduationInput"
 when:activity.visible && ruler.children.length>3
 property var observed:({})
 function descendants(root) {
  var result=[root];if(root.children)for(var child of root.children)result=result.concat(descendants(child));return result;
 }
 function shownCursor() {
  var candidates=cursor.children.filter(child=>child.width>0 && child.height>0 && child.opacity>0.99);
  verify(candidates.length===1,"One painted cursor");return candidates[0];
 }
 function entered() {
  var text=descendants(shownCursor()).filter(child=>child.text!==undefined);
  compare(text.length,1);return String(text[0].text);
 }
 function line() {
  var marks=ruler.children.filter(child=>child.width>0 && child.height>0).map(child=>{
   var vertical=child.children.filter(rect=>rect.color!==undefined && rect.height>rect.width*2);
   verify(vertical.length===1,"A visible vertical graduation");
   return {x:vertical[0].mapToItem(activityBackground,vertical[0].width/2,0).x};
  }).sort((a,b)=>a.x-b.x);
  verify(marks.length>2);
  var x=shownCursor().mapToItem(activityBackground,shownCursor().width/2,0).x;
  var index=-1;for(var i=0;i<marks.length;i++)if(Math.abs(marks[i].x-x)<1)index=i;
  verify(index>=0,"Painted cursor matches a painted tick");
  for(var j=1;j<marks.length;j++)verify(Math.abs((marks[j].x-marks[j-1].x)-(marks[1].x-marks[0].x))<0.02,"Equally spaced ticks");
  return {left:String(leftLimit.text),right:String(rightLimit.text),marks:marks.map(m=>m.x),index:index};
 }
 function pad(label) {
  var matches=descendants(numPad).filter(child=>child.text!==undefined && child.visible && String(child.text)===label);
  compare(matches.length,1,"Displayed keypad label "+label);var text=matches[0];mouseClick(text,text.width/2,text.height/2,Qt.LeftButton,Qt.NoModifier,5);
 }
 function findIcon(root,suffix){return descendants(root).find(child=>child.source!==undefined && String(child.source).endsWith(suffix));}
 function icon(root,suffix){var button=findIcon(root,suffix);verify(button!==undefined,suffix);mouseClick(button,button.width/2,button.height/2,Qt.LeftButton,Qt.NoModifier,5);wait(350);}

 function test_one_physical_key_is_one_action() {
  wait(1200);var before=line();observed.before=before;
  if(activity.activityMode==='tick2number') {
   keyClick(Qt.Key_5);observed.afterText=entered();console.log('GRADUATED_TYPED',observed.afterText);compare(entered(),'5');
  } else {
   var right=before.index+2<before.marks.length-1;
   keyClick(right?Qt.Key_Right:Qt.Key_Left);wait(100);
   observed.after=line();console.log('GRADUATED_MOVED',before.index,observed.after.index);
   compare(observed.after.index,before.index+(right?1:-1));
  }
 }
 function cleanupTestCase(){grabImage(activityBackground).save('__QA_OUTPUT__/keyboard.png');console.log('NATIVE_GRADUATED_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:observed}));}
}
