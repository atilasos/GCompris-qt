// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:'DrawingControlsPT'
    when:true
    property bool useEscape: __ESCAPE__
    property var evidence: ({})
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var found=find(child,predicate);if(found)return found;}return null;}
    function click(item){verify(item!==null);var pos=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,pos.x,pos.y,Qt.LeftButton,Qt.NoModifier,0);}
    function button(suffix){wait(150);click(find(bar,function(item){return item.source!==undefined&&String(item.source).endsWith(suffix);}));}
    function first(){for(var i=0;i<pointImageRepeater.count;i++){var p=pointImageRepeater.itemAt(i);if(!p.visible||p.opacity<0.9)continue;if(activity.pointTextVisible){if(find(p,function(item){return item.text!==undefined&&item.visible&&String(item.text)==='1';}))return p;}else if(String(p.source).endsWith('/bluepointHighlight.svg'))return p;}return null;}
    function test_help_restart_navigation_focus_and_exit(){
        wait(1600);if(!activity.visible){keyClick(Qt.Key_Return);tryCompare(activity,'visible',true,2500);wait(1100);}
        var totals={number_sequence:9,clickanddraw:9,drawletters:26,drawnumbers:10};
        var titles={number_sequence:'Sequência de números',clickanddraw:'Carregar e desenhar',drawletters:'Desenhar as letras',drawnumbers:'Desenhar os números'};
        compare(activity.numberOfLevel,totals[activity.mode]);compare(activity.activityInfo.title,titles[activity.mode]);
        click(first());compare(items.pointIndexToClick,1);
        button('bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2000);wait(1100);
        dialogActivityConfig.forceActiveFocus();keyClick(Qt.Key_Return);tryCompare(dialogActivityConfig,'visible',false,2000);wait(600);
        compare(items.pointIndexToClick,0);compare(items.currentLevel,0);for(var i=0;i<segmentsRepeater.count;i++)compare(segmentsRepeater.itemAt(i).opacity,0);
        button('bar_previous.svg');tryCompare(items,'currentLevel',totals[activity.mode]-1,2000);compare(items.pointIndexToClick,0);
        button('bar_next.svg');tryCompare(items,'currentLevel',0,2000);compare(items.pointIndexToClick,0);
        var depth=pageView.depth;button('bar_help.svg');tryCompare(pageView,'depth',depth+1,2000);wait(1100);
        var help=pageView.currentItem;compare(help.title,titles[activity.mode]);verify(help.content.indexOf(activity.activityInfo.manual)>=0);verify(help.content.indexOf('Click on')<0);verify(activity.activityInfo.manual.length>20);
        grabImage(pageView).save('__QA_OUTPUT__/help.png');evidence={title:help.title,manual:activity.activityInfo.manual,restartBySave:true,previousNext:true,exit:useEscape?'Escape':'Home'};
        click(find(help,function(item){return item.source!==undefined&&String(item.source).endsWith('cancel.svg');}));tryCompare(pageView,'depth',depth,2000);wait(1100);
        ActivityInfoTree.startingActivity='';activityBackground.forceActiveFocus();verify(activityBackground.activeFocus);
        if(useEscape)keyClick(Qt.Key_Escape);else button('bar_home.svg');tryCompare(pageView,'depth',1,2000);verify(pageView.currentItem.isMenu);evidence.menu=true;
    }
    function cleanupTestCase(){console.log('NATIVE_DRAWING_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
