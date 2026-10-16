// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:'PlaneKeyboardMistakeHelpAndMenu'
    when:activity.visible&&items.numberOfLevel>0
    property var evidence: ({})
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

    function move(key,axis,sign){var before=plane[axis];keyPress(key);wait(500);keyRelease(key);wait(150);ensure((plane[axis]-before)*sign>5,'Physical keyboard movement '+axis);return {key:key,axis:axis,before:before,after:plane[axis]};}
    function test_controls(){
        wait(1400);if(tutorialImage.visible){textButton('Ignorar');tryCompare(tutorialImage,'visible',false);wait(1400);}
        compare(activity.activityInfo.title,"Ordem num\u00e9rica");compare(items.numberOfLevel,4);
        activity.forceActiveFocus();var movement=[move(Qt.Key_Right,'x',1),move(Qt.Key_Down,'y',1),move(Qt.Key_Left,'x',-1),move(Qt.Key_Up,'y',-1)];
        var mistake=capture("0",true);compare(bonus.isPlaying,false);compare(items.currentLevel,0);
        wait(2200);ensure(clouds().every(function(row){return !String(row.item.source).endsWith('cloud_storm.svg');}),'Storm feedback expires naturally');
        icon(bar,'bar_next.svg');compare(items.currentLevel,1);icon(bar,'bar_previous.svg');compare(items.currentLevel,0);
        icon(bar,'bar_previous.svg');compare(items.currentLevel,3);compare(score.visible,false);icon(bar,'bar_next.svg');compare(items.currentLevel,0);compare(score.visible,true);wait(1400);
        var depth=pageView.depth;icon(bar,'bar_help.svg');tryCompare(pageView,'depth',depth+1);wait(600);var help=pageView.currentItem;
        compare(help.title,"Ordem num\u00e9rica");ensure(help.content.indexOf(activity.activityInfo.manual)>=0);ensure(help.content.indexOf('teclas')>=0);ensure(help.content.indexOf('keyboard')<0);grabImage(pageView).save('__QA_OUTPUT__/help.png');
        keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth);wait(300);
        var focusMove=move(Qt.Key_Right,'x',1);
        var restarted=capture("0",false);compare(items.currentLevel,0);
        ActivityInfoTree.startingActivity='';if(false)keyClick(Qt.Key_Escape);else icon(bar,'bar_home.svg');tryCompare(pageView,'depth',1);ensure(pageView.currentItem.isMenu);
        evidence={title:"Ordem num\u00e9rica",keyboard:movement,mistake:mistake,naturalStormRecovery:true,previousNextAndWrap:true,indicationHidden:true,restartFirstCapture:restarted,helpPortuguese:true,helpEscape:true,keyboardAfterHelp:focusMove,menu:true};
    }
    function cleanupTestCase(){console.log('NATIVE_PLANE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
