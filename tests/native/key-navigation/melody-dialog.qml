// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    id: keyCase
    name: "MelodyDialogKeyDispatch"
    when: items.numberOfLevel > 0
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
    function test_melody_scrolls_once_and_escape_closes_it() {
        wait(1200);
        if(audioNeededDialog.active) { audioNeededDialog.item.stop(); tryCompare(activityBackground, "audioDisabled", false, 2000); }
        melodyList.visible = true;
        melodyList.forceActiveFocus();
        scrollSpy.target = findScroll(melodyList);
        verify(scrollSpy.target !== null);
        keyClick(Qt.Key_Down);
        console.log("DIALOG_KEY_OBSERVATION", JSON.stringify({scrollSignals:scrollSpy.count}));
        compare(scrollSpy.count, 1, "The actual scroll control receives one down action");
        keyClick(Qt.Key_Escape);
        compare(melodyList.visible, false, "Escape closes the melody dialog");
    }
    function cleanupTestCase() {
        console.log("NATIVE_RESULT", JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount}));
    }
}
