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
        for(var move=1;move<=12;move++)mouseMove(pageView,start.x+(end.x-start.x)*move/12,start.y+(end.y-start.y)*move/12,30,Qt.LeftButton);
        mouseRelease(pageView,end.x,end.y,Qt.LeftButton,Qt.NoModifier,0);wait(80);
    }
    function test_all_three_visible_sliders(){
        wait(1800);var controls=[color1,color2,color3];
        var expected=activity.modeRGB?[[1,0,0],[1,1,0],[1,1,1]]:[[1,0,1],[1,0,0],[0,0,0]];
        for(var index=0;index<3;index++){
            dragSlider(controls[index],1,1);
            observations.push({control:index,expected:expected[index],actual:rgb(result)});
            ensure(closeColor(rgb(result),expected[index]),'Each visible slider accepts a real gesture from its handle');
        }
    }
    function cleanupTestCase(){console.log('NATIVE_COLORS_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,wins:wins,observations:observations}));}
}
