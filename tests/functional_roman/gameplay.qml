// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "RomanFromVisiblePortugueseQuestion"
    when: activity.visible && questionPanel.textItem.text.length>0
    property int targetLevels: 1
    property int firstLevel: 1
    property var completed: []
    property var questions: []
    property int wrong: 0
    property int physical: 0
    property int virtual: 0
    function checked(a,b,msg){if(a!==b)console.log("ROMAN_ASSERT",a,b,msg||"",new Error().stack);compare(a,b,msg||"");}
    function ensure(v,msg){if(!v)console.log("ROMAN_ASSERT",msg||"",new Error().stack);verify(v,msg||"");}
    function roman(number){
        ensure(number>=1&&number<=3999);var tokens=[[1000,"M"],[900,"CM"],[500,"D"],[400,"CD"],[100,"C"],[90,"XC"],[50,"L"],[40,"XL"],[10,"X"],[9,"IX"],[5,"V"],[4,"IV"],[1,"I"]],result="";
        for(var token of tokens)while(number>=token[0]){result+=token[1];number-=token[0];}return result;
    }
    function arabic(text){
        var number=0,values={I:1,V:5,X:10,L:50,C:100,D:500,M:1000};
        for(var i=0;i<text.length;i++){ensure(values[text[i]]!==undefined);number+=i+1<text.length&&values[text[i]]<values[text[i+1]]?-values[text[i]]:values[text[i]];}
        checked(roman(number),text,"Canonical visible Roman numeral");return number;
    }
    function parse(text){
        var match=String(text).match(/^Converter o número romano ([IVXLCDM]+) para árabe\.$/);
        if(match)return {toArabic:true,source:match[1],answer:String(arabic(match[1])),number:arabic(match[1])};
        match=String(text).match(/^Converter o número árabe (\d+) para romano\.$/);ensure(match!==null,"Portuguese question: "+text);
        var number=parseInt(match[1],10);return {toArabic:false,source:match[1],answer:roman(number),number:number};
    }
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var hit=find(child,predicate);if(hit)return hit;}return null;}
    function click(item){ensure(item!==null);var p=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,p.x,p.y);wait(40);}
    function virtualKey(label){click(find(keyboard,function(o){return o.visible&&o.text===label&&o.font!==undefined;}));}
    function clear(virtualInput){
        if(virtualInput){for(var i=0;i<20&&textInput.text.length>0;i++)virtualKey("←");}
        else{click(textInput);keyClick(Qt.Key_A,Qt.ControlModifier);keyClick(Qt.Key_Backspace);}
        checked(textInput.text,"");
    }
    function type(text,virtualInput){
        clear(virtualInput);if(!virtualInput)click(textInput);
        for(var i=0;i<text.length;i++){if(virtualInput)virtualKey(text[i].toUpperCase());else keyClick(i%2?text[i].toUpperCase():text[i].toLowerCase());}
        checked(textInput.text,text.toUpperCase());
    }
    function test_complete(){
        ApplicationSettings.isVirtualKeyboard=true;tryCompare(keyboard,"visible",true,2500);wait(1700);checked(activity.numberOfLevel,14);checked(activity.currentLevel,firstLevel-1);
        for(var offset=0;offset<targetLevels;offset++){
            var level=firstLevel+offset;checked(activity.currentLevel,level-1);var count=score.numberOfSubLevels;
            for(var puzzle=0;puzzle<count;puzzle++){
                checked(score.currentSubLevel,puzzle);tryCompare(textInput,"enabled",true,6000);wait(100);
                var text=String(questionPanel.textItem.text),expected=parse(text),useVirtual=questions.length%2===1;
                checked(textInput.text,"","Fresh question input");
                if(level>=11)ensure(expected.number<=[50,100,500,1000][level-11],"Question within authored range");
                var bad=expected.toArabic?(expected.answer==="1"?"2":"1"):(expected.answer==="I"?"V":"I");
                type(bad,!useVirtual);if(useVirtual)keyClick(Qt.Key_Return);else click(okButton);checked(score.currentSubLevel,puzzle);
                tryVerify(function(){return errorRectangle.opacity>0.5;},1200);wrong++;tryCompare(textInput,"enabled",true,3500);
                type(expected.answer,useVirtual);if(useVirtual)virtual++;else physical++;
                var feedbackText=String(feedback.text);checked(feedbackText,(expected.toArabic?"Valor romano: ":"Valor árabe: ")+expected.source);
                if(useVirtual)click(okButton);else keyClick(puzzle%2?Qt.Key_Enter:Qt.Key_Return);tryCompare(score,"currentSubLevel",puzzle+1,2000);
                questions.push({level:level,question:text,source:expected.source,answer:expected.answer,toArabic:expected.toArabic,feedback:feedbackText,virtual:useVirtual});
                if(puzzle<count-1){tryCompare(textInput,"enabled",true,6000);wait(100);}
            }
            tryVerify(function(){return bonus.isPlaying;},5000);grabImage(activity).save("__QA_OUTPUT__/level-"+level+".png");completed.push({level:level,questions:count});
            tryCompare(activity,"currentLevel",level%14,8000);wait(300);
        }
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,questions:questions,wrong:wrong,physical:physical,virtual:virtual}));}
}
