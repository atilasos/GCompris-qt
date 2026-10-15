// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"DecimalControlsPT"
    when:items.numberOfLevel>0 && activity.visible
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
        if(item.source!==undefined && String(item.source).endsWith(suffix) && item.visible)return item;
        if(item.children)for(var i=0;i<item.children.length;i++){
            var found=findButton(item.children[i],suffix);if(found)return found;
        }
        return null;
    }
    function findText(item,text) {
        if(item.text!==undefined && item.text===text && item.visible)return item;
        if(item.children)for(var i=0;i<item.children.length;i++){
            var found=findText(item.children[i],text);if(found)return found;
        }
        return null;
    }
    function clickButton(parent,suffix) {
        // Key-layout changes can reposition the bar on the following frame.
        wait(150);
        var button=findButton(parent,suffix);
        verify(button!==null,"Button "+suffix+" exists");
        if(parent===bar)tryVerify(function(){
            var point=button.mapToItem(activityBackground,button.width/2,button.height/2);
            return point.y>=0 && point.y<activityBackground.height;
        },4000);
        mouseClick(button,button.width/2,button.height/2,Qt.LeftButton,Qt.NoModifier,50);
    }
    function test_help_level_navigation_and_return_to_menu() {
        wait(1600);
        var id=activity.activityInfo.shortName();
        verify(activity.activityInfo.title.length>0);
        verify(activity.activityInfo.title.indexOf("Learn")<0);
        activityBackground.forceActiveFocus();
        if(tutorialImage.visible)keyClick(Qt.Key_Escape);
        checkedWait(tutorialImage,"visible",false,2000);
        wait(2400);
        var initial=items.currentLevel;
        clickButton(bar,"bar_next.svg");
        checkedWait(items,"currentLevel",(initial+1)%items.numberOfLevel,2000);
        checkedCompare(items.score.currentSubLevel,0);
        clickButton(bar,"bar_previous.svg");
        checkedWait(items,"currentLevel",initial,2000);
        checkedCompare(items.score.currentSubLevel,0);
        // Save the exposed dataset configuration to restart through real UI.
        if(!isSubtractionMode) {
            var from=selectedBar.mapToItem(activityBackground,unselectedBar.cellSize/2,unselectedBar.cellSize/2);
            var to=topRectangle.mapToItem(activityBackground,topRectangle.width/2,topRectangle.height/2);
            mouseDrag(activityBackground,from.x,from.y,to.x-from.x,to.y-from.y,Qt.LeftButton,Qt.NoModifier,15);
            checkedCompare(droppedItems.count,1);
        } else {
            var first=multipleBars.itemAtIndex(0);
            var point=first.mapToItem(activityBackground,multipleBars.cellSize/2,multipleBars.cellSize/2);
            mouseClick(activityBackground,point.x,point.y);
            checkedCompare(largestNumberRepresentation.get(0).selectedSquareNumbers,0);
        }
        var depth=pageView.depth;
        clickButton(bar,"bar_activity_config.svg");
        checkedWait(pageView,"depth",depth+1,2000);
        wait(500);
        var config=pageView.currentItem;
        checkedCompare(config.chosenLevels.length,items.numberOfLevel);
        var save=findText(config,"Gravar");
        verify(save!==null);
        grabImage(pageView).save("__QA_OUTPUT__/datasets.png");
        mouseClick(save,save.width/2,save.height/2,Qt.LeftButton,Qt.NoModifier,50);
        checkedWait(pageView,"depth",depth,2000);
        wait(500);
        checkedCompare(score.currentSubLevel,0);
        checkedCompare(items.typeResult,false);
        if(!isSubtractionMode)checkedCompare(droppedItems.count,0);
        else verify(largestNumberRepresentation.get(0).selectedSquareNumbers>0);
        evidence.restartFromConfiguration=true;
        clickButton(bar,"bar_help.svg");
        checkedWait(pageView,"depth",depth+1,2000);
        wait(600);
        var help=pageView.currentItem;
        checkedCompare(help.title,activity.activityInfo.title);
        verify(help.content.indexOf(activity.activityInfo.description)>=0);
        verify(help.content.indexOf("Practice the")<0);
        evidence={activity:id,restartFromConfiguration:true,title:help.title,description:activity.activityInfo.description,
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
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,controls:evidence}));}
}
