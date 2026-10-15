// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"PortugueseWordAssetsAvailable"
    when:activity.visible
    property var rows:__ROWS__
    property int images:0
    property int recordings:0
    File { id: corpusFile }
    function test_all_audited_words_have_their_assets() {
        wait(1800);
        for(var i=0;i<rows.length;i++) {
            var row=rows[i];
            verify(corpusFile.exists(row.image),"Image exists for "+row.key);
            images++;
            var voice=ApplicationInfo.getAudioFilePathForLocale(row.voice,ApplicationInfo.getVoicesLocale(items.locale));
            if(!corpusFile.exists(voice))console.log("RESOURCE_MISSING",row.key,voice);
            verify(corpusFile.exists(voice),"PT recording exists for "+row.key+" at "+voice);
            recordings++;
        }
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,images:images,recordings:recordings,expected:rows.length}));}
}
