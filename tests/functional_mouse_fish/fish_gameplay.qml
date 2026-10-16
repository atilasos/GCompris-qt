// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    id: nativeFish
    name:"CatchMovingFishAllLevels"
    when:activity.visible
    property var completed: []
    property var observedSources: ({})
    property int clicks: 0
    property int wrongClicks: 0
    property int wins: 0
    property int soundChanges: 0
    File {id: files}
    Connections {target:bonus;function onWin(){nativeFish.wins++;}}
    Connections {target:dripSound;function onPlayingChanged(){nativeFish.soundChanges++;}}
    function recordSource(route){
        route=String(route);if(observedSources[route]!==undefined)return;
        var name=route.split('/').pop();verify(files.copy(route,"__QA_OUTPUT__/"+name));observedSources[route]=name;
    }
    function checked(a,b,message){if(a!==b)console.log("FISH_FAILURE",a,b,message||"");compare(a,b,message||"");}
    function test_catch_all_original_moving_fish() {
        wait(1600);ApplicationSettings.isAudioEffectsEnabled=true;
        var sizes=[5,7,10,12,15,18];
        checked(activity.numberOfLevel,6);
        recordSource(dripSound.source);recordSource(bubbleSound.source);
        for(var level=0;level<6;level++) {
            checked(items.currentLevel,level);checked(score.currentSubLevel,0);checked(score.numberOfSubLevels,sizes[level]);
            checked(String(activityBackground.source),"qrc:/gcompris/src/activities/clickgame/resource/sea"+(level+1)+".webp");checked(activityBackground.status,1);recordSource(activityBackground.source);
            for(var f of Activity.createdFishes){recordSource(f.source);verify(f.running);verify(f.xSpeed!==0);}
            var first=Activity.createdFishes[0],oldX=first.x,oldY=first.y;wait(100);
            verify(first.x!==oldX||(level>0&&first.y!==oldY),"Original fish animations move without test intervention");
            mouseClick(activityBackground,1,1,Qt.LeftButton,Qt.NoModifier,0);wait(100);checked(score.currentSubLevel,0);wrongClicks++;
            var deadline=Date.now()+40000;
            while(score.currentSubLevel<sizes[level]&&Date.now()<deadline) {
                var eligible=Activity.createdFishes.filter(function(f){
                    var p=f.mapToItem(activityBackground,f.width/2,f.height/2);
                    return f.opacity>0.9&&p.x>f.width/2&&p.x<activityBackground.width-f.width/2&&p.y>score.y+score.height&&p.y<bar.y-f.height/2;
                });
                if(!eligible.length){wait(10);continue;}
                var fish=eligible[eligible.length-1],point=fish.mapToItem(activityBackground,fish.width/2,fish.height/2),before=score.currentSubLevel;
                mouseClick(activityBackground,point.x,point.y,Qt.LeftButton,Qt.NoModifier,0);clicks++;
                verify(score.currentSubLevel===before||score.currentSubLevel===before+1,"A real click can kill at most one fish");
                wait(10);
            }
            checked(score.currentSubLevel,sizes[level],"All moving targets caught");verify(bonus.isPlaying);
            completed.push({level:level+1,caught:score.currentSubLevel,total:score.numberOfSubLevels});
            if(level===0||level===5)grabImage(activityBackground).save("__QA_OUTPUT__/level"+(level+1)+"-complete.png");
            tryCompare(items,"currentLevel",(level+1)%6,7000);
        }
        checked(wins,6);checked(score.currentSubLevel,0);
        console.log("FISH_SOUNDS",JSON.stringify({dripStatus:dripSound.status,bubbleStatus:bubbleSound.status,playingChanges:soundChanges}));
    }
    function cleanupTestCase(){console.log("NATIVE_MOUSE_FISH_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,clicks:clicks,wrongClicks:wrongClicks,wins:wins,resources:observedSources,soundChanges:soundChanges}));}
}
