// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "TensCardsComplete"
    when: items.numberOfLevel > 0 && activity.visible
    property bool usingDecomposition: activity.activityInfo.shortName() === "tens_complement_use"
    property int solved: 0
    property int rejected: 0
    property var rejectedByLevel: []
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
    function viewFor(root, model) {
        if(root.model !== undefined && root.model === model && root.itemAtIndex !== undefined) return root;
        if(root.children) for(var i=0;i<root.children.length;i++) {
            var found=viewFor(root.children[i],model); if(found) return found;
        }
        return null;
    }
    function cell(model,index) {
        var view=viewFor(activityBackground,model);
        ensure(view!==null,"Visible view exists for the displayed model");
        var item=view.itemAtIndex(index);
        ensure(item!==null,"Visible card exists at "+index);
        return item;
    }
    function clickCard(model,index) {mouseClick(cell(model,index)); wait(10);}
    function fill(slots,values) {
        for(var s=0;s<slots.length;s++) {
            var chosen=-1;
            for(var c=0;c<cardListModel.count;c++) {
                var card=cardListModel.get(c);
                if(card.visibility && Number(card.value)===values[s]) {chosen=c;break;}
            }
            ensure(chosen>=0,"Available displayed card for "+values[s]);
            clickCard(cardListModel,chosen);
            checked(items.selectedIndex,chosen);
            clickCard(slots[s].model,slots[s].index);
            checked(Number(slots[s].model.get(slots[s].index).value),values[s]);
        }
        ensure(okButton.visible);
    }
    function valid(slots,values) {
        for(var row=0;row<holderListModel.count;row++) {
            var m=holderListModel.get(row)[usingDecomposition?"secondRow":"addition"];
            var numbers=[];
            for(var j=0;j<m.count;j++) numbers.push(m.get(j).value);
            for(var s=0;s<slots.length;s++) if(slots[s].row===row) numbers[slots[s].index]=values[s];
            if(usingDecomposition) {
                if(Number(numbers[1])+Number(numbers[3])!==10 || Number(numbers[6])+10!==Number(numbers[8])) return false;
            } else if(Number(numbers[0])+Number(numbers[2])!==10) return false;
        }
        return true;
    }
    function test_complete_all_levels() {
        wait(1600);
        var levelCount=usingDecomposition?6:8;
        checked(items.numberOfLevel,levelCount);
        checked(activity.levelFolder.length,usingDecomposition?3:4,"All exposed datasets are loaded");
        for(var level=0;level<levelCount;level++) {
            checked(items.currentLevel,level);
            rejectedByLevel.push(0);
            checked(score.numberOfSubLevels,5);
            for(var round=0;round<5;round++) {
                wait(150);
                checked(score.currentSubLevel,round);
                var slots=[], values=[], pool=[];
                for(var c=0;c<cardListModel.count;c++) pool.push(Number(cardListModel.get(c).value));
                for(var row=0;row<holderListModel.count;row++) {
                    var m=holderListModel.get(row)[usingDecomposition?"secondRow":"addition"];
                    if(usingDecomposition) {
                        var original=holderListModel.get(row).addition;
                        var a=Number(original.get(0).value),b=Number(original.get(2).value);
                        checked(Number(original.get(4).value),a+b);
                        slots.push({model:m,index:3,row:row},{model:m,index:6,row:row});
                        values.push(10-a,a+b-10);
                        equationsChecked.push({a:a,b:b,parts:[a,10-a,a+b-10],result:a+b});
                    } else {
                        checked(Number(m.get(4).value),10);
                        var a=m.get(0).value,b=m.get(2).value;
                        if(a==="?" && b==="?") {
                            var first=pool.shift(),other=pool.indexOf(10-first);
                            ensure(other>=0);pool.splice(other,1);
                            slots.push({model:m,index:0,row:row},{model:m,index:2,row:row});values.push(first,10-first);
                        } else {
                            var fixed=Number(a==="?"?b:a), answer=10-fixed;
                            slots.push({model:m,index:a==="?"?0:2,row:row});values.push(answer);
                        }
                    }
                }
                ensure(valid(slots,values),"Independent allocation satisfies all equations");
                var wrong=null;
                for(var i=0;i<values.length && wrong===null;i++) for(var j=i+1;j<values.length;j++) {
                    var candidate=values.slice();candidate[i]=values[j];candidate[j]=values[i];
                    if(!valid(slots,candidate)) {wrong=candidate;break;}
                }
                if(wrong!==null) {
                    fill(slots,wrong);mouseClick(okButton);
                    checked(score.currentSubLevel,round,"Wrong allocation cannot score");ensure(!items.buttonsBlocked);ensure(!bonus.isPlaying);
                    var error=false;
                    for(var r=0;r<holderListModel.count;r++) {
                        var response=holderListModel.get(r);
                        if(!(usingDecomposition?response.isGood:response.isCorrect)) {ensure(response.tickVisibility);error=true;}
                    }
                    ensure(error);rejected++;rejectedByLevel[level]++;
                    for(var s=0;s<slots.length;s++) clickCard(slots[s].model,slots[s].index);
                    ensure(!okButton.visible);
                }
                fill(slots,values);
                if(level===0 && round===0) grabImage(activityBackground).save("__QA_OUTPUT__/complete-board.png");
                mouseClick(okButton);checked(score.currentSubLevel,round+1);ensure(items.buttonsBlocked);solved++;
                if(!usingDecomposition) for(var r=0;r<holderListModel.count;r++) {
                    var m=holderListModel.get(r).addition;
                    equationsChecked.push({a:Number(m.get(0).value),b:Number(m.get(2).value),result:Number(m.get(4).value)});
                }
                if(round<4) awaitValue(items,"buttonsBlocked",false,6000);
                else {awaitValue(bonus,"isPlaying",true,6000);awaitValue(items,"currentLevel",(level+1)%levelCount,10000);}
            }
            completed.push(level+1);
            awaitValue(items,"buttonsBlocked",false,6000);
        }
        checked(solved,levelCount*5);
        ensure(rejected>0);
    }
    function cleanupTestCase() { console.log("NATIVE_TENS_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,activity:activity.activityInfo.shortName(),solved:solved,rejected:rejected,completed:completed,rejectedByLevel:rejectedByLevel,equations:equationsChecked})); }
}
