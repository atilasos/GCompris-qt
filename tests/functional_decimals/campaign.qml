// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "DecimalCompleteCampaign"
    when: activity.visible
    property var completed: []
    property var counts: __COUNTS__
    property bool portrait: __PORTRAIT__
    property bool virtualKeys: __VIRTUAL__
    function check(actual,expected,message) {
        if(actual!==expected) console.log("DECIMAL_ASSERT",JSON.stringify({actual:actual,expected:expected,message:message}));
        compare(actual,expected,message);
    }
    function checkTrue(value,message) {if(!value) console.log("DECIMAL_ASSERT_FALSE",message); verify(value,message);}
    function sum(model) {
        var result=0;
        for(var i=0;i<model.count;i++) result+=model.get(i).selectedSquareNumbers;
        return result;
    }
    function units(text) {
        var parts=text.split(",");
        return isQuantityMode ? Number(parts[0]) : Number(parts[0])*10+(parts.length>1 ? Number(parts[1]) : 0);
    }
    function oracle() {
        var numbers=instructionPanel.textItem.text.match(/[0-9]+(?:,[0-9]+)?/g);
        check(numbers.length,isAdditionMode || isSubtractionMode ? 2 : 1);
        var first=units(numbers[0]);
        return isAdditionMode ? first+units(numbers[1]) : isSubtractionMode ? first-units(numbers[1]) : first;
    }
    function addBar(amount) {
        var a=arrow.mapToItem(activityBackground,arrow.width/2,arrow.height/2);
        var delta=(amount-1)*unselectedBar.cellSize;
        if(amount>1) mouseDrag(activityBackground,a.x,a.y,portrait?0:delta,portrait?delta:0,Qt.LeftButton,Qt.NoModifier,15);
        check(scrollBar.currentStep,amount-1);
        var from=selectedBar.mapToItem(activityBackground,unselectedBar.cellSize/2,unselectedBar.cellSize/2);
        var to=topRectangle.mapToItem(activityBackground,topRectangle.width/2,topRectangle.height/2);
        var before=sum(droppedItems);
        mouseDrag(activityBackground,from.x,from.y,to.x-from.x,to.y-from.y,Qt.LeftButton,Qt.NoModifier,15);
        check(sum(droppedItems),before+amount);
    }
    function represent(expected) {
        if(isSubtractionMode) {
            var index=Math.floor(expected/10), cell=expected%10;
            var delegate=multipleBars.itemAtIndex(index);
            checkTrue(delegate!==null);
            var half=multipleBars.cellSize/2;
            var point=delegate.mapToItem(activityBackground,portrait?half:cell*multipleBars.cellSize+half,portrait?cell*multipleBars.cellSize+half:half);
            mouseClick(activityBackground,point.x,point.y);
            check(sum(largestNumberRepresentation),expected);
        } else {
            for(var left=expected;left>0;left-=10) addBar(Math.min(left,10));
            check(sum(droppedItems),expected);
        }
    }
    function press(character) {
        if(!virtualKeys) {
            activityBackground.forceActiveFocus();
            keyClick(character===","?Qt.Key_Comma:character==="<"?Qt.Key_Backspace:Qt.Key_0+Number(character));
        } else if(character===",") mouseClick(numpad.decimalPointButton);
        else if(character==="<") mouseClick(numpad.backspaceButtonComponent);
        else {
            var digit=Number(character);
            var panel=digit<5?numpad.leftPanelComponent:numpad.rightPanelComponent;
            mouseClick(panel.children[digit%5]);
        }
    }
    function type(text) {for(var i=0;i<text.length;i++) press(text[i]);}
    function test_complete_every_dataset() {
        wait(1400);
        ApplicationSettings.previousWidth=portrait?600:1100;
        ApplicationSettings.previousHeight=portrait?900:700;
        ApplicationSettings.isVirtualKeyboard=virtualKeys;
        wait(400);
        check(activityBackground.horizontalLayout,!portrait);
        activityBackground.forceActiveFocus();
        if(tutorialImage.visible) keyClick(Qt.Key_Escape);
        tryCompare(tutorialImage,"visible",false,2000);
        if(!isSubtractionMode && virtualKeys) {
            mouseClick(hint);
            check(items.helper,true);
        }
        check(items.numberOfLevel,counts.length);
        check(activity.activityInfo.currentLevels.length,counts.length);
        for(var level=0;level<counts.length;level++) {
            check(items.currentLevel,level);
            check(score.numberOfSubLevels,counts[level]);
            for(var sub=0;sub<counts[level];sub++) {
                tryCompare(items,"buttonsBlocked",false,5000);
                check(score.currentSubLevel,sub);
                check(items.typeResult,false);
                var question=instructionPanel.textItem.text, expected=oracle();
                if(sub===0)grabImage(pageView).save("__QA_OUTPUT__/level-"+level+".png");
                // Initial zero (or unreduced minuend) is deliberately wrong.
                if(sub===0 && (expected>0 || isSubtractionMode)) {
                    mouseClick(okButton);
                    check(score.currentSubLevel,sub);
                    checkTrue(items.buttonsBlocked);
                    tryCompare(items,"buttonsBlocked",false,3000);
                }
                represent(expected);
                mouseClick(okButton);
                if(isAdditionMode || isSubtractionMode) {
                    check(items.typeResult,true);
                    if(sub===0) {
                        type(expected===0?"1":"0");
                        mouseClick(okButton);
                        check(score.currentSubLevel,sub);
                        tryCompare(items,"buttonsBlocked",false,3000);
                        press("<");
                        check(numpad.answer,"");
                    }
                    var answer=Math.floor(expected/10)+","+(expected%10);
                    type(answer);
                    check(numpad.answer,answer);
                    mouseClick(okButton);
                }
                check(score.currentSubLevel,sub+1);
                completed.push({level:level,sublevel:sub,question:question,expectedUnits:expected,typed:(isAdditionMode||isSubtractionMode)?answer:null});
                console.log("DECIMAL_ACCEPTED",JSON.stringify(completed[completed.length-1]));
                if(sub===counts[level]-1) {
                    tryCompare(items,"currentLevel",(level+1)%counts.length,6500);
                    tryCompare(score,"currentSubLevel",0,2000);
                } else {
                    tryCompare(score,"isWinAnimationPlaying",false,3000);
                    tryCompare(items,"buttonsBlocked",false,2000);
                }
                wait(60);
            }
        }
    }
    function cleanupTestCase() {
        console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,portrait:portrait,virtualKeys:virtualKeys,completed:completed}));
    }
}
