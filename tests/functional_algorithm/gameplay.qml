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
    function test_complete(){
        wait(1200);checked(activity.currentLevel,0);checked(activity.numberOfLevel,7);
        for(var level=0;level<targetLevels;level++){
            checked(activity.currentLevel,level);
            for(var puzzle=0;puzzle<3;puzzle++){
                checked(score.currentSubLevel,puzzle);checked(answer.count,5);
                var reference=drawn(question),visible=drawn(answer);ensure(visible[4].endsWith("/question_mark.svg"));
                var prefix=visible.slice(0,4),expected=association(reference,prefix);
                var wrong=null;
                for(var i=0;i<choiceGridView.count;i++){var source=String(image(choiceGridView.itemAtIndex(i)).source);if(source!==expected[4]){wrong=source;break;}}
                ensure(wrong!==null);input(wrong,false);checked(drawn(answer).join(),visible.join(),"Wrong choice does not replace the question mark");checked(score.currentSubLevel,puzzle);rejected++;
                for(var step=4;step<8;step++){
                    input(expected[step],correct%2===1);correct++;
                    checked(String(image(answer.itemAt(step)).source),expected[step]);
                    if(step<7){checked(answer.count,step+2);ensure(String(image(answer.itemAt(step+1)).source).endsWith("/question_mark.svg"));}
                }
                checked(drawn(answer).join(),expected.join(),"Entire drawn answer obeys the reference correspondence");
                checked(score.currentSubLevel,puzzle+1);
                puzzles.push({level:level+1,reference:reference,prefix:prefix,answer:drawn(answer)});
                if(puzzle<2)tryVerify(function(){return answer.count===5 && String(image(answer.itemAt(4)).source).endsWith("/question_mark.svg");},5000);
            }
            tryVerify(function(){return bonus.isPlaying;},5000);grabImage(activity).save("__QA_OUTPUT__/level-"+(level+1)+".png");
            completed.push(level+1);tryCompare(activity,"currentLevel",(level+1)%7,8000);wait(250);
        }
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,puzzles:puzzles,correct:correct,rejected:rejected}));}
}
