// SPDX-FileCopyrightText: NONE
// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name: "CrjmUiScale"
 when: activity.visible
 function textIn(item,text) { if(item.text!==undefined&&String(item.text).indexOf(text)>=0)return true;for(var i=0;i<item.children.length;i++)if(textIn(item.children[i],text))return true;return false; }
 function test_large_screen() {
  wait(1800);verify(Screen.width===2048&&Screen.height===1152,"Large primary screen is active"); var win=activity.Window.window;win.width=2048;win.height=1100;wait(300);
  var search=section.itemAtIndex(section.count-1);mouseClick(search,search.width/2,search.height/2);mouseClick(searchTextField,20,20);keyClick(Qt.Key_F);keyClick(Qt.Key_A);keyClick(Qt.Key_I);keyClick(Qt.Key_S);keyClick(Qt.Key_C);wait(800);
  var card=null;for(var i=0;i<activitiesGrid.count;i++){var c=activitiesGrid.itemAtIndex(i);if(c&&textIn(c,"Faísca"))card=c;}verify(card!==null);mouseClick(card,card.width/2,card.height/2);wait(1200);
  var game=activityLoader.item,board=findChild(game,"faiscaBoard");verify(board!==null);grabImage(pageView).save("__QA_OUTPUT__/faisca-large.png");
  console.log("UI_GEOMETRY",JSON.stringify({width:win.width,height:win.height,fontRatio:ApplicationInfo.fontRatio,ratio:ApplicationInfo.ratio,boardWidth:board.width,boardHeight:board.height}));
  verify(board.width>=550,"A playable board must remain visible on a large screen");
 }
 function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount}));}
}
