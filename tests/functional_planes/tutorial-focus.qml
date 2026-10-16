// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:'KeyboardAfterEntireParityTutorial'
    when:activity.visible&&items.numberOfLevel>0
    property var evidence: ({})
__MOVEMENT__
__TUTORIAL__
    function test_keyboard_after_start_and_help(){
        wait(1400);var pages=tutorial();compare(pages.length,8);wait(1400);
        var first=plane.x;keyPress(Qt.Key_Right);wait(600);keyRelease(Qt.Key_Right);wait(200);ensure(plane.x>first+5,'Keyboard receives focus after entire tutorial');var afterStart=plane.x;
        var depth=pageView.depth;icon(bar,'bar_help.svg');tryCompare(pageView,'depth',depth+1);keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth);wait(300);
        first=plane.x;keyPress(Qt.Key_Left);wait(500);keyRelease(Qt.Key_Left);wait(200);ensure(plane.x<first-5,'Keyboard focus survives help after entire tutorial');
        evidence={tutorialPages:pages,keyboardAfterStart:true,keyboardAfterHelp:true,afterStartX:afterStart,afterHelpX:plane.x};
        ActivityInfoTree.startingActivity='';icon(bar,'bar_home.svg');tryCompare(pageView,'depth',1);ensure(pageView.currentItem.isMenu);
    }
    function cleanupTestCase(){console.log('NATIVE_PLANE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
