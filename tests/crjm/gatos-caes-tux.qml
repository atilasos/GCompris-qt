// SPDX-License-Identifier: GPL-3.0-or-later
// Seam: the real menu and activity controls, never the rule engine or game state.
TestCase {
    id: nativeCase
    property double lastBeat: 0
    property double longestBeat: 0
    Timer { id: heartbeat; interval: 10; repeat: true; onTriggered: { var now = Date.now(); if (nativeCase.lastBeat) nativeCase.longestBeat = Math.max(nativeCase.longestBeat, now - nativeCase.lastBeat); nativeCase.lastBeat = now; } }
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
    function click(item) { ensure(item !== null); mouseClick(item, item.width / 2, item.height / 2); wait(60); }
    function test_menu_to_complete_game() {
        wait(1500);
        click(section.itemAtIndex(section.count - 1));
        mouseClick(searchTextField, searchTextField.width / 2, searchTextField.height / 2);
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
        var mode = findChild(game, "tuxModeGatos"); ensure(mode !== null, "Tux mode available");
        // Traverse real Tab focus to a control, then activate with Space.
        board.forceActiveFocus();
        for (var tab = 0; tab < 20 && !mode.activeFocus; ++tab) keyClick(Qt.Key_Tab);
        ensure(mode.activeFocus, "Mode reachable by Tab"); keyClick(Qt.Key_Space); wait(100);
        ensure(textIn(game, "Tu · Gatos"));
        var restart = findChild(game, "restartGatos");
        var difficulty = findChild(game, "difficultyGatos");
        for (var level = 0; level < 3; ++level) {
            console.log("GATOS_STAGE", "difficulty", level, Date.now());
            click(findChild(game, "gatosCell27"));
            tryVerify(function() { return textIn(game, "Tu · Gatos") || textIn(game, "Venceu"); }, 2000);
            var dogs = 0;
            for (var d1 = 0; d1 < 64; ++d1) if (textIn(findChild(game, "gatosCell" + d1), "2 C")) dogs++;
            ensure(dogs === 1, "Each difficulty returns a complete dog placement");
            click(restart); if (level < 2) click(difficulty);
        }
        console.log("GATOS_STAGE", "learning", Date.now());
        var learn = findChild(game, "learnGatos");
        board.forceActiveFocus();
        for (var tab2 = 0; tab2 < 20 && !learn.activeFocus; ++tab2) keyClick(Qt.Key_Tab);
        ensure(learn.activeFocus, "Learning reachable by Tab"); keyClick(Qt.Key_Space); wait(80);
        ensure(textIn(game, "Introdução:"));
        click(findChild(game, "lessonNextGatos")); ensure(textIn(game, "Exercício didático"));
        click(findChild(game, "gatosCell28")); ensure(textIn(game, "Jogada impossível"));
        var hint = findChild(game, "hintGatos"); board.forceActiveFocus();
        for (var hintTab = 0; hintTab < 20 && !hint.activeFocus; ++hintTab) keyClick(Qt.Key_Tab);
        ensure(hint.activeFocus, "Hint reachable by Tab"); keyClick(Qt.Key_Space); wait(80);
        ensure(textIn(game, "Procura uma casa vazia"));
        click(findChild(game, "hintGatos")); ensure(textIn(game, "linha 1"));
        click(findChild(game, "hintGatos")); ensure(textIn(game, "casa assinalada"));
        click(findChild(game, "gatosCell35")); ensure(textIn(game, "Exercício concluído"));
        ensure(!textIn(game, "Venceu")); click(restart);
        var responses = [], help = [], previousDogs = [];
        var turns = 0; heartbeat.start();
        click(findChild(game, "legalGatos"));
        while (!textIn(game, "Venceu") && turns < 40) {
            console.log("GATOS_STAGE", "hard-turn", turns, Date.now());
            var next = -1;
            for (var c = 0; c < 64; ++c) if (textIn(findChild(game, "gatosCell" + c), "+")) { next = c; break; }
            ensure(next >= 0, "A legal cat placement is displayed");
            var start = Date.now(); mouseClick(findChild(game, "gatosCell" + next), 10, 10);
            if (!turns) {
                var helpStart = Date.now(); mouseClick(icon(game, "bar_help.svg"), 20, 20);
                tryCompare(pageView, "depth", 3, 1500); help.push(Date.now() - helpStart);
                ensure(pageView.currentItem.content.indexOf("quatro casas centrais") >= 0);
                keyClick(Qt.Key_Escape); tryCompare(pageView, "depth", 2, 1500); tryCompare(pageView, "busy", false, 2000); wait(80);
            }
            tryVerify(function() { return textIn(game, "Tu · Gatos") || textIn(game, "Venceu"); }, 2000);
            responses.push(Date.now() - start);
            var currentDogs = [], added = [];
            for (var c2 = 0; c2 < 64; ++c2) if (textIn(findChild(game, "gatosCell" + c2), "2 C")) { currentDogs.push(c2); if (previousDogs.indexOf(c2) < 0) added.push(c2); }
            ensure(added.length === 1 || (textIn(game, "Venceu o participante 1!") && !added.length), "One complete Tux action");
            if (added.length) {
                var dog = added[0], neighbours = [];
                if (dog >= 8) neighbours.push(dog - 8); if (dog < 56) neighbours.push(dog + 8);
                if (dog % 8) neighbours.push(dog - 1); if (dog % 8 < 7) neighbours.push(dog + 1);
                for (var n = 0; n < neighbours.length; ++n) ensure(!textIn(findChild(game, "gatosCell" + neighbours[n]), "1 G"), "Dog never neighbours a cat orthogonally");
                if (!turns) ensure([27,28,35,36].indexOf(dog) < 0, "First dog outside centre");
            }
            previousDogs = currentDogs; turns++;
        }
        console.log("GATOS_STAGE", "review", Date.now());
        heartbeat.stop(); ensure(longestBeat < 250, "UI heartbeat below 250ms");
        ensure(textIn(game, "Venceu")); grabImage(pageView).save("__QA_OUTPUT__/result.png");
        click(findChild(game, "reviewGatos")); ensure(textIn(game, "Revisão:"));
        click(findChild(game, "gatosCell27")); ensure(textIn(game, "Escolhe uma alternativa"));
        click(findChild(game, "gatosCell28")); ensure(textIn(game, "Revisão concluída:"));
        ensure(textIn(game, "58 casas")); ensure(!textIn(game, "Venceu"));
        grabImage(pageView).save("__QA_OUTPUT__/review.png");
        click(restart);
        mouseClick(findChild(game, "gatosCell27"), 10, 10); mouseClick(restart, 10, 10); wait(400);
        ensure(textIn(game, "Tu · Gatos"));
        for (var k = 0; k < 64; ++k) { ensure(!textIn(findChild(game, "gatosCell" + k), "1 G")); ensure(!textIn(findChild(game, "gatosCell" + k), "2 C")); }
        var window = game.Window.window;
        window.width = 1100; window.height = 700; wait(200); ensure(board.width / 8 >= 40); grabImage(pageView).save("__QA_OUTPUT__/desktop.png");
        window.width = 600; window.height = 900; wait(200); ensure(board.width / 8 >= 40); grabImage(pageView).save("__QA_OUTPUT__/portrait.png");
        mouseClick(findChild(game, "gatosCell27"), 10, 10); click(icon(game, "bar_home.svg")); tryCompare(pageView, "depth", 1, 1500); wait(300);
        console.log("GATOS_TIMING", JSON.stringify({difficulty:"hard",response_ms:responses,help_ms:help,max_heartbeat_gap_ms:longestBeat}));
    }
    function cleanupTestCase() { if (qtest_results.failCount) grabImage(pageView).save("__QA_OUTPUT__/failure.png"); console.log("NATIVE_RESULT", JSON.stringify({failures:qtest_results.failCount, passes:qtest_results.passCount})); }
}
