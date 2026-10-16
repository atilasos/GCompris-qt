// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: 'LearningKeyboard'
    when: activity.numberOfLevel > 0
    property var evidence: ({})
    function click(item) { var p=item.mapToItem(pageView,item.width/2,item.height/2); mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0); wait(40); }
    function selectedAt(index) { var a=circlesSelector.mapToItem(pageView,0,0),b=circlesLine.itemAt(index).mapToItem(pageView,0,0); compare(Math.round(a.x),Math.round(b.x)); compare(Math.round(a.y),Math.round(b.y)); }
    function filled(index) { var circle=circlesLine.itemAt(index).children[0]; return String(circle.color)!=='#00ffffff'; }
    function test_keyboard_single_step_and_toggle() {
        wait(1800); if(!activity.visible){keyClick(Qt.Key_Return);tryCompare(activity,'visible',true,2500);wait(1100);}
        if(iAmReady.visible)click(iAmReady);
        wait(100);activity.forceActiveFocus();verify(!circlesSelector.visible);
        keyClick(Qt.Key_Right);verify(circlesSelector.visible);selectedAt(0);
        keyClick(Qt.Key_Right);selectedAt(1);keyClick(Qt.Key_Left);selectedAt(0);
        keyClick(Qt.Key_Space);verify(filled(0));keyClick(Qt.Key_Space);verify(!filled(0));
        keyClick(Qt.Key_Left);selectedAt(circlesLine.count-1);
        keyClick(Qt.Key_Right);selectedAt(0);
        evidence={singleStep:true,toggle:true,wrap:true};
    }
    function cleanupTestCase(){console.log('NATIVE_LEARNING_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
