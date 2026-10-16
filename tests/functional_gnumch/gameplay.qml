// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 id:campaign
 name:"GnumchVisibleArithmeticCampaign"
 when:activity.visible && gridNumbers.count===36
 property int startLevel:__START__
 property int levelCount:__COUNT__
 property int totalLevels:__TOTAL__
 property var completed:[]
 property var captures:[]
 property var warnings:[]
 property var sightings:[]
 property int wins:0
 property int losses:0
 Connections {target:bonus;function onWin(){campaign.wins++;}}
__VISIBLE__
 function observeEnemies() {
  for(var enemy of monsters.children)if(enemy.opacity>0.99) {
   var sprite=null;
   for(var child of enemy.children)if(child.source!==undefined)sprite=String(child.source);
   sightings.push({level:items.currentLevel+1,source:sprite,x:enemy.x,y:enemy.y,time:Date.now()});
  }
 }
 function recover() {
  if(warning.opacity===0)return;
  tryCompare(warning,"opacity",1,1000);
  var life=topPanel.life,level=items.currentLevel,text=String(warning.warningText);
  verify(text.indexOf('"Enter"')>=0);verify(text.indexOf("You ")<0);
  warnings.push({level:level+1,lifeBefore:life,text:text});
  keyClick(Qt.Key_Return);tryCompare(warning,"opacity",0,1000);
  if(life) {wait(600);verify(!topPanel.life);}
  else {
   losses++;tryCompare(bonus,"isPlaying",true,2000);tryCompare(bonus,"isPlaying",false,10000);wait(600);
   compare(items.currentLevel,level);verify(topPanel.life);
  }
 }
 function nearest(wanted,request) {
  var here=position(),choice=-1,distance=100;
  for(var i=0;i<36;i++) {
   var text=visibleCell(i);if(text===null || correct(text,request)!==wanted)continue;
   var delta=Math.abs(i%6-here[0])+Math.abs(Math.floor(i/6)-here[1]);
   if(delta<distance){choice=i;distance=delta;}
  }
  return choice;
 }
 function test_complete_all_selected_levels() {
  wait(1800);compare(activity.numberOfLevel,totalLevels);compare(items.currentLevel,startLevel);
  for(var offset=0;offset<levelCount;offset++) {
   var level=startLevel+offset;compare(items.currentLevel,level);
   var request=prompt(),pointer=offset%2===1,began=Date.now(),firstCapture=captures.length;
   if(offset===0) {
    var wrong=nearest(false,request);verify(wrong>=0);
    verify(go(wrong,false));var text=visibleCell(wrong);verify(!correct(text,request));
    eat(false);tryCompare(warning,"opacity",1,1000);
    verify(warning.warningText.indexOf("Comeste um número errado.")>=0);
    captures.push({level:level+1,prompt:request,text:text,index:wrong,correct:false,route:"keyboard"});
    recover();
   }
   while(!bonus.isPlaying && items.currentLevel===level && Date.now()-began<180000) {
    observeEnemies();
    if(warning.opacity>0){recover();continue;}
    var choice=nearest(true,request);
    if(choice<0){wait(100);continue;}
    if(!go(choice,pointer)){recover();continue;}
    var text=visibleCell(choice);
    if(text===null || !correct(text,request))continue;
    eat(pointer);
    if(warning.opacity>0){recover();continue;}
    compare(visibleCell(choice),null,"A mathematically valid displayed cell is consumed");
    captures.push({level:level+1,prompt:request,text:text,index:choice,correct:true,route:pointer?"click":"keyboard"});
   }
   verify(captures.length>firstCapture);
   tryCompare(bonus,"isPlaying",true,1000);
   completed.push({level:level+1,prompt:request,captures:captures.length-firstCapture,pointer:pointer});
   grabImage(activityBackground).save("__QA_OUTPUT__/level-"+(level+1)+".png");
   tryCompare(items,"currentLevel",(level+1)%totalLevels,10000);wait(700);
   console.log("GNUMCH_LEVEL_COMPLETED",level+1,captures.length-firstCapture);
  }
  compare(completed.length,levelCount);compare(wins,levelCount);
 }
 function cleanupTestCase(){console.log("NATIVE_GNUMCH_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,captures:captures,warnings:warnings,sightings:sightings,wins:wins,losses:losses}));}
}
