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
  keyClick(Qt.Key_Return);tryCompare(warning,"opacity",0,1000);wait(600);verify(!topPanel.life);
  var captured=0;
  for(var i=0;i<36;i++) {
   var text=visibleCell(i);if(text===null || !correct(text,request))continue;
   verify(go(i,false));text=visibleCell(i);verify(text!==null);verify(correct(text,request));
   eat(false);compare(visibleCell(i),null);observations.push({prompt:request,text:text,index:i});captured++;
  }
  verify(captured>0);tryCompare(bonus,"isPlaying",true,1000);
  tryCompare(items,"currentLevel",1,10000);compare(topPanel.life,true);
 }
 function cleanupTestCase(){console.log("NATIVE_GNUMCH_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,observations:observations}));}
}
