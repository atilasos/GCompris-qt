// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "FirstKeyboardHelpAndFocus"
    when: activity.visible && items.typedText !== null
    property int helpRoutes: 0
    function findButton(item, suffix) {
        if(item.source !== undefined && String(item.source).endsWith(suffix)) return item;
        if(item.children) for(var i = 0; i < item.children.length; i++) {
            var found = findButton(item.children[i], suffix);
            if(found) return found;
        }
        return null;
    }
    function clickButton(parent, suffix) {
        wait(1600);
        var button = findButton(parent, suffix);
        verify(button !== null, "Button exists: " + suffix);
        mouseClick(button);
    }
    function test_help_restores_physical_input_focus() {
        wait(1600);
        compare(activity.activityInfo.title, "O meu primeiro teclado");
        for(var virtualKeys of [false,true]) {
            ApplicationSettings.isVirtualKeyboard = virtualKeys;
            var depth = pageView.depth;
            clickButton(bar, "bar_help.svg");
            tryCompare(pageView, "depth", depth + 1);
            wait(600);
            var help = pageView.currentItem;
            compare(help.title, "O meu primeiro teclado");
            verify(help.content.indexOf(activity.activityInfo.description) >= 0);
            grabImage(pageView).save("__QA_OUTPUT__/help-" + virtualKeys + ".png");
            clickButton(help, "cancel.svg");
            tryCompare(pageView, "depth", depth);
            wait(600);
            // No explicit focus assignment: the application must restore it.
            keyClick("b");
            compare(typedText.text, "B");
            mouseClick(layoutArea, layoutArea.width * 0.8, layoutArea.height * 0.3);
            keyClick("c");
            compare(typedText.text, "C");
            helpRoutes++;
        }
        ActivityInfoTree.startingActivity = "";
        clickButton(bar, "bar_home.svg");
        tryCompare(pageView, "depth", 1);
        verify(pageView.currentItem.isMenu);
    }
    function cleanupTestCase() {
        console.log("NATIVE_BABY_KEYBOARD_RESULT", JSON.stringify({
            failures:qtest_results.failCount, passes:qtest_results.passCount,
            helpRoutes:helpRoutes
        }));
    }
}
