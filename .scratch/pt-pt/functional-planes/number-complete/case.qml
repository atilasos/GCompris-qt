// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:'NaturalFlightAcrossFourSequenceLevels'
    when:activity.visible&&items.numberOfLevel>0
    property var expectedLevels: [["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"], ["10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20"], ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"], ["10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20"]]
    property var observations: []
    property var tutorialPages: []
    function ensure(value,message){if(!value){console.log('PLANE_ASSERT',message,new Error().stack);grabImage(pageView).save('__QA_OUTPUT__/failure.png');}verify(value,message||'');}
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var value=find(child,predicate);if(value)return value;}return null;}
    function clouds(){var result=[];for(var item of activityBackground.children){if(item.source!==undefined&&/\/cloud(?:_storm)?\.svg$/.test(String(item.source))&&item.visible&&item.opacity>0.5&&item.x>=0&&item.x+item.width<=activityBackground.width){var label=find(item,function(child){return child.text!==undefined&&child.visible&&String(child.text).length>0;});if(label)result.push({item:item,text:String(label.text)});}}return result;}
    function click(item){var point=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,point.x,point.y,Qt.LeftButton,Qt.NoModifier,0);wait(100);}
    function icon(root,suffix){var item=find(root,function(child){return child.source!==undefined&&String(child.source).endsWith(suffix)&&child.visible;});ensure(item!==null,'Visible icon '+suffix);click(item);wait(300);}
    function capture(text,wrong,requireMove){
        var initial={x:plane.x,y:plane.y},tracked=[],object=null,drawn='',firstCloud=null,moved=false,finished=false,escaped=0;
        for(var tick=0;tick<1000;tick++){
            var visible=clouds();
            for(var row of visible){if(row.text===text&&!tracked.some(function(entry){return entry.item===row.item;}))tracked.push({item:row.item,x:row.item.x,y:row.item.y});}
            if(!wrong){var faded=tracked.filter(function(entry){return entry.item&&entry.item.opacity<0.5;});if(faded.length){object=faded[0].item;firstCloud={x:faded[0].x,y:faded[0].y};finished=true;break;}}
            if(object&&wrong&&String(object.source).endsWith('cloud_storm.svg')){finished=true;break;}
            if(object&&(object.x+object.width<=0||object.opacity<0.5)){object=null;escaped++;}
            if(!object){
                var candidates=visible.filter(function(row){return (wrong?row.text!==text:row.text===text)&&row.item.x>activityBackground.width*0.35;});
                candidates.sort(function(a,b){return b.item.x-a.item.x;});
                if(candidates.length){object=candidates[0].item;drawn=candidates[0].text;firstCloud={x:object.x,y:object.y};}
            }
            if(object)mouseClick(activityBackground,object.x+object.width/2,object.y+object.height/2,Qt.LeftButton,Qt.NoModifier,0);
            wait(100);if(Math.abs(plane.x-initial.x)+Math.abs(plane.y-initial.y)>5)moved=true;
        }
        ensure(finished,'Natural collision and feedback within 100 seconds');
        if(requireMove)ensure(moved,'Plane moved through exposed pointer input');
        var row={expected:text,drawn:wrong?drawn:text,wrong:wrong,planeMoved:moved,cloudMoved:firstCloud!==null&&object!==null&&Math.abs(object.x-firstCloud.x)>1,feedback:wrong?'storm':'fade',escapedCandidates:escaped,start:initial,end:{x:plane.x,y:plane.y}};
        // An already observed matching cloud can cross the plane while waiting for a fresh candidate.
        if(firstCloud!==null)ensure(row.cloudMoved,'Cloud moved at its natural speed');
        console.log('PLANE_CAPTURE',JSON.stringify(row));return row;
    }

    function textButton(text){var button=find(tutorialSection,function(item){return item.visible&&item.clicked!==undefined&&item.text===text;});ensure(button!==null,'Tutorial button '+text);click(button);wait(250);}
    function visibleTexts(root){var result=[];function walk(item){if(item.visible&&item.text!==undefined&&String(item.text).length>0)result.push(String(item.text));if(item.children)for(var child of item.children)walk(child);}walk(root);return result;}
    function tutorial(){
        if(!tutorialImage.visible)return [];
        var pages=[];
        for(var page=0;page<8;page++){
            compare(tutorialSection.tutorialNumber,page);wait(300);var texts=visibleTexts(tutorialSection),answers=[];
            ensure(texts.join(' ').indexOf('This activity')<0,'Portuguese tutorial');
            if(page===0)ensure(texts.indexOf('Esta atividade ensina os números pares e ímpares.')>=0);
            if(page>=5){
                var panel=tutorialSection.tutorialQml;ensure(panel!==null);
                var options=[];for(var item of panel.children){if(item.textLabel!==undefined&&/^\d+$/.test(item.textLabel))options.push(item);}
                compare(options.length,2);var question=visibleTexts(panel).join(' ');var remainder=question.indexOf('número ímpar')>=0?1:0;
                var correct=options.filter(function(item){return Number(item.textLabel)%2===remainder;})[0],incorrect=options.filter(function(item){return item!==correct;})[0];
                var wrongText=String(incorrect.textLabel);click(incorrect);tryVerify(function(){return visibleTexts(panel).join(' ').indexOf('Está errado:')>=0;},2000);wait(1000);
                var errorText=visibleTexts(panel).filter(function(text){return text.indexOf('Está errado:')===0;})[0];ensure(errorText.indexOf(wrongText)>=0);ensure(errorText.indexOf('resto igual a '+(Number(wrongText)%2))>=0);
                click(correct);tryVerify(function(){return visibleTexts(panel).indexOf('Ótimo')>=0;},2000);wait(1000);
                answers=[{chosen:wrongText,remainder:Number(wrongText)%2,correct:false,feedback:errorText},{chosen:String(correct.textLabel),remainder:Number(correct.textLabel)%2,correct:true,feedback:'Ótimo'}];
            }
            pages.push({page:page+1,texts:texts,answers:answers});
            if(page===3){textButton('Anterior');compare(tutorialSection.tutorialNumber,2);textButton('Seguinte');compare(tutorialSection.tutorialNumber,3);}
            if(page<7)textButton('Seguinte');else textButton('Iniciar');
        }
        tryCompare(tutorialImage,'visible',false);return pages;
    }

    property var visibleCloudHistory: []
    property var capturedClouds: []
    property var currentExpected: []
    property int observedLevel: 0
    function observeClouds(){
        for(var object of activityBackground.children){
            if(object.source===undefined||!/\/cloud(?:_storm)?\.svg$/.test(String(object.source))||!object.visible||object.opacity<=0.5)continue;
            var label=find(object,function(child){return child.text!==undefined&&child.visible&&String(child.text).length>0;});
            if(!label)continue;var point=label.mapToItem(activityBackground,0,0);
            if(point.x<0||point.x+label.width>activityBackground.width||point.y<0||point.y+label.height>activityBackground.height-bar.height)continue;
            if(!visibleCloudHistory.some(function(row){return row.item===object;}))visibleCloudHistory.push({item:object,text:String(label.text),x:object.x,y:object.y,seen:false});
        }
        for(var row of visibleCloudHistory){
            if(row.item&&!row.seen&&row.item.opacity<0.5){
                row.seen=true;
                ensure(capturedClouds.length<currentExpected.length,'Only the declared sequence is captured');
                var wanted=currentExpected[capturedClouds.length];
                ensure(row.text===wanted,'Observed fade must follow independent order: expected '+wanted+', got '+row.text);
                var evidence={expected:wanted,drawn:row.text,feedback:'fade',cloudMoved:Math.abs(row.item.x-row.x)>1,plane:{x:plane.x,y:plane.y}};
                ensure(evidence.cloudMoved,'Natural cloud movement before capture');capturedClouds.push(evidence);
                console.log('PLANE_PROGRESS',observedLevel,capturedClouds.length,currentExpected.length,row.text);
            }
        }
    }
    function pursueNextVisibleCloud(){
        var before=capturedClouds.length,selected=null;
        for(var tick=0;tick<1000&&capturedClouds.length===before;tick++){
            observeClouds();if(capturedClouds.length!==before)break;
            var candidates=clouds().filter(function(row){return row.text===currentExpected[before]&&row.item.x>activityBackground.width*0.35;});
            candidates.sort(function(a,b){return b.item.x-a.item.x;});
            if(candidates.length)selected=candidates[0].item;
            if(selected&&selected.x+selected.width>0&&selected.opacity>0.5){
                // Intercept in the middle of the field, keeping incoming labels visible.
                mouseClick(activityBackground,Math.min(selected.x+selected.width/2,activityBackground.width*0.6),selected.y+selected.height/2,Qt.LeftButton,Qt.NoModifier,0);
            }
            wait(100);
        }
        ensure(capturedClouds.length>before,'A naturally drawn target is intercepted within 100 seconds');
    }

    function test_all_four_visible_sequences(){
        wait(1400);tutorialPages=tutorial();compare(items.numberOfLevel,4);compare(items.currentLevel,0);
        for(var level=0;level<4;level++){
            wait(1200);compare(items.currentLevel,level);compare(score.visible,level<2);
            visibleCloudHistory=[];capturedClouds=[];currentExpected=expectedLevels[level];observedLevel=level+1;
            while(capturedClouds.length<currentExpected.length)pursueNextVisibleCloud();
            var accepted=capturedClouds.slice();
            tryCompare(bonus,'isPlaying',true,2000);
            observations.push({level:level+1,indicationVisible:level<2,captures:accepted,bonus:true});
            tryCompare(items,'currentLevel',(level+1)%4,10000);tryCompare(bonus,'isPlaying',false,4000);
        }
        compare(items.currentLevel,0);
    }
    function cleanupTestCase(){console.log('NATIVE_PLANE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,observations:observations,tutorial:tutorialPages}));}
}
