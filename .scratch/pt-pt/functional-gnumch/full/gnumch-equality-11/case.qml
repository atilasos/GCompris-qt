// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 id:campaign
 name:"GnumchVisibleArithmeticCampaign"
 when:activity.visible && gridNumbers.count===36
 property int startLevel:10
 property int levelCount:10
 property int totalLevels:40
 property var completed:[]
 property var captures:[]
 property var warnings:[]
 property var sightings:[]
 property int wins:0
 property int losses:0
 Connections {target:bonus;function onWin(){campaign.wins++;}}
    function textWithin(root) {
        if(root.text!==undefined && root.font!==undefined && root.visible && root.text.length)return root;
        if(root.children)for(var child of root.children){var result=textWithin(child);if(result)return result;}
        return null;
    }
    function prompt() {var text=textWithin(topPanel);verify(text!==null);return String(text.text);}
    function visibleCell(index) {
        var cell=gridNumbers.itemAtIndex(index);verify(cell!==null);
        var label=textWithin(cell);
        return label===null?null:String(label.text);
    }
    function correct(text,request) {
        var match=/^(Igual a|Diferente de|Factor de|Múltiplo de|Primos inferiores a) (\d+)$/.exec(request);
        verify(match!==null,"Portuguese visible request");
        var goal=Number(match[2]),parts=/^(\d+)(?:\s*([+*/-])\s*(\d+))?$/.exec(text);
        verify(parts!==null,"Visible numeric expression");
        var a=Number(parts[1]),b=Number(parts[3]),value=a;
        if(parts[2]==='+')value=a+b;else if(parts[2]==='-')value=a-b;
        else if(parts[2]==='*')value=a*b;else if(parts[2]==='/')value=a/b;
        if(match[1]==='Igual a')return value===goal;
        if(match[1]==='Diferente de')return value!==goal;
        if(match[1]==='Factor de')return value>0 && goal%value===0;
        if(match[1]==='Múltiplo de')return value%goal===0;
        if(value<2 || value>=goal || value%1!==0)return false;
        for(var divisor=2;divisor*divisor<=value;divisor++)if(value%divisor===0)return false;
        return true;
    }
    function position() {
        return [Math.round(muncher.x/muncher.width),Math.round(muncher.y/muncher.height)];
    }
    function move(direction,pointer) {
        var before=position();
        activityBackground.forceActiveFocus();
        if(pointer) {
            var delta=[[1,0],[-1,0],[0,1],[0,-1]][direction];
            var point=muncher.mapToItem(activityBackground,muncher.width/2+delta[0]*muncher.width,muncher.height/2+delta[1]*muncher.height);
            mouseClick(activityBackground,point.x,point.y,Qt.LeftButton,Qt.NoModifier,30);
        } else keyClick([Qt.Key_Right,Qt.Key_Left,Qt.Key_Down,Qt.Key_Up][direction]);
        wait(340);
        if(warning.opacity>0)return false;
        var after=position(),delta=[[1,0],[-1,0],[0,1],[0,-1]][direction];
        compare(after[0],Math.max(0,Math.min(5,before[0]+delta[0])),"One movement input changes one column");
        compare(after[1],Math.max(0,Math.min(5,before[1]+delta[1])),"One movement input changes one row");
        return true;
    }
    function go(index,pointer) {
        var target=[index%6,Math.floor(index/6)];
        for(var step=0;step<15;step++) {
            var here=position();if(here.join()===target.join())return true;
            var direction=here[0]<target[0]?0:here[0]>target[0]?1:here[1]<target[1]?2:3;
            if(!move(direction,pointer))return false;
        }
        fail("Visible player reaches chosen cell");
    }
    function eat(pointer) {
        activityBackground.forceActiveFocus();
        if(pointer) {
            var point=muncher.mapToItem(activityBackground,muncher.width/2,muncher.height/2);
            mouseClick(activityBackground,point.x,point.y,Qt.LeftButton,Qt.NoModifier,30);
        } else keyClick(Qt.Key_Space);
        wait(50);
    }

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
