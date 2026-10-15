// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "ScalesControlsPT"
    when: items.numberOfLevel > 0 && activity.visible
    property var evidence: ({})
    function checked(actual,expected,message) {
        if(actual!==expected)console.log("SCALES_CONTROL_ASSERT",String(actual),String(expected),message||"",new Error().stack);
        compare(actual,expected,message||"");
    }
    function ensure(value,message) {
        if(!value)console.log("SCALES_CONTROL_ASSERT",message||"",new Error().stack);
        verify(value,message||"");
    }
    function depth(value) {tryCompare(pageView,"depth",value,3000);tryCompare(pageView,"busy",false,3000);}
    function find(root,property,value) {
        if(root[property]!==undefined && String(root[property]).endsWith(value))return root;
        if(root.children)for(var c=0;c<root.children.length;c++){var item=find(root.children[c],property,value);if(item)return item;}
        return null;
    }
    function button(root,suffix) {wait(150);var item=find(root,"source",suffix);ensure(item!==null);mouseClick(item);}
    function massImage(root) {
        if(root.img!==undefined && root.img!=="gift.svg")return root;
        if(root.children)for(var c=0;c<root.children.length;c++){var item=massImage(root.children[c]);if(item)return item;}
        return null;
    }
    function test_help_restart_navigation_menu() {
        wait(1600);
        var id=activity.activityInfo.shortName();
        var titles={scalesboard:"Equilibrar as balanças corretamente",
            scalesboard_weight:"Balança que usa o Sistema Internacional de Unidades",
            scalesboard_weight_avoirdupois:"Balança que usa o sistema imperial de unidades"};
        var initialDepth=pageView.depth;
        button(bar,"bar_help.svg");depth(initialDepth+1);
        var help=pageView.currentItem;
        grabImage(pageView).save("__QA_OUTPUT__/help.png");
        checked(help.title,titles[id],"Portuguese title agrees in number");
        ensure(help.content.indexOf(activity.activityInfo.description)>=0);
        ensure(help.content.indexOf("balança")>=0);
        if(id==="scalesboard_weight") {ensure(help.content.indexOf("1000")>=0);ensure(help.content.indexOf("gramas")>=0);}
        if(id==="scalesboard_weight_avoirdupois") {ensure(help.content.indexOf("16")>=0);ensure(help.content.indexOf("onças")>=0);}
        evidence={activity:id,title:help.title,manual:activity.activityInfo.manual,helpOpened:true};
        button(help,"cancel.svg");depth(initialDepth);
        button(bar,"bar_next.svg");tryCompare(items,"currentLevel",1);checked(score.currentSubLevel,0);
        button(bar,"bar_previous.svg");tryCompare(items,"currentLevel",0);checked(score.currentSubLevel,0);wait(300);
        var source=massImage(masseAreaCenter);ensure(source!==null);
        var start=source.mapToItem(activityBackground,source.width/2,source.height/2);
        var destination=masseAreaLeft.dropArea.mapToItem(activityBackground,masseAreaLeft.dropArea.width/2,masseAreaLeft.dropArea.height/2);
        mousePress(activityBackground,start.x,start.y,Qt.LeftButton,Qt.NoModifier,20);
        mouseMove(activityBackground,start.x+15,start.y+15,20,Qt.LeftButton);
        mouseMove(activityBackground,start.x+30,start.y+30,20,Qt.LeftButton);
        mouseMove(activityBackground,destination.x,destination.y,40,Qt.LeftButton);
        wait(50);mouseRelease(activityBackground,destination.x,destination.y,Qt.LeftButton,Qt.NoModifier,20);wait(300);
        ensure(massImage(masseAreaLeft)!==null,"Partial drag before restart");
        button(bar,"bar_activity_config.svg");depth(initialDepth+1);
        var save=find(pageView.currentItem,"text","Gravar");ensure(save!==null);mouseClick(save);depth(initialDepth);wait(250);
        checked(items.currentLevel,0);checked(score.currentSubLevel,0);
        ensure(massImage(masseAreaLeft)===null,"Saving restarts the real puzzle");
        evidence.levelButtons=true;evidence.restartViaConfigSave=true;
        ActivityInfoTree.startingActivity="";
        button(bar,"bar_home.svg");depth(1);ensure(pageView.currentItem.isMenu);
        evidence.returnedToMenu=true;grabImage(pageView).save("__QA_OUTPUT__/menu.png");
    }
    function cleanupTestCase(){console.log("NATIVE_SCALES_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,controls:evidence}));}
}
