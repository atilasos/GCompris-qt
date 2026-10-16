// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    id: qaCase
    name: 'LearningQuantities'
    when: activity.numberOfLevel > 0
    property int representation: 2
    property int levelLimit: 1
    property var completed: []
    property int wins: 0
    property int wrong: 0
    property var voices: []
    Connections { target: bonus; function onWin() { qaCase.wins++; } }
    Connections { target: activity.audioVoices; function onSourceChanged() { if(String(activity.audioVoices.source)!=='')qaCase.voices.push(String(activity.audioVoices.source)); } }
    function check(a,b){if(a!==b)console.log('LEARNING_ASSERT',a,b,new Error().stack);compare(a,b);}
    function ensure(value){if(!value)console.log('LEARNING_ASSERT_FALSE',new Error().stack);verify(value);}
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var result=find(child,predicate);if(result)return result;}return null;}
    function click(item){ensure(item!==null);var p=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);wait(25);}
    function button(suffix){click(find(bar,function(item){return item.source!==undefined&&String(item.source).endsWith(suffix);}));}
    function filled(){var result=[];for(var i=0;i<circlesLine.count;i++){var item=circlesLine.itemAt(i),circle=item.children[0],p=circle.mapToItem(pageView,circle.width/2,circle.height/2);result.push({x:p.x,y:p.y,color:String(circle.color),filled:String(circle.color)!=='#00ffffff'});}return result;}
    function countFilled(){return filled().filter(function(c){return c.filled;}).length;}
    function shown(){
        if(questionText.visible){var text=String(questionText.text),match=text.match(/^(\d+)\s*([+-])\s*(\d+)$/);if(match){var a=Number(match[1]),b=Number(match[3]);return {text:text,answer:match[2]==='+'?a+b:a-b};}ensure(/^\d$/.test(text));return {text:text,answer:Number(text)};}
        check(questionImage.status,Image.Ready);ensure(questionImage.visible);var svg=fileId.read(questionImage.source),answer=-1;
        if(representation===2)answer=(svg.match(/<circle\b/g)||[]).length;
        else {var oracle=JSON.parse(fileId.read('__QA_SOURCE__/tests/functional_learning/hands-oracle.json'));for(var entry of oracle)if(entry.md5===Qt.md5(svg))answer=entry.count;}
        ensure(answer>=0&&answer<=9);var p=questionImage.mapToItem(pageView,0,0);return {image:String(questionImage.source),svgMd5:Qt.md5(svg),answer:answer,imageRect:{x:p.x,y:p.y,width:questionImage.width,height:questionImage.height}};
    }
    function ready(){if(iAmReady.visible){click(iAmReady);tryCompare(iAmReady,'visible',false,2500);wait(80);}}
    function configure(){
        if(activity.operationMode)return;
        button('bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2500);wait(1100);
        var combo=find(dialogActivityConfig,function(item){return item.currentIndex!==undefined&&item.currentText!==undefined&&item.boxBackground!==undefined;});ensure(combo!==null);
        click(find(combo,function(item){return item.text!==undefined&&String(item.text)===combo.currentText;}));wait(120);
        var popup=find(dialogActivityConfig,function(item){return item.visible&&item.z===100;});ensure(popup!==null);popup.forceActiveFocus();
        var choice=combo.model[representation-1].text;click(find(popup,function(item){return item.text!==undefined&&String(item.text)===choice;}));wait(120);check(combo.currentIndex,representation-1);
        dialogActivityConfig.forceActiveFocus();keyClick(Qt.Key_Return);tryCompare(dialogActivityConfig,'visible',false,2500);wait(1100);ready();
        var saved=ApplicationSettings.loadActivityConfiguration(activity.activityInfo.shortName());check(Number(saved.mode),representation);
    }
    function test_all_original_levels(){
        wait(1800);if(!activity.visible){keyClick(Qt.Key_Return);tryCompare(activity,'visible',true,2500);wait(1100);}configure();ready();
        var total=activity.operationMode?(activity.activityInfo.shortName()==='learn_additions'?3:5):9;check(activity.numberOfLevel,total);var levels=levelLimit||total;
        for(var level=0;level<levels;level++){
            check(activity.currentLevel,level);var count=score.numberOfSubLevels;ensure(count>0);var answered=[];
            for(var q=0;q<count;q++){
                check(score.currentSubLevel,q);check(countFilled(),0);var target=shown();ensure(target.answer>=0&&target.answer<=circlesLine.count);
                var wrongCount=target.answer===0?1:0;if(wrongCount)click(circlesLine.itemAt(0));
                click(okButton);check(score.currentSubLevel,q);check(okButton.enabled,false);wrong++;
                var current=countFilled();click(circlesLine.itemAt(0));check(countFilled(),current);keyClick(Qt.Key_Return);check(score.currentSubLevel,q);
                tryCompare(okButton,'enabled',true,2500);for(var c=0;c<circlesLine.count;c++)if(filled()[c].filled)click(circlesLine.itemAt(c));
                // One keyboard toggle and back at every level, followed by actual mouse selection.
                if(q===0){activity.forceActiveFocus();keyClick(Qt.Key_Right);var selector=circlesSelector.mapToItem(pageView,circlesSelector.width/2,circlesSelector.height/2),all=filled(),index=-1;for(var j=0;j<all.length;j++)if(Math.abs(all[j].x-selector.x)<2&&Math.abs(all[j].y-selector.y)<2)index=j;ensure(index>=0);keyClick(Qt.Key_Space);check(countFilled(),1);keyClick(Qt.Key_Space);check(countFilled(),0);}
                for(var c=0;c<target.answer;c++)click(circlesLine.itemAt(c));check(countFilled(),target.answer);
                var image='level-'+(level+1)+'-question-'+(q+1)+'.png';grabImage(pageView).save('__QA_OUTPUT__/'+image);
                var record={level:level+1,question:q+1,target:target,circles:filled(),screenshot:image};answered.push(record);completed.push(record);
                var beforeWin=wins;if(q%2===0)click(okButton);else{activity.forceActiveFocus();keyClick(Qt.Key_Return);}
                check(score.currentSubLevel,q+1);check(okButton.enabled,false);click(circlesLine.itemAt(0));keyClick(Qt.Key_Return);check(score.currentSubLevel,q+1);
                if(q+1<count){tryCompare(score,'currentSubLevel',q+1,100);tryCompare(okButton,'enabled',true,3000);}else{tryCompare(this,'wins',beforeWin+1,6500);tryCompare(activity,'currentLevel',(level+1)%total,2500);wait(100);}
                console.log('LEARNING_HEARTBEAT',JSON.stringify({level:level+1,question:q+1,completed:completed.length}));
            }
        }
    }
    function cleanupTestCase(){console.log('NATIVE_LEARNING_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,representation:representation,completed:completed,wins:wins,wrong:wrong,voices:voices}));}
}
