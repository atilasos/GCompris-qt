// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"FunctionalReadingControlsPT"
    when:items.wordlist.maxLevel>0 && activity.visible
    property var evidence: ({})
    function checkedCompare(actual,expected,message) {
        if(actual!==expected) console.log("NATIVE_CONTROL_FAILURE",String(actual),String(expected),message||"");
        compare(actual,expected,message||"");
    }
    function checkedWait(object,property,expected,timeout) {
        try { tryCompare(object,property,expected,timeout); }
        catch(error) { console.log("NATIVE_CONTROL_FAILURE",property,String(object[property]),String(expected),error.stack); throw error; }
    }
    function findButton(item,suffix) {
        if(item.source!==undefined && String(item.source).endsWith(suffix))return item;
        if(item.children)for(var i=0;i<item.children.length;i++){
            var found=findButton(item.children[i],suffix);if(found)return found;
        }
        return null;
    }
    function clickButton(parent,suffix) {
        // Key-layout changes can reposition the bar on the following frame.
        wait(150);
        var button=findButton(parent,suffix);
        verify(button!==null,"Button "+suffix+" exists");
        mouseClick(button,button.width/2,button.height/2,Qt.LeftButton,Qt.NoModifier,0);
    }
    function test_help_level_navigation_and_return_to_menu() {
        wait(1600);
        var id=activity.activityInfo.shortName();
        var titles={readingh:"Exercício de leitura na horizontal",readingv:"Exercício de leitura na vertical"};
        checkedCompare(activity.activityInfo.title,titles[id]);
        checkedCompare(activity.numberOfLevel,3,"Sequence scheduler sees all levels");
        verify(items.wordlist.wordList.levels[2].words.indexOf("música")>=0);
        var initial=items.currentLevel;
        mouseClick(iAmReady);
        checkedWait(items,"currentIndex",0,2000);
        checkedCompare(wordDropTimer.running,true);
        clickButton(bar,"bar_next.svg");
        checkedWait(items,"currentLevel",(initial+1)%items.wordlist.maxLevel,2000);
        checkedCompare(wordDropTimer.running,false);
        checkedCompare(iAmReady.visible,true);
        checkedCompare(items.score.currentSubLevel,0);
        clickButton(bar,"bar_previous.svg");
        checkedWait(items,"currentLevel",initial,2000);
        checkedCompare(items.score.currentSubLevel,0);
        clickButton(bar,"bar_previous.svg");
        checkedWait(items,"currentLevel",2,2000);
        clickButton(bar,"bar_next.svg");
        checkedWait(items,"currentLevel",0,2000);
        var depth=pageView.depth;
        clickButton(bar,"bar_help.svg");
        checkedWait(pageView,"depth",depth+1,2000);
        wait(600);
        var help=pageView.currentItem;
        checkedCompare(help.title,titles[id]);
        verify(help.content.indexOf(activity.activityInfo.description)>=0);
        verify(help.content.indexOf("A word is shown")<0);
        verify(help.content.indexOf("A letter is spoken")<0);
        verify(help.content.indexOf("Find the requested character")<0);
        evidence={activity:id,title:help.title,description:activity.activityInfo.description,
                  manual:activity.activityInfo.manual,helpOpened:true,levelButtons:true};
        grabImage(pageView).save("__QA_OUTPUT__/help.png");
        clickButton(help,"cancel.svg");
        checkedWait(pageView,"depth",depth,2000);
        wait(600);
        verify(pageView.currentItem===activity);
        // --launch otherwise intentionally exits on Home. Clear that launch
        // fixture to exercise the normal application's return-to-menu route.
        ActivityInfoTree.startingActivity="";
        activity.forceActiveFocus();
        keyClick(Qt.Key_Escape);
        checkedWait(pageView,"depth",1,2000);
        wait(600);
        verify(pageView.currentItem.isMenu);
        evidence.returnedToMenu=true;
        grabImage(pageView).save("__QA_OUTPUT__/menu.png");
    }
    function cleanupTestCase(){console.log("NATIVE_READING_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,controls:evidence}));}
}
