// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    id: keyCase
    name: "MenuDialogKeyDispatch"
    when: true
    SignalSpy { id: scrollSpy; signalName: "down" }
    function findScroll(item) {
        if(item.upVisible !== undefined && item.downVisible !== undefined && typeof item.down === "function") return item;
        if(item.children) {
            for(var i = 0; i < item.children.length; i++) {
                var found = findScroll(item.children[i]);
                if(found) return found;
            }
        }
        return null;
    }
    function test_each_menu_dialog_scrolls_once_and_escape_closes_it() {
        wait(1500);
        dialogActivityConfig.active = true;
        dialogActivityConfig.visible = true;
        tryVerify(function() { return dialogActivityConfig.configItem !== null; });
        var dialogs = [backgroundMusicList, serverConfigPage];
        for(var i = 0; i < dialogs.length; i++) {
            var dialog = dialogs[i];
            dialog.visible = true;
            dialog.forceActiveFocus();
            scrollSpy.target = findScroll(dialog);
            verify(scrollSpy.target !== null);
            scrollSpy.clear();
            keyClick(Qt.Key_Down);
            console.log("DIALOG_KEY_OBSERVATION", JSON.stringify({dialog:i, scrollSignals:scrollSpy.count}));
            compare(scrollSpy.count, 1, "The actual scroll control receives one down action");
            keyClick(Qt.Key_Escape);
            compare(dialog.visible, false, "Escape closes this dialog");
        }
    }
    function cleanupTestCase() {
        console.log("NATIVE_RESULT", JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount}));
    }
}
