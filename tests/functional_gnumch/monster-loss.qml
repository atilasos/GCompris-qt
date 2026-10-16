// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:"GnumchNaturalMonstersAndRecovery"
 when:activity.visible && gridNumbers.count===36
 property var encounters:[]
 property var sightings:[]
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
 }
 function cleanupTestCase(){console.log("NATIVE_GNUMCH_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,encounters:encounters,sightings:sightings}));}
}
