// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CaptureLegacyPortugueseWordPairs"
    when:activity.visible
    property var pairs:[{"key": "fawn.ogg", "text": "corso", "image": "qrc:/gcompris/data/words-webp/fawn.webp", "voice": "voices-$CA/$LOCALE/words/fawn.$CA"}, {"key": "tick.ogg", "text": "piolho", "image": "qrc:/gcompris/data/words-webp/tick.webp", "voice": "voices-$CA/$LOCALE/words/tick.$CA"}]
    property var captured:[]
    File {id:wordFile}
    function test_capture_exact_registered_resources() {
        wait(1800);
        for(var i=0;i<pairs.length;i++) {
            var row=pairs[i],stem=row.key.replace('.ogg','');
            var voice=ApplicationInfo.getAudioFilePathForLocale(row.voice,ApplicationInfo.getVoicesLocale(items.locale));
            verify(wordFile.copy(row.image,"__QA_OUTPUT__/"+stem+".webp"));
            verify(wordFile.copy(voice,"__QA_OUTPUT__/"+stem+".ogg"));
            captured.push({key:row.key,translatedText:row.text,imageResource:row.image,voiceResource:voice});
        }
        verify(wordFile.write(JSON.stringify(captured,null,2),"__QA_OUTPUT__/pairs.json"));
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,captured:captured,scope:"Byte captures for linguistic diagnosis only; no translation or audio approval."}));}
}
