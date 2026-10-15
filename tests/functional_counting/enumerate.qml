// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "CountDrawnFruit"
    when: activity.visible && items.numberOfLevel > 0
    property var observations: []
    property int validationMode: __VALIDATION_MODE__
    property int levelLimit: __LEVEL_LIMIT__
    property bool visualPreference: __VISUAL_PREFERENCE__
__UI_HELPERS__
    function checked(actual,expected,message) {
        if(actual!==expected)console.log("COUNTING_ASSERT",JSON.stringify({actual:actual,expected:expected,message:message}),new Error().stack);
        compare(actual,expected,message||"");
    }
    function ensure(value,message) {
        if(!value)console.log("COUNTING_ASSERT",message||"",new Error().stack);
        verify(value,message||"");
    }
    function awaiting(object,key,value,timeout) {
        try {tryCompare(object,key,value,timeout||6000);}
        catch(error){console.log("COUNTING_WAIT",key,String(object[key]),String(value),new Error().stack);throw error;}
    }
    function picture(root) {
        if(root.source!==undefined && String(root.source).endsWith('.svg'))return root;
        if(root.children)for(var child of root.children){var found=picture(child);if(found)return found;}
        return null;
    }
__FRUIT_DRAG__
    function inputAnswer(answer,value,virtualKeys) {
        mouseClick(answer);
        if(virtualKeys && visualPreference) {
            var key=find(keyboard,function(item){return item.specialKey!==undefined && item.text===String(value);});
            ensure(key!==null);mouseClick(key);
        } else keyClick(Qt.Key_0+value);
        checked(answer.itemText,String(value));
    }
    function test_all_datasets() {
        wait(2400);
        ApplicationSettings.isVirtualKeyboard=visualPreference;
        var panel=openOptions();chooseMode(panel,validationMode-1);saveOptions();
        checked(items.mode,validationMode);checked(items.numberOfLevel,14);
        checked(activity.levelFolder.length,4);
        for(var level=0;level<(levelLimit>0?levelLimit:14);level++) {
            checked(items.currentLevel,level);
            var total=score.numberOfSubLevels;
            for(var round=0;round<total;round++) {
                wait(2300);
                if(instructionPanel.opacity>0) {mouseClick(instructionPanel);awaiting(instructionPanel,"opacity",0,1000);}
                var counts={},pictures=[];
                for(var i=0;i<itemList.count;i++) {
                    var image=itemList.itemAt(i);checked(image.status,1);ensure(image.visible);
                    var source=String(image.source);counts[source]=(counts[source]||0)+1;
                    pictures.push(source);
                }
                console.log("COUNTING_PUZZLE",validationMode,level+1,round+1,pictures.length);
                var drag=dragFruit(),rows=[];
                for(var index=0;index<answerRepeater.count;index++) {
                    var answer=answerRepeater.itemAt(index);
                    inputAnswer(answer,0,false);checked(score.currentSubLevel,round);
                }
                if(validationMode===2) {
                    mouseClick(okButton);checked(score.currentSubLevel,round);
                    for(var index=0;index<answerRepeater.count;index++)checked(answerRepeater.itemAt(index).state,"badAnswer");
                    awaiting(items,"buttonsBlocked",false,5000);
                }
                for(var index=0;index<answerRepeater.count;index++) {
                    var answer=answerRepeater.itemAt(index),source=String(picture(answer).source);
                    ensure(counts[source]>0);
                    inputAnswer(answer,counts[source],(round+index)%2===1);
                    rows.push({source:source,count:counts[source]});
                }
                if(validationMode===2)mouseClick(okButton);
                observations.push({mode:validationMode,level:level+1,round:round+1,pictures:pictures,answers:rows,drag:drag});
                awaiting(score,"currentSubLevel",round+1);
                if(round+1<total)awaiting(items,"buttonsBlocked",false,6000);
                else {awaiting(bonus,"isPlaying",true,6000);awaiting(items,"currentLevel",(level+1)%14,10000);}
            }
            console.log("COUNTING_LEVEL_COMPLETED",validationMode,level+1);
        }
    }
    function cleanupTestCase(){if(qtest_results.failCount>0)grabImage(activityBackground).save("__QA_OUTPUT__/failure.png");console.log("NATIVE_COUNTING_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,observations:observations}));}
}
