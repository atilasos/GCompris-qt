// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    id:nativeDrawing
    name:"ConnectedDrawingAllLevels"
    when:true
    property int configuredMode: __MODE__
    property bool configuredHighlight: __HIGHLIGHT__
    property var fixture: __FIXTURE__
    property var completed: []
    property int wins: 0
    property int wrong: 0
    property int pauses: 0
    property var images: ({})
__AUDIO__
    Connections {target:bonus;function onWin(){nativeDrawing.wins++;}}
    function ensured(value,message){if(!value){console.log('DRAWING_VERIFY',message||'',new Error().stack);grabImage(pageView).save('__QA_OUTPUT__/verify-failure.png');}verify(value,message||'');}
    function checked(a,b,message){if(a!==b)console.log('DRAWING_FAILURE',a,b,message||'',new Error().stack);compare(a,b,message||'');}
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var found=find(child,predicate);if(found)return found;}return null;}
    function click(item){ensured(item!==null);var position=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,position.x,position.y,Qt.LeftButton,Qt.NoModifier,0);}
    function button(suffix){wait(150);click(find(bar,function(item){return item.source!==undefined&&String(item.source).endsWith(suffix);}));}
    function configure(){
        button('bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2000);wait(1100);
        var panel=find(dialogActivityConfig,function(item){return item.modeBox!==undefined;});ensured(panel!==null);
        var box=panel.modeBox;
        grabImage(pageView).save('__QA_OUTPUT__/config-before.png');
        if(box.currentIndex!==configuredMode-1){
            var surface=find(box,function(item){return item.border!==undefined&&item.width>0&&item.width<box.width;});ensured(surface!==null);
            click(surface);wait(250);
            var option=find(dialogActivityConfig,function(item){return item.text===(configuredMode===2?'Manual':'Automática')&&item.visible;});ensured(option!==null);click(option);wait(250);
        }
        grabImage(pageView).save('__QA_OUTPUT__/config-after.png');checked(box.currentIndex,configuredMode-1);
        if(activity.mode==='number_sequence'){
            var check=find(panel,function(item){return item.text==='Destacar o próximo ponto'&&item.checked!==undefined;});ensured(check!==null);
            if(check.checked!==configuredHighlight)mouseClick(check,check.indicator.width/2,check.height/2,Qt.LeftButton,Qt.NoModifier,0);checked(check.checked,configuredHighlight);
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
    function recordImage(item){tryCompare(item,'status',1,2000);var route=String(item.source);if(images[route]===undefined){var name=activity.mode+'-'+route.split('/').pop();ensured(copiedResource.copy(route,'__QA_OUTPUT__/'+name));images[route]=name;}}
    function test_complete_all_original_levels(){
        wait(1600);enableObservedAudio();if(!activity.visible){keyClick(Qt.Key_Return);tryCompare(activity,'visible',true,2500);}configure();
        checked(activity.numberOfLevel,fixture.length);checked(items.numberOfLevel,fixture.length);
        for(var level=0;level<fixture.length;level++){
            checked(items.currentLevel,level);checked(items.pointIndexToClick,0);checked(pointImageRepeater.count,fixture[level].coordinates.length);
            recordImage(imageBack);recordImage(imageBack2);
            var expectedVoice=fixture[level].sound;
            if(expectedVoice){var expected='qrc:/gcompris/data/'+expectedVoice;tryVerify(function(){return progressed.some(function(e){return e.route===expected&&e.position>0&&e.playbackState===1;});},4000);}
            var next=target(),position=center(next);
            if(activity.mode==='number_sequence'){
                var peers=visiblePoints().filter(function(p){return p!==next;});ensured(peers.length>0);
                checked(Math.round(next.height/peers[0].height),configuredHighlight?2:1,'Highlight controls rendered dot size');
            }
            var wrongPoint=visiblePoints().filter(function(p){var c=center(p);return p!==next&&Math.hypot(c.x-position.x,c.y-position.y)>next.width+p.width;})[0];ensured(wrongPoint!==undefined);
            var wrongPosition=center(wrongPoint);mouseClick(imageBack2,wrongPosition.x,wrongPosition.y,Qt.LeftButton,Qt.NoModifier,0);checked(items.pointIndexToClick,0,'Wrong visible point rejected');wrong++;
            mouseClick(activityBackground,1,1,Qt.LeftButton,Qt.NoModifier,0);checked(items.pointIndexToClick,0,'Outside click rejected');wrong++;
            var history=[],previous=null,total=pointImageRepeater.count;
            while(history.length<total){
                next=target();position=center(next);var ordinal=history.length;
                if(activity.pointTextVisible)checked(Number(numberLabel(next).text),ordinal+1,'Visible increasing labels');
                var before=lines().length;
                if(level===0&&ordinal===0){mousePress(imageBack2,position.x,position.y,Qt.LeftButton,Qt.NoModifier,0);wait(50);}
                else if(level===0&&ordinal===1){mouseMove(imageBack2,position.x,position.y,20,Qt.LeftButton);mouseRelease(imageBack2,position.x,position.y,Qt.LeftButton,Qt.NoModifier,0);}
                else mouseClick(imageBack2,position.x,position.y,Qt.LeftButton,Qt.NoModifier,0);
                history.push(position);checked(items.pointIndexToClick,history.length,'One real click advances one point');
                if(history.length<total){
                    var pause=fixture[level].breaks[ordinal];
                    checked(lines().length,before+(pause?0:1),'No connector across independent strokes');
                    if(pause&&ordinal>0)pauses++;
                    if(!pause){var found=lines().some(function(line){return Math.abs(line.x-previous.x)<0.5&&Math.abs(line.y-previous.y)<0.5&&Math.abs(line.x2-position.x)<0.5&&Math.abs(line.y2-position.y)<0.5&&Number.isFinite(line.rotation);});ensured(found,'Actual line joins the two clicked positions');}
                }
                previous=position;
            }
            checked(lines().length,0);checked(String(imageBack2.source),activity.resourceUrl+fixture[level].imageName2);recordImage(imageBack2);ensured(bonus.isPlaying);
            if(level===0||level===fixture.length-1)grabImage(activityBackground).save('__QA_OUTPUT__/level'+(level+1)+'-complete.png');
            if(configuredMode===1)tryCompare(items,'currentLevel',(level+1)%fixture.length,7000);
            else{tryCompare(bonus,'isPlaying',false,7000);checked(items.currentLevel,level,'Manual mode keeps completed drawing');checked(items.pointIndexToClick,total);button('bar_next.svg');tryCompare(items,'currentLevel',(level+1)%fixture.length,2000);}
            completed.push({level:level+1,points:history.length,final:fixture[level].imageName2});console.log('DRAWING_LEVEL',activity.mode,level+1,history.length);
        }
        checked(wins,fixture.length);checked(items.pointIndexToClick,0);
    }
    function cleanupTestCase(){console.log('NATIVE_DRAWING_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,mode:configuredMode,highlight:configuredHighlight,completed:completed,wins:wins,wrong:wrong,pauses:pauses,images:images,requested:requested,playing:playing,progressed:progressed,audioErrors:audioErrors,copiedRoutes:copiedRoutes,clickSoundStatus:clickSound.status}));}
}
