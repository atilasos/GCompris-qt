// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:'LearningControls'
    when:true
    property var evidence: ({})
    function check(a,b,message){if(a!==b)console.log('LEARNING_CONTROL_ASSERT',a,b,message||'',new Error().stack);compare(a,b,message||'');}
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var hit=find(child,predicate);if(hit)return hit;}return null;}
    function click(item){verify(item!==null);var p=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);wait(20);}
    function button(suffix){click(find(bar,function(item){return item.source!==undefined&&String(item.source).endsWith(suffix);}));}
    function checkbox(){return find(dialogActivityConfig,function(item){return item.visible&&item.indicatorImageHeight!==undefined&&item.checked!==undefined;});}
    function save(){dialogActivityConfig.forceActiveFocus();keyClick(Qt.Key_Return);tryCompare(dialogActivityConfig,'visible',false,2500);wait(1100);}
    function ready(){if(iAmReady.visible)click(iAmReady);wait(80);}
    function partialInput(){ready();click(circlesLine.itemAt(0));check(String(circlesLine.itemAt(0).children[0].color),'#d2611d');check(score.currentSubLevel,0);}
    function config(){button('bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2500);wait(1100);}
    function datasets(){if(!activity.operationMode)click(find(dialogActivityConfig,function(item){return item.theme==='settingsButton'&&String(item.text)===qsTranslate('DialogChooseLevel','Dataset');}));wait(100);}
    function test_dataset_restart_navigation_help_focus_menu(){
        wait(1800);if(!activity.visible){keyClick(Qt.Key_Return);tryCompare(activity,'visible',true,2500);wait(1100);}
        var total=activity.operationMode?(activity.activityInfo.shortName()==='learn_additions'?3:5):9;
        check(activity.numberOfLevel,total);partialInput();
        button('bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2500);wait(1100);save();
        ready();check(String(circlesLine.itemAt(0).children[0].color),'#00ffffff');check(activity.currentLevel,0);check(score.currentSubLevel,0);
        if(!activity.operationMode){config();var voice=checkbox();verify(voice!==null&&voice.checked);click(voice);check(voice.checked,false);save();check(ApplicationSettings.loadActivityConfiguration(activity.activityInfo.shortName()).voicesEnabled,'false');config();voice=checkbox();check(voice.checked,false);click(voice);save();}
        button('bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2500);wait(1100);
        datasets();var first=checkbox();verify(first!==null&&first.checked);var objective=first.text;
        click(first);check(first.checked,false);save();check(activity.numberOfLevel,total-1);
        check(ApplicationSettings.ignoredLevels(activity.activityInfo.shortName()).length,1);
        button('bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2500);wait(1100);datasets();first=checkbox();check(first.checked,false);check(first.text,objective);click(first);save();check(activity.numberOfLevel,total);
        button('bar_previous.svg');check(activity.currentLevel,total-1);check(score.currentSubLevel,0);button('bar_next.svg');check(activity.currentLevel,0);check(score.currentSubLevel,0);
        var depth=pageView.depth;button('bar_help.svg');tryCompare(pageView,'depth',depth+1,2500);wait(1100);var help=pageView.currentItem;
        check(help.title,activity.activityInfo.title);verify(help.content.indexOf(activity.activityInfo.manual)>=0);verify(activity.activityInfo.manual.length>40);verify(help.content.indexOf('A shape split')<0);
        grabImage(pageView).save('__QA_OUTPUT__/help.png');
        evidence={activity:activity.activityInfo.shortName(),levels:total,reducedLevels:total-1,firstDataset:objective,configurationSaved:true,voicesToggleSaved:!activity.operationMode,restartClearedInput:true,previousNext:true,title:help.title,manual:activity.activityInfo.manual};
        click(find(help,function(item){return item.source!==undefined&&String(item.source).endsWith('cancel.svg');}));tryCompare(pageView,'depth',depth,2500);wait(1100);activityBackground.forceActiveFocus();verify(activityBackground.activeFocus);partialInput();evidence.inputAfterHelp=true;
        ActivityInfoTree.startingActivity='';if(activity.operationMode){keyClick(Qt.Key_Escape);evidence.exit='Escape';}else{button('bar_home.svg');evidence.exit='Home';}
        tryCompare(pageView,'depth',1,2500);verify(pageView.currentItem.isMenu);evidence.menu=true;
    }
    function cleanupTestCase(){console.log('NATIVE_LEARNING_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
