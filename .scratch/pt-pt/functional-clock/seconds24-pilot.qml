// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "ClockByPortugueseInstructionAndVisibleAngles"
    when: activity.visible && clock.width>0
    property int firstLevel: 6
    property int targetLevels: 1
    property bool twentyFour: true
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
        var wanted=angles(answer),observed=[topAngle(h),topAngle(m),topAngle(s)];
        for(var i=0;i<3;i++)if(i===0||(i===1&&m.visible)||(i===2&&s.visible))ensure(distance(observed[i],wanted[i])<0.2,"Visible hand angle "+i+": "+observed[i]+" vs "+wanted[i]);
        return observed;
    }
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var hit=find(child,predicate);if(hit)return hit;}return null;}
    function click(item){ensure(item!==null);var p=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,p.x,p.y);wait(50);}
    function icon(root,suffix){click(find(root,function(o){return o.visible&&o.source!==undefined&&String(o.source).endsWith(suffix);}));}
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
    function test_complete(){
        wait(1300);if(twentyFour)configure();checked(activity.numberOfLevel,10);checked(activity.currentLevel,firstLevel-1);
        for(var offset=0;offset<targetLevels;offset++){
            var level=firstLevel+offset;checked(activity.currentLevel,level-1);checked(score.numberOfSubLevels,5);
            for(var question=0;question<5;question++){
                wait(250);checked(score.currentSubLevel,question);
                var text=String(instructionPanel.textItem.text),answer=parse(text);
                ensure(twentyFour?answer[0]>=12:answer[0]<12,"Selected clock format in visible instruction");
                var before=[topAngle(h),topAngle(m),topAngle(s)],expected=angles(answer);
                ensure(distance(before[0],expected[0])>1||m.visible&&distance(before[1],expected[1])>1||s.visible&&distance(before[2],expected[2])>1,"Initial drawn clock differs from requested time");
                click(okButton);checked(score.currentSubLevel,question);tryVerify(function(){return errorRectangle.opacity>0.5;},1200);wrong++;tryCompare(okButton,"enabled",true,3500);
                var observed=setTime(answer);click(okButton);tryCompare(score,"currentSubLevel",question+1,1500);
                questions.push({level:level,text:text,answer:answer,angles:observed,minutes:m.visible,seconds:s.visible});
                if(question<4)tryCompare(okButton,"enabled",true,6000);
            }
            tryVerify(function(){return bonus.isPlaying;},5000);grabImage(activity).save("__QA_OUTPUT__/level-"+level+".png");completed.push({level:level,questions:5});
            tryCompare(activity,"currentLevel",level%10,8000);wait(300);
        }
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,questions:questions,completed:completed,wrong:wrong,gestures:gestures,twentyFour:twentyFour}));}
}
