// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "FirstPortugueseWordprocessor"
    when: activity.visible && edit.visible
    property var unicodeInput
    property var observations: []
    function checked(actual, expected, message) {
        if(actual !== expected) console.log("WORDPROCESSOR_ASSERT",JSON.stringify({actual:actual,expected:expected,message:message,stack:new Error().stack}));
        compare(actual,expected,message || "");
    }
    function ensure(value,message) {
        if(!value) console.log("WORDPROCESSOR_ASSERT",message || "",new Error().stack);
        verify(value,message || "");
    }
    function initTestCase() {
        wait(1600);
        unicodeInput = Qt.createQmlObject('import "file:__QA_SOURCE__/build/functional-input"; UnicodeInput {}', this);
    }
    function plain() { return edit.getText(0, edit.length); }
    function clearByKeys() {
        mouseClick(edit, 30, 20);
        keyClick(Qt.Key_A, Qt.ControlModifier);
        keyClick(Qt.Key_Backspace);
        checked(plain(), "");
    }
    function findKey(root,text) {
        if(root.specialKey !== undefined && root.text === text) return root;
        if(root.children)for(var child of root.children) {
            var found=findKey(child,text); if(found)return found;
        }
        return null;
    }
    function clickKey(text) {
        var button=findKey(keyboard,text);
        ensure(button!==null,"Visual key: "+text);mouseClick(button);
    }
    function test_a_portuguese_input_and_line_formatting() {
        var sentence="Olá, João! A maçã é ótima. àáâãçéêíóôõú ÀÁÂÃÇÉÊÍÓÔÕÚ";
        for(var visible of [false,true]) {
            ApplicationSettings.isVirtualKeyboard=visible;
            wait(400); clearByKeys();
            for(var character of "abcXYZ0129")keyClick(character);
            checked(plain(),"abcXYZ0129");
            clearByKeys();
            ensure(unicodeInput.commit(edit,sentence));
            checked(plain(),sentence);
            var heights=[];
            for(var i=0;i<3;i++) {
                mouseClick(controls.children[i]);wait(300);
                checked(plain(),sentence,"Formatting preserves Portuguese text");
                heights.push(edit.cursorRectangle.height);
            }
            ensure(heights[0]>heights[1] && heights[1]>heights[2],JSON.stringify(heights));
            observations.push({virtualKeyboard:visible,text:plain(),formatHeights:heights});
        }
        grabImage(activityBackground).save("__QA_OUTPUT__/portuguese-formatted.png");
    }
    function test_b_visual_keyboard_edits() {
        ApplicationSettings.isVirtualKeyboard=true;wait(600);clearByKeys();
        var key=findKey(keyboard,"a") || findKey(keyboard,"A");
        ensure(key!==null);
        var letter=key.text;
        mouseClick(key);checked(plain(),letter);
        clickKey(" ");checked(plain(),letter+" ");
        clickKey(keyboard.backspace);checked(plain(),letter);
        clickKey(keyboard.newline);
        ensure(/[\u2028\u2029\n]/.test(plain()), "Visual Enter inserts a line break");
        clickKey(keyboard.backspace);checked(plain(),letter);
        clickKey(" ");clickKey(" ");checked(plain(),letter+"  ");
        for(var digit of "0123456789")clickKey(digit);
        checked(plain(),letter+"  0123456789");
        observations.push({visualText:plain()});
    }
    function test_c_shift_and_all_visual_letters() {
        ApplicationSettings.isVirtualKeyboard=true;wait(600);clearByKeys();
        var shift=null;
        function scan(root) {
            if(root.specialKey===Qt.Key_Shift)return root;
            if(root.children)for(var child of root.children){var found=scan(child);if(found)return found;}
            return null;
        }
        shift=scan(keyboard);ensure(shift!==null,"Shift key exists");
        var lower=findKey(keyboard,"a")!==null;
        var first=lower?"abcdefghijklmnopqrstuvwxyz":"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        var second=lower?"ABCDEFGHIJKLMNOPQRSTUVWXYZ":"abcdefghijklmnopqrstuvwxyz";
        for(var character of first)clickKey(character);
        checked(plain(),first);
        mouseClick(shift);wait(200);
        for(var character of second)clickKey(character);
        checked(plain(),first+second);
        observations.push({visualLetters:plain(),shift:true});
    }
    function cleanupTestCase() {
        console.log("NATIVE_WORDPROCESSOR_RESULT",JSON.stringify({
            failures:qtest_results.failCount,passes:qtest_results.passCount,observations:observations
        }));
    }
}
