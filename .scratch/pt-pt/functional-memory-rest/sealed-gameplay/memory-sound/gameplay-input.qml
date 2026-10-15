// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    id: nativeMemory
    name:"NativeRemainingMemory"
    when:true
    function levelCount(){return {"memory":6,"memory-tux":6,"memory-sound":7,"memory-sound-tux":7,"memory-case-association-tux":4}[activity.activityInfo.shortName()];}
    function initTestCase(){
        wait(1600);enableObservedAudio();
        if(!activity.visible){keyClick(Qt.Key_Return,Qt.NoModifier,0);tryCompare(activity,"visible",true,2500);}
        activity.stop();activity.start();wait(1100);
        compare(items.numberOfLevel,levelCount());compare(activity.numberOfLevel,levelCount());
    }
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
        activity.audioVoices.muted=false;activityBackground.audioDisabled=false;
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

    property var completed: []
    property int correctPairs: 0
    property int wrongPairs: 0
    property int blockedClicks: 0
    property int tuxPairs: 0
    property int tuxTurns: 0
    property int losses: 0
    property int winSignals: 0
    property int lossSignals: 0
    property int forcedDefeats: 0
    Connections {
        target:bonus
        function onWin(){nativeMemory.winSignals++;}
        function onLoose(){nativeMemory.lossSignals++;}
    }
    function check(a,b,message){if(a!==b)console.log("MATH_FAILURE",a,b,message||"");compare(a,b,message||"");}
    function keyFor(data) {
        if(activity.activityInfo.shortName()==="memory-case-association-tux") {
            var letter=String(data.image).match(/(?:lower|upper)([A-Z])\.svg$/);verify(letter!==null);return letter[1];
        }
        if(activity.activityInfo.shortName().indexOf("memory-sound")===0)return String(data.sound);
        return String(data.image);
    }
    function card(index){var item=cardGrid.itemAtIndex(index);verify(item!==null);return item;}
    function click(index){var item=card(index);mouseClick(item,item.width/2,item.height/2,Qt.LeftButton,Qt.NoModifier,0);}
    function pairs() {
        var result={};
        for(var i=0;i<cardGrid.count;i++) {
            observeVisual(card(i));
            var key=String(keyFor(card(i).pairData));
            if(result[key]===undefined)result[key]=[];result[key].push(i);
        }
        check(Object.keys(result).length,cardGrid.count/2);
        for(var key of Object.keys(result)) {
            check(result[key].length,2,"Exactly two semantic matches");
            if(activity.activityInfo.shortName().indexOf("memory-sound")===0)check(card(result[key][0]).pairData.sound,card(result[key][1]).pairData.sound);
        }
        return result;
    }
    function verifyScores() {
        var found=0;
        for(var i=0;i<cardGrid.count;i++)if(card(i).isFound)found++;
        check(found,2*(items.player1Score.playerScore+items.player2Score.playerScore),"Scores count real found pairs");
    }
    function waitForTux() {
        var old=items.player2Score.playerScore;
        tuxTurns++;
        verify(items.tuxTurn);
        var before=items.selectionCount;
        var back=-1;
        for(var i=0;i<cardGrid.count;i++)if(card(i).isBack&&!card(i).isFound){back=i;break;}
        verify(back>=0);click(back);check(items.selectionCount,before,"Mouse blocked during Tux turn");verify(card(back).isBack);
        activityBackground.forceActiveFocus();keyClick(Qt.Key_Space,Qt.NoModifier,0);
        check(items.selectionCount,before,"Keyboard blocked during Tux turn");
        var deadline=Date.now()+120000;
        while(items.tuxTurn&&!items.blockClicks&&Date.now()<deadline){wait(100);verifyScores();}
        verify(!items.tuxTurn||items.blockClicks,"Original Tux timers return control or finish");
        tuxPairs+=items.player2Score.playerScore-old;
        verifyScores();
    }
    function wrongPair(group) {
        var names=Object.keys(group).filter(function(key){return !card(group[key][0]).isFound;});
        verify(names.length>=2);
        var a=group[names[0]][0],b=group[names[1]][0],third=group[names[0]][1];
        var score=items.player1Score.playerScore+items.player2Score.playerScore;
        selectFirst(a);check(items.selectionCount,1);click(a);check(items.selectionCount,1);
        click(b);check(items.selectionCount,2);wrongPairs++;
        click(third);check(items.selectionCount,2);verify(card(third).isBack);blockedClicks++;
        wait(500);verify(!card(a).isBack&&!card(b).isBack,"Wrong pair remains exposed");
        check(items.player1Score.playerScore+items.player2Score.playerScore,score);
        if(activity.withTux) {
            tryCompare(items,"tuxTurn",true,2000);waitForTux();
        } else {
            tryCompare(items,"selectionCount",0,2000);verify(card(a).isBack&&card(b).isBack);
        }
    }
    function solveRemaining(group) {
        var names=Object.keys(group);
        for(var name of names) {
            var indices=group[name];if(card(indices[0]).isFound)continue;
            verify(!items.tuxTurn);
            var s1=items.player1Score.playerScore,s2=items.player2Score.playerScore;
            selectFirst(indices[0]);click(indices[1]);check(items.selectionCount,2);
            wait(400);check(items.player1Score.playerScore,s1);check(items.player2Score.playerScore,s2);
            tryVerify(function(){return card(indices[0]).isFound&&card(indices[1]).isFound;},2000);
            correctPairs++;verifyScores();
            check(items.player1Score.playerScore,!items.player2Turn?s1+1:s1);
            check(items.player2Score.playerScore,items.player2Turn?s2+1:s2);
            if(!items.blockClicks){click(indices[0]);check(items.selectionCount,0,"Found card cannot be selected");}
        }
        verify(items.blockClicks);check(items.player1Score.playerScore+items.player2Score.playerScore,Object.keys(group).length);
    }
    function runMode(players) {
        activity.stop();items.playerCount=players;
        var count=levelCount();activity.start();
        check(items.numberOfLevel,count);check(activity.numberOfLevel,count,"Public level contract");
        for(var level=0;level<count;level++) {
            check(items.currentLevel,level);wait(1100);
            check(items.player1Score.playerScore,0);check(items.player2Score.playerScore,0);
            check(items.player2Turn,false);check(items.tuxTurn,false);check(items.selectionCount,0);
            var group=pairs();
            activityBackground.forceActiveFocus();var before=cardGrid.currentIndex;
            keyClick(Qt.Key_Right,Qt.NoModifier,0);check(cardGrid.currentIndex,(before+1)%cardGrid.count,"One arrow moves one card");
            wrongPair(group);
            if(!activity.withTux){check(items.player2Turn,players===2);if(players===2&&level%2===1){wrongPair(group);check(items.player2Turn,false);}}
            if(level===0)grabImage(activityBackground).save("__QA_OUTPUT__/"+players+"players-board.png");
            solveRemaining(group);
            var won=!activity.withTux||items.player1Score.playerScore>items.player2Score.playerScore;
            completed.push({players:players,level:level+1,score1:items.player1Score.playerScore,score2:items.player2Score.playerScore,pairs:Object.keys(group).length,won:won});
            console.log("MATH_LEVEL",JSON.stringify(completed[completed.length-1]));
            if(!won) {
                losses++;tryCompare(items,"blockClicks",false,7000);check(items.currentLevel,level,"Tux victory repeats level");
                wait(1100);solveRemaining(pairs());
            }
            tryCompare(items,"currentLevel",(level+1)%count,7000);
        }
    }
    function test_all_levels_modes_and_tux(){
        wait(1600);runMode(1);if(!activity.withTux)runMode(2);
        check(winSignals,items.numberOfLevel*(activity.withTux?1:2),"One real winning Bonus per completed level");
        check(lossSignals,losses,"Every natural loss emits the bad Bonus");
    }
    function test_defeat_by_tux_repeats_the_same_level(){
        if(!activity.withTux)return;
        wait(1100);var level=items.currentLevel,group=pairs();
        var deadline=Date.now()+180000;
        while(!items.blockClicks&&Date.now()<deadline) {
            var remaining=Object.keys(group).filter(function(key){return !card(group[key][0]).isFound;});
            if(remaining.length===1)solveRemaining(group);
            else wrongPair(group);
        }
        verify(items.blockClicks,"Tux finishes using original random turns");
        verify(items.player2Score.playerScore>=Object.keys(group).length-1&&items.player1Score.playerScore<=1,"Player deliberately yields pairs through real mistakes");
        var previous=lossSignals;
        tryCompare(items,"blockClicks",false,7000);
        check(lossSignals,previous+1,"Bad Bonus is emitted for a Tux victory");
        check(items.currentLevel,level,"Defeat repeats the selected level");
        check(items.player1Score.playerScore,0);check(items.player2Score.playerScore,0);check(items.tuxTurn,false);
        forcedDefeats++;
    }
    function cleanupTestCase(){compare(audioErrors.length,0,"No original MediaPlayer errors");console.log("NATIVE_MEMORY_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,correctPairs:correctPairs,wrongPairs:wrongPairs,blockedClicks:blockedClicks,tuxPairs:tuxPairs,tuxTurns:tuxTurns,losses:losses,winSignals:winSignals,lossSignals:lossSignals,forcedDefeats:forcedDefeats,requested:requested,playing:playing,progressed:progressed,audioErrors:audioErrors,copiedRoutes:copiedRoutes,visualRoutes:visualRoutes}));}
}
