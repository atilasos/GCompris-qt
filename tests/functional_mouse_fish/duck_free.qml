// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"FreeMouseExploration"
    when:activity.visible
    property var ducks: []
    property var resources: ({})
    property var movement: ({})
    SignalSpy {id:soundSpy;signalName:"playingChanged"}
    File {id:files}
    function record(route){route=String(route);var name=route.split('/').pop();if(resources[route]===undefined){verify(files.copy(route,"__QA_OUTPUT__/"+name));resources[route]=name;}}
    function sound(root){if(root.source!==undefined&&String(root.source).endsWith('.wav'))return root;if(root.data)for(var child of root.data){var found=sound(child);if(found)return found;}return null;}
    function bounded(){verify(mainArea.mainDuckX>=0&&mainArea.mainDuckX<=mainArea.rightDirectionLimit);verify(mainArea.mainDuckY>=0&&mainArea.mainDuckY<=mainArea.downDirectionLimit);}
    function test_four_ducks_and_pointer_events() {
        wait(1600);ApplicationSettings.isAudioEffectsEnabled=true;
        compare(duckGrid.count,4);compare(activity.numberOfLevel,0);
        var colors=['pink_duck','green_duck','yellow_duck','orange_duck'];
        var sounds=['bleep','smudge','flip','completetask'];
        record(activityBackground.source);record(mainDuck.source);record(arrowsArea.upArrow.source);record(circleSound.source);
        for(var i=0;i<4;i++) {
            var duck=duckGrid.itemAtIndex(i);compare(duck.status,1);verify(String(duck.source).endsWith('/'+colors[i]+'.svg'));record(duck.source);
            var effect=sound(duck);verify(effect!==null);verify(String(effect.source).endsWith('/'+sounds[i]+'.wav'));record(effect.source);
            soundSpy.target=effect;soundSpy.clear();
            mouseClick(duck,duck.width/2,duck.height/2,Qt.LeftButton,Qt.NoModifier,0);
            tryVerify(function(){return duck.rotation>0;},500);
            ducks.push({color:colors[i],rotation:duck.rotation,sound:String(effect.source),soundStatus:effect.status,playingChanges:soundSpy.count});wait(700);
        }
        mouseMove(mainArea,80,80,0);wait(50);var x=mainArea.mainDuckX,y=mainArea.mainDuckY;
        mouseMove(mainArea,150,120,0);wait(50);verify(mainArea.mainDuckX!==x||mainArea.mainDuckY!==y);bounded();
        movement.hover={before:[x,y],after:[mainArea.mainDuckX,mainArea.mainDuckY]};
        x=mainArea.mainDuckX;y=mainArea.mainDuckY;
        mousePress(mainArea,150,120,Qt.LeftButton,Qt.NoModifier,0);mouseMove(mainArea,200,160,30,Qt.LeftButton);mouseRelease(mainArea,200,160,Qt.LeftButton,Qt.NoModifier,0);wait(100);
        verify(mainArea.mainDuckX!==x||mainArea.mainDuckY!==y);bounded();movement.drag={before:[x,y],after:[mainArea.mainDuckX,mainArea.mainDuckY]};
        mouseClick(mainArea,mainArea.width/2,mainArea.height/2,Qt.LeftButton,Qt.NoModifier,0);
        verify(pressCircle.visible);var location=mainArea.mapToItem(activityBackground,mainArea.width/2,mainArea.height/2);
        compare(pressCircle.x+pressCircle.width/2,location.x);compare(pressCircle.y+pressCircle.height/2,location.y);
        movement.marker={x:location.x,y:location.y,soundStatus:circleSound.status};
        grabImage(activityBackground).save("__QA_OUTPUT__/free-mouse.png");
    }
    function cleanupTestCase(){console.log("NATIVE_MOUSE_FISH_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,ducks:ducks,movement:movement,resources:resources}));}
}
