// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"TensControlsPT"
    when:items.numberOfLevel>0 && activity.visible
    property var evidence: ({})
    function checkedCompare(actual,expected,message) {
        if(actual!==expected) console.log("NATIVE_CONTROL_FAILURE",String(actual),String(expected),message||"");
        compare(actual,expected,message||"");
    }
    function checkedWait(object,property,expected,timeout) {
        try {
            tryCompare(object,property,expected,timeout);
            if(object===pageView)tryCompare(pageView,"busy",false,timeout);
        }
        catch(error) { console.log("NATIVE_CONTROL_FAILURE",property,String(object[property]),String(expected),error.stack); throw error; }
    }
    function ensure(value,message) {
        if(!value)console.log("NATIVE_CONTROL_FAILURE",message||"",new Error().stack);
        verify(value,message||"");
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
        ensure(button!==null,"Button "+suffix+" exists");
        mouseClick(button,button.width/2,button.height/2,Qt.LeftButton,Qt.NoModifier,0);
    }
    function findView(root,model) {
        if(root.model!==undefined && root.model===model && root.itemAtIndex!==undefined)return root;
        if(root.children)for(var c=0;c<root.children.length;c++){var v=findView(root.children[c],model);if(v)return v;}
        return null;
    }
    function findText(root,text) {
        if(root.text!==undefined && root.text===text)return root;
        if(root.children)for(var c=0;c<root.children.length;c++){var v=findText(root.children[c],text);if(v)return v;}
        return null;
    }
    function test_help_level_navigation_and_return_to_menu() {
        wait(1600);
        var id=activity.activityInfo.shortName();
        var titles={tens_complement_find:"Descobrir o complemento de dez",tens_complement_swap:"Trocar o complemento de dez",tens_complement_calculate:"Calcular usando o complemento de dez",tens_complement_use:"Usar o complemento de dez"};
        checkedCompare(activity.activityInfo.title,titles[id]);
        var initial=items.currentLevel;
        clickButton(bar,"bar_next.svg");
        checkedWait(items,"currentLevel",(initial+1)%items.numberOfLevel,2000);
        if(id==="tens_complement_find" || id==="tens_complement_use") checkedCompare(items.score.currentSubLevel,0);
        clickButton(bar,"bar_previous.svg");
        checkedWait(items,"currentLevel",initial,2000);
        if(id==="tens_complement_find" || id==="tens_complement_use") checkedCompare(items.score.currentSubLevel,0);
        // The normal next/previous buttons restart level zero, including input.
        wait(200);
        if(id==="tens_complement_calculate") {
            var model=items.equations.get(0).listmodel;
            var inputColumn=model.count-1;
            var inputView=findView(activityBackground,model);ensure(inputView!==null);
            mouseClick(inputView.itemAtIndex(model.count-1));
            activityBackground.forceActiveFocus();keyClick(Qt.Key_5);checkedCompare(numPad.answer,"5");
            clickButton(bar,"bar_next.svg");clickButton(bar,"bar_previous.svg");wait(200);
            checkedCompare(items.equations.get(0).listmodel.get(inputColumn).value,"");
        }
        // Restart through the real dataset dialog after a partial user action.
        var cardGame=id==="tens_complement_find" || id==="tens_complement_use";
        if(cardGame) {
            mouseClick(container.itemAtIndex(0));checkedCompare(items.selectedIndex,0);
            var row=items.holderListModel.get(0);
            var model=id==="tens_complement_use"?row.secondRow:row.addition;
            var blank=-1;for(var c=0;c<model.count;c++)if(model.get(c).value==="?"){blank=c;break;}
            ensure(blank>=0);mouseClick(findView(activityBackground,model).itemAtIndex(blank));
            ensure(model.get(blank).value!=="?");
        } else {
            var model=items.equations.get(0).listmodel;
            mouseClick(findView(activityBackground,model).itemAtIndex(id==="tens_complement_calculate"?model.count-1:1));
            if(id==="tens_complement_calculate") {activityBackground.forceActiveFocus();keyClick(Qt.Key_5);checkedCompare(numPad.answer,"5");}
            else ensure(items.previousSelectedCard!==undefined);
        }
        var beforeConfig=pageView.depth;
        clickButton(bar,"bar_activity_config.svg");checkedWait(pageView,"depth",beforeConfig+1,2000);wait(100);
        var save=findText(pageView.currentItem,"Gravar");ensure(save!==null);
        grabImage(pageView).save("__QA_OUTPUT__/config.png");mouseClick(save);
        checkedWait(pageView,"depth",beforeConfig,2000);wait(100);
        checkedCompare(items.currentLevel,0);
        if(cardGame) {checkedCompare(items.selectedIndex,-1);checkedCompare(items.score.currentSubLevel,0);}
        else {ensure(items.previousSelectedCard===undefined);if(id==="tens_complement_calculate")checkedCompare(items.equations.get(0).listmodel.get(inputColumn).value,"");}
        var depth=pageView.depth;
        clickButton(bar,"bar_help.svg");
        checkedWait(pageView,"depth",depth+1,2000);
        wait(600);
        var help=pageView.currentItem;
        checkedCompare(help.title,titles[id]);
        ensure(help.content.indexOf(activity.activityInfo.description)>=0);
        ensure(help.content.indexOf("Create pairs")<0);
        ensure(help.content.indexOf("complemento")>=0);
        evidence={activity:id,title:help.title,description:activity.activityInfo.description,
                  manual:activity.activityInfo.manual,helpOpened:true,levelButtons:true,restartViaConfigSave:true};
        grabImage(pageView).save("__QA_OUTPUT__/help.png");
        clickButton(help,"cancel.svg");
        checkedWait(pageView,"depth",depth,2000);
        wait(600);
        ensure(pageView.currentItem===activity);
        // --launch otherwise intentionally exits on Home. Clear that launch
        // fixture to exercise the normal application's return-to-menu route.
        ActivityInfoTree.startingActivity="";
        clickButton(bar,"bar_home.svg");
        checkedWait(pageView,"depth",1,2000);
        wait(600);
        ensure(pageView.currentItem.isMenu);
        evidence.returnedToMenu=true;
        grabImage(pageView).save("__QA_OUTPUT__/menu.png");
    }
    function cleanupTestCase(){console.log("NATIVE_TENS_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,controls:evidence}));}
}
