// SPDX-License-Identifier: GPL-3.0-or-later
// Seam: the real menu and activity controls, never the rule engine or game state.
TestCase {
    name: "YTuxNative"
    property double lastTick: 0
    property double heartbeatMax: 0
    Timer { interval: 25; running: true; repeat: true; onTriggered: {
        var now=Date.now();
        if(parent.lastTick) parent.heartbeatMax=Math.max(parent.heartbeatMax,now-parent.lastTick);
        parent.lastTick=now;
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
    function ensure(value, message) { if (!value) console.log("Y_ASSERT_FAILED", message || "", new Error().stack); verify(value, message || ""); }
    function click(item) { ensure(item !== null); mouseClick(item, item.width / 2, item.height / 2); wait(60); }
    function test_menu_to_complete_game() {
        wait(1500);
        var search = section.itemAtIndex(section.count - 1);
        click(search);
        mouseClick(searchTextField, searchTextField.width / 2, searchTextField.height / 2);
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
        var counts = [9,8,7,10,9,8,9,8,9,7,5,3,1], ids = [];
        for (var band = 0; band < counts.length; band++)
            for (var n = 1; n <= counts[band]; n++) ids.push(String.fromCharCode(65 + band) + n);
        var cursor = 0, maxResponse = 0, maxGap = 0, helpTime = 0, lastPlay = 0;
        function node(id) { return findChild(game, "yNode" + id); }
        function occupied(id) { return textIn(node(id), "●") || textIn(node(id), "◆"); }
        function count(symbol) { return ids.filter(function(id){return textIn(node(id),symbol);}).length; }
        function place(id) {
            board.forceActiveFocus(); var goal = ids.indexOf(id);
            while(cursor !== goal) { keyClick(Qt.Key_Right); cursor = (cursor+1)%93; }
            lastPlay=Date.now(); keyClick(Qt.Key_Space); wait(20);
        }
        function reset() { tabActivate(findChild(game, "restartY")); cursor=0; }
        function tabActivate(target) {
            board.forceActiveFocus();
            for(var n=0;n<20 && !target.activeFocus;n++) keyClick(Qt.Key_Tab);
            ensure(target.activeFocus, "Tab reaches " + target.objectName);
            keyClick(Qt.Key_Space); wait(50);
        }
        function awaitHuman() {
            var start = lastPlay, last = Date.now();
            wait(1);
            while(textIn(game, "Tux está a pensar")) {
                wait(15); var now=Date.now(); maxGap=Math.max(maxGap,now-last); last=now;
                ensure(now-start<2000,"Tux responds in 2 seconds");
            }
            maxResponse=Math.max(maxResponse,Date.now()-start);
        }
        tabActivate(findChild(game,"tuxY"));
        ensure(textIn(game,"Tu · Azul"));
        // All real difficulty policies; opening at a two-side corner makes medium/hard adopt Blue.
        for(var level=0;level<3;level++) {
            if(level) { tabActivate(findChild(game,"difficultyY")); cursor=0; }
            place("A1");
            var started=Date.now();
            tabActivate(findChild(game,"helpY")); tryCompare(pageView,"depth",3,1500);
            helpTime=Math.max(helpTime,Date.now()-started);
            keyClick(Qt.Key_Escape); tryCompare(pageView,"depth",2,1500);
            awaitHuman();
            ensure(occupied("A1"));
            if(level) {
                ensure(textIn(game,"Tu · Vermelho"),"Tux swaps colour, not identity");
                ensure(count("●")===1 && count("◆")===0,"Swap retains the original stone");
                place("A2"); awaitHuman();
                ensure(textIn(node("A2"),"◆"));
                ensure(textIn(game,"Tu · Vermelho"));
                ensure(count("●")===2 && count("◆")===1,"Exactly one legal Blue Tux reply after swap");
            } else {
                ensure(textIn(game,"Tu · Azul"));
                ensure(count("●")===1 && count("◆")===1,"Exactly one legal Red Tux reply");
            }
            reset();
        }
        // A full Hard game: every human action uses a currently empty visible node.
        var moves=0;
        while(!textIn(game,"Venceste!") && !textIn(game,"Venceu Tux!")) {
            var free=ids.filter(function(id){return !occupied(id);});
            ensure(free.length>0,"A legal complete Y game has a winner");
            place(free[0]); awaitHuman(); moves++;
            ensure(moves<=93,"Bounded complete game");
        }
        ensure(textIn(game,"Um único grupo liga os três lados"));
        grabImage(pageView).save("__QA_OUTPUT__/hard-result.png");
        tabActivate(findChild(game,"reviewY"));
        ensure(textIn(game,"Revisão da tua decisão em A1"));
        place("A1"); ensure(textIn(game,"Escolhe uma alternativa"));
        place("A2"); ensure(textIn(game,"Revisão concluída"));
        ensure(textIn(game,"2 lados; a alternativa une 1 peças e 1 lados"));
        grabImage(pageView).save("__QA_OUTPUT__/review.png");
        tabActivate(findChild(game,"learnY"));
        ensure(textIn(game,"Introdução:"));
        tabActivate(findChild(game,"exerciseY")); cursor=0;
        ensure(textIn(game,"Exercício didático preparado"));
        for(var h=0;h<3;h++) tabActivate(findChild(game,"hintY"));
        ensure(textIn(game,"intersecção A9"));
        // Synthetic touch and actual ordinary connection detection complete the exercise.
        board.forceActiveFocus();
        var goal=ids.indexOf("A9"); while(cursor!==goal) {keyClick(Qt.Key_Right);cursor=(cursor+1)%93;}
        touchEvent(node("A9")).press(0,node("A9"),22,22).commit();
        touchEvent(node("A9")).release(0,node("A9"),22,22).commit();wait(50);
        ensure(textIn(game,"Venceu o participante 1!"));
        ensure(textIn(game,"Um único grupo liga os três lados"));
        // Restart during pending response invalidates it, including an immediate new game.
        reset(); board.forceActiveFocus(); keyClick(Qt.Key_Right); cursor=1;
        keyClick(Qt.Key_Space);
        // No wait/yield between scheduling the real worker and the cancellation.
        mouseClick(findChild(game,"restartY"),20,20); cursor=0;wait(400);
        ensure(textIn(game,"Tu · Azul"));
        for(var i=0;i<ids.length;i++) ensure(!occupied(ids[i]),"No stale move after reset");
        var window=game.Window.window;
        window.width=1100;window.height=1050;wait(150);
        place("A1");awaitHuman();
        grabImage(pageView).save("__QA_OUTPUT__/desktop.png");
        window.width=1100;window.height=700;wait(150);
        for(var smallHint=0;smallHint<3;smallHint++) tabActivate(findChild(game,"hintY"));
        ensure(textIn(game,"está assinalada com ?"));
        var smallRestart=findChild(game,"restartY");
        ensure(smallRestart.mapToItem(game,0,0).y+smallRestart.height<game.height,"Controls fit normal desktop");
        ensure(findChild(game,"yViewport").height>=200,"Normal desktop has usable scrolling graph");
        grabImage(pageView).save("__QA_OUTPUT__/desktop-small-hint.png");
        place("A2");awaitHuman();ensure(textIn(node("A2"),"◆"));
        grabImage(pageView).save("__QA_OUTPUT__/desktop-small.png");
        window.width=600;window.height=900;wait(150);
        tabActivate(findChild(game,"zoomY"));
        // Reach lower graph with keyboard, then drag viewport back up.
        board.forceActiveFocus();goal=ids.indexOf("M1");
        while(cursor!==goal){keyClick(Qt.Key_Right);cursor=(cursor+1)%93;}wait(100);
        for(i=0;i<ids.length;i++) ensure(node(ids[i]).width>=44 && node(ids[i]).height>=44);
        grabImage(pageView).save("__QA_OUTPUT__/portrait-bottom.png");
        var viewport=findChild(game,"yViewport"), before=node("A1").mapToItem(game,0,0).y;
        mouseDrag(viewport,viewport.width-8,30,0,180,Qt.LeftButton,Qt.NoModifier,400);wait(100);
        ensure(node("A1").mapToItem(game,0,0).y>before,"Zoomed board scrolls");
        grabImage(pageView).save("__QA_OUTPUT__/portrait-scroll.png");
        reset(); board.forceActiveFocus(); keyClick(Qt.Key_Right); cursor=1;
        keyClick(Qt.Key_Space);
        var home=icon(game,"bar_home.svg");mouseClick(home,home.width/2,home.height/2);
        tryCompare(pageView,"depth",1,2000);wait(1100);
        ensure(pageView.currentItem.isMenu);
        card=null;
        for(var d=0;d<activitiesGrid.count;d++) {
            var candidate=activitiesGrid.itemAtIndex(d);
            if(candidate && textIn(candidate,"Y")) card=candidate;
        }
        click(card);tryCompare(pageView,"depth",2,3000);wait(300);
        game=activityLoader.item;
        ensure(textIn(game,"Participante 1 · Azul") || textIn(game,"Tu · Azul"),"Reopened game starts with participant 1 Blue");
        ensure(!textIn(findChild(game,"yNodeA1"),"●"),"No stale move after exit/reopen");
        ensure(heartbeatMax<250,"Heartbeat under 250ms");ensure(helpTime<1500,"Help under 1.5s");
        console.log("Y_TIMINGS",JSON.stringify({maxResponseMs:maxResponse,maxHeartbeatGapMs:heartbeatMax,helpMs:helpTime,humanMoves:moves}));
    }
    function cleanupTestCase() {
        if(qtest_results.failCount) grabImage(pageView).save("__QA_OUTPUT__/failure.png");
        console.log("NATIVE_RESULT", JSON.stringify({failures:qtest_results.failCount, passes:qtest_results.passCount}));
    }
}
