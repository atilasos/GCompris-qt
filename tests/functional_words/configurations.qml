// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"NativeWordSpeedsVirtualKeyboardAndRestart"
    when: items.numberOfLevel>0 && activity.visible
    property var configurations: []
    function findKey(item,text) {
        if(item.specialKey!==undefined && item.text!==undefined && item.text===text)return item;
        if(item.children)for(var i=0;i<item.children.length;i++) {
            var found=findKey(item.children[i],text);if(found!==null)return found;
        }
        return null;
    }
    function clickCharacter(text) {
        var key=null;
        tryVerify(function(){key=findKey(keyboard,text);return key!==null;},2000);
        verify(key.visible && key.enabled);
        mouseClick(key,key.width/2,key.height/2,Qt.LeftButton,Qt.NoModifier,0);
    }
    function test_ten_speeds_two_modes_virtual_keys_and_restart() {
        wait(1600);ApplicationSettings.isVirtualKeyboard=true;
        for(var upper of [false,true]) {
            var previousInterval=Infinity;
            for(var setting=1;setting<=10;setting++) {
                activityBackground.stop();activity.uppercaseOnly=upper;
                activity.speedSetting=setting;activityBackground.start();
                tryCompare(keyboard,"visible",true,3000);wait(600);
                compare(items.currentLevel,0);compare(items.score.currentSubLevel,0);
                var interval=items.wordDropTimer.interval;
                verify(interval>0 && interval<previousInterval);
                previousInterval=interval;
                var word=Activity.droppedWords[0];var text=word.text;
                clickCharacter(text[0].toLowerCase());compare(word.unmatchedIndex,1);
                compare(items.score.currentSubLevel,0);
                // Restart during an unfinished word through the real lifecycle.
                activityBackground.stop();compare(Activity.droppedWords.length,0);
                activityBackground.start();wait(600);
                compare(items.score.currentSubLevel,0);
                word=Activity.droppedWords[0];text=word.text;
                compare(word.unmatchedIndex,0);
                for(var i=0;i<text.length;i++) {
                    clickCharacter(text[i].toLowerCase());
                    if(i+1<text.length)compare(items.score.currentSubLevel,0);
                }
                tryCompare(items.score,"currentSubLevel",1,1000);
                configurations.push({uppercaseOnly:upper,speed:setting,dropInterval:interval,
                    completedWord:text,restartAfterPrefix:true});
            }
        }
        grabImage(activityBackground).save("__QA_OUTPUT__/virtual-keyboard.png");
        ApplicationSettings.isVirtualKeyboard=false;
    }
    function cleanupTestCase(){console.log("NATIVE_WORDS_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,configurations:configurations}));}
}
