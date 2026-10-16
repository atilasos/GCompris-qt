// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'GravityVisibleKeyboardAfterHelp'
 when:activity.visible&&repeater.count>0
 property var evidence: ({samples:[]})
__VISIBLE__
 function sample(label){evidence.samples.push({label:label,column:previewColumn(),x:fallingPiece.x,pointerX:dynamic.mouseX,pointerY:dynamic.mouseY,activityFocus:activity.activeFocus,backgroundFocus:activityBackground.activeFocus});}
 function test_after_help(){wait(1800);if(!humanBoth){fresh(2);icon('bar_reload.svg');}fresh(__STARTER__);sample('initial');icon('bar_help.svg');keyClick(Qt.Key_Escape);wait(2800);sample('closedHelp');for(var n=0;n<3;n++){var beforeColumn=previewColumn();keyClick(Qt.Key_Left);for(var tick=0;tick<4;tick++){wait(300);sample('Left'+n+' tick'+tick);}ensure(previewColumn()===(beforeColumn+6)%7,'Left moves one visible column, including wrap');}sample('beforeDown');var before=snapshot().values,player=turn();keyClick(Qt.Key_Down);evidence.drop=observeSingle(before,player);sample('afterDown');grabImage(pageView).save('__QA_OUTPUT__/keyboard.png');compare(evidence.drop.location,evidence.samples[evidence.samples.length-2].column,'Down drops in visibly selected column');}
 function cleanupTestCase(){console.log('NATIVE_ALIGNMENT_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
