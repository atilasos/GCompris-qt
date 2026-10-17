// SPDX-License-Identifier: GPL-3.0-or-later
// Acceptance seam: real native menu, controls and observable board.
TestCase {
    name: "FaiscaNative"
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
    function test_complete_game() {
        wait(1500); click(section.itemAtIndex(section.count-1)); click(searchTextField);
        keyClick(Qt.Key_F); keyClick(Qt.Key_A); keyClick(Qt.Key_I); keyClick(Qt.Key_S); keyClick(Qt.Key_C); keyClick(Qt.Key_A); wait(800);
        var card=null;
        for(var i=0;i<activitiesGrid.count;++i) { var c=activitiesGrid.itemAtIndex(i); if(c && textIn(c,"Faísca")) card=c; }
        ensure(card !== null,"Faísca discoverable from menu"); click(card);
        tryVerify(function(){return activityLoader.item && activityLoader.item.visible;},5000); wait(1200);
        var game=activityLoader.item, board=findChild(game,"faiscaBoard"), confirm=findChild(game,"confirmFaisca");
        ensure(board !== null); ensure(textIn(game,"Participante 1"));
        // Invalid endpoint preserves reserve and turn; direction/distance are editable.
        click(findChild(game,"faiscaCell2")); click(findChild(game,"direction0"));
        ensure(!confirm.enabled); ensure(textIn(game,"Destino inválido")); ensure(textIn(game,"1: 5 · 2: 5 · 3: 5"));
        click(findChild(game,"direction2")); click(findChild(game,"distance2")); click(findChild(game,"distance1"));
        ensure(confirm.enabled); ensure(textIn(game,"Destino: linha 2, coluna 3"));
        grabImage(pageView).save("__QA_OUTPUT__/preview.png");
        // Keyboard confirmation and fixed independently verified CRJM transcript.
        board.forceActiveFocus(); keyClick(Qt.Key_Return); wait(60);
        ensure(textIn(findChild(game,"faiscaCell2"),"1 ↓1")); ensure(textIn(game,"Participante 2"));
        click(findChild(game,"faiscaCell0")); ensure(textIn(game,"casa obrigatória")); ensure(!confirm.enabled);
        click(icon(game,"bar_help.svg")); tryCompare(pageView,"depth",3,2000);
        ensure(pageView.currentItem.content.indexOf("saltar")>=0); grabImage(pageView).save("__QA_OUTPUT__/help.png");
        keyClick(Qt.Key_Escape); tryCompare(pageView,"depth",2,2000); wait(1000);
        ensure(textIn(findChild(game,"faiscaCell2"),"1 ↓1")); ensure(textIn(game,"Participante 2"));
        // Occupied endpoint cannot consume a piece or change the participant.
        click(findChild(game,"faiscaCell8")); click(findChild(game,"direction0"));
        ensure(!confirm.enabled); ensure(textIn(game,"Destino inválido"));
        ensure(textIn(findChild(game,"reserve2"),"1: 5 · 2: 5 · 3: 5"));
        var moves=[[8,1,3],[7,2,2],[19,1,3],[18,3,1],[21,1,0],[15,2,1],[17,1,3],[16,1,2],[22,1,1],[23,3,3]];
        for(var m=0;m<moves.length;++m) {
            var cell=findChild(game,"faiscaCell"+moves[m][0]);
            if(m===0) {var gesture=touchEvent(cell); gesture.press(0,cell,cell.width/2,cell.height/2).commit(); wait(60); gesture.release(0,cell,cell.width/2,cell.height/2).commit(); wait(200);} else click(cell);
            click(findChild(game,"distance"+moves[m][1])); click(findChild(game,"direction"+moves[m][2]));
            ensure(confirm.enabled,"Legal reference move "+m); click(confirm);
        }
        ensure(textIn(game,"Venceu o participante 1!")); ensure(textIn(game,"participante 2 ficou sem jogada válida"));
        ensure(textIn(findChild(game,"faiscaCell23"),"1 ←3")); ensure(!confirm.enabled);
        ensure(textIn(findChild(game,"reserve2"),"1: 0 · 2: 5 · 3: 5"));
        grabImage(pageView).save("__QA_OUTPUT__/result.png");
        tabTo(findChild(game,"restartFaisca")); keyClick(Qt.Key_Space); wait(80); ensure(textIn(game,"Participante 1")); ensure(!textIn(findChild(game,"faiscaCell2"),"1 ↓1"));
        ensure(textIn(findChild(game,"reserve2"),"1: 5 · 2: 5 · 3: 5"));
        board.forceActiveFocus(); keyClick(Qt.Key_Right); keyClick(Qt.Key_Space); keyClick(Qt.Key_2); keyClick(Qt.Key_D);
        tabTo(findChild(game,"distance2")); keyClick(Qt.Key_Space);
        tabTo(findChild(game,"direction1")); keyClick(Qt.Key_Space);
        tabTo(confirm); keyClick(Qt.Key_Space); wait(80);
        ensure(textIn(findChild(game,"faiscaCell1"),"1 →2"));
        var window=game.Window.window; window.width=1100;window.height=700;wait(350);
        ensure(board.width/6>=40); grabImage(pageView).save("__QA_OUTPUT__/desktop.png");
        window.width=600;window.height=900;wait(350);ensure(board.width/6>=40);
        ensure(confirm.mapToItem(game,0,0).y+confirm.height<=game.height);grabImage(pageView).save("__QA_OUTPUT__/portrait.png");
        click(icon(game,"bar_home.svg"));tryCompare(pageView,"depth",1,2000);ensure(pageView.currentItem.isMenu);
    }
    function cleanupTestCase() {
        if(qtest_results.failCount)grabImage(pageView).save("__QA_OUTPUT__/failure.png");
        console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount}));
    }
}
