// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:"GnumchNaturalMonstersAndRecovery"
 when:activity.visible && gridNumbers.count===36
 property var encounters:[]
 property var sightings:[]
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
