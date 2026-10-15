// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "WordprocessorVisualSpace"
    when: activity.visible && edit.visible
    SignalSpy {id: keys; target:keyboard; signalName:"keypress"}
    property var result: ({})
    function key(root,text) {
        if(root.specialKey!==undefined && root.text===text)return root;
        if(root.children)for(var child of root.children){var found=key(child,text);if(found)return found;}
        return null;
    }
    function test_visual_space_preserves_text() {
        ApplicationSettings.isVirtualKeyboard=true;wait(1600);
        var a=key(keyboard,"a") || key(keyboard,"A");verify(a!==null);
        var space=key(keyboard," ");verify(space!==null);
        mouseClick(a);compare(edit.getText(0,edit.length),a.text);
        keys.clear();mouseClick(space);
        result={emitted:keys.signalArguments,plain:edit.getText(0,edit.length),length:edit.length,
                formatted:edit.getFormattedText(0,edit.length),cursor:edit.cursorPosition,focus:edit.activeFocus};
        compare(keys.count,1);compare(keys.signalArguments[0][0]," ");
        compare(edit.getText(0,edit.length),a.text+" ");
    }
    function cleanupTestCase(){console.log("NATIVE_WORDPROCESSOR_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,observation:result}));}
}
