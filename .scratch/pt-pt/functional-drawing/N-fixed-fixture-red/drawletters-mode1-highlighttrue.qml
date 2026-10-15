// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    id:nativeDrawing
    name:"ConnectedDrawingAllLevels"
    when:true
    property int configuredMode: 1
    property bool configuredHighlight: true
    property var fixture: [{"imageName1": "paper.svg", "imageName2": "N1.svg", "coordinates": [[186, 96], [186, 127], [186, 146], [186, 172], [186, 195], [186, 226], [186, 255], [186, 279], [186, 302], [186, 324], [186, 349], [186, 374], [186, 96], [206, 118], [219, 130], [234, 150], [250, 168], [265, 185], [280, 201], [295, 223], [313, 243], [327, 260], [345, 287], [368, 312], [390, 334], [410, 349], [431, 368], [431, 343], [431, 328], [431, 296], [431, 267], [431, 245], [431, 220], [431, 194], [431, 163], [431, 137], [431, 111], [431, 96]], "coordinates2": [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], "sound": "voices-ogg/pt/alphabet/U006E.ogg", "images": {"src/activities/drawletters/resource/paper.svg": "3f3d5c98638d2c52b6aea46535935b813703f02ca4abf3c6729de223c9d5e06f", "src/activities/drawletters/resource/N1.svg": "005bf9b19691509b5247f43f39e6055a8f4174c915c7bf9feb9deafe5db52065"}, "breaks": [true, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]}]
    property var completed: []
    property int wins: 0
    property int wrong: 0
    property int pauses: 0
    property var images: ({})
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
            nativeDrawing.audioSerial++;
            nativeDrawing.requested.push({serial:nativeDrawing.audioSerial,route:route});
            if(route.indexOf("/voices-")>=0)nativeDrawing.verify(route.indexOf("/voices-ogg/pt/")>=0,"Portuguese voice route, including card or Bonus feedback");
            if(nativeDrawing.copiedRoutes[route]===undefined) {
                var name=route.split('/').pop();
                nativeDrawing.verify(copiedResource.copy(route,"__QA_OUTPUT__/"+name),"Copy actual Qt-registered resource bytes");
                nativeDrawing.copiedRoutes[route]=name;
            }
        }
    }
    Connections {
        target: nativeDrawing.realPlayer
        function onPlaybackStateChanged(){
            if(nativeDrawing.realPlayer.playbackState===1)nativeDrawing.playing.push({serial:nativeDrawing.audioSerial,route:String(activity.audioVoices.source)});
        }
        function onPositionChanged(){
            if(nativeDrawing.realPlayer.position>0&&nativeDrawing.realPlayer.hasAudio&&nativeDrawing.lastProgress!==nativeDrawing.audioSerial){
                nativeDrawing.lastProgress=nativeDrawing.audioSerial;
                nativeDrawing.progressed.push({serial:nativeDrawing.audioSerial,route:String(activity.audioVoices.source),position:nativeDrawing.realPlayer.position,duration:nativeDrawing.realPlayer.duration,playbackState:nativeDrawing.realPlayer.playbackState});
            }
        }
        function onErrorOccurred(error,errorString){nativeDrawing.audioErrors.push({error:error,message:errorString,route:String(activity.audioVoices.source)});}
    }

    Connections {target:bonus;function onWin(){nativeDrawing.wins++;}}
    function checked(a,b,message){if(a!==b)console.log('DRAWING_FAILURE',a,b,message||'',new Error().stack);compare(a,b,message||'');}
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var found=find(child,predicate);if(found)return found;}return null;}
    function click(item){verify(item!==null);mouseClick(item,item.width/2,item.height/2,Qt.LeftButton,Qt.NoModifier,0);}
    function button(suffix){wait(150);click(find(bar,function(item){return item.source!==undefined&&String(item.source).endsWith(suffix);}));}
    function configure(){
        button('bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2000);wait(500);
        var panel=find(dialogActivityConfig,function(item){return item.modeBox!==undefined;});verify(panel!==null);
        var box=panel.modeBox;
        if(box.currentIndex!==configuredMode-1){click(find(box,function(item){return item.text!==undefined&&item.text===box.currentText;}));wait(200);keyClick(configuredMode===2?Qt.Key_Right:Qt.Key_Left);keyClick(Qt.Key_Return);wait(200);}
        checked(box.currentIndex,configuredMode-1);
        if(activity.mode==='number_sequence'){
            var check=find(panel,function(item){return item.text==='Destacar o próximo ponto'&&item.checked!==undefined;});verify(check!==null);
            if(check.checked!==configuredHighlight)click(check);checked(check.checked,configuredHighlight);
        }
        dialogActivityConfig.forceActiveFocus();keyClick(Qt.Key_Return);tryCompare(dialogActivityConfig,'visible',false,2000);wait(500);
        checked(items.mode,configuredMode);if(activity.mode==='number_sequence')checked(items.highlightEnabled,configuredHighlight);
        var stored=ApplicationSettings.loadActivityConfiguration(activity.activityInfo.shortName());checked(Number(stored.mode),configuredMode);
        if(activity.mode==='number_sequence')checked(String(stored.highlight),String(configuredHighlight));
    }
    function point(i){return pointImageRepeater.itemAt(i);}
    function visiblePoints(){var result=[];for(var i=0;i<pointImageRepeater.count;i++){var p=point(i);if(p.visible&&p.opacity>0.9)result.push(p);}return result;}
    function numberLabel(point){return find(point,function(item){return item.text!==undefined&&item.visible&&/^\d+$/.test(String(item.text));});}
    function target(){
        // Only rendered labels or the blue rendered highlight choose a target.
        // Neither the expected engine index nor the fixture selects points.
        var candidates=visiblePoints();
        if(activity.pointTextVisible){candidates.sort(function(a,b){return Number(numberLabel(a).text)-Number(numberLabel(b).text);});return candidates[0];}
        var highlighted=candidates.filter(function(p){return String(p.source).endsWith('/bluepointHighlight.svg');});checked(highlighted.length,1,'One visible blue target');return highlighted[0];
    }
    function center(p){return {x:p.x+p.width/2,y:p.y+p.height/2};}
    function lines(){var result=[];for(var i=0;i<segmentsRepeater.count;i++){var line=segmentsRepeater.itemAt(i);if(line.opacity>0.9)result.push(line);}return result;}
    function recordImage(item){tryCompare(item,'status',1,2000);var route=String(item.source);if(images[route]===undefined){var name=activity.mode+'-'+route.split('/').pop();verify(copiedResource.copy(route,'__QA_OUTPUT__/'+name));images[route]=name;}}
    function test_complete_all_original_levels(){
        wait(1600);enableObservedAudio();if(!activity.visible){keyClick(Qt.Key_Return);tryCompare(activity,'visible',true,2500);}configure();
        checked(activity.numberOfLevel,26);checked(items.numberOfLevel,26);
        for(var level=0;level<fixture.length;level++){
            checked(items.currentLevel,level+13);checked(items.pointIndexToClick,0);checked(pointImageRepeater.count,fixture[level].coordinates.length);
            recordImage(imageBack);recordImage(imageBack2);
            var expectedVoice=fixture[level].sound;
            if(expectedVoice){var expected='qrc:/gcompris/data/'+expectedVoice;tryVerify(function(){return progressed.some(function(e){return e.route===expected&&e.position>0&&e.playbackState===1;});},4000);}
            var next=target(),position=center(next);
            if(activity.mode==='number_sequence'){
                var peers=visiblePoints().filter(function(p){return p!==next;});verify(peers.length>0);
                checked(Math.round(next.height/peers[0].height),configuredHighlight?2:1,'Highlight controls rendered dot size');
            }
            var wrongPoint=visiblePoints().filter(function(p){var c=center(p);return p!==next&&Math.hypot(c.x-position.x,c.y-position.y)>next.width+p.width;})[0];verify(wrongPoint!==undefined);
            var wrongPosition=center(wrongPoint);mouseClick(imageBack2,wrongPosition.x,wrongPosition.y,Qt.LeftButton,Qt.NoModifier,0);checked(items.pointIndexToClick,0,'Wrong visible point rejected');wrong++;
            mouseClick(activityBackground,1,1,Qt.LeftButton,Qt.NoModifier,0);checked(items.pointIndexToClick,0,'Outside click rejected');wrong++;
            var history=[],previous=null,total=pointImageRepeater.count;
            while(history.length<total){
                next=target();position=center(next);var ordinal=history.length;
                if(activity.pointTextVisible)checked(Number(numberLabel(next).text),ordinal+1,'Visible increasing labels');
                var before=lines().length;
                mouseClick(imageBack2,position.x,position.y,Qt.LeftButton,Qt.NoModifier,0);history.push(position);checked(items.pointIndexToClick,history.length,'One real click advances one point');
                if(history.length<total){
                    var pause=fixture[level].breaks[ordinal];
                    checked(lines().length,before+(pause?0:1),'No connector across independent strokes');
                    if(pause&&ordinal>0)pauses++;
                    if(!pause){var found=lines().some(function(line){return Math.abs(line.x-previous.x)<0.5&&Math.abs(line.y-previous.y)<0.5&&Math.abs(line.x2-position.x)<0.5&&Math.abs(line.y2-position.y)<0.5&&Number.isFinite(line.rotation);});verify(found,'Actual line joins the two clicked positions');}
                }
                previous=position;
            }
            checked(lines().length,0);checked(String(imageBack2.source),activity.resourceUrl+fixture[level].imageName2);recordImage(imageBack2);verify(bonus.isPlaying);
            if(level===0||level===fixture.length-1)grabImage(activityBackground).save('__QA_OUTPUT__/level'+(level+1)+'-complete.png');
            if(configuredMode===1)tryCompare(items,'currentLevel',(level+1+13)%26,7000);
            else{tryCompare(bonus,'isPlaying',false,7000);checked(items.currentLevel,level,'Manual mode keeps completed drawing');checked(items.pointIndexToClick,total);button('bar_next.svg');tryCompare(items,'currentLevel',(level+1+13)%26,2000);}
            completed.push({level:level+1+13,points:history.length,final:fixture[level].imageName2});console.log('DRAWING_LEVEL',activity.mode,level+1,history.length);
        }
        checked(wins,fixture.length);checked(items.pointIndexToClick,0);
    }
    function cleanupTestCase(){console.log('NATIVE_DRAWING_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,mode:configuredMode,highlight:configuredHighlight,completed:completed,wins:wins,wrong:wrong,pauses:pauses,images:images,requested:requested,playing:playing,progressed:progressed,audioErrors:audioErrors,copiedRoutes:copiedRoutes,clickSoundStatus:clickSound.status}));}
}
