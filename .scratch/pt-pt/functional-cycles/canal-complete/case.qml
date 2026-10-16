// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name: 'CanalByPhysicalChamberRules'
 when: activity.visible && water.width>0
 property var journeys: []
 property var evidence: ({})
 property var actions: [[{"action": "gate-left", "after": {"boat": 0, "water": 0, "left_gate": true, "right_gate": false, "left_valve": false, "right_valve": false}}, {"action": "boat", "after": {"boat": 1, "water": 0, "left_gate": true, "right_gate": false, "left_valve": false, "right_valve": false}}, {"action": "gate-left", "after": {"boat": 1, "water": 0, "left_gate": false, "right_gate": false, "left_valve": false, "right_valve": false}}, {"action": "valve-right", "after": {"boat": 1, "water": 1, "left_gate": false, "right_gate": false, "left_valve": false, "right_valve": true}}, {"action": "gate-right", "after": {"boat": 1, "water": 1, "left_gate": false, "right_gate": true, "left_valve": false, "right_valve": true}}, {"action": "boat", "after": {"boat": 2, "water": 1, "left_gate": false, "right_gate": true, "left_valve": false, "right_valve": true}}], [{"action": "valve-right", "after": {"boat": 2, "water": 1, "left_gate": false, "right_gate": true, "left_valve": false, "right_valve": false}}, {"action": "boat", "after": {"boat": 1, "water": 1, "left_gate": false, "right_gate": true, "left_valve": false, "right_valve": false}}, {"action": "gate-right", "after": {"boat": 1, "water": 1, "left_gate": false, "right_gate": false, "left_valve": false, "right_valve": false}}, {"action": "valve-left", "after": {"boat": 1, "water": 0, "left_gate": false, "right_gate": false, "left_valve": true, "right_valve": false}}, {"action": "gate-left", "after": {"boat": 1, "water": 0, "left_gate": true, "right_gate": false, "left_valve": true, "right_valve": false}}, {"action": "boat", "after": {"boat": 0, "water": 0, "left_gate": true, "right_gate": false, "left_valve": true, "right_valve": false}}]]
 function all(root){var out=[root];if(root.children)for(var child of root.children)out=out.concat(all(child));return out;}
 function ensure(value,text){if(!value)grabImage(pageView).save('__QA_OUTPUT__/failure.png');verify(value,text||'');}
 function click(item){var p=item.mapToItem(pageView,item.width/2,item.height/2);ensure(p.x>=0&&p.x<pageView.width&&p.y>=0&&p.y<pageView.height,'Input lies on screen');mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);}
 function pose(item){var p=item.mapToItem(activityBackground,item.width/2,item.height/2);return {x:p.x,y:p.y,width:item.width,height:item.height,source:item.source!==undefined?String(item.source):null};}
 function view(){return {boat:pose(boat),water:pose(water),gates:[pose(door1),pose(door2)],valves:[pose(lock1),pose(lock2)],lights:[String(leftLight.source),String(rightLight.source)]};}
 function moving(a,b){return Math.abs(a.boat.x-b.boat.x)>0.01||Math.abs(a.boat.y-b.boat.y)>0.01||Math.abs(a.water.height-b.water.height)>0.01||a.gates.some((r,i)=>Math.abs(r.height-b.gates[i].height)>0.01)||a.valves.some((r,i)=>Math.abs(r.height-b.valves[i].height)>0.01);}
 function settle(){var samples=[view()],stable=0,start=Date.now();while(stable<7&&Date.now()-start<9000){wait(100);var next=view();stable=moving(samples[samples.length-1],next)?0:stable+1;samples.push(next);}ensure(stable>=7,'Visible geometry settles without changing clocks');return samples;}
 function test_round_trip(){
  wait(1200);compare(activity.numberOfLevel,0);keyClick(Qt.Key_Return);tryCompare(message,'visible',false,2000);var initial=view();settle();
  click(boat);var closedBoat=settle();ensure(!moving(initial,closedBoat[closedBoat.length-1]),'Closed gate prevents boat passage');
  click(door2);var wrongGate=settle();ensure(wrongGate[wrongGate.length-1].gates[1].height===initial.gates[1].height,'Wrong water height blocks high-side gate');
  click(lock1);settle();var beforeValve=view();click(lock2);var wrongValve=settle();ensure(!moving(beforeValve,wrongValve[wrongValve.length-1]),'Opposite valves interlock');click(lock1);settle();evidence.rejected={boat:closedBoat,gate:wrongGate,valve:wrongValve};
  var low=initial.water.height,high=null,bonusCount=0;
  for(var leg=0;leg<actions.length;leg++){
   var rows=[];
   for(var choice of actions[leg]){
    var before=view(),target={'gate-left':door1,'gate-right':door2,'valve-left':lock1,'valve-right':lock2,'boat':boat}[choice.action];click(target);var samples=settle(),after=samples[samples.length-1],rule=choice.after;
    for(var j=0;j<2;j++){
     var open=j===0?rule.left_gate:rule.right_gate;ensure(open?after.gates[j].height<initial.gates[j].height:Math.abs(after.gates[j].height-initial.gates[j].height)<1,'Drawn gate matches independent physical rule');ensure(after.lights[j].indexOf(open?'green':'red')>=0,'Traffic light matches gate');var valve=j===0?rule.left_valve:rule.right_valve;ensure(valve?after.valves[j].height<initial.valves[j].height:Math.abs(after.valves[j].height-initial.valves[j].height)<1,'Drawn valve matches plan');
    }
    if(rule.water===0)ensure(Math.abs(after.water.height-low)<1,'Chamber reaches low water');else{ensure(after.water.height>low+10,'Chamber reaches visibly higher water');if(high===null)high=after.water.height;ensure(Math.abs(after.water.height-high)<1,'High water is repeatable');}
    var left=after.water.x-after.water.width/2,right=after.water.x+after.water.width/2;
    ensure(rule.boat===0?after.boat.x<left:rule.boat===2?after.boat.x>right:(after.boat.x>left&&after.boat.x<right),'Boat reaches expected region');
    if(before.boat.x>left&&before.boat.x<right&&Math.abs(after.water.height-before.water.height)>10)ensure(Math.abs((after.boat.y-before.boat.y)+(after.water.height-before.water.height))<2,'Floating boat follows water level');
    rows.push({action:choice.action,before:before,after:after,samples:samples});
    if(leg===0&&choice.action==='boat'&&rule.boat===2){tryCompare(bonus,'isPlaying',true,1500);ensure(String(bonus.source).indexOf('good')>=0,'Natural success Bonus on collecting logs');bonusCount++;tryCompare(bonus,'isPlaying',false,7000);}
   }
   journeys.push({destination:leg===0?'right':'left',steps:rows,final:view()});grabImage(pageView).save('__QA_OUTPUT__/journey-'+leg+'.png');
  }
  compare(bonusCount,1);ensure(String(boat.source).endsWith('boat1.svg'),'Returning unloads the logs');evidence.bonusCount=bonusCount;evidence.completeRoundTrip=true;
 }
 function cleanupTestCase(){console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,journeys:journeys,evidence:evidence}));}
}
