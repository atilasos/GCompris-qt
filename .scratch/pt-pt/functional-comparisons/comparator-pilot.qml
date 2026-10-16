TestCase {
    name: "ComparatorFromVisiblePortugueseOperands"
    when: activity.visible && lineRepeater.count>0
    property int firstLevel: 1
    property int targetLevels: 1
    property int totalLevels: 26
    property var completed: []
    property var puzzles: []
    property int wrong: 0
    property int marks: 0
    function checked(a,b,message){if(a!==b)console.log("COMPARISON_ASSERT",String(a),String(b),message||"",new Error().stack);compare(a,b,message||"");}
    function ensure(value,message){if(!value)console.log("COMPARISON_ASSERT",message||"",new Error().stack);verify(value,message||"");}
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var value=find(child,predicate);if(value!==null)return value;}return null;}
    function texts(row){var result=[];for(var child of row.children)if(child.text!==undefined)result.push(child);result.sort(function(a,b){return a.x-b.x;});checked(result.length,3);return result;}
    function parts(text){
        var clean=String(text).replace(/\s/g,"").replace(/−/g,"-");
        ensure(/^-?\d+(,\d+)?$/.test(clean),"Portuguese decimal glyphs: "+text);
        var sign=clean[0]==="-"?-1:1;if(sign===-1)clean=clean.slice(1);
        var split=clean.split(",");return {sign:sign,whole:split[0],fraction:split[1]||""};
    }
    function signFor(left,right){
        var a=parts(left),b=parts(right),width=Math.max(a.fraction.length,b.fraction.length);
        function integer(p){var f=p.fraction;while(f.length<width)f+="0";return (p.whole+f).replace(/^0+/,"")||"0";}
        var x=integer(a),y=integer(b);if(x==="0")a.sign=1;if(y==="0")b.sign=1;
        var cmp=0;
        if(a.sign!==b.sign)cmp=a.sign<b.sign?-1:1;
        else if(x!==y){cmp=x.length!==y.length?(x.length<y.length?-1:1):(x<y?-1:1);cmp*=a.sign;}
        return cmp<0?"<":cmp>0?">":"=";
    }
    function selectedRow(){for(var i=0;i<lineRepeater.count;i++)if(texts(lineRepeater.itemAt(i))[0].font.bold)return i;return -1;}
    function selectRow(index,keyboard){
        if(keyboard){for(var n=0;n<=lineRepeater.count;n++){if(selectedRow()===index)return;keyClick(Qt.Key_Down);wait(50);}fail("Visible selected row converges");}
        else{mouseClick(lineRepeater.itemAt(index));wait(50);checked(selectedRow(),index);}
    }
    function buttonSign(item){
        var image=find(item,function(o){return o.source!==undefined && (String(o.source).endsWith("/equal.svg") || String(o.source).endsWith("/superior.svg"));});
        ensure(image!==null);return String(image.source).endsWith("/equal.svg")?"=":Math.round(image.rotation)%360===180?"<":">";
    }
    function enter(sign,keyboard){
        if(keyboard)keyClick(sign==="<"?Qt.Key_Less:sign===">"?Qt.Key_Greater:Qt.Key_Equal);
        else{
            var found=null;for(var i=0;i<symbolSelectionList.count;i++){var button=symbolSelectionList.itemAtIndex(i);ensure(button!==null);if(buttonSign(button)===sign)found=button;}
            ensure(found!==null);var image=find(found,function(o){return o.source!==undefined;});mouseClick(image);
        }
        wait(60);checked(texts(lineRepeater.itemAt(selectedRow()))[1].text,sign);
    }
    function submit(keyboard){ensure(okButton.visible);if(keyboard)keyClick(Qt.Key_Return);else mouseClick(okButton);wait(50);}
    function test_complete(){
        wait(1200);checked(activity.numberOfLevel,totalLevels);checked(activity.currentLevel,firstLevel-1);
        for(var offset=0;offset<targetLevels;offset++){
            var level=firstLevel+offset;checked(activity.currentLevel,level-1);
            for(var puzzle=0;puzzle<5;puzzle++){
                checked(score.currentSubLevel,puzzle);checked(lineRepeater.count,5);
                var rows=[];
                for(var i=0;i<lineRepeater.count;i++){
                    var t=texts(lineRepeater.itemAt(i)),left=String(t[0].text),right=String(t[2].text),sign=signFor(left,right);
                    rows.push({left:left,right:right,sign:sign});selectRow(i,(marks+i)%2===1);
                    enter(i===0?(sign==="<"?">":"<"):sign,marks%2===1);marks++;
                }
                submit(puzzle%2===1);checked(score.currentSubLevel,puzzle);wrong++;
                var invalid=find(lineRepeater.itemAt(0),function(o){return o.visible && o.source!==undefined && String(o.source).endsWith("/cancel.svg");});
                ensure(invalid!==null,"Wrong visible comparison is rejected");
                selectRow(0,true);enter(rows[0].sign,true);submit(puzzle%2===0);checked(score.currentSubLevel,puzzle+1);
                puzzles.push({level:level,rows:rows});
                if(puzzle<4)tryVerify(function(){return texts(lineRepeater.itemAt(0))[1].text==="" && !okButton.visible;},5000);
            }
            tryVerify(function(){return bonus.isPlaying;},5000);grabImage(activity).save("__QA_OUTPUT__/level-"+level+".png");
            completed.push({level:level,puzzles:5});tryCompare(activity,"currentLevel",level%totalLevels,8000);wait(300);
        }
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,puzzles:puzzles,wrong:wrong,marks:marks}));}
}
