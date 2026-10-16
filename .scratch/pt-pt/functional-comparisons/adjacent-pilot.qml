// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "AdjacentFromVisibleUnitSequence"
    when: activity.visible && bar.level>0
    property int firstLevel: 1
    property int targetLevels: 1
    property bool manual: false
    property var completed: []
    property var puzzles: []
    property int wrong: 0
    property int moves: 0
    function checked(a,b,msg){if(a!==b)console.log("ADJACENT_ASSERT",a,b,msg||"",new Error().stack);compare(a,b,msg||"");}
    function ensure(v,msg){if(!v)console.log("ADJACENT_ASSERT",msg||"",new Error().stack);verify(v,msg||"");}
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var hit=find(child,predicate);if(hit)return hit;}return null;}
    function click(item){ensure(item!==null);var p=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,p.x,p.y);wait(50);}
    function icon(root,suffix){var item=find(root,function(o){return o.visible&&o.source!==undefined&&String(o.source).endsWith(suffix);});ensure(item!==null,suffix);click(item);}
    function shown(tile){var text=find(tile,function(o){return o.text!==undefined&&o.font!==undefined;});ensure(text!==null);return String(text.text);}
    function tiles(flow,question){var result=[];for(var tile of flow.children)if(question?tile.tileChanged!==undefined:tile.mouseHeld!==undefined)result.push(tile);result.sort(function(a,b){return a.y-b.y||a.x-b.x;});return result;}
    function value(text){var clean=text.replace(/\s/g,"").replace(/−/g,"-");ensure(/^-?\d+$/.test(clean),"Integer Portuguese glyphs: "+text);return parseInt(clean,10);}
    function drag(source,target){
        var a=source.mapToItem(pageView,source.width/2,source.height/2),b=target.mapToItem(pageView,target.width/2,target.height/2);
        mousePress(pageView,a.x,a.y);mouseMove(pageView,a.x+15,a.y,60);
        for(var i=1;i<=12;i++)mouseMove(pageView,a.x+(b.x-a.x)*i/12,a.y+(b.y-a.y)*i/12,20);
        mouseRelease(pageView,b.x,b.y);moves++;wait(70);
    }
    function proposal(number){var options=tiles(proposedTilesFlow,false);for(var option of options)if(value(shown(option))===number)return option;fail("Visible proposal "+number);return null;}
    function configure(){
        icon(bar,"bar_activity_config.svg");tryCompare(dialogActivityConfig,"visible",true,2500);wait(900);
        var box=find(dialogActivityConfig,function(o){return o.visible&&o.currentIndex!==undefined&&o.model!==undefined&&o.label!==undefined&&o.label===qsTranslate("ActivityConfig","Validate answers");});
        ensure(box!==null,"Answer mode selector");
        if(box.currentIndex!==(manual?1:0)){click(box);keyClick(manual?Qt.Key_End:Qt.Key_Home);keyClick(Qt.Key_Return);wait(150);}
        checked(box.currentIndex,manual?1:0);dialogActivityConfig.forceActiveFocus();keyClick(Qt.Key_Return);tryCompare(dialogActivityConfig,"visible",false,2500);wait(1100);
        checked(ApplicationSettings.loadActivityConfiguration(activity.activityInfo.shortName()).answerMode,manual?"2":"1");
    }
    function test_complete(){
        wait(1300);if(manual)configure();
        checked(activity.numberOfLevel,25);checked(activity.currentLevel,firstLevel-1);
        for(var offset=0;offset<targetLevels;offset++){
            var level=firstLevel+offset;checked(bar.level,level);checked(activity.currentLevel,level-1);
            var count=score.numberOfSubLevels;
            for(var p=0;p<count;p++){
                checked(score.currentSubLevel,p);wait(250);
                var question=tiles(questionTilesFlow,true),visible=question.map(function(t){return shown(t);}),anchor=-1,missing=[];
                for(var i=0;i<visible.length;i++){if(visible[i]==="?")missing.push(i);else if(anchor<0)anchor=i;}
                ensure(anchor>=0&&missing.length>0);var start=value(visible[anchor])-anchor,expected=[];
                for(i=0;i<visible.length;i++){expected.push(start+i);if(visible[i]!=="?")checked(value(visible[i]),start+i);}
                var options=tiles(proposedTilesFlow,false),bad=null;
                for(var option of options)if(value(shown(option))!==expected[missing[0]]){bad=option;break;}
                ensure(bad!==null);
                for(i=0;i<missing.length;i++)drag(i===0?bad:proposal(expected[missing[i]]),question[missing[i]]);
                if(manual){ensure(okButton.visible);if(p%2)keyClick(Qt.Key_Return);else click(okButton);}
                wait(100);checked(score.currentSubLevel,p);checked(question[missing[0]].state,"WRONG");wrong++;wait(650);
                // Correct fields keep their visible RIGHT state; only repair the rejected one.
                drag(proposal(expected[missing[0]]),question[missing[0]]);
                if(manual){ensure(okButton.visible);if(p%2)click(okButton);else keyClick(Qt.Key_Enter);}
                tryCompare(score,"currentSubLevel",p+1,2500);
                puzzles.push({level:level,visible:visible,expected:expected,missing:missing,instruction:String(instructionPanel.textItem.text),manual:manual});
                if(p<count-1){tryVerify(function(){return tiles(questionTilesFlow,true).some(function(t){return shown(t)==="?";});},6000);wait(300);}
            }
            tryVerify(function(){return bonus.isPlaying;},5000);grabImage(activity).save("__QA_OUTPUT__/level-"+level+".png");completed.push({level:level,puzzles:count});
            tryCompare(bar,"level",level%25+1,8000);wait(300);
        }
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,puzzles:puzzles,wrong:wrong,moves:moves,manual:manual}));}
}
