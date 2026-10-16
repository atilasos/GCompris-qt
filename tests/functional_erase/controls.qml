// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: 'EraseControls'
    when: true
    property var evidence: ({})
    function waitProperty(object,property,value,timeout){try{tryCompare(object,property,value,timeout);}catch(error){console.log('ERASE_CONTROL_WAIT',property,object[property],value,error.stack);grabImage(pageView).save('__QA_OUTPUT__/failure.png');throw error;}}
    function check(a,b,message){if(a!==b)console.log('ERASE_CONTROL_ASSERT',a,b,message||'',new Error().stack);compare(a,b,message||'');}
    function find(root,predicate) {
        if(predicate(root))return root;
        if(root.children)for(var child of root.children){var found=find(child,predicate);if(found)return found;}
        return null;
    }
    function click(item) {
        verify(item!==null);var p=item.mapToItem(pageView,item.width/2,item.height/2);
        mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);
    }
    function button(suffix) {
        click(find(bar,function(item){return item.source!==undefined&&String(item.source).endsWith(suffix);}));
    }
    function saveConfiguration() {
        button('bar_activity_config.svg');waitProperty(dialogActivityConfig,'visible',true,2500);wait(1100);
        dialogActivityConfig.forceActiveFocus();keyClick(Qt.Key_Return);waitProperty(dialogActivityConfig,'visible',false,2500);wait(1100);
    }
    function visibleCount() {
        var result=0;for(var i=0;i<repeater.count;i++)if(repeater.itemAt(i).visible&&repeater.itemAt(i).opacity>0)result++;
        return result;
    }
    function revealFirst() {
        var outside=activityBackground.mapToItem(pageView,activityBackground.width/2,bar.y-5);mouseMove(pageView,outside.x,outside.y,0);wait(60);
        var tile=repeater.itemAt(0),p=tile.mapToItem(pageView,tile.width/2,tile.height/2);
        if(activity.type==='erase')mouseMove(pageView,p.x,p.y,0);
        else if(activity.type==='click')mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,10);
        else mouseDoubleClickSequence(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,10);
        wait(260);console.log('ERASE_CONTROL_REVEAL',activity.type,tile.opacity,visibleCount(),p.x,p.y);waitProperty(tile,'opacity',0,1000);
        var safe=activityBackground.mapToItem(pageView,activityBackground.width/2,bar.y-5);mouseMove(pageView,safe.x,safe.y,0);
    }
    function test_restart_navigation_help_focus_menu() {
        wait(1800);saveConfiguration();
        check(activity.numberOfLevel,6);check(items.numberOfLevel,6);check(items.currentLevel,0);check(visibleCount(),25);
        revealFirst();check(visibleCount(),24);check(items.currentSubLevel,0);
        saveConfiguration();check(items.currentLevel,0);check(items.currentSubLevel,0);check(visibleCount(),25);check(okButton.visible,false);check(score.message,'0/6');
        button('bar_previous.svg');check(items.currentLevel,5);check(visibleCount(),64);check(items.currentSubLevel,0);
        button('bar_next.svg');check(items.currentLevel,0);check(visibleCount(),25);check(items.currentSubLevel,0);
        var depth=pageView.depth;button('bar_help.svg');waitProperty(pageView,'depth',depth+1,2500);wait(1100);
        var help=pageView.currentItem;
        var titles={erase:'Mover o rato ou tocar no ecrã',click:'Carregar ou tocar',double_click:'Duplo-toque ou duplo-clique'};
        check(help.title,titles[activity.type]);verify(help.content.indexOf(activity.activityInfo.manual)>=0);verify(activity.activityInfo.manual.length>20);
        verify(help.content.indexOf('Click or tap')<0&&help.content.indexOf('Move the mouse')<0&&help.content.indexOf('Double tap')<0);
        grabImage(pageView).save('__QA_OUTPUT__/help.png');
        evidence={restartClearedPartial:true,previousNext:true,title:help.title,manual:activity.activityInfo.manual};
        click(find(help,function(item){return item.source!==undefined&&String(item.source).endsWith('cancel.svg');}));waitProperty(pageView,'depth',depth,2500);wait(1100);
        activityBackground.forceActiveFocus();verify(activityBackground.activeFocus);
        revealFirst();check(visibleCount(),24);evidence.inputAfterHelp=true;
        ActivityInfoTree.startingActivity='';
        if(activity.type==='click'){keyClick(Qt.Key_Escape);evidence.exit='Escape';}else{button('bar_home.svg');evidence.exit='Home';}
        waitProperty(pageView,'depth',1,2500);verify(pageView.currentItem.isMenu);evidence.menu=true;
    }
    function cleanupTestCase(){console.log('NATIVE_ERASE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
