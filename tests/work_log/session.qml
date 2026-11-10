// SPDX-FileCopyrightText: NONE
// SPDX-License-Identifier: GPL-3.0-or-later
// Public seams: native menu cards, activity input and rendered session notes.
// Reads fruit images to solve Enumerate; never replaces game state or functions.
TestCase {
    name: "WorkLogSessionNative"
    when: activity.visible

    function ensure(value, message) {
        if (!value) console.log("WORK_LOG_ASSERT_FAILED", message, new Error().stack);
        verify(value, message || "");
    }
    function walk(item, predicate) {
        var result = [];
        if (predicate(item)) result.push(item);
        for (var i = 0; i < item.children.length; ++i)
            result = result.concat(walk(item.children[i], predicate));
        return result;
    }
    function textIn(item, text) {
        return walk(item, function(c) { return c.text !== undefined && String(c.text).indexOf(text) >= 0; }).length > 0;
    }
    function icon(item, suffix) {
        var found = walk(item, function(c) { return c.source !== undefined && String(c.source).endsWith(suffix); });
        ensure(found.length > 0, "Icon " + suffix);
        return found[0];
    }
    function click(item) {
        ensure(item !== null, "Control exists");
        mouseClick(item, item.width / 2, item.height / 2);
    }
    function settled() { tryCompare(pageView, "busy", false, 5000); wait(150); }
    function openCard(query, title) {
        click(section.itemAtIndex(section.count - 1));
        click(searchTextField);
        keyClick(Qt.Key_A, Qt.ControlModifier);
        for (var i = 0; i < query.length; ++i) keyClick(query[i]);
        wait(800);
        var card = null;
        for (var d = 0; d < activitiesGrid.count; ++d) {
            var candidate = activitiesGrid.itemAtIndex(d);
            if (candidate && textIn(candidate, title)) card = candidate;
        }
        ensure(card !== null, "Card " + title);
        click(card);
        tryVerify(function() { return activityLoader.item && activityLoader.item.visible; }, 5000);
        settled();
        return activityLoader.item;
    }
    function openLog() {
        keyClick(Qt.Key_T, Qt.ControlModifier);
        tryCompare(pageView, "depth", 2, 2000);
        settled();
        ensure(pageView.currentItem.objectName === "workLogDialog", "Shortcut opens the work log");
        return pageView.currentItem;
    }
    function closeLog() {
        keyClick(Qt.Key_Escape);
        tryCompare(pageView, "depth", 1, 2000);
        settled();
    }
    function checkTextFits(root) {
        var labels = walk(root, function(c) { return c.text !== undefined && c.paintedWidth !== undefined && c.visible; });
        for (var i = 0; i < labels.length; ++i) {
            var t = labels[i];
            ensure(t.paintedWidth <= t.width + 2, "Text fits width: " + t.text);
            ensure(t.paintedHeight <= t.height + 2, "Text fits height: " + t.text);
            var p = t.mapToItem(root, 0, 0);
            ensure(p.x >= -1 && p.x + t.width <= root.width + 1, "Text inside window: " + t.text);
        }
        var list = findChild(root, "workLogEntries");
        ensure(list.height >= 120, "List has usable space");
        var close = findChild(root, "workLogClose");
        var pos = close.mapToItem(root, 0, 0);
        ensure(pos.y >= 0 && pos.y + close.height <= root.height, "Footer inside window");
    }
    function test_session_to_paper_plan() {
        wait(1600);
        var win = activity.Window.window;
        if (Screen.width === 2048) {
            ensure(Screen.height === 1152, "Large primary screen");
            win.width = 2048; win.height = 1100;
            ApplicationSettings.baseFontSize = 7;
        }
        settled();
        var log = openLog();
        ensure(textIn(log, "Ainda não há atividades nesta sessão."), "Friendly empty state");
        compare(findChild(log, "workLogEntries").count, 0);
        ensure(!findChild(log, "workLogClear").enabled, "Nothing to clear yet");
        checkTextFits(log);
        grabImage(pageView).save("__QA_OUTPUT__/work-log-empty.png");
        // Closing is also possible through the button, using the keyboard.
        ensure(findChild(log, "workLogClose").activeFocus, "Close receives initial focus");
        keyClick(Qt.Key_Space);
        tryCompare(pageView, "depth", 1, 2000); settled();

        var game = openCard("itens", "Contagem dos itens");
        var title = game.activityInfo.title;
        var goal = game.activityInfo.goal;
        var gamePage = walk(game, function(c) { return c.answersWidth !== undefined; })[0];
        // Find the score display and solve every presented sublevel by counting
        // the actual fruit images. All answers go through the native keyboard.
        var scores = walk(game, function(c) { return c.currentSubLevel !== undefined && c.numberOfSubLevels !== undefined; });
        ensure(scores.length === 1, "One score display");
        var score = scores[0];
        ensure(score.numberOfSubLevels > 0 && score.numberOfSubLevels <= 8, "Small real first level");
        for (var sub = 0; sub < score.numberOfSubLevels; ++sub) {
            tryCompare(score, "currentSubLevel", sub, 4000);
            wait(1800);
            var fruits = walk(game, function(c) { return c.source !== undefined && typeof c.positionMe === "function"; });
            ensure(fruits.length >= 1 && fruits.length <= 9, "Count visible fruits");
            console.log("WORK_LOG_FRUIT_ANSWER", sub, fruits.length);
            gamePage.forceActiveFocus();
            keyClick(String(fruits.length));
            tryCompare(score, "currentSubLevel", sub + 1, 2000);
        }
        // Return during Bonus, before its delayed win signal advances the level.
        // The successful round must already have been recorded by good().
        var bonuses = walk(game, function(c) { return c.isPlaying !== undefined && c.isWin !== undefined; });
        ensure(bonuses.length === 1, "Real Bonus component");
        tryCompare(bonuses[0], "isPlaying", true, 4000);
        click(icon(game, "bar_home.svg"));
        tryCompare(pageView, "depth", 1, 2000); settled();
        log = openLog();
        compare(findChild(log, "workLogEntries").count, 1);
        ensure(textIn(log, title), "Translated title: " + title);
        ensure(textIn(log, goal), "Translated goal: " + goal);
        ensure(textIn(log, "Rondas concluídas: 1"), "Round recorded before delayed win");
        closeLog();

        game = openCard("domin", "Dominório");
        ensure(findChild(game, "dominorioBoard") !== null, "Real CRJM game");
        click(icon(game, "bar_help.svg"));
        tryCompare(pageView, "depth", 3, 2000); settled();
        keyClick(Qt.Key_Escape);
        tryCompare(pageView, "depth", 2, 2000); settled();
        click(icon(game, "bar_home.svg"));
        tryCompare(pageView, "depth", 1, 2000); settled();
        log = openLog();
        compare(findChild(log, "workLogEntries").count, 2);
        ensure(textIn(log, "Dominório"), "CRJM title");
        ensure(textIn(log, "Rondas concluídas: —"), "No Bonus means dash");
        ensure(textIn(log, "Rondas concluídas: 1"), "Previous round preserved after help");
        closeLog();

        // Reopen the first activity and visit its configuration. Neither
        // operation should duplicate its entry or reset the completed round.
        game = openCard("itens", "Contagem dos itens");
        click(icon(game, "bar_activity_config.svg"));
        tryCompare(pageView, "depth", 3, 2000); settled();
        keyClick(Qt.Key_Escape);
        tryCompare(pageView, "depth", 2, 2000); settled();
        click(icon(game, "bar_home.svg"));
        tryCompare(pageView, "depth", 1, 2000); settled();
        log = openLog();
        compare(findChild(log, "workLogEntries").count, 2);
        ensure(textIn(log, "Rondas concluídas: 1"), "Reopening/configuration preserves rounds");
        checkTextFits(log);
        grabImage(pageView).save("__QA_OUTPUT__/work-log-entries.png");
        if (Screen.width === 2048) {
            var sizes = [[1280, 800], [800, 600], [600, 900], [600, 480]];
            for (var size = 0; size < sizes.length; ++size) {
                win.width = sizes[size][0]; win.height = sizes[size][1]; wait(250);
                checkTextFits(log);
                var list = findChild(log, "workLogEntries");
                list.forceActiveFocus();
                var before = list.contentY;
                keyClick(Qt.Key_PageDown);
                if (list.contentHeight > list.height)
                    ensure(list.contentY > before, "Keyboard scrolls overflowing list");
                keyClick(Qt.Key_PageUp);
                grabImage(pageView).save("__QA_OUTPUT__/work-log-" + sizes[size][0] + "x" + sizes[size][1] + ".png");
            }
            win.width = 2048; win.height = 1100; wait(250);
            findChild(log, "workLogClose").forceActiveFocus();
        }

        // Tab reaches the list, then clear. Cancelling is the default focus.
        keyClick(Qt.Key_Tab);
        ensure(findChild(log, "workLogEntries").activeFocus, "List reachable with Tab");
        keyClick(Qt.Key_Down);
        keyClick(Qt.Key_Tab);
        ensure(findChild(log, "workLogClear").activeFocus, "Clear reachable with Tab");
        keyClick(Qt.Key_Space);
        ensure(findChild(log, "workLogCancel").activeFocus, "Safe default in confirmation");
        ensure(textIn(log, "Já copiaste para o teu plano?"), "Simple confirmation");
        keyClick(Qt.Key_Escape);
        compare(findChild(log, "workLogEntries").count, 2);
        keyClick(Qt.Key_Space);
        keyClick(Qt.Key_Tab);
        ensure(findChild(log, "workLogConfirm").activeFocus, "Confirm reachable with Tab");
        keyClick(Qt.Key_Space);
        compare(findChild(log, "workLogEntries").count, 0);
        ensure(textIn(log, "Ainda não há atividades nesta sessão."), "Clear empties the session");
        closeLog();

        // Opened with the shortcut or the mouse, the view gives the keys back
        // to the grid it came from, so the arrows keep working.
        ensure(!workLogButton.activeFocus, "Closing does not strand focus on the button");
        ensure(activityBackground.currentActiveGrid !== workLogButton, "Arrow keys stay with a grid");
        click(workLogButton);
        tryCompare(pageView, "depth", 2, 2000); settled();
        closeLog();
        ensure(!workLogButton.activeFocus, "A mouse click does not move keyboard focus to the button");
        ensure(activityBackground.currentActiveGrid !== workLogButton, "Arrow keys stay with a grid after a click");

        // Existing grid cycle reaches the new button, and continues to sections.
        activityBackground.currentActiveGrid = workLogButton;
        workLogButton.forceActiveFocus();
        keyClick(Qt.Key_Tab);
        compare(activityBackground.currentActiveGrid, section);
        keyClick(Qt.Key_Tab);
        if (activityBackground.currentActiveGrid === categoriesGrid) keyClick(Qt.Key_Tab);
        compare(activityBackground.currentActiveGrid, activitiesGrid);
        keyClick(Qt.Key_Tab);
        ensure(workLogButton.activeFocus, "Menu Tab cycle reaches work log");
        keyClick(Qt.Key_Return);
        tryCompare(pageView, "depth", 2, 2000); settled();
        closeLog();
        ApplicationSettings.sectionVisible = false;
        keyClick(Qt.Key_Tab);
        compare(activityBackground.currentActiveGrid, activitiesGrid);
        keyClick(Qt.Key_Tab);
        ensure(workLogButton.activeFocus, "Tab also works with hidden sections");
        keyClick(Qt.Key_Tab, Qt.ShiftModifier);
        compare(activityBackground.currentActiveGrid, activitiesGrid);
        keyClick(Qt.Key_Tab);
        ensure(workLogButton.activeFocus, "Shift+Tab returns to the activities");
        ApplicationSettings.sectionVisible = true;
        console.log("WORK_LOG_SCREEN", JSON.stringify({screenWidth: Screen.width, screenHeight: Screen.height,
                    fontRatio: ApplicationInfo.fontRatio, width: win.width, height: win.height}));
    }
    function cleanupTestCase() {
        if (qtest_results.failCount) grabImage(pageView).save("__QA_OUTPUT__/failure.png");
        console.log("NATIVE_RESULT", JSON.stringify({failures:qtest_results.failCount, passes:qtest_results.passCount}));
    }
}
