// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"HangmanExactPortugueseAccentPolicy"
    when:activity.visible
    property var expectedWords:__WORDS__
    property var tested:({})
    property var completed:[]
    property var unicodeInput:null
    function input(text,visual) {
        if(visual) {
            var button=findKey(keyboard,text);verify(button!==null);
            mouseClick(button,button.width/2,button.height/2,Qt.LeftButton,Qt.NoModifier,50);
        } else {
            textinput.forceActiveFocus();
            if(text.charCodeAt(0)>127) {
                if(unicodeInput===null)unicodeInput=Qt.createQmlObject('import "file:__QA_SOURCE__/build/functional-input"; UnicodeInput {}',this);
                var previous=items.hidden.text;
                verify(unicodeInput.preedit(textinput,text));compare(items.hidden.text,previous);
                verify(unicodeInput.commit(textinput,text));
            } else keyClick(text,Qt.NoModifier,0);
        }
    }
    function findKey(item,text) {
        if(item.specialKey!==undefined && item.text===text && item.visible)return item;
        if(item.children)for(var i=0;i<item.children.length;i++) {
            var result=findKey(item.children[i],text);if(result)return result;
        }
        return null;
    }
    function mask(word,guessed) {
        var text='';
        for(var i=0;i<word.length;i++)text+=(word[i]===' '?' ':guessed[word[i].toLowerCase()]?word[i]:'_')+' ';
        return text;
    }
    function test_complete_body_lesson_with_missing_accent_probes() {
        wait(1800);ApplicationSettings.isVirtualKeyboard=true;
        tryCompare(keyboard,"visible",true,3000);wait(300);
        compare(ApplicationSettings.useExternalWordset(),false);
        compare(items.currentLevel,2);
        compare(score.numberOfSubLevels,20);
        var plain={'ç':'c','é':'e','ã':'a','í':'i'};
        for(var ordinal=0;ordinal<20;ordinal++) {
            compare(score.currentSubLevel,ordinal+1);
            var source=String(wordImage.source),key=source.slice(source.lastIndexOf('/')+1).replace('.webp','.ogg');
            var target=expectedWords[key];verify(target!==undefined);
            var guessed={};
            for(var i=0;i<target.length;i++) {
                var character=target[i].toLowerCase();
                if(character===' ' || guessed[character])continue;
                if(plain[character]!==undefined) {
                    input(plain[character],false);guessed[plain[character]]=true;
                    compare(items.hidden.text,mask(target,guessed));
                    compare(items.hidden.text[2*i],'_',"Unaccented key must not reveal the accented position");
                    tested[character]=true;
                    grabImage(pageView).save("__QA_OUTPUT__/missing-"+character+".png");
                }
                input(character,ordinal%2===1);guessed[character]=true;
            }
            compare(items.hidden.text,target);verify(goodIcon.visible);
            completed.push({key:key,word:target});
            if(ordinal===19)tryCompare(items,"currentLevel",3,6500);
            else tryCompare(score,"currentSubLevel",ordinal+2,6500);
            wait(40);
        }
        for(var accent of ['ç','é','ã','í'])verify(tested[accent]===true);
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,missingAccentProbes:tested,completed:completed}));}
}
