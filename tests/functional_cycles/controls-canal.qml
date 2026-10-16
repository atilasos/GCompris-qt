// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'CanalPublicControls'
 when:activity.visible
__COMMON__
 function test_controls(){wait(1300);keyClick(Qt.Key_Return);tryCompare(message,'visible',false,2000);helpPT('eclusa');var before=point(door1);click(door1);tryVerify(()=>door1.height<before.height-10,3000);tryVerify(()=>String(leftLight.source).indexOf('green')>=0,2000);evidence.inputAfterHelp=true;wait(4000);var rest=point(boat);click(boat);tryVerify(()=>point(boat).x>rest.x+2,2000);evidence.menuDuringMotion={before:rest,moving:point(boat)};menu();}
}
