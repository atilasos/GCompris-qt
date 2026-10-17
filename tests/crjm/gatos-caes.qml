// SPDX-License-Identifier: GPL-3.0-or-later
// Seam: the real menu and activity controls, never the rule engine or game state.
TestCase {
    function clickNative(item, x, y) {
        // Scroll secondary tools into view through the real Flickable, without
        // delaying immediate restart/exit cases while Tux is calculating.
        var area = item.parent;
        while (area) {
            if (area.objectName === "boardGameToolsViewport") {
                area.cancelFlick();
                var point = item.mapToItem(area.contentItem, 0, 0);
                if (point.y < area.contentY || point.y + item.height > area.contentY + area.height)
                    area.contentY = Math.max(0, Math.min(area.contentHeight - area.height, point.y - 8));
                break;
            }
            area = area.parent;
        }
        mouseClick(item, x, y);
    }

    name: "GatosCaesNative"
    when: activity.visible
    function textIn(item, text) {
        if (item.text !== undefined && String(item.text).indexOf(text) >= 0) return true;
        for (var i = 0; i < item.children.length; ++i)
            if (textIn(item.children[i], text)) return true;
        return false;
    }
    function icon(item, suffix) {
        if (item.source !== undefined && String(item.source).endsWith(suffix)) return item;
        for (var i = 0; i < item.children.length; ++i) {
            var found = icon(item.children[i], suffix); if (found) return found;
        }
        return null;
    }
    function ensure(value, message) { if (!value) console.log("GATOS_ASSERT_FAILED", message || "", new Error().stack); verify(value, message || ""); }
    function click(item) { ensure(item !== null); clickNative(item, item.width / 2, item.height / 2); wait(60); }
    function test_menu_to_complete_game() {
        wait(1500);
        click(section.itemAtIndex(section.count - 1));
        clickNative(searchTextField, searchTextField.width / 2, searchTextField.height / 2);
        keyClick(Qt.Key_G); keyClick(Qt.Key_A); keyClick(Qt.Key_T); keyClick(Qt.Key_O); keyClick(Qt.Key_S);
        wait(800);
        var card = null;
        for (var d = 0; d < activitiesGrid.count; ++d) {
            var candidate = activitiesGrid.itemAtIndex(d);
            if (candidate && textIn(candidate, "Gatos & Cães")) card = candidate;
        }
        ensure(card !== null, "Search finds Gatos & Cães in real menu");
        click(card);
        tryVerify(function() { return activityLoader.item && activityLoader.item.visible; }, 5000);
        wait(800);
        var game = activityLoader.item;
        var board = findChild(game, "gatosCaesBoard");
        ensure(board !== null, "Native board loaded");
        var restart = findChild(game, "restartGatos");
        ensure(textIn(game, "Participante 1 · Gatos"));
        click(findChild(game, "gatosCell0"));
        ensure(textIn(game, "Jogada impossível"));
        ensure(!textIn(findChild(game, "gatosCell0"), "1 G"));
        click(findChild(game, "legalGatos"));
        ensure(textIn(findChild(game, "gatosCell27"), "+"));
        ensure(!textIn(findChild(game, "gatosCell0"), "+"));
        board.forceActiveFocus(); keyClick(Qt.Key_Space);
        ensure(textIn(findChild(game, "gatosCell0"), "1 G") === false);
        // Restore initial cursor through the normal restart control.
        click(restart); keyClick(Qt.Key_Return);
        ensure(textIn(findChild(game, "gatosCell27"), "1 G"));
        ensure(textIn(game, "Participante 2 · Cães"));
        click(findChild(game, "gatosCell36")); // central but diagonal, not adjacency
        ensure(textIn(game, "Jogada impossível"));
        ensure(!textIn(findChild(game, "gatosCell36"), "2 C"));
        click(findChild(game, "gatosCell28")); // orthogonal
        ensure(!textIn(findChild(game, "gatosCell28"), "2 C"));
        var diagonal = findChild(game, "gatosCell20");
        touchEvent(diagonal).press(0, diagonal, diagonal.width / 2, diagonal.height / 2).commit();
        touchEvent(diagonal).release(0, diagonal, diagonal.width / 2, diagonal.height / 2).commit(); wait(80);
        ensure(textIn(diagonal, "2 C")); // diagonal enemy is allowed
        ensure(textIn(game, "Participante 1 · Gatos"));
        click(findChild(game, "gatosCell19"));
        ensure(textIn(game, "Jogada impossível"));
        ensure(!textIn(findChild(game, "gatosCell19"), "1 G"));
        click(findChild(game, "gatosCell27")); // occupied
        ensure(textIn(game, "Participante 1 · Gatos"));
        click(icon(game, "bar_help.svg"));
        tryCompare(pageView, "depth", 3, 2000);
        ensure(pageView.currentItem.content.indexOf("quatro casas centrais") >= 0);
        grabImage(pageView).save("__QA_OUTPUT__/help.png");
        keyClick(Qt.Key_Escape); tryCompare(pageView, "depth", 2, 2000); wait(500);
        ensure(textIn(diagonal, "2 C"));
        ensure(textIn(findChild(game, "gatosCell27"), "1 G"));
        click(restart);
        // Fixed legal transcript verified with CRJM b206a7b4, expected cats win.
        var moves = [36,29,42,2,54,47,48,39,9,33,13,23,63,26,14,52,19,60,57,30,16,59,24,3,6,38,17,31,12,0,43,45,62];
        for (var n = 0; n < moves.length; ++n) {
            click(findChild(game, "gatosCell" + moves[n]));
            ensure(textIn(findChild(game, "gatosCell" + moves[n]), n % 2 === 0 ? "1 G" : "2 C"), "Reference move " + n);
        }
        ensure(textIn(game, "Venceu o participante 1!"));
        ensure(textIn(game, "O participante 2 ficou sem uma colocação válida."));
        click(findChild(game, "gatosCell1"));
        ensure(!textIn(findChild(game, "gatosCell1"), "1 G"));
        ensure(textIn(game, "Venceu o participante 1!"));
        grabImage(pageView).save("__QA_OUTPUT__/result.png");
        click(restart);
        ensure(textIn(game, "Participante 1 · Gatos"));
        ensure(!textIn(findChild(game, "gatosCell36"), "1 G"));
        keyClick(Qt.Key_Right); keyClick(Qt.Key_Space);
        ensure(textIn(findChild(game, "gatosCell28"), "1 G"));
        var window = game.Window.window;
        window.width = 1100; window.height = 700; wait(350);
        ensure(board.width / 8 >= 40, "Desktop targets");
        grabImage(pageView).save("__QA_OUTPUT__/desktop.png");
        window.width = 600; window.height = 900; wait(350);
        ensure(board.width / 8 >= 40, "Portrait targets");
        ensure(restart.mapToItem(game, 0, 0).y + restart.height <= game.height, "Portrait controls fit");
        grabImage(pageView).save("__QA_OUTPUT__/portrait.png");
        click(icon(game, "bar_home.svg")); tryCompare(pageView, "depth", 1, 2000);
        ensure(pageView.currentItem.isMenu);

    }
    function cleanupTestCase() {
        if (qtest_results.failCount) grabImage(pageView).save("__QA_OUTPUT__/failure.png");
        console.log("NATIVE_RESULT", JSON.stringify({failures:qtest_results.failCount, passes:qtest_results.passCount}));
    }
}
