// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "ScalesCompleteByVisibleEvidence"
    when: items.numberOfLevel > 0 && activity.visible
    property var math: __SCALES_ORACLE__
    property int limit: __LEVEL_LIMIT__
    property bool virtualKeyboard: __VIRTUAL_KEYBOARD__
    property int rejected: 0
    property int drags: 0
    property var puzzles: []
    property var completed: []
    property var captures: ({})
    function checked(actual,expected,message) {
        if(actual!==expected)console.log("SCALES_ASSERT",String(actual),String(expected),message||"",new Error().stack);
        compare(actual,expected,message||"");
    }
    function ensure(value,message) {
        if(!value)console.log("SCALES_ASSERT",message||"",new Error().stack);
        verify(value,message||"");
    }
    function awaiting(object,key,value,timeout) {
        try {tryCompare(object,key,value,timeout||6000);}
        catch(error) {console.log("SCALES_WAIT",key,String(object[key]),String(value),new Error().stack);throw error;}
    }
    function image(root,index,gift) {
        if(root.img!==undefined && (gift ? root.img==="gift.svg" : root.img!=="gift.svg" && root.masseIndex===index)) return root;
        if(root.children)for(var c=0;c<root.children.length;c++){var found=image(root.children[c],index,gift);if(found)return found;}
        return null;
    }
    function known(area,index) {return image(area,index,false);}
    function dragCard(index,from,to) {
        wait(350);
        var source=known(from,index);ensure(source!==null && source.opacity===1);
        var start=source.mapToItem(activityBackground,source.width/2,source.height/2);
        var destination=to.dropArea.mapToItem(activityBackground,to.dropArea.width/2,to.dropArea.height/2);
        // Bootstrap the drag threshold with small moves before travelling to
        // the plate. Keep all mouse coordinates in the stationary scene.
        mousePress(activityBackground,start.x,start.y,Qt.LeftButton,Qt.NoModifier,20);
        mouseMove(activityBackground,start.x+15,start.y+15,20,Qt.LeftButton);
        mouseMove(activityBackground,start.x+30,start.y+30,20,Qt.LeftButton);
        mouseMove(activityBackground,destination.x,destination.y,40,Qt.LeftButton);
        wait(50);
        ensure(source.Drag.active,"The intended labelled mass owns the drag");
        if(!to.dropArea.containsDrag)console.log("SCALES_DRAG_BEFORE_RELEASE",index,source.Drag.active,source.mapToItem(activityBackground,source.width/2,source.height/2),destination,to.dropArea.enabled);
        mouseRelease(activityBackground,destination.x,destination.y,Qt.LeftButton,Qt.NoModifier,20);
        wait(120);
        var arrived=known(to,index);
        if(arrived===null || arrived.opacity!==1) {console.log("SCALES_DRAG",index,source.text,from===masseAreaCenter?"center":"plate",to===masseAreaLeft?"left":to===masseAreaRight?"right":"center",destination.x,destination.y,source.x,source.y);grabImage(activityBackground).save("__QA_OUTPUT__/drag-failure.png");}
        ensure(arrived!==null && arrived.opacity===1,"Real drag arrived at destination");
        drags++;
    }
    function apply(plan,positions,stopAtEquilibrium) {
        var areas={"0":masseAreaCenter,"1":masseAreaLeft,"-1":masseAreaRight};
        for(var i=0;i<positions.length;i++)if(positions[i]!==plan.positions[i]) {
            dragCard(i,areas[positions[i]],areas[plan.positions[i]]);
            positions[i]=plan.positions[i];
            // The real question panel appears as soon as an intermediate
            // arrangement balances. That is already a solved weighing.
            if(stopAtEquilibrium && question.visible) {wait(550);checked(tilt(),0);return;}
        }
        wait(550);
    }
    function tilt() {
        ensure(needle.angle===0 || needle.angle===7 || needle.angle===-7,"Needle is visually stable");
        return needle.angle===0?0:needle.angle>0?1:-1;
    }
    function enterNumber(value,virtualKeys) {
        virtualKeys = virtualKeys && virtualKeyboard;
        activityBackground.forceActiveFocus();
        while(numpad.answer.length)keyClick(Qt.Key_Backspace);
        for(var ch of String(value)) {
            var digit=Number(ch);
            if(virtualKeys) {var panel=digit<5?numpad.leftPanelComponent:numpad.rightPanelComponent;mouseClick(panel.children[digit%5]);}
            else keyClick(Qt.Key_0+digit);
        }
        checked(numpad.answer,String(value));
        checked(question.userEntry,String(value));
    }
    function test_all_datasets_and_puzzles() {
        wait(1600);
        ApplicationSettings.isVirtualKeyboard=virtualKeyboard;
        var activityName=activity.activityInfo.shortName();
        var counts={scalesboard:52,scalesboard_weight:45,scalesboard_weight_avoirdupois:45};
        checked(items.numberOfLevel,counts[activityName]);
        checked(activity.levelFolder.length,activityName==="scalesboard"?8:6);
        var levels=limit>0?limit:items.numberOfLevel;
        for(var level=0;level<levels;level++) {
            checked(items.currentLevel,level);
            console.log("SCALES_LEVEL_START",activityName,level+1);
            var rounds=score.numberOfSubLevels;
            for(var round=0;round<rounds;round++) {
                wait(200);checked(score.currentSubLevel,round);
                var labels=[],positions=[];
                for(var index=0;known(masseAreaCenter,index)!==null;index++) {
                    var card=known(masseAreaCenter,index);
                    ensure(card.opacity===1);
                    labels.push(card.text);positions.push(0);
                }
                ensure(labels.length>0 && labels.length<=7,"All visible known masses are enumerated");
                if(activityName==="scalesboard_weight")for(var label of labels)ensure(/ (?:g|kg)$/.test(label));
                if(activityName==="scalesboard_weight_avoirdupois")for(var label of labels)ensure(/ (?:lb|oz)$/.test(label));
                var gift=image(masseAreaRight,0,true);ensure(gift!==null);
                var visibleLabel=gift.text;
                var both=masseAreaRight.dropArea.enabled;
                var candidates=math.plans(labels,both);
                var probes=[],solution=null;
                if(visibleLabel!=="") {
                    var target=math.parse(visibleLabel);
                    for(var p of candidates)if(p.sum===target){solution=p;break;}
                    ensure(solution!==null,"Visible target can be balanced from known labels");
                    if(round===0) {
                        var wrong=candidates[0].sum!==target?candidates[0]:candidates[1];
                        apply(wrong,positions);ensure(tilt()!==0);ensure(okButton.enabled);
                        mouseClick(okButton);checked(score.currentSubLevel,round);rejected++;
                        awaiting(items,"buttonsBlocked",false,6000);
                    }
                    apply(solution,positions);checked(tilt(),0);
                } else {
                    ensure(!okButton.enabled,"Hidden mass cannot be submitted before balancing");
                    var low=0,high=candidates.length-1;
                    while(low<=high) {
                        var mid=Math.floor((low+high)/2),candidate=candidates[mid];
                        apply(candidate,positions,true);
                        var observed=0;for(var i=0;i<labels.length;i++)observed+=math.parse(labels[i])*positions[i];
                        var direction=tilt();probes.push({sum:observed,tilt:direction});
                        if(direction===0){solution={sum:observed,positions:positions.slice()};break;}
                        if(direction>0)low=mid+1;else high=mid-1;
                    }
                    if(solution===null) {
                        console.log("SCALES_SEARCH_FAILURE",JSON.stringify({labels:labels,positions:positions,probes:probes,low:low,high:high}));
                        grabImage(activityBackground).save("__QA_OUTPUT__/search-failure.png");
                    }
                    ensure(solution!==null,"Search using only inclination reaches equilibrium");
                    awaiting(question,"visible",true);
                    var prompt=question.children[0].text;
                    ensure(prompt.indexOf("Indica o peso do presente")>=0);
                    var answer=math.entry(solution.sum,prompt);
                    ensure(Number.isInteger(answer));
                    if(round===0) {
                        enterNumber(0,false);mouseClick(okButton);checked(score.currentSubLevel,round);rejected++;
                        awaiting(items,"buttonsBlocked",false,6000);
                    }
                    enterNumber(answer,round%2===1);
                    keyClick(Qt.Key_Backspace);checked(numpad.answer,String(answer).slice(0,-1));
                    keyClick(Qt.Key_0+Number(String(answer).slice(-1)));checked(numpad.answer,String(answer));
                }
                var unitSet={};for(var label of labels)unitSet[label.replace(/^[0-9., ]+/,"")||"number"]=true;
                var signature=Object.keys(unitSet).sort().join("-")+"-"+(visibleLabel?"visible":"hidden")+"-"+(both?"two-pans":"left");
                if(!captures[signature]) {grabImage(activityBackground).save("__QA_OUTPUT__/"+signature+".png");captures[signature]=true;}
                puzzles.push({level:level+1,round:round+1,labels:labels,visibleTarget:visibleLabel,
                              both:both,positions:positions.slice(),canonical:solution.sum,probes:probes,
                              entry:question.visible?question.userEntry:null,prompt:question.visible?question.children[0].text:null});
                ensure(okButton.enabled);
                if(round%2 && question.visible)keyClick(Qt.Key_Return);else mouseClick(okButton);
                checked(score.currentSubLevel,round+1);ensure(items.buttonsBlocked);
                if(round+1<score.numberOfSubLevels)awaiting(items,"buttonsBlocked",false,6000);
                else {awaiting(bonus,"isPlaying",true,6000);awaiting(items,"currentLevel",(level+1)%items.numberOfLevel,10000);awaiting(items,"buttonsBlocked",false,6000);}
            }
            completed.push(level+1);console.log("SCALES_LEVEL_COMPLETED",activityName,level+1);
        }
    }
    function cleanupTestCase() {console.log("NATIVE_SCALES_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,activity:activity.activityInfo.shortName(),puzzles:puzzles,rejected:rejected,drags:drags,completed:completed}));}
}
