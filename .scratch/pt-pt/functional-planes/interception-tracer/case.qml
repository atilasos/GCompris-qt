// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:'PlaneActualPointerInterception'
    when:activity.visible&&plane.visible
    property var evidence: ({})
    function ensure(value,message){if(!value){console.log('PLANE_ASSERT',message,new Error().stack);grabImage(pageView).save('__QA_OUTPUT__/failure.png');}verify(value,message||'');}
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var value=find(child,predicate);if(value)return value;}return null;}
    function clouds(){var result=[];for(var item of activityBackground.children){if(item.source!==undefined&&/\/cloud(?:_storm)?\.svg$/.test(String(item.source))&&item.visible&&item.opacity>0.5&&item.x>=0&&item.x+item.width<=activityBackground.width){var label=find(item,function(child){return child.text!==undefined&&child.visible&&String(child.text).length>0;});if(label)result.push({item:item,text:String(label.text)});}}return result;}
    function click(item){var point=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,point.x,point.y,Qt.LeftButton,Qt.NoModifier,0);wait(100);}
    function icon(root,suffix){var item=find(root,function(child){return child.source!==undefined&&String(child.source).endsWith(suffix)&&child.visible;});ensure(item!==null,'Visible icon '+suffix);click(item);wait(300);}
    function capture(text,wrong){
        var chosen=null;tryVerify(function(){var options=clouds().filter(function(row){return wrong?row.text!==text:row.text===text;});if(options.length)chosen=options[0];return chosen!==null;},45000);
        var object=chosen.item,initial={x:plane.x,y:plane.y},ticks=0,moved=false,firstCloud={x:object.x,y:object.y},finished=false;
        while(ticks++<140){
            if(object.opacity<0.5){ensure(!wrong,'Wrong cloud must not be captured');finished=true;break;}
            if(wrong&&String(object.source).endsWith('cloud_storm.svg')){finished=true;break;}
            ensure(object.x+object.width>0,'Cloud left before interception');
            mouseClick(activityBackground,object.x+object.width/2,object.y+object.height/2,Qt.LeftButton,Qt.NoModifier,0);
            wait(100);if(Math.abs(plane.x-initial.x)+Math.abs(plane.y-initial.y)>5)moved=true;
        }
        ensure(finished,'Natural collision and feedback');
        ensure(moved,'Plane moved through exposed pointer input');
        var row={expected:text,drawn:chosen.text,wrong:wrong,planeMoved:moved,cloudMoved:Math.abs(object.x-firstCloud.x)>1,feedback:wrong?'storm':'fade',start:initial,end:{x:plane.x,y:plane.y}};
        ensure(row.cloudMoved,'Cloud moved at its natural speed');
        console.log('PLANE_CAPTURE',JSON.stringify(row));return row;
    }

    function test_capture_the_first_visible_zero(){wait(1500);evidence=capture('0',false);}
    function cleanupTestCase(){console.log('NATIVE_PLANE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
