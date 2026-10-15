// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "HanoiPortugueseControls"
    when: activity.visible && discRepeater.count>0
    property var result: ({})
    function checked(actual,expected,message) {
        if(actual!==expected)console.log("HANOI_CONTROL_ASSERT",String(actual),String(expected),message||"",new Error().stack);
        compare(actual,expected,message||"");
    }
    function ensure(value,message) {
        if(!value)console.log("HANOI_CONTROL_ASSERT",message||"",new Error().stack);
        verify(value,message||"");
    }
    function awaiting(root,property,value,timeout) {
        try {tryCompare(root,property,value,timeout || 5000);}
        catch(error) {console.log("HANOI_CONTROL_WAIT",property,String(root[property]),String(value),new Error().stack);throw error;}
    }
    function find(root,suffix) {
        if(root.source!==undefined && String(root.source).endsWith(suffix))return root;
        if(root.children)for(var child of root.children){var found=find(child,suffix);if(found)return found;}
        return null;
    }
    function icon(root,suffix) {
        wait(1600);var button=find(root,suffix);ensure(button!==null,"Icon "+suffix);mouseClick(button);
    }
    function visibleTop(peg) {
        var found=null;
        for(var i=0;i<discRepeater.count;i++) {
            var disc=discRepeater.itemAt(i);
            if(disc.parent===peg && (found===null || disc.y<found.y))found=disc;
        }
        return found;
    }
    function drag(disc,target) {
        var start=disc.mapToItem(activityBackground,disc.width/2,disc.height/2);
        var end=target.mapToItem(activityBackground,target.width/2,target.height/2);
        mousePress(activityBackground,start.x,start.y,Qt.LeftButton,Qt.NoModifier,20);
        mouseMove(activityBackground,start.x+15,start.y+15,20,Qt.LeftButton);
        mouseMove(activityBackground,start.x+30,start.y+30,20,Qt.LeftButton);
        mouseMove(activityBackground,end.x,end.y,50,Qt.LeftButton);
        mouseRelease(activityBackground,end.x,end.y,Qt.LeftButton,Qt.NoModifier,20);wait(150);
    }
    function test_navigation_reload_help_and_menu() {
        wait(1600);
        var real=activity.activityMode==="real",levels=real?3:6;
        checked(activity.numberOfLevel,levels);
        checked(activity.activityInfo.title,real?"A Torre de Hanói":"Torre de Hanói Simplificada");
        icon(bar,"bar_next.svg");awaiting(activity,"currentLevel",1);
        icon(bar,"bar_previous.svg");awaiting(activity,"currentLevel",0);wait(600);
        result.phase="partial-before-reload";
        var peg=towerModel.itemAt(real?1:towerModel.count-2);
        var disc=visibleTop(towerModel.itemAt(0));ensure(disc!==null && disc.enabled);
        drag(disc,peg);checked(disc.parent,peg);
        icon(bar,"bar_reload.svg");
        tryVerify(function(){return visibleTop(towerModel.itemAt(real?1:towerModel.count-2))===null;},3000);
        result.phase="help";
        var depth=pageView.depth;
        icon(bar,"bar_help.svg");awaiting(pageView,"depth",depth+1);wait(600);
        var help=pageView.currentItem;
        checked(help.title,activity.activityInfo.title);
        ensure(help.content.indexOf(activity.activityInfo.description)>=0);
        ensure(help.content.indexOf("Drag and drop")<0 && help.content.indexOf("Mouse-manipulation")<0);
        grabImage(pageView).save("__QA_OUTPUT__/help.png");
        keyClick(Qt.Key_Escape);awaiting(pageView,"depth",depth);wait(600);
        result.phase="drag-after-help";
        peg=towerModel.itemAt(real?1:towerModel.count-2);
        disc=visibleTop(towerModel.itemAt(0));ensure(disc!==null && disc.enabled);
        drag(disc,peg);checked(disc.parent,peg);
        var reader=Qt.createQmlObject('import core 1.0; File {}',this);
        var resources=[];
        var images=[activityBackground];
        for(var i=0;i<towerModel.count;i++)images.push(towerModel.itemAt(i));
        for(var image of images) {
            checked(image.status,Image.Ready);
            var source=String(image.source);if(resources.indexOf(source)>=0)continue;
            resources.push(source);
            var name=source.slice(source.lastIndexOf("/")+1);
            ensure(reader.copy(source,"file://__QA_OUTPUT__/"+name));
        }
        result={activity:activity.activityInfo.shortName(),levels:levels,helpClosedWithEscape:true,
                reloadClearedPartial:true,dragAfterHelp:true,resources:resources};
        ActivityInfoTree.startingActivity="";icon(bar,"bar_home.svg");
        awaiting(pageView,"depth",1);ensure(pageView.currentItem.isMenu);
        grabImage(pageView).save("__QA_OUTPUT__/menu.png");
    }
    function cleanupTestCase(){console.log("NATIVE_HANOI_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,controls:result}));}
}
