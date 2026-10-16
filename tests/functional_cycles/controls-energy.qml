// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'EnergyPublicControls'
 when:activity.visible
__COMMON__
 function test_controls(){wait(1300);compare(activity.numberOfLevel,3);keyClick(Qt.Key_Return);tryCompare(message,'visible',false,2000);helpPT('energia');icon('bar_previous.svg');compare(activity.currentLevel,2);tryVerify(()=>wind.item!==null&&solar.item!==null,3000);icon('bar_next.svg');compare(activity.currentLevel,2);icon('bar_previous.svg');compare(activity.currentLevel,1);icon('bar_previous.svg');compare(activity.currentLevel,0);evidence.navigation=true;click(stepDown);tryVerify(()=>stepDownOn.visible,1000);evidence.inputAfterHelp=true;click(sun);var vapor=all(hydro.item).find(c=>c.source!==undefined&&String(c.source).endsWith('watercycle/resource/vapor.svg'));verify(vapor!==undefined);tryVerify(()=>vapor.opacity>0.9,2500);evidence.partial={transformer:point(stepDownOn),vapor:point(vapor)};icon('bar_reload.svg');tryVerify(()=>!stepDownOn.visible&&vapor.opacity===0,3000);evidence.partialRestart=true;evidence.restarted={transformer:point(stepDownOn),vapor:point(vapor)};click(sun);tryVerify(()=>vapor.opacity>0.9,2500);evidence.menuDuringMotion=point(vapor);menu();}
}
