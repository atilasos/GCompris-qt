// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "FallingVisibleCounts"
    when: activity.visible && items.numberOfLevel>0
    property var dice: {"qrc:/gcompris/src/activities/smallnumbers/resource/dice0.svg": 0, "qrc:/gcompris/src/activities/smallnumbers/resource/dice1.svg": 1, "qrc:/gcompris/src/activities/smallnumbers/resource/dice2.svg": 2, "qrc:/gcompris/src/activities/smallnumbers/resource/dice3.svg": 3, "qrc:/gcompris/src/activities/smallnumbers/resource/dice4.svg": 4, "qrc:/gcompris/src/activities/smallnumbers/resource/dice5.svg": 5, "qrc:/gcompris/src/activities/smallnumbers/resource/dice6.svg": 6, "qrc:/gcompris/src/activities/smallnumbers/resource/dice7.svg": 7, "qrc:/gcompris/src/activities/smallnumbers/resource/dice8.svg": 8, "qrc:/gcompris/src/activities/smallnumbers/resource/dice9.svg": 9}
    property var observations: []
    property int levelLimit: 3
    property bool visualPreference: false
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

    function enterCount(value,virtualKeys) {
        if(virtualKeys && visualPreference) {
            var button=find(keyboard,function(item){return item.specialKey!==undefined && item.text===String(value);});
            verify(button!==null,"A visible digit key exists");mouseClick(button);
        } else {textinput.forceActiveFocus();keyClick(String(value));}
    }
    function test_all_levels_and_representations() {
        wait(1600);ApplicationSettings.isVirtualKeyboard=visualPreference;
        compare(items.numberOfLevel,9);compare(activity.levelFolder.length,8);
        var modes=activity.activityName==="smallnumbers"?["dice"]:("all"==="all"?["dot","number","roman","image"]:["all"]);
        for(var modeIndex=0;modeIndex<modes.length;modeIndex++) {
            if(modes[modeIndex]!=="dice") {
                var panel=openOptions();chooseMode(panel,modeIndex);saveOptions();
                compare(activity.dominoMode,modes[modeIndex]);
            }
            for(var level=0;level<(levelLimit>0?levelLimit:9);level++) {
                compare(items.currentLevel,level);
                var total=score.numberOfSubLevels;
                for(var round=0;round<total;round++) {
                    tryVerify(function(){return visibleItems().length>0;},15000);
                    var word=visibleItems()[0];
                    var count=activity.activityName==="smallnumbers"?diceCount(word):dominoCount(word);
                    var before=score.currentSubLevel;
                    textinput.forceActiveFocus();keyClick("#");compare(score.currentSubLevel,before);
                    var y=word.y;wait(100);verify(word.y>y,"The original falling animation moves");
                    enterCount(count.count,round%2===1);tryCompare(score,"currentSubLevel",before+1,1000);
                    observations.push({mode:modes[modeIndex],level:level+1,round:round+1,visual:count,virtualKeys:round%2===1});
                    if(round===0)grabImage(activityBackground).save("__QA_OUTPUT__/"+modes[modeIndex]+"-level-"+(level+1)+".png");
                }
                tryCompare(items,"currentLevel",(level+1)%9,10000);
                console.log("COUNTING_FALLING_LEVEL",modes[modeIndex],level+1);
            }
        }
    }
    function cleanupTestCase(){console.log("NATIVE_COUNTING_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,observations:observations}));}
}
