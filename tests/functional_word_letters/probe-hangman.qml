// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"HangmanPTCorpusTracer"
    when:activity.visible
    function findKey(item,label) {
        if(item.text!==undefined && item.text===label && item.visible)return item;
        if(item.children)for(var i=0;i<item.children.length;i++) {
            var result=findKey(item.children[i],label);if(result)return result;
        }
        return null;
    }
    function test_complete_actual_word() {
        wait(1800);
        console.log("HANGMAN_CONTEXT",JSON.stringify({external:ApplicationSettings.useExternalWordset(),levels:items.numberOfLevel,locale:items.locale,image:String(wordImage.source),hidden:items.hidden.text,word:items.goodWord,layout:keyboard.layout}));
        var source=String(wordImage.source), key=source.slice(source.lastIndexOf('/')+1).replace('.webp','.ogg');
        var corpus=parser.parseFromUrl('qrc:/gcompris/src/activities/lang/resource/content-pt.json');
        var expected=corpus[key];verify(expected!==undefined);
        var letters=[];
        for(var i=0;i<expected.length;i++) {
            var character=expected[i].toLowerCase();
            if(character===' ' || letters.indexOf(character)!==-1)continue;
            letters.push(character);
            var button=findKey(keyboard,character);
            console.log("HANGMAN_KEY",character,String(button));
            verify(button!==null);
            mouseClick(button);
        }
        compare(items.hidden.text,expected);
        verify(goodIcon.visible);
        var initial=score.currentSubLevel;
        tryCompare(score,'currentSubLevel',initial+1,6500);
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount}));}
}
