// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    id: nativeMemory
    name:"MemoryActualAudioBoundary"
    when:true
__AUDIO_OBSERVER__
    function test_card_requests_native_audio(){
        wait(1600);
        enableObservedAudio();
        if(!activity.visible){keyClick(Qt.Key_Return,Qt.NoModifier,0);tryCompare(activity,"visible",true,2500);}
        realPlayer=findPlayer(activity.audioVoices);verify(realPlayer!==null,"Actual Qt MediaPlayer is observed");
        activity.stop();activity.start();wait(1100);
        var card=cardGrid.itemAtIndex(0),expected=String(card.pairData.sound);verify(expected!=="");
        mouseClick(card,card.width/2,card.height/2,Qt.LeftButton,Qt.NoModifier,0);
        tryVerify(function(){return requested.some(function(e){return e.route===expected;});},2500);
        tryVerify(function(){return playing.some(function(e){return e.route===expected;});},2500);
        tryVerify(function(){return progressed.some(function(e){return e.route===expected;});},3500);
        verify(activity.audioVoices.hasAudio,"Decoder recognises an audio track");
        console.log("ACTUAL_AUDIO",JSON.stringify({route:expected,duration:realPlayer.duration,position:realPlayer.position}));
    }
    function cleanupTestCase(){console.log("NATIVE_MEMORY_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,requested:requested,playing:playing,progressed:progressed}));}
}
