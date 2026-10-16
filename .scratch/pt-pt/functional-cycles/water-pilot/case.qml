// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'WaterCycleByDrawnInstructionsAndPipes'
 when:activity.visible&&layoutArea.width>0
 property var evidence:({intro:[],stages:[]})
 function all(root){var found=[root];if(root.children)for(var c of root.children)found=found.concat(all(c));return found;}
 function ensure(value,message){if(!value){console.log('WATER_ASSERT',message);evidence.failure={message:message,view:view()};grabImage(pageView).save('__QA_OUTPUT__/failure.png');}verify(value,message||'');}
 function point(item){var p=item.mapToItem(activityBackground,item.width/2,item.height/2);return {x:p.x,y:p.y,width:item.width,height:item.height,opacity:item.opacity,visible:item.visible,scale:item.scale,source:item.source!==undefined?String(item.source):null};}
 function view(){return {instruction:String(infoPanel.textItem.text),sun:point(sun),vapor:point(vapor),cloud:point(cloud),rain:point(rain),river:point(river),fill:point(fillpipe),waste:point(wastepipe),tower:point(towerfill),boat:point(tuxboat),parked:point(boatparked),shower:point(shower),bath:point(tuxbath)};}
 function stage(name){evidence.stages.push({name:name,timestamp:Date.now(),view:view()});grabImage(pageView).save('__QA_OUTPUT__/'+name+'.png');}
 function click(item){ensure(item.visible&&item.width>0&&item.height>0,'Visible control');var p=item.mapToItem(pageView,item.width/2,item.height/2);ensure(p.x>=0&&p.y>=0&&p.x<pageView.width&&p.y<pageView.height,'Control lies on screen');mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);}
 function test_cycle(){
  wait(1200);compare(activity.numberOfLevel,0);ensure(message.visible,'Intro offered');
  for(var i=0;i<4;i++){var t=all(message).filter(c=>c.visible&&c.text!==undefined&&String(c.text).length>70).map(c=>String(c.text));compare(t.length,1);evidence.intro.push(t[0]);keyClick(Qt.Key_Space);wait(300);}
  tryCompare(message,'visible',false,2000);wait(500);stage('initial');var dry=fillpipe.opacity;click(waterplant);wait(400);ensure(Math.abs(fillpipe.opacity-dry)<0.01,'Pump has no water before rain');evidence.dryPumpRejected=true;
  click(sun);tryVerify(()=>vapor.opacity>0.9,2500);stage('evaporation');tryVerify(()=>String(infoPanel.textItem.text).indexOf('nuv')>=0&&cloud.opacity>0.9&&cloud.width>0,18000);stage('cloud');click(cloud);tryVerify(()=>rain.opacity>0.9,1500);stage('rain');tryCompare(river,'opacity',1,12000);stage('river');click(waterplant);tryVerify(()=>fillpipe.opacity>0.9,2000);stage('pumping');click(sewageplant);tryVerify(()=>wastepipe.opacity>0.9,2000);stage('treatment');tryVerify(()=>towerfill.scale>=0.99,6000);tryVerify(()=>shower.visible&&boatparked.opacity>0.9,20000);stage('ready');click(shower);tryVerify(()=>tuxbath.visible,2000);tryCompare(bonus,'isPlaying',true,1500);tryVerify(()=>bonus.opacity>0.5,1500);ensure(String(bonus.source).indexOf('good')>=0,'Natural water cycle Bonus');wait(500);stage('success');evidence.bonus=String(bonus.source);evidence.cycleComplete=true;tryCompare(bonus,'isPlaying',false,7000);stage('continued');
 }
 function cleanupTestCase(){console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
