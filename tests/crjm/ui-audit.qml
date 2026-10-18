// SPDX-FileCopyrightText: NONE
// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "CrjmNativeUiAudit"
    when: activity.visible
    function exact(item, text) {
        if (item.text !== undefined && String(item.text).trim() === text) return true;
        for (var i=0;i<item.children.length;++i) if(exact(item.children[i],text))return true;
        return false;
    }
    function contains(item, text) {
        if (item.text !== undefined && String(item.text).indexOf(text)>=0)return true;
        for(var i=0;i<item.children.length;++i)if(contains(item.children[i],text))return true;
        return false;
    }
    function icon(item,suffix) {
        if(item.source!==undefined&&String(item.source).endsWith(suffix))return item;
        for(var i=0;i<item.children.length;++i){var r=icon(item.children[i],suffix);if(r)return r;}return null;
    }
    function click(item) {
        verify(item!==null);
        var area=item.parent;
        while(area){if(area.objectName==="boardGameToolsViewport"){
            var pos=item.mapToItem(area.contentItem,0,0);
            if(pos.y<area.contentY||pos.y+item.height>area.contentY+area.height)
                area.contentY=Math.max(0,Math.min(area.contentHeight-area.height,pos.y-8));
            break;
        }area=area.parent;}
        mouseClick(item,item.width/2,item.height/2);wait(80);
    }
    function check(value,message){if(!value)console.log("UI_ASSERT_FAILED",message);verify(value,message);}
    function test_every_activity() {
        wait(1600);
        check(Screen.width===2048&&Screen.height===1152,"The configured primary screen, not only the window, is large");
        var cases=[
            ["DOMIN","Dominório","dominorioBoard","dominoCell0","confirmDomino"],
            ["GATOS","Gatos & Cães","gatosCaesBoard","gatosCell27",""],
            ["FAISC","Faísca","faiscaBoard","faiscaCell0","confirmFaisca"],
            ["QUELHAS","Quelhas","quelhasBoard","quelhasCell0","confirmQuelhas"],
            ["ATARI","Atari Go","atariBoard","atariPoint0",""],
            ["PRODUTO","Produto","produtoBoard","produtoCell0","confirmProduto"],
            ["Y","Y","yBoard","yNodeA1",""],
            ["NEX","Nex","nexBoard","nexCell0","confirmNex"]
        ];
        var win=activity.Window.window;
        for(var n=0;n<cases.length;++n){
            var c=cases[n];win.width=1280;win.height=800;ApplicationSettings.baseFontSize=0;wait(150);
            click(section.itemAtIndex(section.count-1));mouseClick(searchTextField,20,20);keyClick(Qt.Key_A,Qt.ControlModifier);keyClick(Qt.Key_Backspace);
            for(var k=0;k<c[0].length;k++)keyClick(c[0].charCodeAt(k));if(c[0]==="Y"){keyClick(Qt.Key_Slash);keyClick(Qt.Key_Y);}wait(650);
            var card=null;for(var d=0;d<activitiesGrid.count;d++){var candidate=activitiesGrid.itemAtIndex(d);if(candidate&&exact(candidate,c[1]))card=candidate;}
            check(card!==null,c[1]+" card exists");click(card);tryVerify(function(){return activityLoader.item&&activityLoader.item.visible;},5000);wait(650);
            var game=activityLoader.item,board=findChild(game,c[2]);check(board!==null,c[1]+" board exists");
            var sizes=[[2048,1100],[1280,800],[800,600],[600,900]];
            for(var font=-7;font<=7;font+=7)for(var size=0;size<sizes.length;size++){
                ApplicationSettings.baseFontSize=font;win.width=sizes[size][0];win.height=sizes[size][1];wait(180);
                var viewport=findChild(game,"boardGameToolsViewport");
                check(viewport!==null,"Tools have their own bounded scrolling area");
                var point=board.mapToItem(game,0,0);
                console.log("UI_AUDIT",JSON.stringify({game:c[1],width:win.width,height:win.height,font:font,fontRatio:ApplicationInfo.fontRatio,boardWidth:board.width,boardHeight:board.height,boardX:point.x,boardY:point.y,toolsWidth:viewport.width,toolsHeight:viewport.height}));
                check(board.width>=320&&board.height>=320,c[1]+" keeps a substantial game area");
                if(c[0]==="Y"||c[0]==="NEX") {
                    var vp=findChild(game,c[0]==="Y"?"yViewport":"nexViewport");
                    check(board.width<=vp.width+1&&board.height<=vp.height+1,"Overview shows the entire graph without scrolling");
                }
                check(viewport.width>=240&&viewport.height>=140,c[1]+" tools remain usable");
                if(size===0||font===7)grabImage(pageView).save("__QA_OUTPUT__/"+c[0]+"-"+sizes[size][0]+"-font"+font+".png");
            }
            if(c[0]==="Y"||c[0]==="NEX") {
                var zoom=findChild(game,c[0]==="Y"?"zoomY":"zoomNex");click(zoom);
                var target=findChild(game,c[3]);check(target.width>=40,"Enlarged board provides touch targets");
                grabImage(pageView).save("__QA_OUTPUT__/"+c[0]+"-600-zoom.png");click(zoom);
            }
            ApplicationSettings.baseFontSize=0;win.width=1280;win.height=800;wait(150);
            var cell=findChild(game,c[3]);
            // Existing board coordinates come from the visible native controls.
            if(c[0]==="NEX"){
                var vp=findChild(game,"nexViewport");vp.contentX=0;vp.contentY=0;
            }
            click(cell);
            if(c[0]==="FAISC") {
                click(findChild(game,"faiscaCell1"));check(findChild(game,c[4]).enabled,"Destination is previewed");
                click(findChild(game,"clearFaisca"));check(!findChild(game,c[4]).enabled,"Preview can be cancelled without playing");
                click(cell);click(findChild(game,"faiscaCell12"));
            }
            if(c[0]==="QUELHAS")click(findChild(game,"quelhasCell10"));
            if(c[0]==="NEX")click(findChild(game,"nexCell11"));
            if(c[4])click(findChild(game,c[4]));
            check(contains(game,"Participante 2"),c[1]+" accepts the first complete turn");
            if(c[0]==="FAISC")check(contains(findChild(game,"faiscaCell0"),"↓2"),"Selecting the destination chooses its distance and direction");
            grabImage(pageView).save("__QA_OUTPUT__/"+c[0]+"-opening.png");
            click(icon(game,"bar_help.svg"));tryCompare(pageView,"depth",3,2000);keyClick(Qt.Key_Escape);tryCompare(pageView,"depth",2,2000);wait(1050);
            check(contains(game,"Participante 2"),"Help preserves the turn");
            var modeNames=["tuxMode","tuxModeGatos","tuxMode","tuxQuelhas","tuxAtari","produtoMode","tuxY","tuxNex"];
            click(findChild(game,modeNames[n]));
            for(var t=0;t<2;t++){
                win.width=t?600:2048;win.height=t?900:1100;ApplicationSettings.baseFontSize=7;wait(180);
                check(board.width>=320&&board.height>=320,"Tux options preserve the game area");
                grabImage(pageView).save("__QA_OUTPUT__/"+c[0]+"-tux-"+win.width+".png");
            }
            click(icon(game,"bar_home.svg"));tryCompare(pageView,"depth",1,2500);wait(900);
        }
    }
    function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save("__QA_OUTPUT__/failure.png");console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount}));}
}
