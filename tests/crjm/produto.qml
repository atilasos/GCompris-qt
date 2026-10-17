// SPDX-License-Identifier: GPL-3.0-or-later
// Seam: the real menu and activity controls, never the rule engine or game state.
TestCase {
    name: "ProdutoNative"
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
    function ensure(value, message) { if (!value) console.log("PRODUTO_ASSERT_FAILED", message || "", new Error().stack); verify(value, message || ""); }
    function click(item) { ensure(item !== null); mouseClick(item, item.width / 2, item.height / 2); wait(60); }
    function test_menu_to_complete_game() {
        wait(1500);
        var search = section.itemAtIndex(section.count - 1);
        click(search);
        mouseClick(searchTextField, searchTextField.width / 2, searchTextField.height / 2);
        keyClick(Qt.Key_P); keyClick(Qt.Key_R); keyClick(Qt.Key_O); keyClick(Qt.Key_D);
        wait(800);
        var card = null;
        for (var d = 0; d < activitiesGrid.count; ++d) {
            var candidate = activitiesGrid.itemAtIndex(d);
            if (candidate && textIn(candidate, "Produto")) card = candidate;
        }
        ensure(card !== null, "Search finds native activity");
        click(card);
        tryVerify(function() { return activityLoader.item && activityLoader.item.visible; }, 5000);
        wait(800);
        var game = activityLoader.item;
        var board = findChild(game, "produtoBoard");
        ensure(board !== null);
        var confirm = findChild(game, "confirmProduto");
        var clear = findChild(game, "clearProduto");
        var restart = findChild(game, "restartProduto");
        var black = findChild(game, "produtoColor1");
        var white = findChild(game, "produtoColor2");
        function cell(i) { return findChild(game, "produtoCell" + i); }
        function play(indices, color) {
            click(color === 1 ? black : white);
            for (var i=0; i<indices.length; ++i) click(cell(indices[i]));
            ensure(confirm.enabled, "Complete selection can confirm"); click(confirm);
        }
        ensure(textIn(game, "Participante 1")); ensure(!confirm.enabled);
        // Opening may be WHITE, irrespective of opening participant's own colour.
        click(white); board.forceActiveFocus(); keyClick(Qt.Key_Space);
        ensure(confirm.enabled); keyClick(Qt.Key_Return);
        ensure(textIn(cell(0), "◇")); ensure(textIn(game, "Participante 2"));
        click(cell(0)); ensure(textIn(game, "Casa ocupada")); ensure(!confirm.enabled);
        click(cell(1)); ensure(!confirm.enabled);
        click(cell(2)); ensure(confirm.enabled);
        click(cell(1)); ensure(!confirm.enabled); click(clear); ensure(!confirm.enabled);
        // Tab and Space reach both colour selectors and the restart control.
        board.forceActiveFocus(); keyClick(Qt.Key_Tab); ensure(black.activeFocus);
        keyClick(Qt.Key_Space); keyClick(Qt.Key_Tab); ensure(white.activeFocus);
        keyClick(Qt.Key_Space); keyClick(Qt.Key_Tab); ensure(restart.activeFocus);
        keyClick(Qt.Key_Space); ensure(textIn(game, "Participante 1"));
        // Independently worked group case: white (0,0),(1,0) and (3,0),(4,0)
        // form two groups of two. Adding (2,0) joins them: 4 -> 0.
        play([30], 2); play([39,54], 2); play([60,0], 2);
        ensure(textIn(game, "Brancas: 2 × 2 = 4"));
        click(white); click(cell(47)); click(cell(1));
        click(icon(game, "bar_help.svg")); tryCompare(pageView,"depth",3,2000);
        ensure(pageView.currentItem.content.indexOf("Menos de dois grupos dá zero") >= 0);
        keyClick(Qt.Key_Escape); tryCompare(pageView,"depth",2,2000); wait(1000);
        ensure(confirm.enabled); ensure(textIn(game,"Brancas: 2 × 2 = 4"));
        // Tab through all enabled action controls and activate confirm by Space.
        board.forceActiveFocus(); keyClick(Qt.Key_Tab); ensure(black.activeFocus);
        keyClick(Qt.Key_Tab); ensure(white.activeFocus);
        keyClick(Qt.Key_Tab); ensure(confirm.activeFocus); keyClick(Qt.Key_Space);
        ensure(textIn(game, "Brancas: 5 × 2 = 10"), "Bridge joins the two largest groups");
        // Remove unrelated stones in a fresh exact reference case.
        click(restart); wait(300); ensure(textIn(game,"Brancas: 0 × 0 = 0"),"Restart emptied board");
        // black filler at (-4,0) is separate from all white groups.
        play([30],2); play([39,54],2);
        click(white); click(cell(60)); click(black); click(cell(0)); click(confirm);
        ensure(textIn(game,"Brancas: 2 × 2 = 4"));
        click(white); click(cell(47)); click(black); click(cell(1));
        board.forceActiveFocus(); keyClick(Qt.Key_Tab); keyClick(Qt.Key_Tab); keyClick(Qt.Key_Tab);
        keyClick(Qt.Key_Tab); ensure(clear.activeFocus); keyClick(Qt.Key_Space);
        ensure(!confirm.enabled); ensure(textIn(game,"Brancas: 2 × 2 = 4"));
        click(white); click(cell(47)); click(black); click(cell(1)); click(confirm);
        ensure(textIn(game,"Brancas: 5 × 0 = 0"), "Merged single group scores zero");
        click(restart);
        // Complete official-compatible transcript, axial q then r:
        // first 30 black, remaining 31 white. Both connected, 0 each; P1 wins 30<31.
        play([0],1);
        for (var n=1;n<61;n+=2) {
            click(n<30 ? black : white); click(cell(n));
            click(n+1<30 ? black : white);
            var target=cell(n+1);
            if(n===1) {
                touchEvent(target).press(0,target,target.width/2,target.height/2).commit();
                touchEvent(target).release(0,target,target.width/2,target.height/2).commit(); wait(80);
            } else click(target);
            ensure(confirm.enabled); click(confirm);
        }
        ensure(textIn(game,"Venceu o participante 1!"));
        ensure(textIn(game,"Negras: 30 × 0 = 0")); ensure(textIn(game,"Brancas: 31 × 0 = 0"));
        ensure(textIn(game,"Desempate: vence quem tem menos peças"));
        ensure(!confirm.enabled); click(cell(0)); ensure(!confirm.enabled);
        grabImage(pageView).save("__QA_OUTPUT__/result.png");
        click(restart);
        var window=game.Window.window;
        window.width=1100; window.height=700; wait(350);
        ensure(cell(30).width>=36,"Desktop target width");
        grabImage(pageView).save("__QA_OUTPUT__/desktop.png");
        window.width=600; window.height=900; wait(350);
        ensure(cell(30).width>=40,"Portrait target width");
        ensure(restart.mapToItem(game,0,0).y+restart.height<=game.height);
        grabImage(pageView).save("__QA_OUTPUT__/portrait.png");
        click(icon(game,"bar_home.svg")); tryCompare(pageView,"depth",1,2000);
        ensure(pageView.currentItem.isMenu);
    }
    function cleanupTestCase() {
        if (qtest_results.failCount) grabImage(pageView).save("__QA_OUTPUT__/failure.png");
        console.log("NATIVE_RESULT", JSON.stringify({failures:qtest_results.failCount, passes:qtest_results.passCount}));
    }
}
