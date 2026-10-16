// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"MouseFishPortugueseControls"
    when:activity.visible
    property var evidence: ({})
    property bool useEscape: true
    function find(root,suffix){if(root.source!==undefined&&String(root.source).endsWith(suffix))return root;if(root.children)for(var child of root.children){var found=find(child,suffix);if(found)return found;}return null;}
    function click(root,suffix){wait(150);var button=find(root,suffix);verify(button!==null);mouseClick(button,button.width/2,button.height/2,Qt.LeftButton,Qt.NoModifier,0);}
    function test_help_navigation_focus_and_home(){
        wait(1600);var fish=activity.activityInfo.shortName()==='clickgame';
        var title=fish?'Carrega em mim':'O meu primeiro rato';compare(activity.activityInfo.title,title);
        if(fish){click(bar,'bar_next.svg');tryCompare(items,'currentLevel',1,2000);compare(score.currentSubLevel,0);click(bar,'bar_previous.svg');tryCompare(items,'currentLevel',0,2000);compare(score.numberOfSubLevels,5);}
        var depth=pageView.depth;click(bar,'bar_help.svg');tryCompare(pageView,'depth',depth+1,2000);wait(500);
        var help=pageView.currentItem;compare(help.title,title);verify(help.content.indexOf(activity.activityInfo.description)>=0);
        verify(help.content.indexOf(fish?'peixes':'patos')>=0);verify(help.content.indexOf(fish?'moving fish':'blue duck')<0);
        evidence={title:help.title,manual:activity.activityInfo.manual,navigation:fish,exit:useEscape?'Escape':'Home'};
        grabImage(pageView).save('__QA_OUTPUT__/help.png');click(help,'cancel.svg');tryCompare(pageView,'depth',depth,2000);wait(600);
        ActivityInfoTree.startingActivity='';activityBackground.forceActiveFocus();verify(activityBackground.activeFocus);
        if(useEscape)keyClick(Qt.Key_Escape,Qt.NoModifier,0);else click(bar,'bar_home.svg');
        tryCompare(pageView,'depth',1,2000);verify(pageView.currentItem.isMenu);evidence.menu=true;
    }
    function cleanupTestCase(){console.log('NATIVE_MOUSE_FISH_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
