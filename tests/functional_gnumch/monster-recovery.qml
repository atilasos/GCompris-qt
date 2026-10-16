// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:"GnumchNaturalMonstersAndRecovery"
 when:activity.visible && gridNumbers.count===36
 property var encounters:[]
 property var sightings:[]
 property var recoveryCaptures:[]
 property bool recovered:false
__VISIBLE__
 function test_natural_capture_and_loss() {
  wait(1800);compare(items.currentLevel,1);
  var level=items.currentLevel;
  for(var capture=0;capture<2;capture++) {
   var began=Date.now();
   while(warning.opacity===0 && Date.now()-began<90000) {
    var visible=[];
    for(var enemy of monsters.children)if(enemy.opacity>0.99)visible.push(enemy);
    if(!visible.length){wait(300);continue;}
    var enemy=visible[0],x=Math.round(enemy.x/enemy.width),y=Math.round(enemy.y/enemy.height);
    sightings.push({elapsed:Date.now()-began,x:x,y:y});
    var here=position();
    if(here[0]===x && here[1]===y){wait(350);continue;}
    var direction=here[0]<x?0:here[0]>x?1:here[1]<y?2:3;
    move(direction,false);
   }
   tryCompare(warning,"opacity",1,1000);
   var text=String(warning.warningText);
   encounters.push({lifeBefore:topPanel.life,text:text,elapsed:Date.now()-began});
   verify(text.indexOf("Foste comido")>=0,"Portuguese capture message is correctly written");
   compare(topPanel.life,capture===0);keyClick(Qt.Key_Return);
   if(capture===0){tryCompare(warning,"opacity",0,1000);wait(600);verify(!topPanel.life);}
   else {tryCompare(bonus,"isPlaying",true,2000);tryCompare(bonus,"isPlaying",false,10000);wait(700);compare(items.currentLevel,level);verify(topPanel.life);}
  }
  verify(sightings.length>0);
  var began=Date.now(),request=prompt();
  while(!bonus.isPlaying && Date.now()-began<150000) {
   if(warning.opacity>0) {
    tryCompare(warning,"opacity",1,1000);var life=topPanel.life;keyClick(Qt.Key_Return);
    tryCompare(warning,"opacity",0,1000);
    if(life)wait(600);else {tryCompare(bonus,"isPlaying",true,2000);tryCompare(bonus,"isPlaying",false,10000);wait(600);}
    continue;
   }
   var here=position(),choice=-1,distance=100;
   for(var i=0;i<36;i++) {
    var text=visibleCell(i);if(text===null || !correct(text,request))continue;
    var d=Math.abs(here[0]-i%6)+Math.abs(here[1]-Math.floor(i/6));if(d<distance){choice=i;distance=d;}
   }
   if(choice<0){wait(100);continue;}
   if(!go(choice,false))continue;
   var text=visibleCell(choice);if(text===null || !correct(text,request))continue;
   eat(false);if(warning.opacity>0)continue;
   compare(visibleCell(choice),null);recoveryCaptures.push({text:text,prompt:request,index:choice});
  }
  verify(recoveryCaptures.length>0);tryCompare(bonus,"isPlaying",true,2000);tryCompare(items,"currentLevel",2,10000);recovered=true;
 }
 function cleanupTestCase(){console.log("NATIVE_GNUMCH_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,encounters:encounters,sightings:sightings,recoveryCaptures:recoveryCaptures,recovered:recovered}));}
}
