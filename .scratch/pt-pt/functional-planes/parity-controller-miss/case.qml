// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:'NaturalFlightAcrossFourSequenceLevels'
    when:activity.visible&&items.numberOfLevel>0
    property var expectedLevels: [["0", "2", "4", "6", "8", "10", "12", "14", "16", "18", "20"], ["1", "3", "5", "7", "9", "11", "13", "15", "17", "19"], ["0", "2", "4", "6", "8", "10", "12", "14", "16", "18", "20"], ["1", "3", "5", "7", "9", "11", "13", "15", "17", "19"]]
    property var observations: []
    property var tutorialPages: []
    function ensure(value,message){if(!value){console.log('PLANE_ASSERT',message,new Error().stack);grabImage(pageView).save('__QA_OUTPUT__/failure.png');}verify(value,message||'');}
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var value=find(child,predicate);if(value)return value;}return null;}
    function clouds(){var result=[];for(var item of activityBackground.children){if(item.source!==undefined&&/\/cloud(?:_storm)?\.svg$/.test(String(item.source))&&item.visible&&item.opacity>0.5&&item.x>=0&&item.x+item.width<=activityBackground.width){var label=find(item,function(child){return child.text!==undefined&&child.visible&&String(child.text).length>0;});if(label)result.push({item:item,text:String(label.text)});}}return result;}
    function click(item){var point=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,point.x,point.y,Qt.LeftButton,Qt.NoModifier,0);wait(100);}
    function icon(root,suffix){var item=find(root,function(child){return child.source!==undefined&&String(child.source).endsWith(suffix)&&child.visible;});ensure(item!==null,'Visible icon '+suffix);click(item);wait(300);}
    function capture(text,wrong,requireMove){
        var chosen=null;tryVerify(function(){var options=clouds().filter(function(row){return wrong?row.text!==text:row.text===text;});if(options.length)chosen=options[0];return chosen!==null;},45000);
        var object=chosen.item,initial={x:plane.x,y:plane.y},ticks=0,moved=false,firstCloud={x:object.x,y:object.y},finished=false,tracked=[object];
        while(ticks++<140){
            for(var row of clouds()){if(row.text===text&&tracked.indexOf(row.item)<0)tracked.push(row.item);}
            if(!wrong&&tracked.some(function(item){return item&&item.opacity<0.5;})){finished=true;break;}
            if(object.opacity<0.5){ensure(!wrong,'Wrong cloud must not be captured');finished=true;break;}
            if(wrong&&String(object.source).endsWith('cloud_storm.svg')){finished=true;break;}
            ensure(object.x+object.width>0,'Cloud left before interception');
            mouseClick(activityBackground,object.x+object.width/2,object.y+object.height/2,Qt.LeftButton,Qt.NoModifier,0);
            wait(100);if(Math.abs(plane.x-initial.x)+Math.abs(plane.y-initial.y)>5)moved=true;
        }
        ensure(finished,'Natural collision and feedback');
        if(requireMove)ensure(moved,'Plane moved through exposed pointer input');
        var row={expected:text,drawn:chosen.text,wrong:wrong,planeMoved:moved,cloudMoved:Math.abs(object.x-firstCloud.x)>1,feedback:wrong?'storm':'fade',start:initial,end:{x:plane.x,y:plane.y}};
        ensure(row.cloudMoved,'Cloud moved at its natural speed');
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

    function test_all_four_visible_sequences(){
        wait(1400);tutorialPages=tutorial();compare(items.numberOfLevel,4);compare(items.currentLevel,0);
        for(var level=0;level<4;level++){
            wait(1200);compare(items.currentLevel,level);compare(score.visible,level<2);
            var accepted=[];
            for(var text of expectedLevels[level]){
                accepted.push(capture(text,false));
                console.log('PLANE_PROGRESS',level+1,accepted.length,expectedLevels[level].length,text);
            }
            tryCompare(bonus,'isPlaying',true,2000);
            observations.push({level:level+1,indicationVisible:level<2,captures:accepted,bonus:true});
            tryCompare(items,'currentLevel',(level+1)%4,10000);tryCompare(bonus,'isPlaying',false,4000);
        }
        compare(items.currentLevel,0);
    }
    function cleanupTestCase(){console.log('NATIVE_PLANE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,observations:observations,tutorial:tutorialPages}));}
}
