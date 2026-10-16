// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:'PlaneKeyboardMistakeHelpAndMenu'
    when:activity.visible&&items.numberOfLevel>0
    property var evidence: ({})
__MOVEMENT__
__TUTORIAL__
    function move(key,axis,sign){var before=plane[axis];keyPress(key);wait(500);keyRelease(key);wait(150);ensure((plane[axis]-before)*sign>5,'Physical keyboard movement '+axis);return {key:key,axis:axis,before:before,after:plane[axis]};}
    function test_controls(){
        wait(1400);if(tutorialImage.visible){textButton('Ignorar');tryCompare(tutorialImage,'visible',false);wait(1400);}
        compare(activity.activityInfo.title,__TITLE__);compare(items.numberOfLevel,4);
        activity.forceActiveFocus();var movement=[move(Qt.Key_Right,'x',1),move(Qt.Key_Down,'y',1),move(Qt.Key_Left,'x',-1),move(Qt.Key_Up,'y',-1)];
        var mistake=capture(__FIRST__,true);compare(bonus.isPlaying,false);compare(items.currentLevel,0);
        wait(2200);ensure(clouds().every(function(row){return !String(row.item.source).endsWith('cloud_storm.svg');}),'Storm feedback expires naturally');
        icon(bar,'bar_next.svg');compare(items.currentLevel,1);icon(bar,'bar_previous.svg');compare(items.currentLevel,0);
        icon(bar,'bar_previous.svg');compare(items.currentLevel,3);compare(score.visible,false);icon(bar,'bar_next.svg');compare(items.currentLevel,0);compare(score.visible,true);wait(1400);
        var depth=pageView.depth;icon(bar,'bar_help.svg');tryCompare(pageView,'depth',depth+1);wait(600);var help=pageView.currentItem;
        compare(help.title,__TITLE__);ensure(help.content.indexOf(activity.activityInfo.manual)>=0);ensure(help.content.indexOf('teclas')>=0);ensure(help.content.indexOf('keyboard')<0);grabImage(pageView).save('__QA_OUTPUT__/help.png');
        keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth);wait(300);
        var focusMove=move(Qt.Key_Right,'x',1);
        var restarted=capture(__FIRST__,false);compare(items.currentLevel,0);
        ActivityInfoTree.startingActivity='';if(__ESCAPE__)keyClick(Qt.Key_Escape);else icon(bar,'bar_home.svg');tryCompare(pageView,'depth',1);ensure(pageView.currentItem.isMenu);
        evidence={title:__TITLE__,keyboard:movement,mistake:mistake,naturalStormRecovery:true,previousNextAndWrap:true,indicationHidden:true,restartFirstCapture:restarted,helpPortuguese:true,helpEscape:true,keyboardAfterHelp:focusMove,menu:true};
    }
    function cleanupTestCase(){console.log('NATIVE_PLANE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
