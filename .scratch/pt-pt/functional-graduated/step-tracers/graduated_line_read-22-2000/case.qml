// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:"PublishedStepVisibleTracer"
 when:activity.visible && ruler.children.length>3
 property var evidence:({attempts:[]})
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
  verify(marks.length>2);verify(marks[1].x>marks[0].x,"Ruler layout has painted distinct tick positions");
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
 function icon(root,suffix){wait(450);var button=findIcon(root,suffix);verify(button!==undefined,suffix);mouseClick(button,button.width/2,button.height/2,Qt.LeftButton,Qt.NoModifier,5);wait(350);}

 function gcd(a,b){a=Math.abs(a);b=Math.abs(b);while(b){var r=a%b;a=b;b=r;}return a;}
 function fraction(n,d){var g=gcd(n,d);return {n:n/g,d:d/g};}
 function numeric(text){var s=String(text).replace(/[\s\u00a0\u202f]/g,'').replace('−','-').replace(',','.');var point=s.indexOf('.');return point<0?fraction(Number(s),1):fraction(Number(s.replace('.','')),Math.pow(10,s.length-point-1));}
 function atTick(view,index){var l=numeric(view.left),r=numeric(view.right),segments=view.marks.length-1;return fraction(l.n*r.d*segments+(r.n*l.d-l.n*r.d)*index,l.d*r.d*segments);}
 function canonical(value){var sign=value.n<0?'-':'',n=Math.abs(value.n),text=sign+Math.floor(n/value.d),remainder=n%value.d;if(remainder)text+=',';for(var i=0;remainder && i<10;i++){remainder*=10;text+=Math.floor(remainder/value.d);remainder%=value.d;}verify(!remainder,'Finite decimal graduated line');return text;}
 function indexFor(view,target){var l=numeric(view.left),r=numeric(view.right),t=numeric(target);var n=(t.n*l.d-l.n*t.d)*r.d*(view.marks.length-1),d=t.d*(r.n*l.d-l.n*r.d);compare(n%d,0,'Requested value is on a visible tick');return n/d;}

 function test_solve_one_observed_published_step() {
  wait(1200);compare(activity.currentLevel,22-1);
  var view,matched=false;
  for(var attempt=0;attempt<250;attempt++) {
   view=line();var l=numeric(view.left),next=atTick(view,1);var step=fraction(next.n*l.d-l.n*next.d,next.d*l.d);
   evidence.attempts.push({view:view,step:canonical(step)});
   if(step.n===2000*step.d){matched=true;break;}
   icon(bar,'bar_previous.svg');icon(bar,'bar_next.svg');compare(activity.currentLevel,22-1);
  }
  verify(matched,'Published step observed through real navigation');var read=activity.activityMode==='tick2number';
  var request=read?canonical(atTick(view,view.index)):String(boxText.text);
  if(read){keyClick(Qt.Key_Delete);for(var c of request)keyClick(c===','?Qt.Key_Comma:Qt.Key_0+Number(c));compare(entered(),request);}
  else {var wanted=indexFor(view,request);while(line().index!==wanted)keyClick(line().index<wanted?Qt.Key_Right:Qt.Key_Left);}
  evidence.sample={level:22,view:view,request:request,response:read?entered():line().index};
  grabImage(activityBackground).save('__QA_OUTPUT__/step.png');keyClick(Qt.Key_Return);tryCompare(score,'currentSubLevel',1,1000);tryCompare(score,'isWinAnimationPlaying',false,4000);evidence.solved=true;
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(activityBackground).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_GRADUATED_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
