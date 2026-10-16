// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    id: nativeColors
    name: "VisiblePortugueseColorNames"
    when: activity.visible && items.numberOfLevel>0
    property var vocabulary: {"Descobrir o pato amarelo": "yellow_duck.svg", "Descobrir o pato preto": "black_duck.svg", "Descobrir o pato verde": "green_duck.svg", "Descobrir o pato vermelho": "red_duck.svg", "Descobrir o pato branco": "white_duck.svg", "Descobrir o pato azul": "blue_duck.svg", "Descobrir o pato castanho": "brown_duck.svg", "Descobrir o pato cinzento": "grey_duck.svg", "Descobrir o pato laranja": "orange_duck.svg", "Descobrir o pato púrpura": "purple_duck.svg", "Descobrir o pato rosa": "pink_duck.svg"}
    property var sizes: [6,8,8]
    property var observations: []
    property int wins: 0
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
        realPlayer=findPlayer(activity.audioVoices);verify(realPlayer!==null,"Observe original Qt MediaPlayer");
    }
    Connections {
        target: activity.audioVoices
        function onSourceChanged(){
            var route=String(activity.audioVoices.source);
            if(!route)return;
            nativeColors.audioSerial++;
            nativeColors.requested.push({serial:nativeColors.audioSerial,route:route});
            if(route.indexOf("/voices-")>=0)nativeColors.verify(route.indexOf("/voices-ogg/pt/")>=0,"Portuguese voice route, including card or Bonus feedback");
            if(nativeColors.copiedRoutes[route]===undefined) {
                var name=route.split('/').pop();
                nativeColors.verify(copiedResource.copy(route,"__QA_OUTPUT__/"+name),"Copy actual Qt-registered resource bytes");
                nativeColors.copiedRoutes[route]=name;
            }
        }
    }
    Connections {
        target: nativeColors.realPlayer
        function onPlaybackStateChanged(){
            if(nativeColors.realPlayer.playbackState===1)nativeColors.playing.push({serial:nativeColors.audioSerial,route:String(activity.audioVoices.source)});
        }
        function onPositionChanged(){
            if(nativeColors.realPlayer.position>0&&nativeColors.realPlayer.hasAudio&&nativeColors.lastProgress!==nativeColors.audioSerial){
                nativeColors.lastProgress=nativeColors.audioSerial;
                nativeColors.progressed.push({serial:nativeColors.audioSerial,route:String(activity.audioVoices.source),position:nativeColors.realPlayer.position,duration:nativeColors.realPlayer.duration,playbackState:nativeColors.realPlayer.playbackState});
            }
        }
        function onErrorOccurred(error,errorString){nativeColors.audioErrors.push({error:error,message:errorString,route:String(activity.audioVoices.source)});}
    }

    Connections {target:bonus;function onWin(){nativeColors.wins++;}}
    function ensure(value,message){if(!value){console.log('COLORS_ASSERT',message,new Error().stack);grabImage(pageView).save('__QA_OUTPUT__/failure.png');}verify(value,message||'');}
    function checked(a,b,message){if(a!==b)console.log('COLORS_COMPARE',a,b,message,new Error().stack);compare(a,b,message||'');}
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var result=find(child,predicate);if(result)return result;}return null;}
    function click(item){ensure(item!==null);var p=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);wait(50);}
    function choose(item,keyboard,ordinal){
        if(!keyboard){click(item);return;}
        activityBackground.forceActiveFocus();
        for(var tries=0;tries<container.count+1&&container.currentItem!==item;tries++)keyClick(Qt.Key_Right);
        checked(container.currentItem,item);keyClick(ordinal%2?Qt.Key_Return:Qt.Key_Space);
    }
    function ready(){tryCompare(instructionPanel,'opacity',1,5000);tryCompare(items,'objectSelected',false,5000);wait(100);}
    function test_all_visible_requests(){
        wait(1800);enableObservedAudio();checked(items.numberOfLevel,sizes.length);
        if(activity.mode==='Colors'){
            click(find(bar,function(item){return item.source!==undefined&&String(item.source).endsWith('bar_next.svg');}));wait(700);
            click(find(bar,function(item){return item.source!==undefined&&String(item.source).endsWith('bar_previous.svg');}));wait(700);
        }
        var first=0,limit=1||sizes.length;
        for(var skip=0;skip<first;skip++){
            click(find(bar,function(item){return item.source!==undefined&&String(item.source).endsWith('bar_next.svg');}));wait(700);
        }
        for(var level=first;level<limit;level++){
            checked(items.currentLevel,level);ready();checked(container.count,sizes[level]);
            var seen=[];
            for(var question=0;question<sizes[level];question++){
                ready();var text=String(instructionPanel.textItem.text),name=vocabulary[text];
                ensure(name!==undefined,'Independent Portuguese vocabulary covers visible request: '+text);
                var choices=[];for(var i=0;i<container.count;i++){var item=container.itemAtIndex(i);ensure(item!==null);tryCompare(item,'status',1,3000);choices.push(item);}
                var matching=choices.filter(function(item){return String(item.source).endsWith('/'+name);});
                checked(matching.length,1,'One rendered image matches the independent colour name '+text+' -> '+name);
                if(activity.mode==='Colors'){
                    var expectedVoice='qrc:/gcompris/data/voices-ogg/pt/colors/'+name.replace('_duck.svg','.ogg');
                    tryVerify(function(){return progressed.some(function(event){return event.route===expectedVoice&&event.position>0&&event.playbackState===1;});},5000);
                    if(question===0){
                        tryVerify(function(){return !activity.audioVoices.isPlaying();},5000);ensure(repeatItem.visible);
                        var serial=audioSerial;click(repeatItem);
                        tryVerify(function(){return audioSerial>serial&&progressed.some(function(event){return event.serial>serial&&event.route===expectedVoice;});},5000);
                        tryVerify(function(){return !activity.audioVoices.isPlaying();},5000);
                        serial=audioSerial;activityBackground.forceActiveFocus();keyClick(Qt.Key_Tab);
                        tryVerify(function(){return audioSerial>serial&&progressed.some(function(event){return event.serial>serial&&event.route===expectedVoice;});},5000);
                    }
                }
                var correct=matching[0],wrong=choices.filter(function(item){return item!==correct;})[0],before=score.currentSubLevel;
                choose(wrong,question%2===0,question);checked(score.currentSubLevel,before);
                var cross=find(wrong,function(item){return item.source!==undefined&&String(item.source).endsWith('/checkError.svg');});
                ensure(cross!==null);tryVerify(function(){return cross.width>0;},1000);ready();
                checked(String(instructionPanel.textItem.text),text,'Wrong answer preserves question');
                choose(correct,question%2!==0,question);checked(score.currentSubLevel,before+1);
                seen.push(name);observations.push({level:level+1,question:question+1,text:text,source:String(correct.source),route:question%2!==0?'keyboard':'click'});
                if(question===0)grabImage(activityBackground).save('__QA_OUTPUT__/level'+(level+1)+'.png');
                if(question===sizes[level]-1){tryCompare(bonus,'isPlaying',true,6000);tryCompare(items,'currentLevel',(level+1)%sizes.length,9000);}
                else{tryVerify(function(){return String(instructionPanel.textItem.text)!==text;},6000);}
                console.log('COLORS_NAME',activity.mode,level+1,question+1);
            }
            checked(new Set(seen).size,sizes[level],'Each request occurs once in this level');
        }
        checked(wins,limit-first);
    }
    function cleanupTestCase(){console.log('NATIVE_COLORS_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,wins:wins,observations:observations,requested:requested,playing:playing,progressed:progressed,audioErrors:audioErrors,copiedRoutes:copiedRoutes}));}
}
