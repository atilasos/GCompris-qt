// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    id: nativeColors
    name: "VisibleColorMixing"
    when: activity.visible && items.numberOfLevel>0
    property var observations: []
    property int wins: 0
    Connections {target:bonus;function onWin(){nativeColors.wins++;}}
    function ensure(value,message){if(!value){console.log('COLORS_ASSERT',message,new Error().stack);grabImage(pageView).save('__QA_OUTPUT__/failure.png');}verify(value,message||'');}
    function checked(a,b,message){if(a!==b)console.log('COLORS_COMPARE',a,b,message,new Error().stack);compare(a,b,message||'');}
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var result=find(child,predicate);if(result)return result;}return null;}
    function click(item){ensure(item!==null);var p=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);wait(40);}
    function rgb(item){return [item.color.r,item.color.g,item.color.b];}
    function closeColor(a,b){return a.every(function(value,i){return Math.abs(value-b[i])<0.006;});}
    function steps(displayed,divisions){
        if(activity.modeRGB)return displayed.map(function(channel){return Math.round(channel*divisions);});
        return [Math.round((1-displayed[1])*divisions),Math.round((1-displayed[2])*divisions),Math.round((1-displayed[0])*divisions)];
    }
    function icon(chooser,suffix){return find(chooser,function(item){return item.source!==undefined&&String(item.source).endsWith(suffix)&&item.buttonsBlocked!==undefined;});}
    function dragSlider(chooser,value,divisions){
        var slider=find(chooser,function(item){return item.maxLimit!==undefined;});ensure(slider!==null);
        var handle=find(slider,function(item){return item.color!==undefined&&String(item.color)==='#535353';});ensure(handle!==null);
        var start=handle.mapToItem(pageView,handle.width/2,handle.height/2);
        var end=slider.mapToItem(pageView,handle.width/2+slider.maxLimit*value/divisions,slider.height/2);
        mousePress(pageView,start.x,start.y,Qt.LeftButton,Qt.NoModifier,0);
        mouseMove(pageView,start.x+15,start.y+15,20,Qt.LeftButton);
        mouseMove(pageView,end.x,end.y,60,Qt.LeftButton);
        mouseRelease(pageView,end.x,end.y,Qt.LeftButton,Qt.NoModifier,0);wait(80);
    }
    function test_all_levels_by_visible_target(){
        wait(1600);checked(items.numberOfLevel,6);checked(items.currentLevel,0);
        var choosers=[color1,color2,color3];
        var limit=1||6;
        for(var level=0;level<limit;level++){
            checked(items.currentLevel,level);checked(score.numberOfSubLevels,6);
            for(var question=0;question<6;question++){
                tryCompare(validate,'enabled',true,5000);wait(150);
                var wanted=rgb(target),divisions=level+1,answer=steps(wanted,divisions);
                ensure(wanted.every(function(c){return c>=0&&c<=1;}));
                // Deliberately wrong, selected from visible target alone.
                if(closeColor(rgb(result),wanted))click(icon(color1,'plus.svg'));
                var before=score.currentSubLevel;click(validate);checked(score.currentSubLevel,before);
                ensure(helpMessage.text.length>0,'Wrong answer produces visible Portuguese guidance');
                ensure(helpMessage.text.indexOf('enough')<0&&helpMessage.text.indexOf('Too much')<0);
                var rejection=helpMessage.text;
                for(var c=0;c<3;c++){
                    // Exercise both buttons and real slider gestures in every level.
                    for(var reset=0;reset<divisions;reset++)click(icon(choosers[c],'minus.svg'));
                    if(question%2===0)for(var step=0;step<answer[c];step++)click(icon(choosers[c],'plus.svg'));
                    else dragSlider(choosers[c],answer[c],divisions);
                }
                ensure(closeColor(rgb(result),wanted),'Rendered mixture matches the rendered target');
                var actual=rgb(result);click(validate);checked(score.currentSubLevel,before+1);
                checked(validate.enabled,false);
                click(icon(color1,'plus.svg'));ensure(closeColor(rgb(result),actual),'Feedback blocks extra input');
                observations.push({level:level+1,question:question+1,displayedTarget:wanted,steps:answer,result:actual,rejection:rejection,route:question%2===0?'buttons':'drag'});
                if(question===0)grabImage(activityBackground).save('__QA_OUTPUT__/level'+(level+1)+'.png');
                if(question<5){tryCompare(validate,'enabled',true,6000);checked(score.currentSubLevel,before+1);}
                else{tryCompare(bonus,'isPlaying',true,6000);tryCompare(items,'currentLevel',(level+1)%6,9000);}
                console.log('COLORS_MIX',activity.modeRGB?'light':'paint',level+1,question+1);
            }
        }
        checked(wins,limit);
    }
    function cleanupTestCase(){console.log('NATIVE_COLORS_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,wins:wins,observations:observations}));}
}
