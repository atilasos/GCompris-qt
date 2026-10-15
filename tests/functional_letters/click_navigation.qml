// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"ClickLettersKeyboardTransitions"
    when:items.numberOfLevel>0 && activity.visible
    function expect(actual,expected,message) {
        console.log("NATIVE_NAV_STATE",message,actual,expected,train.currentIndex,items.keyNavigationMode,trainModel.count);
        compare(actual,expected,message);
    }
    function findButton(item,suffix) {
        if(item.source!==undefined && String(item.source).endsWith(suffix))return item;
        if(item.children)for(var i=0;i<item.children.length;i++){
            var found=findButton(item.children[i],suffix);if(found)return found;
        }
        return null;
    }
    function test_one_step_and_space_after_level_change() {
        wait(1600);
        console.log("NATIVE_NAV_INITIAL",items.currentLevel,train.currentIndex,items.keyNavigationMode,trainModel.count);
        eventHandler.forceActiveFocus();
        keyClick(Qt.Key_Right,Qt.NoModifier,0);
        expect(train.currentIndex,0,"First arrow establishes selection");
        keyClick(Qt.Key_Right,Qt.NoModifier,0);
        expect(train.currentIndex,1,"One right arrow moves exactly one answer");
        while(train.currentIndex<trainModel.count-1) {
            var before=train.currentIndex;
            keyClick(Qt.Key_Right,Qt.NoModifier,0);
            expect(train.currentIndex,before+1,"Every answer can be reached once");
        }
        var previous=items.currentLevel;
        var next=findButton(bar,"bar_next.svg");verify(next!==null);
        mouseClick(next,next.width/2,next.height/2);
        tryCompare(items,"currentLevel",(previous+1)%11,2000);
        console.log("NATIVE_NAV_AFTER_LEVEL",train.currentIndex,items.keyNavigationMode,trainModel.count);
        eventHandler.forceActiveFocus();
        keyClick(Qt.Key_Space,Qt.NoModifier,0);
        console.log("NATIVE_NAV_AFTER_SPACE",train.currentIndex,items.keyNavigationMode,items.buttonsBlocked,items.score.currentSubLevel);
        verify(train.currentIndex>=0 && train.currentIndex<trainModel.count);
        // A stale selection must not lock the input or throw in checkAnswer.
        tryCompare(items,"buttonsBlocked",false,4000);
    }
    function cleanupTestCase(){console.log("NATIVE_LETTERS_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount}));}
}
