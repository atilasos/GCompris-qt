// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: 'ColorsHelpNavigationAndMenu'
    when: activity.visible && items.numberOfLevel>0
    property var vocabulary: __VOCABULARY__
    property var evidence: ({})
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var found=find(child,predicate);if(found)return found;}return null;}
    function click(item){verify(item!==null);var point=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,point.x,point.y,Qt.LeftButton,Qt.NoModifier,0);wait(200);}
    function button(suffix){click(find(bar,function(item){return item.source!==undefined&&String(item.source).endsWith(suffix);}));}
    function test_controls(){
        wait(1800);compare(activity.activityInfo.title,__TITLE__);compare(items.numberOfLevel,__TOTAL__);
        verify(find(bar,function(item){return item.source!==undefined&&String(item.source).endsWith('bar_activity_config.svg');})===null,'No local configuration is exposed');
        if(__MIX__){
            var plus=find(color1,function(item){return item.source!==undefined&&String(item.source).endsWith('plus.svg')&&item.buttonsBlocked!==undefined;});
            click(plus);verify(String(result.color)!==String(activity.modeRGB?'#000000':'#ffffff'));
        }else{
            tryCompare(instructionPanel,'opacity',1,4000);tryCompare(items,'objectSelected',false,4000);
            var wanted=vocabulary[String(instructionPanel.textItem.text)],correct=null;
            for(var i=0;i<container.count;i++){var option=container.itemAtIndex(i);if(String(option.source).endsWith('/'+wanted))correct=option;}
            verify(correct!==null);activityBackground.forceActiveFocus();
            for(var turn=0;turn<container.count+1&&container.currentItem!==correct;turn++)keyClick(Qt.Key_Right);
            compare(container.currentItem,correct);keyClick(Qt.Key_Space);compare(score.currentSubLevel,1);wait(1200);
        }
        button('bar_next.svg');compare(items.currentLevel,1);compare(score.currentSubLevel,0);
        button('bar_previous.svg');compare(items.currentLevel,0);compare(score.currentSubLevel,0);wait(800);
        if(__MIX__)compare(String(result.color),activity.modeRGB?'#000000':'#ffffff');
        var depth=pageView.depth;button('bar_help.svg');tryCompare(pageView,'depth',depth+1,3000);wait(800);
        var help=pageView.currentItem;compare(help.title,__TITLE__);
        verify(help.content.indexOf(activity.activityInfo.manual)>=0);verify(activity.activityInfo.manual.length>20);
        verify(help.content.indexOf('This activity')<0&&help.content.indexOf('Click on')<0);
        grabImage(pageView).save('__QA_OUTPUT__/help.png');
        click(find(help,function(item){return item.source!==undefined&&String(item.source).endsWith('cancel.svg');}));
        tryCompare(pageView,'depth',depth,3000);wait(800);
        if(__MIX__){
            var old=String(result.color);click(plus);verify(String(result.color)!==old,'Controls work after help');
        }else{
            var oldIndex=container.currentIndex;keyClick(Qt.Key_Right);verify(container.currentIndex!==oldIndex,'Keyboard focus restored after help');
        }
        ActivityInfoTree.startingActivity='';
        if(__ESCAPE__)keyClick(Qt.Key_Escape);else button('bar_home.svg');
        tryCompare(pageView,'depth',1,3000);verify(pageView.currentItem.isMenu);
        evidence={title:__TITLE__,helpPortuguese:true,localConfigurationAbsent:true,partialRestart:true,previousNext:true,inputAfterHelp:true,exit:__ESCAPE__?'Escape':'Home',menu:true};
    }
    function cleanupTestCase(){console.log('NATIVE_COLORS_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
