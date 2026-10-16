// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'WaterPublicControls'
 when:activity.visible
__COMMON__
 function test_controls(){wait(1300);keyClick(Qt.Key_Return);tryCompare(message,'visible',false,2000);helpPT('água');click(sun);tryVerify(()=>vapor.opacity>0.9,2500);evidence.inputAfterHelp=true;evidence.partial={vapor:point(vapor),cloud:point(cloud)};icon('bar_reload.svg');tryCompare(vapor,'opacity',0,3000);tryCompare(cloud,'opacity',0,3000);tryCompare(towerfill,'scale',0,3000);verify(!tuxbath.visible);evidence.restarted={vapor:point(vapor),cloud:point(cloud),fill:point(fillpipe),waste:point(wastepipe),tower:point(towerfill),instruction:String(infoPanel.textItem.text)};evidence.partialRestart=true;click(sun);tryVerify(()=>vapor.opacity>0.9,2500);evidence.menuDuringMotion=point(vapor);menu();}
}
