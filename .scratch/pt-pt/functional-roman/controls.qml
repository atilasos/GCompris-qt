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
        if(virtualInput){tryCompare(keyboard,"visible",true,2500);wait(50);}
        clear(virtualInput);if(!virtualInput)click(textInput);
        for(var i=0;i<text.length;i++){if(virtualInput)virtualKey(text[i].toUpperCase());else keyClick(i%2?text[i].toUpperCase():text[i].toLowerCase());}
        checked(textInput.text,text.toUpperCase());
    }
    property var evidence: ({})
    function icon(suffix){wait(1700);click(find(bar,function(o){return o.visible&&o.source!==undefined&&String(o.source).endsWith(suffix);}));}
    function test_controls(){
        ApplicationSettings.isVirtualKeyboard=false;wait(1700);checked(keyboard.visible,false);checked(activity.numberOfLevel,14);checked(activity.currentLevel,0);
        checked(activity.activityInfo.title,"Números romanos");ensure(String(instructionPanel.textItem.text).indexOf("Os números romanos")===0);
        var expected=parse(questionPanel.textItem.text);type(expected.answer,false);ensure(feedbackArea.visible);checked(String(feedback.text),"Valor romano: I");
        icon("bar_hint.svg");checked(feedbackArea.visible,false);icon("bar_hint.svg");checked(feedbackArea.visible,true);
        icon("bar_previous.svg");checked(activity.currentLevel,13);checked(score.currentSubLevel,0);checked(textInput.text,"");
        icon("bar_next.svg");checked(activity.currentLevel,0);checked(score.currentSubLevel,0);checked(textInput.text,"");
        ApplicationSettings.isVirtualKeyboard=true;tryCompare(keyboard,"visible",true,2500);wait(1700);type("1",true);virtualKey("←");checked(textInput.text,"");checked(String(feedback.text),"Valor romano: ");
        var depth=pageView.depth;icon("bar_help.svg");tryCompare(pageView,"depth",depth+1,2500);wait(900);var help=pageView.currentItem;checked(help.title,"Números romanos");ensure(help.content.indexOf(activity.activityInfo.manual)>=0);ensure(help.content.indexOf("Convert the")<0);grabImage(pageView).save("__QA_OUTPUT__/help.png");
        keyClick(Qt.Key_Escape);tryCompare(pageView,"depth",depth,2500);wait(700);
        // Do not click or force focus after help: the physical key must reach the input.
        keyClick("1");checked(textInput.text,"1");keyClick(Qt.Key_Backspace);checked(textInput.text,"");keyClick(Qt.Key_Enter);checked(score.currentSubLevel,0);tryCompare(textInput,"enabled",true,3500);
        type("1",true);click(okButton);tryCompare(score,"currentSubLevel",1,1500);
        ActivityInfoTree.startingActivity="";icon("bar_home.svg");tryCompare(pageView,"depth",1,2500);ensure(pageView.currentItem.isMenu);
        evidence={title:"Números romanos",levels:14,virtualVisibleAndHidden:true,virtualBackspace:true,partialRestartByNavigation:true,previousNextWrap:true,hintVisibleAndHidden:true,helpPortuguese:true,physicalKeyAfterHelp:true,blankRejectedAfterHelp:true,home:true,menu:true};
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
