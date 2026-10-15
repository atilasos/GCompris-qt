// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "TensSwapComplete"
    when: items.numberOfLevel > 0 && activity.visible
    property bool calculation: activity.mode === "input"
    property int solved: 0
    property int rejected: 0
    property var completed: []
    property var equationsChecked: []
    function checked(actual,expected,message) {
        if(actual!==expected)console.log("TENS_ASSERT",String(actual),String(expected),message||"",new Error().stack);
        compare(actual,expected,message||"");
    }
    function ensure(value,message) {
        if(!value)console.log("TENS_ASSERT",message||"",new Error().stack);
        verify(value,message||"");
    }
    function awaitValue(object,key,expected,timeout) {
        try {tryCompare(object,key,expected,timeout||5000);}
        catch(error) {console.log("TENS_WAIT",key,String(object[key]),String(expected),new Error().stack);throw error;}
    }
    function viewFor(root,model) {
        if(root.model !== undefined && root.model===model && root.itemAtIndex!==undefined)return root;
        if(root.children)for(var i=0;i<root.children.length;i++) {var found=viewFor(root.children[i],model);if(found)return found;}
        return null;
    }
    function clickCell(model,index) {
        var view=viewFor(activityBackground,model);ensure(view!==null);
        var cell=view.itemAtIndex(index);ensure(cell!==null);mouseClick(cell);wait(15);
    }
    function arrangement(numbers,chosen) {
        if(numbers.length===0)return chosen;
        for(var n=0;n<numbers.length;n++) {
            if(chosen.length%2===1 && chosen[chosen.length-1]+numbers[n]!==10)continue;
            var rest=numbers.slice();rest.splice(n,1);
            var found=arrangement(rest,chosen.concat([numbers[n]]));if(found!==null)return found;
        }
        return null;
    }
    function numberSlots(model) {
        var indexes=[];for(var n=0;n<model.count;n++)if(model.get(n).type==="numberCard")indexes.push(n);return indexes;
    }
    function typeResult(model,value,virtualKeys) {
        clickCell(model,model.count-1);ensure(numPad.enableInput);
        activityBackground.forceActiveFocus();
        while(numPad.answer.length) keyClick(Qt.Key_Backspace);
        for(var digit of String(value)) {
            var n=Number(digit);
            if(virtualKeys) {var panel=n<5?numPad.leftPanelComponent:numPad.rightPanelComponent;mouseClick(panel.children[n%5]);}
            else keyClick(Qt.Key_0+n);
        }
        checked(numPad.answer,String(value));checked(model.get(model.count-1).value,String(value));
    }
    function test_complete_every_level_and_calculator_mode() {
        wait(1600);
        var levelCount=calculation?4:12;
        checked(items.numberOfLevel,levelCount);
        checked(activity.levelFolder.length,calculation?2:3);
        for(var mode=0;mode<(calculation?2:1);mode++) {
            ApplicationSettings.isVirtualKeyboard=mode===1;
            wait(250);
            for(var level=0;level<levelCount;level++) {
                checked(items.currentLevel,level);awaitValue(bonus,"isPlaying",false,6000);wait(180);
                var rows=[],invalid=false;
                for(var row=0;row<equations.count;row++) {
                    var model=equations.get(row).listmodel,indexes=numberSlots(model),original=[];
                    for(var index of indexes)original.push(Number(model.get(index).value));
                    // The odd final operand is free. Try every possible leftover.
                    var target=null;
                    if(original.length%2) for(var extra=0;extra<original.length && target===null;extra++) {
                        var rest=original.slice(),last=rest.splice(extra,1)[0];
                        var paired=arrangement(rest,[]);if(paired!==null)target=paired.concat([last]);
                    } else target=arrangement(original,[]);
                    ensure(target!==null,"Displayed multiset admits pairs of ten");
                    for(var i=0;i+1<original.length;i+=2)if(original[i]+original[i+1]!==10)invalid=true;
                    var sum=0;for(var n of original)sum+=n;
                    rows.push({model:model,indexes:indexes,numbers:original,target:target,total:sum});
                    if(calculation)typeResult(model,0,mode===1);
                }
                if(invalid || calculation) {
                    mouseClick(okButton);ensure(!bonus.isPlaying);checked(items.currentLevel,level);
                    var errors=0;for(var row=0;row<equations.count;row++) {
                        ensure(equations.get(row).isValidationImageVisible);
                        if(!equations.get(row).isGood)errors++;
                    }
                    ensure(errors>0);rejected++;
                }
                for(var row=0;row<rows.length;row++) {
                    var data=rows[row],model=data.model,indexes=data.indexes;
                    for(var i=0;i<indexes.length;i++) {
                        if(Number(model.get(indexes[i]).value)===data.target[i])continue;
                        var other=-1;for(var j=i+1;j<indexes.length;j++)if(Number(model.get(indexes[j]).value)===data.target[i]) {other=j;break;}
                        ensure(other>=0);clickCell(model,indexes[i]);clickCell(model,indexes[other]);
                        checked(Number(model.get(indexes[i]).value),data.target[i]);
                    }
                    if(calculation) {
                        typeResult(model,data.total,mode===1);
                        keyClick(Qt.Key_Backspace);
                        checked(numPad.answer,String(data.total).slice(0,-1));
                        var lastDigit=Number(String(data.total).slice(-1));
                        keyClick(Qt.Key_0+lastDigit);
                        checked(numPad.answer,String(data.total));
                    }
                    var displayed=[];for(var index of indexes)displayed.push(Number(model.get(index).value));
                    equationsChecked.push({numbers:data.numbers,ordered:displayed,result:Number(model.get(model.count-1).value),virtualKeys:mode===1});
                }
                if(level===0)grabImage(activityBackground).save("__QA_OUTPUT__/complete-mode-"+mode+".png");
                if(calculation && level%2)keyClick(Qt.Key_Return);else mouseClick(okButton);
                awaitValue(bonus,"isPlaying",true,2000);
                for(var row=0;row<equations.count;row++)ensure(equations.get(row).isGood);
                solved++;
                awaitValue(items,"currentLevel",(level+1)%levelCount,10000);
                completed.push({mode:calculation?(mode===1?"virtual":"physical"):"cards",level:level+1});
            }
        }
        checked(solved,levelCount*(calculation?2:1));ensure(rejected>0);
    }
    function cleanupTestCase() {console.log("NATIVE_TENS_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,activity:activity.activityInfo.shortName(),solved:solved,rejected:rejected,completed:completed,equations:equationsChecked}));}
}
