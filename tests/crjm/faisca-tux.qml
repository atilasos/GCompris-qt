// SPDX-License-Identifier: GPL-3.0-or-later
// Acceptance seam: real native menu, controls and observable board.
TestCase {
    id: nativeCase
    name: "FaiscaTuxNative"
    property double lastBeat: 0
    property double longestBeat: 0
    Timer { id: heartbeat; interval: 10; repeat: true; onTriggered: {
        var now = Date.now();
        if (nativeCase.lastBeat) nativeCase.longestBeat = Math.max(nativeCase.longestBeat, now - nativeCase.lastBeat);
        nativeCase.lastBeat = now;
    } }
    when: activity.visible
    function textIn(item, text) {
        if (item.text !== undefined && String(item.text).indexOf(text) >= 0) return true;
        for (var i=0; i<item.children.length; ++i) if (textIn(item.children[i], text)) return true;
        return false;
    }
    function icon(item, suffix) {
        if (item.source !== undefined && String(item.source).endsWith(suffix)) return item;
        for (var i=0; i<item.children.length; ++i) { var found=icon(item.children[i], suffix); if(found) return found; }
        return null;
    }
    function ensure(value, message) { if(!value) console.log("FAISCA_ASSERT_FAILED", message, new Error().stack); verify(value, message || ""); }
    function click(item) { ensure(item !== null, "Control exists"); mouseClick(item,item.width/2,item.height/2); wait(60); }
    function tabTo(button) {
        for(var k=0;k<30 && !button.activeFocus;++k) keyClick(Qt.Key_Tab);
        ensure(button.activeFocus,"Tab reaches "+button.objectName);
    }
    function activate(button) { tabTo(button); keyClick(Qt.Key_Space); wait(60); }
    function pieceCount(game, who) {
        var count=0;
        for(var i=0;i<30;++i) for(var d=0;d<4;++d) if(textIn(findChild(game,"faiscaCell"+i),who+" "+["↑","→","↓","←"][d])) count++;
        return count;
    }
    function test_complete_game() {
        wait(1500); click(section.itemAtIndex(section.count-1)); click(searchTextField);
        keyClick(Qt.Key_F); keyClick(Qt.Key_A); keyClick(Qt.Key_I); keyClick(Qt.Key_S); keyClick(Qt.Key_C); keyClick(Qt.Key_A); wait(800);
        var card=null;
        for(var i=0;i<activitiesGrid.count;++i) { var c=activitiesGrid.itemAtIndex(i); if(c && textIn(c,"Faísca")) card=c; }
        ensure(card !== null,"Faísca discoverable from menu"); click(card);
        tryVerify(function(){return activityLoader.item && activityLoader.item.visible;},5000); wait(1200);
        var game=activityLoader.item, board=findChild(game,"faiscaBoard"), confirm=findChild(game,"confirmFaisca");
        ensure(board !== null); ensure(textIn(game,"Participante 1"));
        var mode=findChild(game,"tuxMode"), difficulty=findChild(game,"difficultyFaisca"), restart=findChild(game,"restartFaisca");
        ensure(mode !== null,"Tux mode available"); activate(mode); ensure(textIn(game,"Tu · 1"));
        // Real local policies each produce a complete arrow from the mandatory cell.
        var times=[];
        for(var level=0;level<3;++level) {
            ensure(textIn(difficulty,["Fácil","Médio","Difícil"][level]));
            click(findChild(game,"faiscaCell2")); click(findChild(game,"distance1")); click(findChild(game,"direction2"));
            var start=Date.now(); mouseClick(confirm,confirm.width/2,confirm.height/2);
            tryVerify(function(){return textIn(game,"Tu · 1") || textIn(game,"Venceu");},2000);
            times.push(Date.now()-start);
            ensure(pieceCount(game,1)===1 && pieceCount(game,2)===1,"One complete legal Tux arrow");
            ensure(textIn(findChild(game,"faiscaCell8"),"2 "),"Tux uses mandatory arrival");
            activate(restart); if(level<2) activate(difficulty);
        }
        activate(findChild(game,"learnFaisca")); ensure(textIn(game,"Introdução:"));
        ensure(!confirm.enabled); activate(findChild(game,"lessonNext")); ensure(textIn(game,"Exercício didático"));
        var hint=findChild(game,"hintFaisca");
        activate(hint); ensure(textIn(game,"Conta a distância"));
        activate(hint); ensure(textIn(game,"Procura uma seta"));
        activate(hint); ensure(textIn(game,"A pista não confirma")); ensure(textIn(game,"linha 2, coluna 3"),"Exercise hint targets requested arrival"); ensure(pieceCount(game,1)===0);
        var cell=findChild(game,"faiscaCell2"), gesture=touchEvent(cell);
        gesture.press(0,cell,cell.width/2,cell.height/2).commit(); wait(60);
        gesture.release(0,cell,cell.width/2,cell.height/2).commit(); wait(150);
        activate(findChild(game,"distance1")); activate(findChild(game,"direction2")); activate(confirm);
        ensure(textIn(game,"Correto!")); ensure(!textIn(game,"Venceu")); activate(restart);
        // Play the full CRJM match through ordinary controls and graded hints.
        click(findChild(game,"faiscaCell2")); click(findChild(game,"distance1")); click(findChild(game,"direction2"));
        var moves=0, helpTimes=[];
        heartbeat.start();
        while(!textIn(game,"Venceu") && moves<15) {
            var oldTux=pieceCount(game,2), oldUs=pieceCount(game,1);
            ensure(confirm.enabled,"Human has a legal complete selection");
            var expectedTux=-1;
            for(var target=0;target<30;++target) if(textIn(findChild(game,"faiscaCell"+target),"↳")) expectedTux=target;
            ensure(expectedTux>=0,"Arrow destination visible before confirmation");
            var started=Date.now(); mouseClick(confirm,confirm.width/2,confirm.height/2);
            if(moves===0) {
                var helpStart=Date.now(); var help=icon(game,"bar_help.svg"); mouseClick(help,help.width/2,help.height/2);
                tryCompare(pageView,"depth",3,1500); helpTimes.push(Date.now()-helpStart);
                keyClick(Qt.Key_Escape); tryCompare(pageView,"depth",2,2000); wait(1000);
            }
            tryVerify(function(){return textIn(game,"Tu · 1") || textIn(game,"Venceu");},2000);
            times.push(Date.now()-started);
            ensure(pieceCount(game,1)===oldUs+1,"Confirmed human arrow survives help");
            ensure(pieceCount(game,2)===oldTux+1 || (textIn(game,"Venceu") && pieceCount(game,2)===oldTux),"Tux only places one complete arrow");
            if(pieceCount(game,2)===oldTux+1) ensure(textIn(findChild(game,"faiscaCell"+expectedTux),"2 "),"Tux follows previous arrow exactly");
            moves++;
            if(!textIn(game,"Venceu")) {click(hint);click(hint);click(hint);ensure(confirm.enabled);}
        }
        heartbeat.stop(); ensure(longestBeat<250,"Native UI heartbeat below 250ms");
        ensure(textIn(game,"Venceu")); ensure(textIn(game,"ficou sem jogada válida"));
        grabImage(pageView).save("__QA_OUTPUT__/result.png");
        activate(findChild(game,"reviewFaisca")); ensure(textIn(game,"Revisão da tua primeira decisão"));
        click(findChild(game,"faiscaCell2")); click(findChild(game,"direction1")); click(findChild(game,"distance1")); activate(confirm);
        ensure(textIn(game,"Revisão concluída:"));ensure(textIn(game,"opções a Tux"));ensure(!textIn(game,"Venceu"));
        grabImage(pageView).save("__QA_OUTPUT__/review.png");
        // Restart and leaving discard late worker replies without any test state mutation.
        activate(restart); click(findChild(game,"faiscaCell2"));click(findChild(game,"direction2"));
        mouseClick(confirm,confirm.width/2,confirm.height/2);mouseClick(restart,restart.width/2,restart.height/2);wait(400);
        ensure(pieceCount(game,1)===0 && pieceCount(game,2)===0,"Restart discards pending reply");ensure(textIn(game,"Tu · 1"));
        var window=game.Window.window;window.width=1100;window.height=700;wait(350);
        ensure(board.width/6>=40,"Desktop targets");grabImage(pageView).save("__QA_OUTPUT__/desktop.png");
        window.width=600;window.height=900;wait(350);ensure(board.width/6>=40,"Portrait targets");
        ensure(confirm.mapToItem(game,0,0).y+confirm.height<=game.height);grabImage(pageView).save("__QA_OUTPUT__/portrait.png");
        click(findChild(game,"faiscaCell2"));click(findChild(game,"direction2"));mouseClick(confirm,confirm.width/2,confirm.height/2);
        click(icon(game,"bar_home.svg"));tryCompare(pageView,"depth",1,2000);wait(1000);ensure(pageView.currentItem.isMenu);
        // Resizing the menu can recreate its delegates; use its current card.
        card=null;
        for(var reopen=0;reopen<activitiesGrid.count;++reopen) {
            var current=activitiesGrid.itemAtIndex(reopen);if(current && textIn(current,"Faísca")) card=current;
        }
        click(card);tryCompare(pageView,"depth",2,2000);wait(1200);game=activityLoader.item;
        ensure(pieceCount(game,1)===0 && pieceCount(game,2)===0,"Reopened activity has no reply from previous match");
        ensure(textIn(findChild(game,"reserve2"),"1: 5 · 2: 5 · 3: 5"));
        click(icon(game,"bar_home.svg"));tryCompare(pageView,"depth",1,2000);
        console.log("FAISCA_TIMING",JSON.stringify({response_ms:times,help_ms:helpTimes,max_heartbeat_gap_ms:longestBeat}));
    }
    function cleanupTestCase() {
        if(qtest_results.failCount)grabImage(pageView).save("__QA_OUTPUT__/failure.png");
        console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount}));
    }
}
