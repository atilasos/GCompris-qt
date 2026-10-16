// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:'AllVisibleMagicHatLevels'
    when:activity.visible&&items.numberOfLevel>0
    property var observations: []
    function ensure(value,message){if(!value){console.log('MAGIC_ASSERT',message,new Error().stack);grabImage(pageView).save('__QA_OUTPUT__/failure.png');}verify(value,message||'');}
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var value=find(child,predicate);if(value)return value;}return null;}
    function drawn(item,threshold){var alpha=1;for(var node=item;node&&node!==pageView;node=node.parent){if(!node.visible)return false;if(node.opacity!==undefined)alpha*=node.opacity;}return alpha>=threshold&&item.width>0&&item.height>0;}
    function imageOf(slot){return find(slot,function(item){return item.source!==undefined&&/\/star-[123](?:-off)?\.svg$/.test(String(item.source))&&drawn(item,0.05);});}
    function svgStars(root){var result=[];function walk(item){if(item.source!==undefined&&/\/star-[123]\.svg$/.test(String(item.source))&&drawn(item,0.9)){var point=item.mapToItem(activityBackground,0,0);ensure(point.x>=0&&point.y>=0&&point.x+item.width<=activityBackground.width&&point.y+item.height<=activityBackground.height-bar.height,'Visible star geometry');tryCompare(item,'status',1,2000);result.push({source:String(item.source),x:point.x,y:point.y,width:item.width,height:item.height});}if(item.children)for(var child of item.children)walk(child);}walk(root);return result;}
    function rows(repeater){var result=[];for(var i=0;i<repeater.count;i++){
        var row=repeater.itemAt(i);if(!drawn(row,0.9)){result.push(null);continue;}
        var label=find(row,function(item){return item.text!==undefined&&drawn(item,0.9)&&/^\s*\d+\s*[x×]\s*$/.test(String(item.text));});
        var coefficient=label?Number(String(label.text).replace(/\D/g,'')):1;
        var slot=row.repeaterStars.itemAt(0);ensure(slot!==null);var shape=imageOf(slot.starFixed);ensure(shape!==null);
        var group=String(shape.source).match(/star-([123])/)[1];var stars=svgStars(row);
        result.push({group:group,count:stars.length,weight:coefficient,coefficientText:label?String(label.text):null,stars:stars});
    }return result;}
    function vector(first,second){var result={};for(var listIndex=0;listIndex<2;listIndex++){var list=listIndex===0?first:second,sign=listIndex===0||mode==='plus'?1:-1;for(var row of list){if(row)result[row.group]=(result[row.group]||0)+sign*row.count*row.weight;}}return result;}
    function represent(target,answerRows){var best=null;for(var a=0;a<=(answerRows[0]?10:0);a++)for(var b=0;b<=(answerRows[1]?10:0);b++)for(var c=0;c<=(answerRows[2]?10:0);c++){
        var counts=[a,b,c],actual={};for(var key in target)actual[key]=0;
        for(var i=0;i<3;i++)if(answerRows[i])actual[answerRows[i].group]=(actual[answerRows[i].group]||0)+counts[i]*answerRows[i].weight;
        var valid=Object.keys(actual).every(function(key){return actual[key]===(target[key]||0);});
        if(valid&&(best===null||a+b+c<best[0]+best[1]+best[2]))best=counts;
    }return best;}
    function click(item){ensure(item!==null);var point=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,point.x,point.y,Qt.LeftButton,Qt.NoModifier,0);wait(40);}
    function answer(counts){for(var row=0;row<3;row++)for(var index=0;index<counts[row];index++){var slot=repeaterAnswerRow.itemAt(row).repeaterStars.itemAt(index).starFixed;click(slot);var image=imageOf(slot);ensure(/\/star-[123]\.svg$/.test(String(image.source)),'Real click selects visible SVG');}}
    function onePuzzle(level){
        wait(600);var beforeFirst=rows(repeaterFirstRow),beforeSecond=rows(repeaterSecondRow);ensure(beforeFirst.some(function(row){return row&&row.count>0;}),'Visible first operand');
        if(mode==='minus')ensure(beforeSecond.every(function(row){return row===null||row.count===0;}),'Subtrahend is not exposed before animation');
        if(level===1)grabImage(pageView).save('__QA_OUTPUT__/first.png');
        click(theHat);tryCompare(okButton,'enabled',true,12000);wait(350);
        var second=mode==='plus'?beforeSecond:rows(repeaterSecondRow),answerRows=rows(repeaterAnswerRow),wanted=vector(beforeFirst,second),solution=represent(wanted,answerRows);ensure(solution!==null,'Independent bounded colored representation exists');
        if(mode==='minus')ensure(second.some(function(row){return row&&row.count>0;}),'Animated stars leave hat and reach second row');
        ensure(answerRows.every(function(row){return row===null||row.count===0;}));
        var current=items.currentLevel;click(okButton);tryCompare(bonus,'isPlaying',true,2000);tryVerify(function(){return bonus.opacity>0.5;},2000);var wrongSource=String(bonus.source);ensure(wrongSource.indexOf('bad')>=0,'Visible wrong Bonus');tryCompare(bonus,'isPlaying',false,7000);compare(items.currentLevel,current);tryCompare(okButton,'enabled',true,2000);
        answer(solution);var selected=rows(repeaterAnswerRow);click(okButton);tryCompare(bonus,'isPlaying',true,2000);tryVerify(function(){return bonus.opacity>0.5;},2000);var goodSource=String(bonus.source);ensure(goodSource.indexOf('good')>=0,'Visible correct Bonus');
        return {level:level,mode:mode,first:beforeFirst,secondBefore:beforeSecond,second:second,answerRows:answerRows,target:wanted,payment:solution,selected:selected,wrongBonus:wrongSource,goodBonus:goodSource};
    }

    function test_every_level_wrong_repair_and_natural_bonus(){
        wait(1800);compare(items.numberOfLevel,41);compare(items.currentLevel,0);
        for(var level=0;level<41;level++){
            compare(items.currentLevel,level);observations.push(onePuzzle(level+1));console.log('MAGIC_PROGRESS',mode,level+1,41);
            tryCompare(items,'currentLevel',(level+1)%41,9000);tryCompare(bonus,'isPlaying',false,4000);
        }
    }
    function cleanupTestCase(){console.log('NATIVE_MAGIC_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,observations:observations}));}
}
