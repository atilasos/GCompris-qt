// SPDX-License-Identifier: GPL-3.0-or-later
// Seam: the real menu and activity controls, never the rule engine or game state.
TestCase {
    name: "AtariGoNative"
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
    function ensure(value, message) { if (!value) console.log("ATARI_ASSERT_FAILED", message || "", new Error().stack); verify(value, message || ""); }
    function click(item) { ensure(item !== null); mouseClick(item, item.width / 2, item.height / 2); wait(60); }
    function test_menu_to_complete_game() {
        wait(1500);
        var search = section.itemAtIndex(section.count - 1);
        click(search);
        mouseClick(searchTextField, searchTextField.width / 2, searchTextField.height / 2);
        keyClick(Qt.Key_A); keyClick(Qt.Key_T); keyClick(Qt.Key_A); keyClick(Qt.Key_R);
        wait(800);
        var card = null;
        for (var d = 0; d < activitiesGrid.count; ++d) {
            var candidate = activitiesGrid.itemAtIndex(d);
            if (candidate && textIn(candidate, "Atari Go")) card = candidate;
        }
        ensure(card !== null, "Search finds native activity");
        click(card);
        tryVerify(function() { return activityLoader.item && activityLoader.item.visible; }, 5000);
        wait(800);
        var game = activityLoader.item;
        var board = findChild(game, "atariBoard");
        ensure(board !== null, "Native 9x9 intersection board loaded");
        function cell(i) { return findChild(game, "atariPoint" + i); }
        var restart = findChild(game, "restartAtari");
        var inspect = findChild(game, "inspectAtari");
        ensure(textIn(game, "Pretas ● · Participante 1"));
        click(cell(9)); click(cell(9));
        ensure(textIn(game, "ocupada")); ensure(textIn(game, "Brancas ○ · Participante 2"));
        click(cell(0));
        click(icon(game, "bar_help.svg")); tryCompare(pageView, "depth", 3, 2000);
        ensure(pageView.currentItem.content.indexOf("liberdades") >= 0);
        grabImage(pageView).save("__QA_OUTPUT__/help.png");
        keyClick(Qt.Key_Escape); tryCompare(pageView, "depth", 2, 2000); wait(900);
        ensure(textIn(cell(9), "●")); ensure(textIn(cell(0), "○"));
        click(cell(1)); ensure(textIn(game, "Venceram as Pretas"));
        ensure(!textIn(cell(0), "○")); ensure(textIn(game, "1 pedra"));
        click(cell(80)); ensure(!textIn(cell(80), "○"));
        grabImage(pageView).save("__QA_OUTPUT__/capture.png");
        click(restart);
        // Capture removes every stone of the connected adversary group.
        click(cell(9)); click(cell(0)); click(cell(10)); click(cell(1)); click(cell(2));
        ensure(textIn(game, "Venceram as Pretas")); ensure(textIn(game, "2 pedra"));
        ensure(!textIn(cell(0), "○")); ensure(!textIn(cell(1), "○"));
        click(restart);
        // The same first-capture rule also awards White the win.
        click(cell(80)); click(cell(9)); click(cell(0)); click(cell(1));
        ensure(textIn(game, "Venceram as Brancas")); ensure(!textIn(cell(0), "●"));
        click(restart);
        // Reference suicide history; distinct liberties of adjacent corner group.
        click(cell(80)); click(cell(1)); click(cell(79)); click(cell(9));
        click(cell(0)); ensure(textIn(game, "Suicídio")); ensure(!textIn(cell(0), "●"));
        ensure(textIn(game, "Pretas ● · Participante 1"));
        // Inspect an existing connected pair: B(8,8), B(8,7) has three distinct liberties.
        click(inspect); click(cell(80));
        ensure(textIn(game, "2 pedras · 3 liberdades"));
        ensure(textIn(cell(79), "●"));
        grabImage(pageView).save("__QA_OUTPUT__/group.png");
        click(inspect); click(cell(78)); ensure(textIn(game, "Brancas ○ · Participante 2"));
        click(restart);
        // L-shaped connected group shares the empty intersection (2,2).
        click(cell(10)); click(cell(80)); click(cell(11)); click(cell(79)); click(cell(19));
        click(inspect); click(cell(10));
        ensure(textIn(game, "3 pedras · 7 liberdades"), "Shared liberty counted once");
        grabImage(pageView).save("__QA_OUTPUT__/shared-liberty.png");
        click(restart);
        // Final move has no immediately empty neighbour, but captures white(0,1).
        click(cell(2)); click(cell(1)); click(cell(10)); click(cell(9));
        var target = cell(0);
        touchEvent(target).press(0, target, target.width/2, target.height/2).commit();
        touchEvent(target).release(0, target, target.width/2, target.height/2).commit(); wait(100);
        ensure(textIn(game, "Venceram as Pretas")); ensure(textIn(cell(0), "●"));
        ensure(!textIn(cell(1), "○")); ensure(textIn(cell(9), "○"));
        click(restart);
        board.forceActiveFocus(); keyClick(Qt.Key_Right); keyClick(Qt.Key_Space);
        ensure(textIn(cell(1), "●"));
        keyClick(Qt.Key_Tab); ensure(inspect.activeFocus, "Tab reaches group help");
        keyClick(Qt.Key_Space); wait(80); ensure(textIn(game, "Toca numa pedra"));
        for (var t = 0; t < 20 && !restart.activeFocus; ++t) keyClick(Qt.Key_Tab);
        ensure(restart.activeFocus, "Tab reaches restart");
        keyClick(Qt.Key_Space); wait(80); ensure(!textIn(cell(1), "●"));
        var window = game.Window.window;
        window.width = 1100; window.height = 700; wait(350);
        ensure(board.width / 9 >= 36); grabImage(pageView).save("__QA_OUTPUT__/desktop.png");
        window.width = 600; window.height = 900; wait(350);
        ensure(board.width / 9 >= 40);
        ensure(inspect.mapToItem(game,0,0).y > board.mapToItem(game,0,0).y + board.height);
        grabImage(pageView).save("__QA_OUTPUT__/portrait.png");
        click(icon(game, "bar_home.svg")); tryCompare(pageView, "depth", 1, 2000);
        ensure(pageView.currentItem.isMenu);
    }
    function cleanupTestCase() {
        if (qtest_results.failCount) grabImage(pageView).save("__QA_OUTPUT__/failure.png");
        console.log("NATIVE_RESULT", JSON.stringify({failures:qtest_results.failCount, passes:qtest_results.passCount}));
    }
}
