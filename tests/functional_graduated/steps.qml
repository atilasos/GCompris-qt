// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:"PublishedStepVisibleTracer"
 when:activity.visible && ruler.children.length>3
 property var evidence:({attempts:[]})
__VISIBLE__
__ORACLE__
 function test_solve_one_observed_published_step() {
  wait(1200);compare(activity.currentLevel,__LEVEL__-1);
  var view,matched=false;
  for(var attempt=0;attempt<250;attempt++) {
   view=line();var l=numeric(view.left),next=atTick(view,1);var step=fraction(next.n*l.d-l.n*next.d,next.d*l.d);
   evidence.attempts.push({view:view,step:canonical(step)});
   if(step.n===__STEP__*step.d){matched=true;break;}
   icon(bar,'bar_previous.svg');icon(bar,'bar_next.svg');compare(activity.currentLevel,__LEVEL__-1);
  }
  verify(matched,'Published step observed through real navigation');var read=activity.activityMode==='tick2number';
  var request=read?canonical(atTick(view,view.index)):String(boxText.text);
  if(read){keyClick(Qt.Key_Delete);for(var c of request)keyClick(c===','?Qt.Key_Comma:Qt.Key_0+Number(c));compare(entered(),request);}
  else {var wanted=indexFor(view,request);while(line().index!==wanted)keyClick(line().index<wanted?Qt.Key_Right:Qt.Key_Left);}
  evidence.sample={level:__LEVEL__,view:view,request:request,response:read?entered():line().index};
  grabImage(activityBackground).save('__QA_OUTPUT__/step.png');keyClick(Qt.Key_Return);tryCompare(score,'currentSubLevel',1,1000);tryCompare(score,'isWinAnimationPlaying',false,4000);evidence.solved=true;
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(activityBackground).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_GRADUATED_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
