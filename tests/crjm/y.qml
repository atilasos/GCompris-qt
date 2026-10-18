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

    name: "YNative"
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
    function ensure(value, message) { if (!value) console.log("Y_ASSERT_FAILED", message || "", new Error().stack); verify(value, message || ""); }
    function click(item) { ensure(item !== null); clickNative(item, item.width / 2, item.height / 2); wait(60); }
    function test_menu_to_complete_game() {
        wait(1500);
        var search = section.itemAtIndex(section.count - 1);
        click(search);
        clickNative(searchTextField, searchTextField.width / 2, searchTextField.height / 2);
        keyClick(Qt.Key_Y); keyClick(Qt.Key_Slash);
        wait(800);
        var card = null;
        for (var d = 0; d < activitiesGrid.count; ++d) {
            var candidate = activitiesGrid.itemAtIndex(d);
            if (candidate && textIn(candidate, "Y")) card = candidate;
        }
        ensure(card !== null, "Search finds native activity");
        click(card);
        tryVerify(function() { return activityLoader.item && activityLoader.item.visible; }, 5000);
        wait(800);
        var game = activityLoader.item;
        var board = findChild(game, "yBoard");
        ensure(board !== null, "Native Y board loaded");
        var swap = findChild(game, "swapY"), restart = findChild(game, "restartY");
        var counts = [9,8,7,10,9,8,9,8,9,7,5,3,1], ids = [];
        for (var band = 0; band < counts.length; band++)
            for (var n = 1; n <= counts[band]; n++) ids.push(String.fromCharCode(65 + band) + n);
        var cursor = 0;
        function node(id) { return findChild(game, "yNode" + id); }
        function reveal(id) {
            board.forceActiveFocus();
            var goal = ids.indexOf(id); ensure(goal >= 0);
            while (cursor !== goal) { keyClick(Qt.Key_Right); cursor = (cursor + 1) % 93; }
            wait(15);
        }
        function place(id) { reveal(id); keyClick(Qt.Key_Space); wait(15); }
        function reset() { click(restart); cursor = 0; }
        click(findChild(game, "zoomY")); // Enlarged touch mode; default overview is covered by ui-audit.
        for (var i = 0; i < ids.length; i++) {
            ensure(node(ids[i]) !== null, "All 93 intersections available");
            ensure(node(ids[i]).width >= 44 && node(ids[i]).height >= 44, "Touch target 44px");
        }
        ensure(!swap.enabled);
        // Touch, occupied rejection and first-turn ownership.
        reveal("A1");
        touchEvent(node("A1")).press(0, node("A1"), 22, 22).commit();
        touchEvent(node("A1")).release(0, node("A1"), 22, 22).commit(); wait(80);
        ensure(textIn(node("A1"), "●")); ensure(swap.enabled);
        click(node("A1")); ensure(textIn(game, "Intersecção ocupada")); ensure(swap.enabled);
        keyClick(Qt.Key_Tab); ensure(swap.activeFocus, "Tab reaches swap");
        keyClick(Qt.Key_Space); wait(80);
        ensure(!swap.enabled); ensure(textIn(game, "Participante 1 · Vermelho"));
        ensure(textIn(node("A1"), "●"));
        ensure(textIn(game, "A troca consumiu o turno"));
        place("B1"); ensure(textIn(node("B1"), "◆"));
        // Open help with keyboard and retain both pieces.
        keyClick(Qt.Key_Tab); // swap disabled, next enabled control is restart
        ensure(restart.activeFocus, "Tab reaches restart");
        keyClick(Qt.Key_Tab); ensure(findChild(game, "zoomY").activeFocus);
        keyClick(Qt.Key_Tab); ensure(findChild(game, "helpY").activeFocus);
        keyClick(Qt.Key_Space); wait(250);
        tryCompare(pageView, "depth", 3, 2000);
        ensure(textIn(pageView.currentItem, "Três grupos separados não bastam"));
        grabImage(pageView).save("__QA_OUTPUT__/help.png");
        keyClick(Qt.Key_Escape); tryCompare(pageView, "depth", 2, 2000); wait(250);
        ensure(textIn(node("A1"), "●")); ensure(textIn(node("B1"), "◆"));
        reset();
        // Independent literal drawing transcript; three disconnected boundary groups do not win.
        var separate = ["A5","C3","G1","C5","G9","I5","A1","I3","A9"];
        for (i = 0; i < separate.length; i++) { place(separate[i]); ensure(!textIn(game, "Venceu")); }
        reset();
        var incomplete = ["A1","B1","C1","E2","E3","F3","F4","F5","F6","F7","E8","D9","A9","B8"];
        var replies = ["M1","L1","L2","L3","K1","K2","K3","K4","K5","J1","J2","J3","J5","J6"];
        for (i = 0; i < incomplete.length; i++) {
            place(incomplete[i]); ensure(!textIn(game, "Venceu"), "E2 and E3 are not adjacent");
            place(replies[i]); ensure(!textIn(game, "Venceu"));
        }
        place("D3"); ensure(textIn(game, "Venceu o participante 1!"));
        grabImage(pageView).save("__QA_OUTPUT__/non-geometric.png");
        var path = ["A1","B1","C1","D3","E3","E4","E5","E6","E7","D8","C7","B8","A9"];
        replies = ["M1","L1","K1","J1","I1","G1","E1","D1","I9","J7","K5","L3"];
        for (var swapped = 0; swapped < 2; swapped++) {
            reset(); place(path[0]);
            if (swapped) { click(swap); ensure(textIn(game, "Participante 1 · Vermelho")); }
            for (i = 1; i < path.length; i++) {
                place(replies[i - 1]); ensure(!textIn(game, "Venceu"));
                place(path[i]);
                if (i < path.length - 1) ensure(!textIn(game, "Venceu"));
            }
            ensure(textIn(game, "Venceu o participante " + (swapped ? 2 : 1) + "!"));
            ensure(textIn(game, "Um único grupo liga os três lados"));
            ensure(!swap.enabled);
            place("A5"); ensure(!textIn(node("A5"), "●")); ensure(!textIn(node("A5"), "◆"));
            grabImage(pageView).save("__QA_OUTPUT__/blue-win-" + swapped + ".png");
        }
        // Red lower-corner path verifies the other colour and participant mapping.
        path = ["M1","L2","K3","J4","I5","H4","G4","F3","E3","D4","C3","B3","A3"];
        var blue = ["A1","D1","E1","G1","I1","J1","K1","L1","A9","D10","E9","G9","I9"];
        for (swapped = 0; swapped < 2; swapped++) {
            reset();
            if (swapped) { place("A1"); click(swap); }
            for (i = 0; i < path.length; i++) {
                if (!swapped || i > 0) place(blue[i]);
                place(path[i]);
                if (i < path.length - 1) ensure(!textIn(game, "Venceu"));
            }
            ensure(textIn(game, "Venceu o participante " + (swapped ? 1 : 2) + "!"));
        }
        reset();
        var window = game.Window.window;
        window.width = 1100; window.height = 1050; wait(300);
        reveal("A5"); click(node("A5"));
        ensure(textIn(node("A5"), "●"));
        grabImage(pageView).save("__QA_OUTPUT__/desktop.png");
        window.width = 600; window.height = 900; wait(300);
        reveal("M1"); click(node("M1")); ensure(textIn(node("M1"), "◆"));
        ensure(restart.mapToItem(game, 0, 0).y + restart.height < game.height);
        grabImage(pageView).save("__QA_OUTPUT__/portrait-bottom.png");
        reveal("A1"); grabImage(pageView).save("__QA_OUTPUT__/portrait-top.png");
        var viewport = findChild(game, "yViewport");
        var before = node("M1").mapToItem(game, 0, 0).y;
        // A real drag exposes the lower graph without placing an accidental stone.
        mouseDrag(viewport, viewport.width - 8, viewport.height - 30, 0, -160, Qt.LeftButton, Qt.NoModifier, 400);
        wait(300);
        ensure(node("M1").mapToItem(game, 0, 0).y < before, "Board can slide with a pointer");
        ensure(textIn(node("A5"), "●")); ensure(textIn(node("M1"), "◆"));
        board.forceActiveFocus(); keyClick(Qt.Key_Tab);
        ensure(restart.activeFocus, "Tab reaches restart after a normal reply");
        keyClick(Qt.Key_Space); wait(80); cursor = 0;
        ensure(textIn(game, "Participante 1 · Azul")); ensure(!swap.enabled);
        ensure(!textIn(node("A5"), "●")); ensure(!textIn(node("M1"), "◆"));
        click(icon(game, "bar_home.svg")); tryCompare(pageView, "depth", 1, 2000);
        ensure(pageView.currentItem.isMenu);
        grabImage(pageView).save("__QA_OUTPUT__/menu.png");

    }
    function cleanupTestCase() {
        if (qtest_results.failCount) grabImage(pageView).save("__QA_OUTPUT__/failure.png");
        console.log("NATIVE_RESULT", JSON.stringify({failures:qtest_results.failCount, passes:qtest_results.passCount}));
    }
}
