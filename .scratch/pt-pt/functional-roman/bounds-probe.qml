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
    property bool checkBounds: true
    property bool checkReset: false
    property var samples: []
    function icon(suffix){wait(1700);click(find(bar,function(o){return o.visible&&o.source!==undefined&&String(o.source).endsWith(suffix);}));}
    function test_random_level_contract(){
        ApplicationSettings.isVirtualKeyboard=true;tryCompare(keyboard,"visible",true,2500);wait(1700);checked(activity.currentLevel,10);checked(score.numberOfSubLevels,10);
        for(var round=0;round<15;round++){
            for(var question=0;question<10;question++){
                tryCompare(textInput,"enabled",true,6000);wait(100);checked(score.currentSubLevel,question);
                var text=String(questionPanel.textItem.text),expected=parse(text),input=String(textInput.text);
                samples.push({round:round,question:question,text:text,answer:expected.answer,input:input});
                if(checkBounds&&expected.number>50){console.log("ROMAN_RANDOM_BOUND",text,"authored maximum50");grabImage(activity).save("__QA_OUTPUT__/failure.png");fail("Requested number is within authored maximum50");}
                if(checkReset&&input!==""){console.log("ROMAN_RANDOM_RESET",text,"retained input",input);grabImage(activity).save("__QA_OUTPUT__/failure.png");fail("Each new question starts with an empty input");}
                type(expected.answer,false);keyClick(Qt.Key_Return);tryCompare(score,"currentSubLevel",question+1,2000);
                if(question<9)tryCompare(textInput,"enabled",true,6000);
            }
            tryVerify(function(){return bonus.isPlaying;},5000);tryCompare(activity,"currentLevel",11,8000);icon("bar_previous.svg");checked(activity.currentLevel,10);
        }
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,samples:samples,checkBounds:checkBounds,checkReset:checkReset}));}
}
