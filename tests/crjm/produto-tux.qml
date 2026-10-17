// SPDX-License-Identifier: GPL-3.0-or-later
// Seam: the real menu and activity controls, never the rule engine or game state.
TestCase {
    id: nativeCase
    name: "ProdutoTuxNative"
    property double lastBeat: 0
    property double longestBeat: 0
    Timer { id: heartbeat; interval: 10; repeat: true; onTriggered: {
        var now=Date.now(); if(nativeCase.lastBeat) nativeCase.longestBeat=Math.max(nativeCase.longestBeat,now-nativeCase.lastBeat); nativeCase.lastBeat=now;
    } }
    function tabTo(button) {
        for(var k=0;k<35 && !button.activeFocus;++k) keyClick(Qt.Key_Tab);
        ensure(button.activeFocus,"Tab reaches "+button.objectName);
    }
    function activate(button) { tabTo(button); keyClick(Qt.Key_Space); wait(60); }
    function stoneCount(game) {
        var count=0;
        for(var i=0;i<61;++i) {
            var cell=findChild(game,"produtoCell"+i);
            if(cell.opacity===1 && (textIn(cell,"●") || textIn(cell,"◇"))) ++count;
        }
        return count;
    }
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
        var mode=findChild(game,"produtoMode"), difficulty=findChild(game,"produtoDifficulty");
        var confirm=findChild(game,"confirmProduto"), restart=findChild(game,"restartProduto");
        var black=findChild(game,"produtoColor1"), white=findChild(game,"produtoColor2");
        var lesson=findChild(game,"produtoLesson"), hint=findChild(game,"produtoHint"), review=findChild(game,"produtoReview");
        ensure(mode!==null,"Tux mode exists"); activate(mode); ensure(textIn(game,"Contra Tux"));
        function cell(i) { return findChild(game,"produtoCell"+i); }
        function choose(i,color) { click(color===1?black:white); click(cell(i)); }
        var times=[],helpTimes=[];
        for(var level=0;level<3;++level) {
            ensure(textIn(difficulty,["Fácil","Médio","Difícil"][level]));
            choose(30,2);
            var started=Date.now(); mouseClick(confirm,confirm.width/2,confirm.height/2);
            tryVerify(function(){return textIn(game,"Participante 1") && !textIn(game,"pensa");},2000);
            times.push(Date.now()-started);
            ensure(stoneCount(game)===3,"Opening plus one complete legal Tux double turn");
            ensure(textIn(cell(30),"◇"),"Tux preserves human opening");
            activate(restart); if(level<2) activate(difficulty);
        }
        activate(lesson); ensure(textIn(game,"Introdução:")); ensure(!confirm.enabled);
        activate(lesson); ensure(textIn(game,"Exercício didático:"));
        ensure(textIn(game,"Brancas: 2 × 2 = 4"));
        activate(hint); ensure(textIn(game,"Pista 1:"));
        activate(hint); ensure(textIn(game,"Pista 2:"));
        activate(hint); ensure(textIn(game,"Pista 3:")); ensure(confirm.enabled);
        // Touch toggles a selected stone off and back on without committing a turn.
        var touch=cell(47);
        touchEvent(touch).press(0,touch,touch.width/2,touch.height/2).commit();
        touchEvent(touch).release(0,touch,touch.width/2,touch.height/2).commit(); wait(100);
        ensure(!confirm.enabled); choose(47,2); activate(confirm);
        ensure(textIn(game,"Certo!")); ensure(textIn(game,"Brancas: 5 × 0 = 0"));
        ensure(!textIn(game,"Venceu")); activate(restart);
        // Native complete 61-cell game: choose empty visible points, leave Tux real.
        heartbeat.start();
        var humanTurns=0;
        while(!textIn(game,"Venceu") && humanTurns<20) {
            var old=stoneCount(game), need=old===0?1:2, selected=0;
            for(var c=0;c<61 && selected<need;++c)
                if(!textIn(cell(c),"●") && !textIn(cell(c),"◇")) { choose(c,(humanTurns+selected)%2+1); ++selected; }
            ensure(confirm.enabled,"Complete human turn");
            var start=Date.now(); mouseClick(confirm,confirm.width/2,confirm.height/2);
            if(humanTurns===0) {
                var hs=Date.now(), help=icon(game,"bar_help.svg");mouseClick(help,help.width/2,help.height/2);
                tryCompare(pageView,"depth",3,1500); helpTimes.push(Date.now()-hs);
                keyClick(Qt.Key_Escape);tryCompare(pageView,"depth",2,2000);wait(1000);
            }
            tryVerify(function(){return !textIn(game,"pensa") && (textIn(game,"Participante 1") || textIn(game,"Venceu"));},2000);
            if(humanTurns>0) times.push(Date.now()-start);
            ensure(stoneCount(game)===old+need+(old+need<61?2:0),"Both complete turns add exactly their legal stones");
            ++humanTurns;
        }
        heartbeat.stop();
        ensure(longestBeat<250,"Heartbeat under 250ms");
        ensure(stoneCount(game)===61 && textIn(game,"Venceu"),"Full real match result");
        grabImage(pageView).save("__QA_OUTPUT__/result.png");
        activate(review); ensure(textIn(game,"Revisão didática da tua última decisão"));
        ensure(!textIn(game,"Venceu"));
        // Graded suggestion is a different full turn on the actual saved position.
        activate(hint);activate(hint);activate(hint);ensure(confirm.enabled);activate(confirm);
        ensure(textIn(game,"Comparação: original"));ensure(textIn(game,"Alternativa"));
        ensure(textIn(game,"O vencedor da partida mantém-se"));ensure(!textIn(game,"Venceu"));
        grabImage(pageView).save("__QA_OUTPUT__/review.png");
        activate(restart);choose(30,1);
        mouseClick(confirm,confirm.width/2,confirm.height/2);mouseClick(restart,restart.width/2,restart.height/2);wait(600);
        ensure(stoneCount(game)===0,"Restart discards pending reply");
        var window=game.Window.window;window.width=1100;window.height=700;wait(350);
        ensure(cell(30).width>=36,"Desktop targets");grabImage(pageView).save("__QA_OUTPUT__/desktop.png");
        window.width=600;window.height=900;wait(350);
        ensure(cell(30).width>=40,"Portrait targets");grabImage(pageView).save("__QA_OUTPUT__/portrait.png");
        choose(30,1);mouseClick(confirm,confirm.width/2,confirm.height/2);
        click(icon(game,"bar_home.svg"));tryCompare(pageView,"depth",1,2000);wait(700);
        card=null;
        for(var r=0;r<activitiesGrid.count;++r) {var current=activitiesGrid.itemAtIndex(r);if(current && textIn(current,"Produto")) card=current;}
        click(card);tryCompare(pageView,"depth",2,2000);wait(1000);game=activityLoader.item;
        ensure(stoneCount(game)===0,"Reopen discards stale reply");
        click(icon(game,"bar_home.svg"));tryCompare(pageView,"depth",1,2000);
        console.log("PRODUTO_TIMING",JSON.stringify({response_ms:times,help_ms:helpTimes,max_heartbeat_gap_ms:longestBeat}));
    }
    function cleanupTestCase() {
        if (qtest_results.failCount) grabImage(pageView).save("__QA_OUTPUT__/failure.png");
        console.log("NATIVE_RESULT", JSON.stringify({failures:qtest_results.failCount, passes:qtest_results.passCount}));
    }
}
