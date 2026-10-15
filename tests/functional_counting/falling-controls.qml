// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "CountingFallingControls"
    when: activity.visible && items.numberOfLevel>0
    property var dice: __DICE_COUNTS__
    property var observations: []
    function checked(actual,expected,message) {
        if(actual!==expected)console.log("COUNTING_ASSERT",JSON.stringify({actual:actual,expected:expected,message:message}),new Error().stack);
        compare(actual,expected,message||"");
    }
    function ensure(value,message) {
        if(!value)console.log("COUNTING_ASSERT",message||"",new Error().stack);
        verify(value,message||"");
    }
    function awaiting(object,key,value,timeout) {
        try {tryCompare(object,key,value,timeout||6000);}
        catch(error){console.log("COUNTING_WAIT",key,String(object[key]),String(value),new Error().stack);throw error;}
    }
__COUNT_READERS__
__UI_HELPERS__
    function allFalling() {
        var found=[];for(var child of activityBackground.children)if(child.wonState!==undefined && !child.wonState && child.opacity===1)found.push(child);
        return found;
    }
    function currentCount(word) {return activity.activityName==="smallnumbers"?diceCount(word):dominoCount(word);}
    function test_a_all_ten_speeds_by_interface() {
        wait(1600);
        for(var speed=1;speed<=10;speed++) {
            var panel=openOptions();ensure(panel!==null);
            var slider=panel.speedSlider;
            var x=slider.leftPadding+(slider.availableWidth)*(speed-1)/9;
            mouseClick(slider,x,slider.height/2);checked(slider.value,speed);
            saveOptions();checked(activity.speedSetting,speed);
            checked(Number(ApplicationSettings.loadActivityConfiguration(activity.activityName).speedSetting),speed);
            tryVerify(function(){return allFalling().length>0;},5000);
            var word=allFalling()[0],y=word.y;wait(1000);ensure(word.y>y,"Configured animation really moves");
            observations.push({speed:speed,fromY:y,toY:word.y});console.log("COUNTING_SPEED",speed,word.y-y);
            if(speed===1 || speed===10)grabImage(activityBackground).save("__QA_OUTPUT__/speed-"+speed+".png");
        }
    }
    function test_b_loss_and_recovery_without_timer_changes() {
        var panel=openOptions();saveOptions();
        checked(activity.speedSetting,10);checked(score.currentSubLevel,0);
        tryVerify(function(){return allFalling().length>0;},5000);
        var word=allFalling()[0],started=Date.now(),lastY=word.y;
        while(activityBackground.children.indexOf(word)>=0 && Date.now()-started<120000) {
            ensure(!word.wonState);lastY=word.y;wait(50);
        }
        ensure(activityBackground.children.indexOf(word)<0,"The unanswered item naturally leaves the screen");
        ensure(lastY>activityBackground.height*0.8,"The missed object fell to the ground");
        ensure(Date.now()-started>5000,"Real falling time elapsed");checked(score.currentSubLevel,0);
        observations.push({missed:true,lastY:lastY,elapsedMs:Date.now()-started});
        var total=score.numberOfSubLevels;
        for(var round=0;round<total;round++) {
            tryVerify(function(){return visibleItems().length>0;},15000);
            var count=currentCount(visibleItems()[0]);textinput.forceActiveFocus();keyClick(String(count.count));
            awaiting(score,"currentSubLevel",round+1,1000);
        }
        awaiting(items,"currentLevel",1,10000);observations.push({recovered:true});
    }
    function test_c_help_navigation_restart_focus_and_menu() {
        var titles={smallnumbers:"Números com dados",smallnumbers2:"Números com dominós"};
        checked(activity.activityInfo.title,titles[activity.activityName]);
        checked(activity.levelFolder.length,8);checked(items.numberOfLevel,9);
        clickIcon(bar,"bar_next.svg");checked(items.currentLevel,2);
        clickIcon(bar,"bar_previous.svg");checked(items.currentLevel,1);
        var panel=openOptions();saveOptions();checked(score.currentSubLevel,0);
        var depth=pageView.depth;clickIcon(bar,"bar_help.svg");awaiting(pageView,"depth",depth+1);wait(600);
        var help=pageView.currentItem;checked(help.title,titles[activity.activityName]);
        ensure(help.content.indexOf(activity.activityInfo.manual)>=0);grabImage(pageView).save("__QA_OUTPUT__/help.png");
        clickIcon(help,"cancel.svg");awaiting(pageView,"depth",depth);wait(600);
        ApplicationSettings.isVirtualKeyboard=false;
        tryVerify(function(){return visibleItems().length>0;},15000);
        var count=currentCount(visibleItems()[0]),before=score.currentSubLevel;
        keyClick(String(count.count));awaiting(score,"currentSubLevel",before+1,1000);
        observations.push({focusRestored:true,physicalWithoutVisual:true});
        ActivityInfoTree.startingActivity="";clickIcon(bar,"bar_home.svg");awaiting(pageView,"depth",1);ensure(pageView.currentItem.isMenu);
    }
    function cleanupTestCase(){if(qtest_results.failCount>0)grabImage(activityBackground).save("__QA_OUTPUT__/failure.png");console.log("NATIVE_COUNTING_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,observations:observations}));}
}
