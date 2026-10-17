// SPDX-License-Identifier: GPL-3.0-or-later
// Seam: the real menu and activity controls, never the rule engine or game state.
TestCase {
    name: "QuelhasNative"
    property double lastTick: 0
    property double heartbeatMax: 0
    Timer { interval: 25; running: true; repeat: true; onTriggered: {
        var now = Date.now();
        if (parent.lastTick) parent.heartbeatMax = Math.max(parent.heartbeatMax, now - parent.lastTick);
        parent.lastTick = now;
    } }
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
        var mode = findChild(game, "tuxQuelhas");
        ensure(mode !== null, "Mode against Tux is available");
        var confirm = findChild(game, "confirmQuelhas");
        var restart = findChild(game, "restartQuelhas");
        var difficulty = findChild(game, "difficultyQuelhas");
        var learn = findChild(game, "learnQuelhas");
        var hint = findChild(game, "hintQuelhas");
        var review = findChild(game, "reviewQuelhas");
        function cell(index) { return findChild(game, "quelhasCell" + index); }
        function segment(first, last) { click(cell(first)); click(cell(last)); ensure(confirm.enabled); click(confirm); }
        function activate(target) {
            board.forceActiveFocus();
            for (var t = 0; t < 30 && !target.activeFocus; ++t) keyClick(Qt.Key_Tab);
            ensure(target.activeFocus, "Tab reaches " + target.objectName);
            keyClick(Qt.Key_Space); wait(70);
        }
        activate(mode); ensure(textIn(game, "Tu · Vertical"));
        activate(difficulty); ensure(textIn(game, "Médio: compara espaço"));
        activate(difficulty); ensure(textIn(game, "Difícil: troca e antecipa"));
        activate(learn); ensure(textIn(game, "Introdução:"));
        activate(findChild(game, "lessonQuelhas")); ensure(textIn(game, "Exercício didático"));
        segment(0, 10); ensure(textIn(game, "Participante 2 · Horizontal"));
        segment(22, 23); ensure(textIn(game, "Venceu o participante 1!"));
        ensure(textIn(game, "Perde quem faz a última jogada: participante 2"));
        click(restart);
        activate(hint); ensure(textIn(game, "Tenta conservar"));
        activate(hint); ensure(textIn(game, "Procura um segmento"));
        activate(hint); ensure(textIn(game, "extremos assinalados"));
        // Hard opening exercises the real swap, preserving participant identity.
        segment(0, 10);
        tryVerify(function() { return textIn(game, "Tu · Horizontal"); }, 2000);
        ensure(textIn(game, "1 ↔ Horizontal · 2 ↕ Vertical"));
        ensure(textIn(cell(0), "●")); ensure(textIn(cell(10), "●"));
        var maxResponse = 0;
        for (var turn = 0; turn < 50 && !textIn(game, "Venceu"); ++turn) {
            var chosen = -1;
            for (var n = 0; n < 99; ++n)
                if (n % 10 < 9 && !textIn(cell(n), "●") && !textIn(cell(n + 1), "●")) { chosen = n; break; }
            ensure(chosen >= 0, "Human has a visible legal horizontal pair");
            click(cell(chosen)); click(cell(chosen + 1)); ensure(confirm.enabled);
            var before = Date.now(); click(confirm);
            if (turn === 0) {
                click(icon(game, "bar_help.svg")); tryCompare(pageView, "depth", 3, 1500); wait(500);
                ensure(pageView.currentItem.content.indexOf("última jogada") >= 0, "Misère rule in native help");
                keyClick(Qt.Key_Escape); tryCompare(pageView, "depth", 2, 1500); wait(600);
            }
            tryVerify(function() { return textIn(game, "Tu · Horizontal") || textIn(game, "Venceu"); }, 2000);
            maxResponse = Math.max(maxResponse, Date.now() - before);
        }
        ensure(textIn(game, "Venceu"), "Real misère match terminates");
        ensure(textIn(game, "não tem jogadas na sua orientação"));
        grabImage(pageView).save("__QA_OUTPUT__/result.png");
        activate(review); ensure(textIn(game, "Revisão: jogaste"));
        // Review restores the real first decision, vertical before swap.
        segment(1, 11);
        ensure(textIn(game, "Revisão concluída:"));
        ensure(textIn(game, "pares livres")); ensure(!textIn(game, "Venceu"));
        grabImage(pageView).save("__QA_OUTPUT__/review.png");
        // Reset/mode/difficulty invalidate any pending generation.
        click(restart); segment(0, 10); click(restart); wait(400);
        ensure(textIn(game, "Tu · Vertical")); ensure(!textIn(cell(0), "●"));
        activate(difficulty); ensure(textIn(game, "Fácil: ao acaso"));
        segment(0, 10); tryVerify(function() { return textIn(game, "Tu · Vertical") || textIn(game, "Venceu"); }, 2000);
        ensure(textIn(cell(0), "●"));
        activate(difficulty); segment(0, 10);
        tryVerify(function() { return textIn(game, "Tu · Vertical") || textIn(game, "Venceu"); }, 2000);
        var window = game.Window.window;
        window.width = 1100; window.height = 700; wait(200);
        ensure(board.width / 10 >= 36); grabImage(pageView).save("__QA_OUTPUT__/desktop.png");
        window.width = 600; window.height = 900; wait(200);
        ensure(board.width / 10 >= 40); grabImage(pageView).save("__QA_OUTPUT__/portrait.png");
        click(restart); segment(0, 10); click(icon(game, "bar_home.svg"));
        tryCompare(pageView, "depth", 1, 2000); wait(400); ensure(pageView.currentItem.isMenu);
        console.log("QUELHAS_TIMING", JSON.stringify({maxResponseIncludingFirstHelpMs:maxResponse, heartbeatMaxMs:heartbeatMax}));
        ensure(maxResponse < 2000, "Response plus help below 2 seconds");
        ensure(heartbeatMax < 250, "UI heartbeat under 250ms");
    }
    function cleanupTestCase() {
        if (qtest_results.failCount) grabImage(pageView).save("__QA_OUTPUT__/failure.png");
        console.log("NATIVE_RESULT", JSON.stringify({failures:qtest_results.failCount, passes:qtest_results.passCount}));
    }
}
