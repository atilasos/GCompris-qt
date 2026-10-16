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
        else{var row=lineRepeater.itemAt(index);mouseClick(row,row.width*0.25,row.height*0.5);wait(50);checked(selectedRow(),index);}
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
    property var evidence: ({})
    function pressIcon(suffix){
        var hit=find(bar,function(o){return o.visible&&o.source!==undefined&&String(o.source).endsWith(suffix);});ensure(hit!==null,suffix);
        var p=hit.mapToItem(pageView,hit.width/2,hit.height/2);mouseClick(pageView,p.x,p.y);wait(60);
    }
    function clickItem(item){ensure(item!==null);var p=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,p.x,p.y);wait(70);}
    function openConfig(){pressIcon("bar_activity_config.svg");tryCompare(dialogActivityConfig,"visible",true,2500);wait(900);}
    function saveConfig(){dialogActivityConfig.forceActiveFocus();keyClick(Qt.Key_Return);tryCompare(dialogActivityConfig,"visible",false,2500);wait(1100);}
    function datasetOptions(){
        openConfig();var tab=find(dialogActivityConfig,function(o){return o.visible&&o.theme==="settingsButton"&&o.text===qsTranslate("DialogChooseLevel","Dataset");});
        if(tab!==null){clickItem(tab);wait(200);}
        var result=[];function walk(o){if(o.visible&&o.checked!==undefined&&o.indicatorImageHeight!==undefined)result.push(o);if(o.children)for(var child of o.children)walk(child);}walk(dialogActivityConfig);return result;
    }
    function test_controls(){
        wait(1400);checked(activity.numberOfLevel,26);checked(activity.activityInfo.title,"Comparar os números");
        selectRow(0,false);enter("<",true);keyClick(Qt.Key_Backspace);checked(texts(lineRepeater.itemAt(0))[1].text,"");keyClick(Qt.Key_Right);keyClick(Qt.Key_Space);ensure(texts(lineRepeater.itemAt(0))[1].text!=="");keyClick(Qt.Key_Up);checked(selectedRow(),4);keyClick(Qt.Key_Down);checked(selectedRow(),0);
        openConfig();saveConfig();checked(score.currentSubLevel,0);checked(activity.currentLevel,0);
        checked(texts(lineRepeater.itemAt(0))[1].text,"");checked(okButton.visible,false);
        var options=datasetOptions();checked(options.length,10);ensure(options[0].checked);var objective=String(options[0].text);ensure(objective.length>10);
        clickItem(options[0]);checked(options[0].checked,false);saveConfig();checked(activity.numberOfLevel,23);checked(activity.currentLevel,0);
        options=datasetOptions();checked(options[0].checked,false);checked(String(options[0].text),objective);clickItem(options[0]);saveConfig();checked(activity.numberOfLevel,26);
        pressIcon("bar_previous.svg");checked(activity.currentLevel,26-1);checked(score.currentSubLevel,0);pressIcon("bar_next.svg");checked(activity.currentLevel,0);checked(score.currentSubLevel,0);
        var depth=pageView.depth;pressIcon("bar_help.svg");tryCompare(pageView,"depth",depth+1,2500);wait(800);var help=pageView.currentItem;
        checked(help.title,"Comparar os números");ensure(help.content.indexOf(activity.activityInfo.manual)>=0);ensure(help.content.indexOf("Click on")<0);ensure(activity.activityInfo.manual.length>30);grabImage(pageView).save("__QA_OUTPUT__/help.png");
        keyClick(Qt.Key_Escape);tryCompare(pageView,"depth",depth,2500);wait(700);
        keyClick(Qt.Key_Down);checked(selectedRow(),1);enter("=",true);checked(texts(lineRepeater.itemAt(1))[1].text,"=");
        ActivityInfoTree.startingActivity="";pressIcon("bar_home.svg");tryCompare(pageView,"depth",1,2500);ensure(pageView.currentItem.isMenu);
        evidence={title:"Comparar os números",levels:26,datasetObjective:objective,reduced:23,partialRestart:true,selectorsPersist:true,previousNext:true,helpPortuguese:true,focusAfterHelp:true,home:true};
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
