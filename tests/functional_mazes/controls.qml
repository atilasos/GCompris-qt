// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "MazePortugueseControlsAndResources"
    when: activity.visible && mazeRepeater.count>0
    property var observations: ({})
    function find(root,suffix) {
        if(root.source!==undefined && String(root.source).endsWith(suffix))return root;
        if(root.children)for(var child of root.children){var found=find(child,suffix);if(found)return found;}
        return null;
    }
    function icon(root,suffix) {wait(1600);var button=find(root,suffix);verify(button!==null,suffix);mouseClick(button);}
    function test_controls_help_focus_and_resources() {
        wait(1600);compare(activity.numberOfLevel,25);
        var titles={maze:"Labirinto",mazeinvisible:"Labirinto invisível",mazerelative:"Labirinto relativo"};
        var activityName=activity.activityInfo.shortName();compare(activity.activityInfo.title,titles[activityName]);
        icon(bar,"bar_next.svg");tryCompare(activity,"currentLevel",1);
        icon(bar,"bar_previous.svg");tryCompare(activity,"currentLevel",0);wait(600);
        mouseClick(fastmode);wait(200);compare(shoes.visible,true);
        mouseClick(fastmode);wait(200);compare(shoes.visible,false);
        if(activity.invisibleMode) {
            mouseClick(switchMaze);wait(200);compare(message.visible,true);
            verify(message.text.length>20 && message.text.indexOf("Look at")<0);
            mouseClick(switchMaze);wait(200);compare(message.visible,false);
        }
        var depth=pageView.depth;
        icon(bar,"bar_help.svg");tryCompare(pageView,"depth",depth+1);wait(600);
        var help=pageView.currentItem;compare(help.title,titles[activityName]);
        verify(help.content.indexOf(activity.activityInfo.description)>=0);
        verify(help.content.indexOf("Use the arrow keys")<0 && help.content.indexOf("You cannot move")<0);
        grabImage(pageView).save("__QA_OUTPUT__/help.png");
        keyClick(Qt.Key_Escape);tryCompare(pageView,"depth",depth);wait(600);
        // A visible rotation change proves keyboard focus survives the dialog.
        var previous=player.rotation;
        keyClick(Qt.Key_Right);wait(300);
        if(Math.abs(previous-player.rotation)<1) {keyClick(Qt.Key_Left);wait(300);}
        verify(Math.abs(previous-player.rotation)>1,"Actual arrow events rotate the player after help");
        var reader=Qt.createQmlObject('import core 1.0; File {}',this),resources=[];
        var images=[activityBackground,player,shoes,door,fastmode,switchMaze];
        var hint=find(activityBackground,"arrows_move.svg");verify(hint!==null);images.push(hint);
        for(var image of images) {
            compare(image.status,Image.Ready);
            var source=String(image.source);
            if(resources.indexOf(source)>=0)continue;resources.push(source);
            verify(reader.copy(source,"file://__QA_OUTPUT__/"+source.slice(source.lastIndexOf("/")+1)));
        }
        var audio=String(brickSound.source);verify(audio.endsWith("brick.wav"));
        verify(reader.copy(audio,"file://__QA_OUTPUT__/brick.wav"));resources.push(audio);
        observations={activity:activityName,levels:25,navigation:true,fastToggle:true,
                      mapToggle:activity.invisibleMode,helpEscape:true,focusAfterHelp:true,resources:resources};
        ActivityInfoTree.startingActivity="";icon(bar,"bar_home.svg");tryCompare(pageView,"depth",1);
        verify(pageView.currentItem.isMenu);grabImage(pageView).save("__QA_OUTPUT__/menu.png");
    }
    function cleanupTestCase(){console.log("NATIVE_MAZE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,controls:observations}));}
}
