TestCase {
    name: "LogicalAssociationsFromDrawnFruitPairs"
    when: activity.visible && question.count===8
    property int targetLevels: 1
    property var completed: []
    property var puzzles: []
    property int correct: 0
    property int rejected: 0
    function checked(a,b,message){if(a!==b)console.log("ALGORITHM_ASSERT",String(a),String(b),message||"",new Error().stack);compare(a,b,message||"");}
    function ensure(value,message){if(!value)console.log("ALGORITHM_ASSERT",message||"",new Error().stack);verify(value,message||"");}
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var value=find(child,predicate);if(value!==null)return value;}return null;}
    function image(item){var value=find(item,function(o){return o.source!==undefined && String(o.source).endsWith(".svg");});ensure(value!==null);checked(value.status,Image.Ready);return value;}
    function drawn(repeater){var result=[];for(var i=0;i<repeater.count;i++)result.push(String(image(repeater.itemAt(i)).source));return result;}
    function association(reference,prefix){
        checked(reference.length,8);checked(prefix.length,4);var map={},reverse={};
        for(var i=0;i<4;i++){
            ensure(map[reference[i]]===undefined || map[reference[i]]===prefix[i],"Consistent visible correspondence");
            ensure(reverse[prefix[i]]===undefined || reverse[prefix[i]]===reference[i],"Visible mapping is one to one");
            map[reference[i]]=prefix[i];reverse[prefix[i]]=reference[i];
        }
        for(var original of reference)ensure(map[original]!==undefined,"Every reference symbol is identified by the first four visible pairs");
        return reference.map(function(original){return map[original];});
    }
    function choice(source){
        for(var i=0;i<choiceGridView.count;i++){var item=choiceGridView.itemAtIndex(i);ensure(item!==null);if(String(image(item).source)===source)return item;}
        fail("Expected drawn fruit is exposed in the choice tray");return null;
    }
    function input(source,keyboard){
        var item=choice(source);
        if(keyboard){
            keyClick(Qt.Key_Right);wait(60);
            for(var guard=0;guard<9;guard++){
                if(String(image(choiceGridView.currentItem).source)===source){
                    ensure(activityBackground.keyNavigationVisible,"Keyboard selection highlight is visible");
                    keyClick([Qt.Key_Space,Qt.Key_Enter,Qt.Key_Return][correct%3]);wait(80);return;
                }
                keyClick(Qt.Key_Right);wait(60);
            }
            fail("Keyboard reaches the visible requested fruit");
        }else{mouseClick(item);wait(80);}
    }
    property var controls: ({})
    function icon(suffix){wait(1600);var button=find(bar,function(o){return o.source!==undefined && String(o.source).endsWith(suffix);});ensure(button!==null,suffix);mouseClick(button);wait(350);}
    function test_keyboard_restart_help_menu(){
        wait(1200);checked(activity.currentLevel,0);checked(score.currentSubLevel,0);
        var current=choiceGridView.currentItem,at=-1;
        for(var i=0;i<choiceGridView.count;i++)if(choiceGridView.itemAtIndex(i)===current)at=i;
        ensure(at>=0);var left=String(image(choiceGridView.itemAtIndex((at+7)%8)).source),original=String(image(current).source);
        keyClick(Qt.Key_Left);wait(150);checked(String(image(choiceGridView.currentItem).source),left);
        keyClick(Qt.Key_Right);wait(150);checked(String(image(choiceGridView.currentItem).source),original);
        var expected=association(drawn(question),drawn(answer).slice(0,4));
        for(var n=4;n<8;n++){input(expected[n],true);correct++;}
        checked(score.currentSubLevel,1);tryCompare(answer,"count",5,5000);
        icon("bar_previous.svg");checked(activity.currentLevel,6);checked(score.currentSubLevel,0);checked(answer.count,5);
        icon("bar_next.svg");checked(activity.currentLevel,0);checked(score.currentSubLevel,0);checked(answer.count,5);
        var depth=pageView.depth;icon("bar_help.svg");tryCompare(pageView,"depth",depth+1,3000);wait(500);
        checked(pageView.currentItem.title,"Associações lógicas");ensure(pageView.currentItem.content.indexOf("Olha para as duas sequências")>=0);
        ensure(pageView.currentItem.content.indexOf("Look at the two sequences")<0);grabImage(pageView).save("__QA_OUTPUT__/help.png");
        keyClick(Qt.Key_Escape);tryCompare(pageView,"depth",depth,3000);wait(500);
        expected=association(drawn(question),drawn(answer).slice(0,4));input(expected[4],true);correct++;
        checked(String(image(answer.itemAt(4)).source),expected[4]);checked(answer.count,6);
        controls={leftRight:true,selectionKeys:true,restart:true,navigation:true,helpPortuguese:true,escape:true,inputAfterHelp:true};
        ActivityInfoTree.startingActivity="";icon("bar_home.svg");tryCompare(pageView,"depth",1,3000);ensure(pageView.currentItem.isMenu);grabImage(pageView).save("__QA_OUTPUT__/menu.png");
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,controls:controls}));}
}
