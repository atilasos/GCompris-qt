// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"FunctionalMemoryControlsPT"
    when:true
    function initTestCase() {
        wait(1600);
        if(!activity.visible){keyClick(Qt.Key_Return,Qt.NoModifier,0);tryCompare(activity,"visible",true,2500);}
        activity.stop();
        var count=activity.activityInfo.shortName().indexOf("memory-math-mult-div")===0?9:10;
        var folders=[];for(var i=1;i<=count;i++)folders.push(String(i));
        activity.levelFolder=folders;activity.start();wait(1100);
        compare(items.numberOfLevel,count);compare(activity.numberOfLevel,count);
    }

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
        var families={"add":"adição","minus":"subtração","mult":"multiplicação","div":"divisão","add-minus":"adição e subtração","mult-div":"multiplicação e divisão","add-minus-mult-div":"todas as operações"};
        var family=id.replace("memory-math-","").replace(/-tux$/,"");
        var title="Jogo de memória "+(family==="add-minus-mult-div"?"de ":"da ")+families[family]+(activity.withTux?" contra o Tux":"");
        var titles={};titles[id]=title;
        checkedCompare(activity.activityInfo.title,titles[id]);
        var initial=items.currentLevel;
        clickButton(bar,"bar_next.svg");
        checkedWait(items,"currentLevel",(initial+1)%items.numberOfLevel,2000);
        checkedCompare(items.player1Score.playerScore,0);
        clickButton(bar,"bar_previous.svg");
        checkedWait(items,"currentLevel",initial,2000);
        checkedCompare(items.player1Score.playerScore,0);
        var depth=pageView.depth;
        clickButton(bar,"bar_help.svg");
        checkedWait(pageView,"depth",depth+1,2000);
        wait(600);
        var help=pageView.currentItem;
        checkedCompare(help.title,titles[id]);
        verify(help.content.indexOf(activity.activityInfo.description)>=0);
        verify(activity.activityInfo.manual.indexOf("setas")>=0 || activity.activityInfo.manual.indexOf("Setas")>=0,"Portuguese keyboard help");
        verify(help.content.indexOf("Flip the cards")<0);
        if(activity.withTux)verify(activity.activityInfo.title.indexOf("Tux")>=0);
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
        clickButton(bar,"bar_home.svg");
        checkedWait(pageView,"depth",1,2000);
        wait(600);
        verify(pageView.currentItem.isMenu);
        evidence.returnedToMenu=true;
        grabImage(pageView).save("__QA_OUTPUT__/menu.png");
    }
    function cleanupTestCase(){console.log("NATIVE_MEMORY_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,controls:evidence}));}
}
