// SPDX-License-Identifier: GPL-3.0-or-later
// Seam: the real menu and activity controls, never the rule engine or game state.
TestCase {
    name: "AtariGoTuxNative"
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
        var mode = findChild(game, "tuxAtari");
        ensure(mode !== null, "Mode against Tux available");
        function activate(target) {
            board.forceActiveFocus();
            for (var t = 0; t < 35 && !target.activeFocus; ++t) keyClick(Qt.Key_Tab);
            ensure(target.activeFocus, "Tab reaches " + target.objectName);
            keyClick(Qt.Key_Space); wait(70);
        }
        var difficulty = findChild(game, "difficultyAtari");
        var learn = findChild(game, "learnAtari");
        var hint = findChild(game, "hintAtari");
        var restart = findChild(game, "restartAtari");
        var inspect = findChild(game, "inspectAtari");
        var review = findChild(game, "reviewAtari");
        activate(mode); ensure(textIn(game, "Tu · Pretas"));
        activate(difficulty); ensure(textIn(game, "Médio: captura e liberdades"));
        activate(difficulty); ensure(textIn(game, "Difícil: antecipa capturas"));
        activate(learn); ensure(textIn(game, "Introdução:"));
        activate(findChild(game, "lessonAtari")); ensure(textIn(game, "Exercício didático"));
        activate(inspect); click(cell(0)); ensure(textIn(game, "1 pedras · 1 liberdades"));
        activate(inspect);
        activate(hint); ensure(textIn(game, "Conta as liberdades"));
        activate(hint); ensure(textIn(game, "linha 1"));
        activate(hint); ensure(textIn(cell(1), "?"));
        var point = cell(1);
        touchEvent(point).press(0, point, point.width/2, point.height/2).commit();
        touchEvent(point).release(0, point, point.width/2, point.height/2).commit(); wait(100);
        ensure(textIn(game, "Venceram as Pretas")); ensure(!textIn(cell(0), "○"));
        activate(restart); ensure(textIn(game, "Tu · Pretas"));
        var maxResponse = 0;
        var helpLatency = 0;
        // Drive only visible empty points. Rejected suicide is observed, not bypassed.
        for (var turn = 0; turn < 80 && !textIn(game, "Venceram"); ++turn) {
            var played = false;
            for (var i = 0; i < 81 && !played; ++i) {
                if (textIn(cell(i), "●") || textIn(cell(i), "○")) continue;
                var before = Date.now();
                mouseClick(cell(i), cell(i).width/2, cell(i).height/2);
                wait(10);
                if (textIn(game, "Suicídio")) continue;
                played = true;
                if (turn === 0) {
                    var helpStart = Date.now();
                    mouseClick(icon(game, "bar_help.svg"));
                    tryCompare(pageView, "depth", 3, 1500);
                    helpLatency = Date.now() - helpStart; ensure(helpLatency < 1500);
                    ensure(pageView.currentItem.content.indexOf("liberdades") >= 0);
                    wait(450); keyClick(Qt.Key_Escape); tryCompare(pageView, "depth", 2, 1500); wait(600);
                    ensure(textIn(cell(i), "●"), "Help preserves real move");
                }
                tryVerify(function() { return textIn(game, "Tu · Pretas") || textIn(game, "Venceram"); }, 2000);
                if (turn > 0) maxResponse = Math.max(maxResponse, Date.now() - before);
            }
            ensure(played || textIn(game, "Venceram"), "Visible legal human action");
        }
        ensure(textIn(game, "Venceram"), "Real Tux match reaches first capture");
        ensure(textIn(game, "Primeira captura"));
        grabImage(pageView).save("__QA_OUTPUT__/result.png");
        click(cell(80)); ensure(textIn(game, "Primeira captura"));
        activate(review); ensure(textIn(game, "Revisão: jogaste"));
        click(cell(0)); ensure(textIn(game, "alternativa à jogada original"));
        click(cell(40)); ensure(textIn(game, "Revisão concluída: o grupo da jogada original tinha 2 liberdades"));
        ensure(textIn(game, "alternativa tem 4 liberdades")); ensure(!textIn(game, "Venceram"));
        click(cell(41)); ensure(!textIn(cell(41), "●"));
        grabImage(pageView).save("__QA_OUTPUT__/review.png");
        activate(restart);
        mouseClick(cell(0),cell(0).width/2,cell(0).height/2);
        mouseClick(restart,restart.width/2,restart.height/2); wait(500);
        ensure(textIn(game, "Tu · Pretas"));
        for (var n = 0; n < 81; ++n) ensure(!textIn(cell(n), "○") && !textIn(cell(n), "●"), "Reset invalidates worker");
        // Remaining difficulty policies each produce a real legal reply.
        for (var level = 0; level < 2; ++level) {
            activate(difficulty);
            board.forceActiveFocus(); keyClick(Qt.Key_Right); keyClick(Qt.Key_Space);
            tryVerify(function() { return textIn(game, "Tu · Pretas"); }, 2000);
            ensure(textIn(cell(1), "●"));
            var whites = 0;
            for (var w = 0; w < 81; ++w) if (textIn(cell(w), "○")) whites++;
            ensure(whites === 1, "One legal complete Tux response");
        }
        var window = game.Window.window;
        window.width = 1100; window.height = 700; wait(200);
        ensure(board.width/9 >= 36); grabImage(pageView).save("__QA_OUTPUT__/desktop.png");
        window.width = 600; window.height = 900; wait(200);
        ensure(board.width/9 >= 40); grabImage(pageView).save("__QA_OUTPUT__/portrait.png");
        click(restart);
        mouseClick(cell(0),cell(0).width/2,cell(0).height/2);
        mouseClick(icon(game, "bar_home.svg")); tryCompare(pageView,"depth",1,2000); wait(1100);
        card = null;
        for (var d2 = 0; d2 < activitiesGrid.count; ++d2) {
            var candidate2 = activitiesGrid.itemAtIndex(d2);
            if (candidate2 && textIn(candidate2, "Atari Go")) card = candidate2;
        }
        click(card); tryCompare(pageView,"depth",2,5000); wait(900);
        game = activityLoader.item; board = findChild(game,"atariBoard");
        ensure(textIn(game,"Pretas ● · Participante 1") || textIn(game,"Tu · Pretas"));
        for (var r = 0; r < 81; ++r) ensure(!textIn(cell(r),"○") && !textIn(cell(r),"●"));
        console.log("ATARI_TIMING",JSON.stringify({maxResponseMs:maxResponse,helpOpenMs:helpLatency,heartbeatMaxMs:heartbeatMax}));
        ensure(maxResponse < 2000); ensure(heartbeatMax < 250);
        click(icon(game,"bar_home.svg")); tryCompare(pageView,"depth",1,2000);
    }
    function cleanupTestCase() {
        if (qtest_results.failCount) grabImage(pageView).save("__QA_OUTPUT__/failure.png");
        console.log("NATIVE_RESULT", JSON.stringify({failures:qtest_results.failCount, passes:qtest_results.passCount}));
    }
}
