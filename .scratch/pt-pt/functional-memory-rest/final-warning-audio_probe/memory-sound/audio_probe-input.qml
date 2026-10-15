// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    id: nativeMemory
    name:"MemoryActualAudioBoundary"
    when:true
    property var requested: []
    property var playing: []
    property var progressed: []
    property var audioErrors: []
    property var copiedRoutes: ({})
    property int audioSerial: 0
    property int lastProgress: -1
    property var realPlayer: null
    File {id: copiedResource}
    function findPlayer(root) {
        if(root.position!==undefined&&root.playbackState!==undefined&&root.duration!==undefined)return root;
        if(root.data)for(var i=0;i<root.data.length;i++){var p=findPlayer(root.data[i]);if(p)return p;}
        return null;
    }
    function enableObservedAudio() {
        ApplicationSettings.isAudioVoicesEnabled=true;ApplicationSettings.isAudioEffectsEnabled=true;
        activity.audioVoices.muted=false;
        if(audioNeededDialog.active) {
            audioNeededDialog.item.forceActiveFocus();keyClick(Qt.Key_Escape);
            tryCompare(audioNeededDialog,"active",false,2000);
        }
        realPlayer=findPlayer(activity.audioVoices);verify(realPlayer!==null,"Observe original Qt MediaPlayer");
    }
    Connections {
        target: activity.audioVoices
        function onSourceChanged(){
            var route=String(activity.audioVoices.source);
            if(!route)return;
            nativeMemory.audioSerial++;
            nativeMemory.requested.push({serial:nativeMemory.audioSerial,route:route});
            if(route.indexOf("/voices-")>=0)nativeMemory.verify(route.indexOf("/voices-ogg/pt/")>=0,"Portuguese voice route, including card or Bonus feedback");
            if(nativeMemory.copiedRoutes[route]===undefined) {
                var name=route.split('/').pop();
                nativeMemory.verify(copiedResource.copy(route,"__QA_OUTPUT__/"+name),"Copy actual Qt-registered resource bytes");
                nativeMemory.copiedRoutes[route]=name;
            }
        }
    }
    Connections {
        target: nativeMemory.realPlayer
        function onPlaybackStateChanged(){
            if(nativeMemory.realPlayer.playbackState===1)nativeMemory.playing.push({serial:nativeMemory.audioSerial,route:String(activity.audioVoices.source)});
        }
        function onPositionChanged(){
            if(nativeMemory.realPlayer.position>0&&nativeMemory.realPlayer.hasAudio&&nativeMemory.lastProgress!==nativeMemory.audioSerial){
                nativeMemory.lastProgress=nativeMemory.audioSerial;
                nativeMemory.progressed.push({serial:nativeMemory.audioSerial,route:String(activity.audioVoices.source),position:nativeMemory.realPlayer.position,duration:nativeMemory.realPlayer.duration,playbackState:nativeMemory.realPlayer.playbackState});
            }
        }
        function onErrorOccurred(error,errorString){nativeMemory.audioErrors.push({error:error,message:errorString,route:String(activity.audioVoices.source)});}
    }
    function selectFirst(index) {
        var c=cardGrid.itemAtIndex(index),expected=String(c.pairData.sound),before=audioSerial;
        mouseClick(c,c.width/2,c.height/2,Qt.LeftButton,Qt.NoModifier,0);
        if(expected!=="")tryVerify(function(){return progressed.some(function(event){return event.serial>before&&event.route===expected&&event.playbackState===1;});},3500);
    }
    property var visualRoutes: ({})
    function observeVisual(cardItem) {
        var route=String(cardItem.pairData.image);if(!route)return;
        function find(root) {
            if(root.source!==undefined&&String(root.source)===route)return root;
            if(root.children)for(var i=0;i<root.children.length;i++){var child=find(root.children[i]);if(child)return child;}
            return null;
        }
        var rendered=find(cardItem.back);verify(rendered!==null,"Original card Image uses its assigned picture");
        compare(rendered.status,1,"Original Qt Image resource is Ready");
        if(visualRoutes[route]===undefined){var name="visual-"+route.split('/').pop();verify(copiedResource.copy(route,"__QA_OUTPUT__/"+name));visualRoutes[route]=name;}
    }

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
