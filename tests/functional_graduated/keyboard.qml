// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:"SinglePhysicalGraduationInput"
 when:activity.visible && ruler.children.length>3
 property var observed:({})
__VISIBLE__
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
