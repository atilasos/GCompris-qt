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

    id: nativeCase
    name: "DominorioKeyboardNative"
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
    function ensure(value, message) { if (!value) console.log("DOMINORIO_ASSERT_FAILED", message || "", new Error().stack); verify(value, message || ""); }
    function click(item) { ensure(item !== null); clickNative(item, item.width / 2, item.height / 2); wait(60); }
    function keyboardActivate(game, name) {
        var target = findChild(game, name);
        ensure(target !== null, "Keyboard target exists: " + name);
        findChild(game, "dominorioBoard").forceActiveFocus();
        for (var tab = 0; tab < 24 && !target.activeFocus; ++tab) keyClick(Qt.Key_Tab);
        ensure(target.activeFocus, "Tab reaches " + name);
        keyClick(Qt.Key_Space); wait(80);
    }
    function test_tux_learning() {
        wait(1500);
        click(section.itemAtIndex(section.count - 1));
        clickNative(searchTextField, searchTextField.width / 2, searchTextField.height / 2);
        keyClick(Qt.Key_D); keyClick(Qt.Key_O); keyClick(Qt.Key_M); keyClick(Qt.Key_I); keyClick(Qt.Key_N);
        wait(800);
        var card = null;
        for (var d = 0; d < activitiesGrid.count; ++d) {
            var candidate = activitiesGrid.itemAtIndex(d);
            if (candidate && textIn(candidate, "Dominório")) card = candidate;
        }
        ensure(card !== null, "Dominório card"); click(card);
        wait(900);
        var game = activityLoader.item;
        var mode = findChild(game, "tuxMode");
        ensure(mode !== null, "Tux mode selectable");
        keyboardActivate(game, "tuxMode");
        ensure(textIn(game, "Tu · Vertical"));
        var confirm = findChild(game, "confirmDomino");
        var restart = findChild(game, "restartDomino");
        var difficulty = findChild(game, "difficultyDomino");
        // All three advertised difficulties actually answer on the native board.
        for (var level = 0; level < 2; ++level) {
            click(findChild(game, "dominoCell0")); keyboardActivate(game, "confirmDomino");
            tryVerify(function() { return textIn(game, "Tu · Vertical"); }, 2000);
            var count = 0;
            for (var i = 0; i < 64; ++i) if (textIn(findChild(game, "dominoCell" + i), "2 ↔")) count++;
            ensure(count === 2, "Tux completes a legal response at level " + level);
            keyboardActivate(game, "restartDomino");
            if (level === 0) keyboardActivate(game, "difficultyDomino");
        }
        // Return to easy, then explicitly select medium and hard for the full match.
        keyboardActivate(game, "difficultyDomino"); keyboardActivate(game, "difficultyDomino");
        keyboardActivate(game, "difficultyDomino"); ensure(textIn(difficulty, "Médio"));
        keyboardActivate(game, "difficultyDomino"); ensure(textIn(difficulty, "Difícil"));
        // An explicitly didactic final position is reached through the normal lesson.
        keyboardActivate(game, "learnDomino");
        ensure(textIn(game, "Introdução:"));
        keyboardActivate(game, "lessonNext");
        ensure(textIn(game, "Exercício didático"));
        keyboardActivate(game, "hintDomino"); ensure(textIn(game, "Procura duas casas"));
        keyboardActivate(game, "hintDomino"); ensure(textIn(game, "linha 1"));
        keyboardActivate(game, "hintDomino"); ensure(textIn(game, "casa assinalada"));
        click(findChild(game, "dominoCell0")); keyboardActivate(game, "confirmDomino");
        ensure(textIn(game, "Venceu o participante 1!"));
        keyboardActivate(game, "restartDomino");
        // Native input, actual bounded worker, no AI substitution or assigned winner.
        var responseTimes = [];
        var interactions = [];
        var moves = 0;
        var previousHorizontal = [];

        while (!textIn(game, "Venceu") && moves < 32) {
            var next = -1;
            for (var c = 0; c < 56; ++c) {
                if (!textIn(findChild(game, "dominoCell" + c), "1 ↕") &&
                    !textIn(findChild(game, "dominoCell" + c), "2 ↔") &&
                    !textIn(findChild(game, "dominoCell" + (c + 8)), "1 ↕") &&
                    !textIn(findChild(game, "dominoCell" + (c + 8)), "2 ↔")) { next = c; break; }
            }
            ensure(next >= 0, "Player has a visible legal vertical pair");
            click(findChild(game, "dominoCell" + next));
            ensure(confirm.enabled, "Confirm enabled at turn " + moves + " cell " + next);
            var start = Date.now();
            clickNative(confirm, confirm.width / 2, confirm.height / 2);
            // Opening help is allowed while Tux is calculating.
            if (moves === 0) {
                var inputStart = Date.now();
                clickNative(icon(game, "bar_help.svg"), 20, 20);
                tryCompare(pageView, "depth", 3, 1500);
                interactions.push(Date.now() - inputStart);
                keyClick(Qt.Key_Escape); tryCompare(pageView, "depth", 2, 1500); tryCompare(pageView, "busy", false, 2000); wait(80);
            }
            tryVerify(function() { return textIn(game, "Tu · Vertical") || textIn(game, "Venceu"); }, 2000);
            responseTimes.push(Date.now() - start);
            // Tux must add exactly a complete horizontal pair unless player ended game.
            var horizontal = 0;
            var currentHorizontal = [];
            var added = [];
            for (var c2 = 0; c2 < 64; ++c2) if (textIn(findChild(game, "dominoCell" + c2), "2 ↔")) {
                horizontal++; currentHorizontal.push(c2);
                if (previousHorizontal.indexOf(c2) < 0) added.push(c2);
            }
            if (added.length) ensure(added.length === 2 && added[1] === added[0] + 1 && Math.floor(added[0] / 8) === Math.floor(added[1] / 8), "Tux uses horizontal neighbours");
            previousHorizontal = currentHorizontal;
            ensure(horizontal === (moves + 1) * 2 || (textIn(game, "Venceu") && horizontal === moves * 2), "Complete Tux domino");
            moves++;
        }

        ensure(textIn(game, "Venceu"));
        grabImage(pageView).save("__QA_OUTPUT__/tux-result.png");
        keyboardActivate(game, "reviewDomino"); ensure(textIn(game, "Revisão:"));
        click(findChild(game, "dominoCell1")); keyboardActivate(game, "confirmDomino");
        ensure(textIn(game, "Revisão concluída:"));
        ensure(!textIn(game, "Venceu"));
        grabImage(pageView).save("__QA_OUTPUT__/review.png");
        // Restart invalidates a pending worker response and restores all empty cells.
        keyboardActivate(game, "restartDomino");
        click(findChild(game, "dominoCell0"));
        clickNative(confirm, confirm.width / 2, confirm.height / 2);
        clickNative(restart, restart.width / 2, restart.height / 2);
        wait(400);
        ensure(textIn(game, "Tu · Vertical"));
        ensure(!textIn(findChild(game, "dominoCell0"), "1 ↕"));
        for (var k = 0; k < 64; ++k) ensure(!textIn(findChild(game, "dominoCell" + k), "2 ↔"));
        var window = game.Window.window;
        window.width = 1100; window.height = 700; wait(200);
        ensure(findChild(game, "dominorioBoard").width / 8 >= 40, "Desktop target size");
        grabImage(pageView).save("__QA_OUTPUT__/tux-desktop.png");
        window.width = 600; window.height = 900; wait(200);
        ensure(findChild(game, "dominorioBoard").width / 8 >= 40, "Portrait target size");
        grabImage(pageView).save("__QA_OUTPUT__/tux-portrait.png");
        click(findChild(game, "dominoCell0")); clickNative(confirm, confirm.width / 2, confirm.height / 2);
        click(icon(game, "bar_home.svg")); tryCompare(pageView, "depth", 1, 1500); wait(300);
    }
    function cleanupTestCase() {
        if (qtest_results.failCount) grabImage(pageView).save("__QA_OUTPUT__/failure.png");
        console.log("NATIVE_RESULT", JSON.stringify({failures:qtest_results.failCount, passes:qtest_results.passCount}));
    }
}
