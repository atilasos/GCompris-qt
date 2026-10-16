// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:"GnumchVisibleBoardPilot"
 when:activity.visible && gridNumbers.count===36
 property var observations:[]
__VISIBLE__
 function test_first_board() {
  wait(1800);compare(activity.numberOfLevel,40);
  var request=prompt();console.log("GNUMCH_PROMPT",request);
  var wrong=-1;
  for(var i=0;i<36;i++)if(!correct(visibleCell(i),request)){wrong=i;break;}
  verify(wrong>=0);verify(go(wrong,false));
  var before=visibleCell(wrong);eat(false);tryCompare(warning,"opacity",1,1000);
  verify(warning.warningText.indexOf("You ate")<0);verify(topPanel.life);
  verify(warning.warningText.indexOf('"Enter"')>=0,"Visible instruction names the actual continuation key");
 }
 function cleanupTestCase(){console.log("NATIVE_GNUMCH_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,observations:observations}));}
}
