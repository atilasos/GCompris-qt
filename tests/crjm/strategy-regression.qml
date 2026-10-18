// SPDX-FileCopyrightText: NONE
// SPDX-License-Identifier: GPL-3.0-or-later
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

    name: "ExistingStrategyNative"
    when: activity.visible
    function textIn(item, text) {
        if (item.text !== undefined && String(item.text).indexOf(text) >= 0) return true;
        for (var i=0; i<item.children.length; ++i) if (textIn(item.children[i], text)) return true;
        return false;
    }
    function icon(item, suffix) {
        if (item.source !== undefined && String(item.source).endsWith(suffix)) return item;
        for (var i=0; i<item.children.length; ++i) { var found=icon(item.children[i],suffix); if(found)return found; }
        return null;
    }
    function countImages(item, suffix) {
        var count = item.source !== undefined && item.opacity > 0 && String(item.source).endsWith(suffix) ? 1 : 0;
        for(var i=0;i<item.children.length;++i) count+=countImages(item.children[i],suffix);
        return count;
    }
    function gridIn(item) {
        if(item.columns===7 && item.rows===6) return item;
        for(var i=0;i<item.children.length;++i) { var found=gridIn(item.children[i]); if(found)return found; }
        return null;
    }
    function click(item) { verify(item!==null); clickNative(item,item.width/2,item.height/2); wait(100); }
    function test_existing_strategy_from_menu() {
        wait(1500); click(section.itemAtIndex(section.count-1));
        clickNative(searchTextField,searchTextField.width/2,searchTextField.height/2);
        keyClick(Qt.Key_L); keyClick(Qt.Key_I); keyClick(Qt.Key_N); keyClick(Qt.Key_H); keyClick(Qt.Key_A);
        wait(900);
        var card=null;
        for(var i=0;i<activitiesGrid.count;++i) {
            var c=activitiesGrid.itemAtIndex(i);
            if(c && textIn(c,"com um amigo")) card=c;
        }
        verify(card!==null,"Existing two-player align-four remains in translated menu"); click(card);
        tryVerify(function(){return activityLoader.item && activityLoader.item.visible;},5000); wait(1000);
        var game=activityLoader.item;
        // A normal vertical win, clicking the actual existing columns.
        var board = icon(game,"background.svg"); verify(board!==null);
        var grid=gridIn(game); verify(grid!==null);
        for(var turn=0;turn<7;++turn) {
            var col=turn%2===0 ? 3 : 4;
            var point=grid.mapToItem(board,(col+0.5)*grid.width/7,grid.height/12);
            mouseMove(board,point.x,point.y); clickNative(board,point.x,point.y); wait(950);
        }
        console.log("STRATEGY_WIN_MARKS", countImages(game,"win1.svg"));
        tryVerify(function(){return countImages(game,"win1.svg")===4;},3000);
        grabImage(pageView).save("__QA_OUTPUT__/existing-align-four-win.png");
        wait(2500); click(icon(game,"bar_help.svg")); tryCompare(pageView,"depth",3,2000);
        verify(pageView.currentItem.content.length>0); keyClick(Qt.Key_Escape); tryCompare(pageView,"depth",2,2000); wait(1000);
        click(icon(game,"bar_home.svg")); tryCompare(pageView,"depth",1,2000); verify(pageView.currentItem.isMenu);
    }
    function cleanupTestCase() {
        if(qtest_results.failCount)grabImage(pageView).save("__QA_OUTPUT__/failure.png");
        console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount}));
    }
}
