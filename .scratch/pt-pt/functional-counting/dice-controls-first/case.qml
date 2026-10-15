// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "CountingFallingControls"
    when: activity.visible && items.numberOfLevel>0
    property var dice: {"qrc:/gcompris/src/activities/smallnumbers/resource/dice3.svg": 3, "qrc:/gcompris/src/activities/smallnumbers/resource/dice7.svg": 7, "qrc:/gcompris/src/activities/smallnumbers/resource/dice1.svg": 1, "qrc:/gcompris/src/activities/smallnumbers/resource/dice4.svg": 4, "qrc:/gcompris/src/activities/smallnumbers/resource/dice9.svg": 9, "qrc:/gcompris/src/activities/smallnumbers/resource/dice8.svg": 8, "qrc:/gcompris/src/activities/smallnumbers/resource/dice5.svg": 5, "qrc:/gcompris/src/activities/smallnumbers/resource/dice0.svg": 0, "qrc:/gcompris/src/activities/smallnumbers/resource/dice6.svg": 6, "qrc:/gcompris/src/activities/smallnumbers/resource/dice2.svg": 2}
    property var observations: []
    function visibleItems() {
        var found=[];
        for(var child of activityBackground.children)
            if(child.wonState!==undefined && !child.wonState && child.opacity===1 && child.y>=0 && child.y+child.height<bar.y)
                found.push(child);
        return found.sort(function(a,b){return b.y-a.y;});
    }
    function diceCount(word) {
        for(var child of word.children)if(child.source!==undefined && dice[String(child.source)]!==undefined) {
            compare(child.status,1);
            return {source:String(child.source),count:dice[String(child.source)]};
        }
        fail("A visible audited die image is required");
    }
    function dominoCount(word) {
        var domino=null;
        for(var child of word.children)if(child.front!==undefined && child.back!==undefined)domino=child;
        verify(domino!==null,"Original drawn domino exists");
        var parts=[];
        for(var side of domino.front.children)if(side.mode!==undefined && side.width>domino.width*0.4 && side.width<domino.width*0.6) {
            if(side.mode==="dot") {
                var grid=find(side,function(item){return item.columns===3 && item.visible;});verify(grid!==null);
                var count=0;for(var dot of grid.children)if(dot.width>0 && dot.opacity>0.99)count++;
                parts.push({dots:count});
            } else if(side.mode==="number" || side.mode==="roman") {
                var label=find(side,function(item){return item.text!==undefined && item.visible;});verify(label!==null);
                var text=String(label.text),count;
                if(side.mode==="number") {verify(/^[0-9]$/.test(text));count=Number(text);}
                else {var romans={"":0,I:1,II:2,III:3,IV:4,V:5,VI:6,VII:7,VIII:8,IX:9};verify(romans[text]!==undefined);count=romans[text];}
                parts.push({label:text,count:count});
            } else if(side.mode==="image") {
                var images=[];
                function visit(root) {
                    if(root.source!==undefined && root.status!==undefined && root.visible && String(root.source).endsWith('butterfly.svg')) {compare(root.status,1);images.push(String(root.source));}
                    if(root.children)for(var child of root.children)visit(child);
                }
                visit(side);parts.push({images:images,count:images.length});
            } else fail("Unknown visible domino representation");
        }
        compare(parts.length,2);
        return {parts:parts,count:parts.reduce(function(sum,part){return sum+(part.dots===undefined?part.count:part.dots);},0)};
    }

    function find(root,predicate) {
        if(predicate(root))return root;
        if(root.children)for(var child of root.children){var result=find(child,predicate);if(result)return result;}
        return null;
    }
    function clickIcon(root,suffix) {
        wait(400);
        var button=find(root,function(item){return item.source!==undefined && String(item.source).endsWith(suffix);});
        verify(button!==null,"Icon "+suffix);mouseClick(button);
    }
    function clickText(root,text) {
        var button=find(root,function(item){return item.clicked!==undefined && item.text===text && item.visible;});
        verify(button!==null,"Button "+text);mouseClick(button);
    }
    function openOptions() {
        clickIcon(bar,"bar_activity_config.svg");tryCompare(dialogActivityConfig,"visible",true);wait(600);
        clickText(dialogActivityConfig,"Opções");wait(300);
        return find(dialogActivityConfig,function(item){return item.modeBox!==undefined || item.speedSlider!==undefined;});
    }
    function saveOptions() {
        clickText(dialogActivityConfig,"Gravar");tryCompare(dialogActivityConfig,"visible",false);wait(2400);
    }
    function chooseMode(panel,index) {
        verify(panel!==null);
        var box=panel.modeBox;
        var label=find(box,function(item){return item.text!==undefined && item.text===box.currentText && item.visible;});
        verify(label!==null);mouseClick(label);wait(200);
        var previous=box.currentIndex;
        for(var step=0;step<Math.abs(index-previous);step++)keyClick(index>previous?Qt.Key_Right:Qt.Key_Left);
        keyClick(Qt.Key_Return);wait(250);compare(box.currentIndex,index);
    }

    function allFalling() {
        var found=[];for(var child of activityBackground.children)if(child.wonState!==undefined && !child.wonState && child.opacity===1)found.push(child);
        return found;
    }
    function currentCount(word) {return activity.activityName==="smallnumbers"?diceCount(word):dominoCount(word);}
    function test_a_all_ten_speeds_by_interface() {
        wait(1600);
        for(var speed=1;speed<=10;speed++) {
            var panel=openOptions();verify(panel!==null);
            var slider=panel.speedSlider;
            var x=slider.leftPadding+(slider.availableWidth)*(speed-1)/9;
            mouseClick(slider,x,slider.height/2);compare(slider.value,speed);
            saveOptions();compare(activity.speedSetting,speed);
            compare(Number(ApplicationSettings.loadActivityConfiguration(activity.activityName).speedSetting),speed);
            tryVerify(function(){return allFalling().length>0;},5000);
            var word=allFalling()[0],y=word.y;wait(1000);verify(word.y>y,"Configured animation really moves");
            observations.push({speed:speed,fromY:y,toY:word.y});
            if(speed===1 || speed===10)grabImage(activityBackground).save("__QA_OUTPUT__/speed-"+speed+".png");
        }
    }
    function test_b_loss_and_recovery_without_timer_changes() {
        var panel=openOptions();saveOptions();
        compare(activity.speedSetting,10);compare(score.currentSubLevel,0);
        tryVerify(function(){return allFalling().length>0;},5000);
        var word=allFalling()[0],started=Date.now(),lastY=word.y;
        while(activityBackground.children.indexOf(word)>=0 && Date.now()-started<120000) {
            verify(!word.wonState);lastY=word.y;wait(50);
        }
        verify(activityBackground.children.indexOf(word)<0,"The unanswered item naturally leaves the screen");
        verify(lastY>activityBackground.height*0.8,"The missed object fell to the ground");
        verify(Date.now()-started>5000,"Real falling time elapsed");compare(score.currentSubLevel,0);
        observations.push({missed:true,lastY:lastY,elapsedMs:Date.now()-started});
        var total=score.numberOfSubLevels;
        for(var round=0;round<total;round++) {
            tryVerify(function(){return visibleItems().length>0;},15000);
            var count=currentCount(visibleItems()[0]);textinput.forceActiveFocus();keyClick(String(count.count));
            tryCompare(score,"currentSubLevel",round+1,1000);
        }
        tryCompare(items,"currentLevel",1,10000);observations.push({recovered:true});
    }
    function test_c_help_navigation_restart_focus_and_menu() {
        var titles={smallnumbers:"Números com dados",smallnumbers2:"Números com dominós"};
        compare(activity.activityInfo.title,titles[activity.activityName]);
        compare(activity.levelFolder.length,8);compare(items.numberOfLevel,9);
        clickIcon(bar,"bar_next.svg");compare(items.currentLevel,2);
        clickIcon(bar,"bar_previous.svg");compare(items.currentLevel,1);
        var panel=openOptions();saveOptions();compare(score.currentSubLevel,0);
        var depth=pageView.depth;clickIcon(bar,"bar_help.svg");tryCompare(pageView,"depth",depth+1);wait(600);
        var help=pageView.currentItem;compare(help.title,titles[activity.activityName]);
        verify(help.content.indexOf(activity.activityInfo.manual)>=0);grabImage(pageView).save("__QA_OUTPUT__/help.png");
        clickIcon(help,"cancel.svg");tryCompare(pageView,"depth",depth);wait(600);
        ApplicationSettings.isVirtualKeyboard=false;
        tryVerify(function(){return visibleItems().length>0;},15000);
        var count=currentCount(visibleItems()[0]),before=score.currentSubLevel;
        keyClick(String(count.count));tryCompare(score,"currentSubLevel",before+1,1000);
        observations.push({focusRestored:true,physicalWithoutVisual:true});
        ActivityInfoTree.startingActivity="";clickIcon(bar,"bar_home.svg");tryCompare(pageView,"depth",1);verify(pageView.currentItem.isMenu);
    }
    function cleanupTestCase(){console.log("NATIVE_COUNTING_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,observations:observations}));}
}
