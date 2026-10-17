// SPDX-License-Identifier: GPL-3.0-or-later
// Seam: the real menu and activity controls, never the rule engine or game state.
TestCase {
    name: "NexNative"
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
    function ensure(value, message) { if (!value) console.log("NEX_ASSERT_FAILED", message || "", new Error().stack); verify(value, message || ""); }
    function click(item) { ensure(item !== null); mouseClick(item, item.width / 2, item.height / 2); wait(60); }
    function test_menu_to_complete_game() {
        wait(1500);
        var search = section.itemAtIndex(section.count - 1);
        click(search);
        mouseClick(searchTextField, searchTextField.width / 2, searchTextField.height / 2);
        keyClick(Qt.Key_N); keyClick(Qt.Key_E); keyClick(Qt.Key_X);
        wait(800);
        var card = null;
        for (var d = 0; d < activitiesGrid.count; ++d) {
            var candidate = activitiesGrid.itemAtIndex(d);
            if (candidate && textIn(candidate, "Nex")) card = candidate;
        }
        ensure(card !== null, "Search finds native activity");
        click(card);
        tryVerify(function() { return activityLoader.item && activityLoader.item.visible; }, 5000);
        wait(800);
        var game=activityLoader.item;
        var board=findChild(game,"nexBoard"), viewport=findChild(game,"nexViewport");
        var confirm=findChild(game,"confirmNex"), clear=findChild(game,"clearNex");
        var restart=findChild(game,"restartNex"), replace=findChild(game,"replaceNex"), swap=findChild(game,"swapNex");
        function tabClick(target) {
            board.forceActiveFocus();
            for(var t=0;t<25&&!target.activeFocus;++t)keyClick(Qt.Key_Tab);
            ensure(target.activeFocus,"Tab reaches "+target.objectName);keyClick(Qt.Key_Space);wait(60);
        }
        function cell(i) { return findChild(game,"nexCell"+i); }
        function select(i,touch) {
            var c=cell(i);
            viewport.contentX=Math.max(0,Math.min(viewport.contentWidth-viewport.width,c.x+c.width/2-viewport.width/2));
            viewport.contentY=Math.max(0,Math.min(viewport.contentHeight-viewport.height,c.y+c.height/2-viewport.height/2));wait(30);
            if(touch) {touchEvent(c).press(0,c,c.width/2,c.height/2).commit();touchEvent(c).release(0,c,c.width/2,c.height/2).commit();wait(70);}
            else click(c);
        }
        function play(a,b) { select(a);ensure(!confirm.enabled);select(b);ensure(confirm.enabled);click(confirm); }
        ensure(board!==null);ensure(!confirm.enabled);ensure(textIn(game,"Participante 1"));
        board.forceActiveFocus();keyClick(Qt.Key_Space);ensure(!confirm.enabled);
        select(0);ensure(!confirm.enabled);select(0);select(1,true);ensure(confirm.enabled);
        click(icon(game,"bar_help.svg"));tryCompare(pageView,"depth",3,2000);
        ensure(pageView.currentItem.content.indexOf("duas neutras")>=0);
        keyClick(Qt.Key_Escape);tryCompare(pageView,"depth",2,2000);wait(1200);
        ensure(confirm.enabled);click(clear);ensure(!confirm.enabled);
        play(0,1);ensure(textIn(game,"Participante 2"));ensure(swap.enabled);
        click(swap);ensure(textIn(game,"P1: ◇ O ↔ E"));ensure(textIn(game,"Participante 1"));ensure(!swap.enabled);
        ensure(textIn(cell(0),"●"));ensure(textIn(cell(1),"+"));
        click(restart);play(0,1);play(11,12);
        click(replace);select(0);ensure(textIn(game,"Seleção inválida"));ensure(!confirm.enabled);
        select(1);select(1);ensure(!confirm.enabled);select(1);select(12);ensure(!confirm.enabled);
        select(0);ensure(confirm.enabled);select(0);ensure(!confirm.enabled);select(0);click(confirm);
        ensure(textIn(cell(1),"●"));ensure(textIn(cell(12),"●"));ensure(textIn(cell(0),"+"));
        ensure(textIn(game,"Participante 2"));
        // Tab+Space on every enabled control from the public focus chain.
        click(restart);board.forceActiveFocus();keyClick(Qt.Key_Tab);ensure(findChild(game,"placeNex").activeFocus);keyClick(Qt.Key_Space);
        keyClick(Qt.Key_Tab);ensure(replace.activeFocus);keyClick(Qt.Key_Space);
        keyClick(Qt.Key_Tab);ensure(findChild(game,"zoomNex").activeFocus);keyClick(Qt.Key_Space);
        keyClick(Qt.Key_Tab);ensure(restart.activeFocus);keyClick(Qt.Key_Space);
        click(findChild(game,"zoomNex"));
        select(0);select(1);tabClick(clear);ensure(!confirm.enabled);
        select(0);select(1);tabClick(confirm);tabClick(swap);tabClick(restart);
        // Independently verified CRJM transcript: 21 completed legal turns.
        for(var k=0;k<11;++k) { play(55+k,99+k);if(k<10)play(k,88+k); }
        ensure(textIn(game,"Venceu o participante 1!"));ensure(!confirm.enabled);select(40);ensure(!confirm.enabled);
        grabImage(pageView).save("__QA_OUTPUT__/result.png");
        click(restart);
        // Independent reference transcript verified with actual CRJM actions:
        // black along y0 never reaches y10; white connects x0 to x10 at y5.
        for(var w=0;w<11;++w) {play(w*11,w*11+8);play(w*11+5,w*11+9);}
        ensure(textIn(game,"Venceu o participante 2!"));
        ensure(textIn(game,"Ligaste as duas margens"));
        grabImage(pageView).save("__QA_OUTPUT__/white-result.png");
        // Real didactic near-final positions. Neither colour has a connection beforehand.
        for(var f=0;f<3;++f) {
            tabClick(findChild(game,"finalNex"+f));ensure(textIn(game,"Exercício:"));ensure(!textIn(game,"Venceu"));
            ensure(!confirm.enabled);tabClick(findChild(game,"resolveNex"));
            ensure(textIn(game,"Venceu o participante 1!"));ensure(textIn(cell(60),"●"));
            if(f===2)ensure(textIn(cell(59),"◇"));
            ensure(textIn(game,"Convenção das últimas casas aplicada"));
        }
        click(restart);var window=game.Window.window;window.width=1100;window.height=700;wait(350);
        ensure(cell(60).width>=40);grabImage(pageView).save("__QA_OUTPUT__/desktop.png");
        window.width=600;window.height=900;wait(350);ensure(cell(60).width>=40);
        ensure(restart.mapToItem(game,0,0).y+restart.height<=game.height);
        select(120);select(119);ensure(confirm.enabled);click(confirm);ensure(textIn(game,"Participante 2"));
        grabImage(pageView).save("__QA_OUTPUT__/portrait.png");
        click(icon(game,"bar_home.svg"));tryCompare(pageView,"depth",1,2000);ensure(pageView.currentItem.isMenu);
    }
    function cleanupTestCase() {
        if (qtest_results.failCount) grabImage(pageView).save("__QA_OUTPUT__/failure.png");
        console.log("NATIVE_RESULT", JSON.stringify({failures:qtest_results.failCount, passes:qtest_results.passCount}));
    }
}
