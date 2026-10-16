// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:"GnumchPortugueseControls"
 when:activity.visible && gridNumbers.count===36
 property var evidence:({})
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

 function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var value=find(child,predicate);if(value)return value;}return null;}
 function icon(root,suffix){wait(400);var button=find(root,function(item){return item.source!==undefined && String(item.source).endsWith(suffix);});verify(button!==null,suffix);mouseClick(button);wait(500);}
 function textButton(root,text){var button=find(root,function(item){return item.clicked!==undefined && item.text===text && item.visible;});verify(button!==null,text);mouseClick(button,button.width/2,button.height/2,Qt.LeftButton,Qt.NoModifier,50);}
 function choices(root,values){if(root.indicatorImageHeight!==undefined && root.checked!==undefined && root.text!==undefined && root.visible)values.push(root);if(root.children)for(var child of root.children)choices(child,values);}
 function test_help_navigation_restart_configuration_and_menu() {
  wait(1800);var expected=activity.useMultipleDataset?40:8;compare(activity.numberOfLevel,expected);
  icon(bar,'bar_next.svg');compare(items.currentLevel,1);
  icon(bar,'bar_previous.svg');compare(items.currentLevel,0);
  var request=prompt(),wrong=-1;
  for(var i=0;i<36;i++)if(!correct(visibleCell(i),request)){wrong=i;break;}
  verify(wrong>=0);verify(go(wrong,false));eat(false);tryCompare(warning,'opacity',1,1000);
  keyClick(Qt.Key_Return);tryCompare(warning,'opacity',0,1000);wait(600);verify(!topPanel.life);
  icon(bar,'bar_next.svg');icon(bar,'bar_previous.svg');compare(items.currentLevel,0);verify(topPanel.life);compare(position().join(),'0,0');
  var depth=pageView.depth;icon(bar,'bar_help.svg');tryCompare(pageView,'depth',depth+1,2000);wait(500);
  var help=pageView.currentItem;compare(help.title,activity.activityInfo.title);verify(help.content.indexOf(activity.activityInfo.description)>=0);verify(help.content.indexOf('Guide the Number')<0);
  grabImage(pageView).save('__QA_OUTPUT__/help.png');keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth,2000);wait(400);
  keyClick(Qt.Key_Right);wait(340);compare(position().join(),'1,0','Keyboard focus after closing help');
  var datasets=[];
  if(activity.useMultipleDataset) {
   icon(bar,'bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2000);wait(400);
   choices(dialogActivityConfig,datasets);compare(datasets.length,4);for(var choice of datasets)verify(choice.checked);
   mouseClick(datasets[3]);verify(!datasets[3].checked);textButton(dialogActivityConfig,'Gravar');tryCompare(dialogActivityConfig,'visible',false,2000);wait(1200);compare(activity.numberOfLevel,30);compare(items.currentLevel,0);verify(topPanel.life);
   icon(bar,'bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2000);wait(400);datasets=[];choices(dialogActivityConfig,datasets);verify(!datasets[3].checked);mouseClick(datasets[3]);textButton(dialogActivityConfig,'Gravar');tryCompare(dialogActivityConfig,'visible',false,2000);wait(1200);compare(activity.numberOfLevel,40);
  } else verify(find(bar,function(item){return item.source!==undefined && String(item.source).endsWith('bar_activity_config.svg');})===null);
  evidence={activity:activity.activityInfo.shortName(),levels:expected,help:true,keyboardAfterHelp:true,navigation:true,restart:true,datasetChoices:datasets.length};
  ActivityInfoTree.startingActivity='';icon(bar,'bar_home.svg');tryCompare(pageView,'depth',1,2000);verify(pageView.currentItem.isMenu);grabImage(pageView).save('__QA_OUTPUT__/menu.png');
 }
 function cleanupTestCase(){console.log('NATIVE_GNUMCH_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
