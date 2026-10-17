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

    id:nexCase
    name: "NexTuxNative"
    property double heartbeatAt: 0
    property double heartbeatMax: 0
    property double replyMax: 0
    property bool measuring: false
    property double dispatchAt: 0
    property int lockedChecks: 0
    Timer { interval:20;repeat:true;running:true;onTriggered:{var now=Date.now();if(nexCase.measuring&&nexCase.heartbeatAt)nexCase.heartbeatMax=Math.max(nexCase.heartbeatMax,now-nexCase.heartbeatAt);nexCase.heartbeatAt=now;} }
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
    function click(item) { ensure(item !== null); clickNative(item, item.width / 2, item.height / 2); wait(60); }
    function test_menu_to_complete_game() {
        wait(1500);
        var search = section.itemAtIndex(section.count - 1);
        click(search);
        clickNative(searchTextField, searchTextField.width / 2, searchTextField.height / 2);
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
        var confirm=findChild(game,"confirmNex"),restart=findChild(game,"restartNex"),mode=findChild(game,"tuxNex");
        var difficulty=findChild(game,"difficultyNex"),hint=findChild(game,"hintNex"),lesson=findChild(game,"lessonNex");
        function tabClick(target) {
            board.forceActiveFocus();
            for(var t=0;t<35&&!target.activeFocus;++t)keyClick(Qt.Key_Tab);
            ensure(target.activeFocus,"Tab reaches "+target.objectName);keyClick(Qt.Key_Space);wait(35);
        }
        function cell(i) {return findChild(game,"nexCell"+i);}
        function select(i,touch) {
            var c=cell(i);
            viewport.contentX=Math.max(0,Math.min(viewport.contentWidth-viewport.width,c.x+c.width/2-viewport.width/2));
            viewport.contentY=Math.max(0,Math.min(viewport.contentHeight-viewport.height,c.y+c.height/2-viewport.height/2));wait(15);
            if(touch){touchEvent(c).press(0,c,c.width/2,c.height/2).commit();touchEvent(c).release(0,c,c.width/2,c.height/2).commit();wait(30);}
            else click(c);
        }
        function play(a,b) {
            select(a);select(b);ensure(confirm.enabled);measuring=true;dispatchAt=Date.now();
            clickNative(confirm,confirm.width/2,confirm.height/2);
            if(textIn(game,"Tux pensa")) {
                ensure(!confirm.enabled&&!findChild(game,"swapNex").enabled&&!findChild(game,"replaceNex").enabled&&!findChild(game,"placeNex").enabled,"Human cannot act for Tux");
                ++lockedChecks;
            }
            wait(30);
        }
        function result() {return textIn(game,"Venceu o participante")||textIn(game,"Empate!");}
        function reply() {
            var begin=dispatchAt;
            tryVerify(function(){return textIn(game,"Participante 1")||result();},2000);
            replyMax=Math.max(replyMax,Date.now()-begin);measuring=false;
            ensure(!textIn(game,"Tux pensa"),"Tux completes legal action");
        }
        ensure(mode!==null);tabClick(mode);ensure(textIn(game,"Contra Tux"));
        ensure(textIn(game,"Tux = participante 2"),"Tux identity is explicit");
        // Learn complete actions, preserving normal game rules and no synthetic winner.
        tabClick(lesson);ensure(textIn(game,"Introdução:"));ensure(!confirm.enabled);
        tabClick(findChild(game,"continueNex"));ensure(textIn(game,"Exercício 1"));
        tabClick(hint);ensure(textIn(game,"Pista 1:"));tabClick(hint);ensure(textIn(game,"Pista 2:"));tabClick(hint);ensure(confirm.enabled);
        select(61);ensure(!confirm.enabled);select(61,true);tabClick(confirm);ensure(textIn(game,"Colocaste uma peça própria"));
        tabClick(findChild(game,"continueNex"));ensure(textIn(game,"Exercício 2"));
        select(60);select(61);select(49);tabClick(confirm);ensure(textIn(game,"São três mudanças"));
        tabClick(findChild(game,"continueNex"));select(65);select(0);tabClick(confirm);
        ensure(textIn(game,"Ligação completa!"));ensure(!result());tabClick(restart);
        // Easy full legal transcript against real Tux: human connects N–S.
        heartbeatMax=0;heartbeatAt=Date.now();
        for(var k=0;k<11;++k){play(55+k,99+k);if(k<10)reply();}
        measuring=false;ensure(textIn(game,"Venceu o participante 1!"));
        ensure(findChild(game,"reviewNex").enabled);
        grabImage(pageView).save("__QA_OUTPUT__/easy-result.png");
        tabClick(findChild(game,"reviewNex"));ensure(textIn(game,"última decisão real"));
        tabClick(hint);tabClick(hint);tabClick(hint);ensure(confirm.enabled);tabClick(confirm);
        ensure(textIn(game,"Comparação:"));ensure(textIn(game,"Original:"));ensure(textIn(game,"Alternativa:"));ensure(textIn(game,"O resultado da partida mantém-se: participante 1"));
        grabImage(pageView).save("__QA_OUTPUT__/review.png");
        tabClick(difficulty);ensure(textIn(game,"Médio:"));play(0,120);reply();
        ensure(textIn(game,"Participante 1"));
        tabClick(difficulty);ensure(textIn(game,"Difícil:"));
        play(60,61);reply();ensure(textIn(game,"P1: ◇ O ↔ E"));ensure(textIn(game,"P2: ● N ↔ S"));ensure(textIn(cell(60),"●"));
        // Real hard match after swap. Selections come only from visible symbols.
        var rounds=0;
        while(!result()&&rounds++<130) {
            var empty=[],neutral=[],owned=[];
            for(var i=0;i<121;++i){if(textIn(cell(i),"+"))neutral.push(i);else if(textIn(cell(i),"◇"))owned.push(i);else if(!textIn(cell(i),"●"))empty.push(i);}
            if(empty.length>=2){click(findChild(game,"placeNex"));play(empty[0],empty[1]);}
            else {ensure(neutral.length>=2&&owned.length>0,"Full board still supports substitution");click(findChild(game,"replaceNex"));select(neutral[0]);select(neutral[1]);select(owned[0]);ensure(confirm.enabled);click(confirm);}
            if(!result())reply();
        }
        measuring=false;ensure(result(),"Hard match reaches natural connection/convention result");ensure(findChild(game,"reviewNex").enabled);
        grabImage(pageView).save("__QA_OUTPUT__/hard-result.png");
        tabClick(findChild(game,"reviewNex"));tabClick(hint);tabClick(hint);tabClick(hint);tabClick(confirm);ensure(textIn(game,"Comparação:"));
        // Restart and leave immediately after dispatch: no late moves in fresh game.
        click(restart);select(0);select(120);clickNative(confirm,confirm.width/2,confirm.height/2);clickNative(restart,restart.width/2,restart.height/2);wait(2100);
        ensure(textIn(game,"Participante 1"));ensure(!textIn(cell(0),"●"));ensure(!textIn(cell(120),"+"));
        select(0);select(120);dispatchAt=Date.now();clickNative(confirm,confirm.width/2,confirm.height/2);
        var beforeHelp=Date.now(),help=icon(game,"bar_help.svg");clickNative(help,help.width/2,help.height/2);tryCompare(pageView,"depth",3,1500);var helpMs=Date.now()-beforeHelp;ensure(helpMs<=1500);keyClick(Qt.Key_Escape);tryCompare(pageView,"depth",2,1500);wait(1200);tryVerify(function(){return textIn(game,"Participante 1")||result();},2000);
        ensure(textIn(cell(0),"●"));
        click(restart);var window=game.Window.window;window.width=1100;window.height=760;wait(300);if(findChild(game,"zoomNex").text === "Ampliar") click(findChild(game,"zoomNex"));ensure(cell(60).width>=40);grabImage(pageView).save("__QA_OUTPUT__/desktop.png");
        window.width=600;window.height=900;wait(300);ensure(cell(60).width>=40);ensure(restart.mapToItem(game,0,0).y+restart.height<=game.height);grabImage(pageView).save("__QA_OUTPUT__/portrait.png");
        select(0,true);select(120);clickNative(confirm,confirm.width/2,confirm.height/2);
        var home=icon(game,"bar_home.svg");clickNative(home,home.width/2,home.height/2);tryCompare(pageView,"depth",1,2000);wait(2100);
        console.log("NEX_STAGE","left while computing");click(card);tryVerify(function(){return activityLoader.item&&activityLoader.item.visible;},5000);wait(1500);game=activityLoader.item;
        ensure(textIn(game,"Participante 1"));ensure(!textIn(findChild(game,"nexCell0"),"●"));
        console.log("NEX_STAGE","reopened",pageView.depth);click(icon(game,"bar_home.svg"));tryCompare(pageView,"depth",1,3000);
        console.log("NEX_TIMINGS",JSON.stringify({replyMaxMs:replyMax,heartbeatMaxMs:heartbeatMax,hardRounds:rounds,lockedChecks:lockedChecks,helpMs:helpMs}));
        ensure(lockedChecks>0,"Observed disabled controls during real Tux calculation");
        ensure(replyMax<=2000,"Tux response budget");ensure(heartbeatMax<=250,"Event loop heartbeat budget");
    }
    function cleanupTestCase() {
        if (qtest_results.failCount) grabImage(pageView).save("__QA_OUTPUT__/failure.png");
        console.log("NATIVE_RESULT", JSON.stringify({failures:qtest_results.failCount, passes:qtest_results.passCount}));
    }
}
