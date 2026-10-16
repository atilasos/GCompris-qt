// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "CountingFruitControls"
    when: activity.visible && items.numberOfLevel>0
    property var evidence: []
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
__UI_HELPERS__
__FRUIT_DRAG__
    function test_controls_and_physical_focus_with_both_preferences() {
        wait(2400);checked(items.numberOfLevel,14);checked(activity.levelFolder.length,4);
        checked(activity.activityInfo.title,"Contagem dos itens");
        while(items.currentLevel<4) {clickIcon(bar,"bar_next.svg");}
        wait(2400);var initial=items.currentLevel;ensure(answerRepeater.count>=2);
        clickIcon(bar,"bar_next.svg");checked(items.currentLevel,(initial+1)%14);
        clickIcon(bar,"bar_previous.svg");checked(items.currentLevel,initial);
        for(var visualKeys of [false,true]) {
            ApplicationSettings.isVirtualKeyboard=visualKeys;wait(500);
            var depth=pageView.depth;clickIcon(bar,"bar_help.svg");awaiting(pageView,"depth",depth+1);wait(600);
            var help=pageView.currentItem;checked(help.title,"Contagem dos itens");
            ensure(help.content.indexOf(activity.activityInfo.description)>=0);
            grabImage(pageView).save("__QA_OUTPUT__/help-"+visualKeys+".png");
            clickIcon(help,"cancel.svg");awaiting(pageView,"depth",depth);wait(500);
            keyClick(Qt.Key_Down);checked(answerRepeater.currentIndex,1);
            keyClick(Qt.Key_Up);checked(answerRepeater.currentIndex,0);
            keyClick(Qt.Key_0);checked(answerRepeater.itemAt(0).itemText,"0");checked(score.currentSubLevel,0);
            if(instructionPanel.opacity>0){mouseClick(instructionPanel);awaiting(instructionPanel,"opacity",0);}
            var drag=dragFruit();
            var panel=openOptions();saveOptions();checked(items.currentLevel,0);checked(score.currentSubLevel,0);
            while(items.currentLevel<initial)clickIcon(bar,"bar_next.svg");wait(2400);
            for(var index=0;index<answerRepeater.count;index++)checked(answerRepeater.itemAt(index).itemText,"?");
            evidence.push({visualKeyboard:visualKeys,helpFocus:true,restartPartialAnswerAndDrag:true,drag:drag});
        }
        ActivityInfoTree.startingActivity="";clickIcon(bar,"bar_home.svg");awaiting(pageView,"depth",1);ensure(pageView.currentItem.isMenu);
    }
    function cleanupTestCase(){if(qtest_results.failCount>0)grabImage(activityBackground).save("__QA_OUTPUT__/failure.png");console.log("NATIVE_COUNTING_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
