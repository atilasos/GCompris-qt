// SPDX-License-Identifier: GPL-3.0-or-later
// Seam: the real menu and activity controls, never the rule engine or game state.
TestCase {
    name: "QuelhasNative"
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
    function ensure(value, message) { if (!value) console.log("QUELHAS_ASSERT_FAILED", message || "", new Error().stack); verify(value, message || ""); }
    function click(item) { ensure(item !== null); mouseClick(item, item.width / 2, item.height / 2); wait(60); }
    function test_menu_to_complete_game() {
        wait(1500);
        var search = section.itemAtIndex(section.count - 1);
        click(search);
        mouseClick(searchTextField, searchTextField.width / 2, searchTextField.height / 2);
        keyClick(Qt.Key_Q); keyClick(Qt.Key_U); keyClick(Qt.Key_E); keyClick(Qt.Key_L);
        wait(800);
        var card = null;
        for (var d = 0; d < activitiesGrid.count; ++d) {
            var candidate = activitiesGrid.itemAtIndex(d);
            if (candidate && textIn(candidate, "Quelhas")) card = candidate;
        }
        ensure(card !== null, "Search finds native activity");
        click(card);
        tryVerify(function() { return activityLoader.item && activityLoader.item.visible; }, 5000);
        wait(800);
        var game = activityLoader.item;
        var board = findChild(game, "quelhasBoard");
        ensure(board !== null, "Native Quelhas board loaded");
        var confirm = findChild(game, "confirmQuelhas");
        var clear = findChild(game, "clearQuelhas");
        var swap = findChild(game, "swapQuelhas");
        var restart = findChild(game, "restartQuelhas");
        function cell(index) { return findChild(game, "quelhasCell" + index); }
        function segment(first, last) { click(cell(first)); click(cell(last)); ensure(confirm.enabled); click(confirm); }
        ensure(textIn(game, "Participante 1 · Vertical"));
        ensure(!confirm.enabled); ensure(!swap.enabled);
        // Length one and wrong orientation cannot advance the turn.
        board.forceActiveFocus(); keyClick(Qt.Key_Space); keyClick(Qt.Key_Space);
        ensure(!confirm.enabled); ensure(textIn(game, "Segmento inválido"));
        keyClick(Qt.Key_Right); keyClick(Qt.Key_Space);
        ensure(!confirm.enabled); ensure(textIn(game, "Participante 1 · Vertical"));
        // Correct a diagonal endpoint, preview three cells, shorten to two.
        click(cell(11)); ensure(!confirm.enabled);
        click(cell(20)); ensure(confirm.enabled); ensure(textIn(game, "Segmento de 3 casas"));
        ensure(textIn(cell(10), "↕")); ensure(!textIn(cell(10), "●"));
        grabImage(pageView).save("__QA_OUTPUT__/preview.png");
        click(cell(10)); ensure(textIn(game, "Segmento de 2 casas"));
        keyClick(Qt.Key_Return);
        ensure(textIn(cell(0), "●")); ensure(textIn(cell(10), "●"));
        ensure(!textIn(cell(20), "●"));
        ensure(textIn(game, "Participante 2 · Horizontal")); ensure(swap.enabled);
        keyClick(Qt.Key_Tab); ensure(swap.activeFocus, "Tab reaches swap control");
        keyClick(Qt.Key_Space); wait(80);
        ensure(!swap.enabled); ensure(textIn(game, "Participante 1 · Horizontal"));
        ensure(textIn(game, "1 ↔ Horizontal · 2 ↕ Vertical"));
        ensure(textIn(game, "A troca consumiu o turno"));
        ensure(textIn(cell(0), "●")); ensure(textIn(cell(10), "●"));
        // After swap identities remain unchanged, but their orientations reverse.
        click(cell(20)); click(cell(30)); ensure(!confirm.enabled);
        click(clear); segment(20, 21);
        ensure(textIn(game, "Participante 2 · Vertical")); ensure(!swap.enabled);
        click(clear); segment(2, 12);
        ensure(textIn(game, "Participante 1 · Horizontal"));
        click(restart);
        ensure(textIn(game, "Participante 1 · Vertical")); ensure(!swap.enabled);
        ensure(!textIn(cell(0), "●")); ensure(!confirm.enabled);
        // Complete fixed CRJM-verified history: 9 segments, last mover P1 loses.
        // Endpoints reversed on first move to verify normalization.
        segment(99, 9);
        ensure(textIn(game, "Participante 2 · Horizontal")); ensure(swap.enabled);
        // Crossing the occupied right edge is illegal, not a partial placement.
        click(cell(30)); click(cell(39)); ensure(!confirm.enabled);
        ensure(!textIn(cell(30), "●")); ensure(swap.enabled);
        click(cell(38)); ensure(confirm.enabled);
        click(icon(game, "bar_help.svg"));
        tryCompare(pageView, "depth", 3, 2000);
        ensure(pageView.currentItem.content.indexOf("Perde quem faz a última jogada") >= 0);
        ensure(pageView.currentItem.content.indexOf("consome o turno") >= 0);
        grabImage(pageView).save("__QA_OUTPUT__/help.png");
        keyClick(Qt.Key_Escape); tryCompare(pageView, "depth", 2, 2000); wait(500);
        ensure(confirm.enabled); ensure(textIn(cell(39), "●"));
        ensure(textIn(game, "Participante 2 · Horizontal"));
        click(confirm); ensure(!swap.enabled);
        var moves = [[47,97],[0,8],[45,95],[10,18],[43,93],[20,28],[41,91]];
        for (var n = 0; n < moves.length; ++n) {
            if (n === 0) {
                var target = cell(moves[n][0]);
                touchEvent(target).press(0, target, target.width / 2, target.height / 2).commit();
                touchEvent(target).release(0, target, target.width / 2, target.height / 2).commit();
                wait(80); click(cell(moves[n][1])); ensure(confirm.enabled); click(confirm);
            } else segment(moves[n][0], moves[n][1]);
        }
        ensure(textIn(game, "Venceu o participante 2!"));
        ensure(textIn(game, "Perde quem faz a última jogada: participante 1"));
        ensure(textIn(game, "O participante 2 não tem jogadas na sua orientação"));
        // Literal reference final: columns 0,2,4,6,8 retain vertical moves.
        ensure(!textIn(cell(40), "●")); ensure(!textIn(cell(50), "●"));
        ensure(!confirm.enabled); ensure(!swap.enabled);
        click(cell(40)); click(cell(50)); ensure(!confirm.enabled);
        ensure(textIn(game, "Venceu o participante 2!"));
        grabImage(pageView).save("__QA_OUTPUT__/result.png");
        click(restart);
        board.forceActiveFocus(); keyClick(Qt.Key_Right); keyClick(Qt.Key_Space);
        keyClick(Qt.Key_Down); keyClick(Qt.Key_Space); keyClick(Qt.Key_Return);
        ensure(textIn(cell(1), "●")); ensure(textIn(cell(11), "●"));
        var window = game.Window.window;
        window.width = 1100; window.height = 700; wait(350);
        ensure(board.width / 10 >= 36, "Desktop selectable cell size");
        grabImage(pageView).save("__QA_OUTPUT__/desktop.png");
        window.width = 600; window.height = 900; wait(350);
        ensure(board.width / 10 >= 40, "Portrait selectable cell size");
        ensure(confirm.mapToItem(game, 0, 0).y + confirm.height <= game.height);
        ensure(swap.mapToItem(game, 0, 0).y > board.mapToItem(game, 0, 0).y + board.height, "Controls below board");
        grabImage(pageView).save("__QA_OUTPUT__/portrait.png");
        click(icon(game, "bar_home.svg")); tryCompare(pageView, "depth", 1, 2000);
        ensure(pageView.currentItem.isMenu);
        grabImage(pageView).save("__QA_OUTPUT__/menu.png");
    }
    function cleanupTestCase() {
        if (qtest_results.failCount) grabImage(pageView).save("__QA_OUTPUT__/failure.png");
        console.log("NATIVE_RESULT", JSON.stringify({failures:qtest_results.failCount, passes:qtest_results.passCount}));
    }
}
