// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"MemoryPlayerConfiguration"
    when:true
    property var saved: []
    function find(root,predicate) {
        if(predicate(root))return root;
        if(root.children)for(var child of root.children){var result=find(child,predicate);if(result)return result;}
        return null;
    }
    function checked(a,b,message){if(a!==b)console.log("CONFIG_FAILURE",a,b,message||"",new Error().stack);compare(a,b,message||"");}
    function click(item){verify(item!==null);mouseClick(item,item.width/2,item.height/2,Qt.LeftButton,Qt.NoModifier,0);}
    function test_choose_save_and_reload_both_player_modes() {
        wait(1600);
        ApplicationSettings.isAudioVoicesEnabled=true;ApplicationSettings.isAudioEffectsEnabled=true;
        if(audioNeededDialog.active){audioNeededDialog.item.forceActiveFocus();keyClick(Qt.Key_Escape);tryCompare(audioNeededDialog,"active",false,2000);}
        if(!activity.visible){keyClick(Qt.Key_Return);tryCompare(activity,"visible",true,2500);}
        for(var players of [2,1]) {
            wait(1000);
            click(find(bar,function(item){return item.source!==undefined&&String(item.source).endsWith('bar_activity_config.svg');}));
            tryCompare(dialogActivityConfig,"visible",true,2000);wait(600);
            console.log("CONFIG_OPEN");var panel=find(dialogActivityConfig,function(item){return item.modeBox!==undefined;});verify(panel!==null);
            console.log("CONFIG_PANEL",panel!==null);var box=panel.modeBox;
            checked(box.label,"Escolhe o número de jogadores");
            console.log("CONFIG_BOX",box.currentText);var label=find(box,function(item){return item.text!==undefined&&item.text===box.currentText;});click(label);
            wait(300);
            console.log("CONFIG_POPUP");keyClick(players===2?Qt.Key_Right:Qt.Key_Left);keyClick(Qt.Key_Return);wait(300);
            checked(box.currentIndex,players-1);
            grabImage(pageView).save("__QA_OUTPUT__/"+players+"players-configuration.png");
            console.log("CONFIG_SELECTION",box.currentIndex,box.currentText);dialogActivityConfig.forceActiveFocus();keyClick(Qt.Key_Return);
            tryCompare(dialogActivityConfig,"visible",false,2000);tryCompare(items,"playerCount",players,2000);
            checked(player2Score.visible,players===2);compare(items.selectionCount,0);
            var stored=ApplicationSettings.loadActivityConfiguration(activity.activityInfo.shortName());
            checked(Number(stored.mode),players);saved.push(players);
        }
    }
    function cleanupTestCase(){console.log("NATIVE_MEMORY_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,savedModes:saved}));}
}
