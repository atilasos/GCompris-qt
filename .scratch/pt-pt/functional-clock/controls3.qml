// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "ClockByPortugueseInstructionAndVisibleAngles"
    when: activity.visible && clock.width>0
    property int firstLevel: 1
    property int targetLevels: 1
    property bool twentyFour: false
    property var questions: []
    property var completed: []
    property int wrong: 0
    property int gestures: 0
    function checked(a,b,msg){if(a!==b)console.log("CLOCK_ASSERT",a,b,msg||"",new Error().stack);compare(a,b,msg||"");}
    function ensure(v,msg){if(!v)console.log("CLOCK_ASSERT",msg||"",new Error().stack);verify(v,msg||"");}
    function norm(a){return (a%360+360)%360;}
    function distance(a,b){var d=Math.abs(norm(a)-norm(b));return Math.min(d,360-d);}
    function topAngle(arrow){return norm(arrow.angle+180);}
    function parse(text){var match=String(text).match(/^Acertar o relógio para as:\s+(\d+)\s+horas?\s+(\d+)\s+minutos?(?:\s+(\d+)\s+segundos?)?$/);ensure(match!==null,"Portuguese clock wording: "+text);var answer=[parseInt(match[1],10),parseInt(match[2],10),parseInt(match[3]||"0",10)];ensure(answer[0]<24&&answer[1]<60&&answer[2]<60);return answer;}
    function angles(time){return [(time[0]%12)*30+time[1]/2,time[1]*6+time[2]/10,time[2]*6];}
    function point(degrees){var radians=degrees*Math.PI/180,r=clock.width*0.40;return {x:clock.width/2+r*Math.sin(radians),y:clock.height/2-r*Math.cos(radians)};}
    function moveRaw(arrow,degrees){
        wait(140);var a=point(topAngle(arrow)),b=point(degrees);
        mousePress(clock,a.x,a.y);mouseMove(clock,a.x+2,a.y+1,30);
        for(var step=1;step<=12;step++)mouseMove(clock,a.x+(b.x-a.x)*step/12,a.y+(b.y-a.y)*step/12,15);
        mouseRelease(clock,b.x,b.y);gestures++;wait(150);
    }
    function move(arrow,degrees){
        var list=[h,m,s],index=list.indexOf(arrow);
        // When hands overlap, earlier hands receive the physical pointer first.
        for(var attempt=0;attempt<5;attempt++){
            var blocker=null;
            for(var i=0;i<index;i++)if(list[i].visible&&distance(topAngle(list[i]),topAngle(arrow))<2){blocker=list[i];break;}
            if(blocker===null){moveRaw(arrow,degrees);return;}
            move(blocker,norm(topAngle(blocker)+65));
        }
        fail("Overlapping hands can be separated by real gestures");
    }
    function setTime(answer){
        if(s.visible)move(s,answer[2]*6);
        if(m.visible)move(m,answer[1]*6+answer[2]/10);
        move(h,(answer[0]%12)*30+answer[1]/2);
        var wanted=angles(answer),observed=[topAngle(h),m.visible?topAngle(m):null,s.visible?topAngle(s):null];
        for(var i=0;i<3;i++)if(i===0||(i===1&&m.visible)||(i===2&&s.visible))ensure(distance(observed[i],wanted[i])<0.2,"Visible hand angle "+i+": "+observed[i]+" vs "+wanted[i]);
        return observed;
    }
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var hit=find(child,predicate);if(hit)return hit;}return null;}
    function click(item){ensure(item!==null);var p=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,p.x,p.y);wait(50);}
    function icon(root,suffix){wait(1700);click(find(root,function(o){return o.visible&&o.source!==undefined&&String(o.source).endsWith(suffix);}));}
    function configure(){
        icon(bar,"bar_activity_config.svg");tryCompare(dialogActivityConfig,"visible",true,2500);wait(900);
        var box=find(dialogActivityConfig,function(o){return o.visible&&o.modeBox!==undefined;});ensure(box!==null);box=box.modeBox;
        if(box.currentIndex!==(twentyFour?1:0)){
            click(find(box,function(o){return o.visible&&o.text===box.currentText;}));wait(200);
            var label=qsTranslate("ActivityConfig",twentyFour?"24 hours":"12 hours");click(find(dialogActivityConfig,function(o){return o.visible&&o.text===label&&o.font!==undefined;}));wait(400);
        }
        checked(box.currentIndex,twentyFour?1:0);dialogActivityConfig.forceActiveFocus();keyClick(Qt.Key_Return);tryCompare(dialogActivityConfig,"visible",false,2500);wait(1100);
        checked(String(ApplicationSettings.loadActivityConfiguration(activity.activityInfo.shortName()).mode),twentyFour?"2":"1");
    }
    property var evidence: ({})
    function save(){dialogActivityConfig.forceActiveFocus();keyClick(Qt.Key_Return);tryCompare(dialogActivityConfig,"visible",false,2500);wait(1100);}
    function open(){icon(bar,"bar_activity_config.svg");tryCompare(dialogActivityConfig,"visible",true,2500);wait(900);}
    function options(){open();var tab=find(dialogActivityConfig,function(o){return o.visible&&o.theme==="settingsButton"&&o.text===qsTranslate("DialogChooseLevel","Dataset");});ensure(tab!==null);click(tab);wait(200);var boxes=[];function walk(o){if(o.visible&&o.checked!==undefined&&o.indicatorImageHeight!==undefined)boxes.push(o);if(o.children)for(var child of o.children)walk(child);}walk(dialogActivityConfig);return boxes;}
    function test_controls(){
        wait(1400);checked(activity.activityInfo.title,"Aprende o relógio");checked(activity.numberOfLevel,10);
        icon(bar,"bar_hint.svg");ensure(helper.visible&&helper.opacity>0.9);var text=String(helper.text);ensure(/^\d{2}:00:00$/.test(text));ensure(distance(topAngle(h),parseInt(text.slice(0,2),10)%12*30)<0.2);icon(bar,"bar_hint.svg");checked(helper.visible,false);
        move(h,norm(topAngle(h)+30));var old=String(instructionPanel.textItem.text);open();save();checked(activity.currentLevel,0);checked(score.currentSubLevel,0);checked(okButton.enabled,true);
        twentyFour=true;configure();ensure(parse(instructionPanel.textItem.text)[0]>=12);configure();checked(String(ApplicationSettings.loadActivityConfiguration(activity.activityInfo.shortName()).mode),"2");twentyFour=false;configure();ensure(parse(instructionPanel.textItem.text)[0]<12);
        var boxes=options();checked(boxes.length,6);ensure(boxes[0].checked);var objective=String(boxes[0].text);ensure(objective.length>5);click(boxes[0]);save();checked(activity.numberOfLevel,9);
        boxes=options();checked(boxes[0].checked,false);checked(String(boxes[0].text),objective);click(boxes[0]);save();checked(activity.numberOfLevel,10);
        icon(bar,"bar_previous.svg");checked(activity.currentLevel,9);checked(score.currentSubLevel,0);ensure(!find(bar,function(o){return o.visible&&o.source!==undefined&&String(o.source).endsWith("bar_hint.svg");}));icon(bar,"bar_next.svg");checked(activity.currentLevel,0);
        var depth=pageView.depth;icon(bar,"bar_help.svg");tryCompare(pageView,"depth",depth+1,2500);wait(800);var help=pageView.currentItem;checked(help.title,"Aprende o relógio");ensure(help.content.indexOf(activity.activityInfo.manual)>=0);ensure(help.content.indexOf("Drag the")<0);grabImage(pageView).save("__QA_OUTPUT__/help.png");
        keyClick(Qt.Key_Escape);tryCompare(pageView,"depth",depth,2500);wait(700);
        // No focus forcing after help. The advertised interaction is dragging.
        var answer=parse(instructionPanel.textItem.text);setTime(answer);click(okButton);tryCompare(score,"currentSubLevel",1,1500);
        ActivityInfoTree.startingActivity="";keyClick(Qt.Key_W,Qt.ControlModifier);tryCompare(pageView,"depth",1,2500);ensure(pageView.currentItem.isMenu);
        evidence={title:"Aprende o relógio",levels:10,reduced:9,objective:objective,hintVisibleAndHidden:true,twelveAndTwentyFourSaved:true,partialRestart:true,previousNextWrap:true,helpPortuguese:true,dragAfterHelp:true,ctrlW:true,menu:true};
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
