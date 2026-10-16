// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 when:activity.visible
 property var evidence:({})
 function test_target_instruction(){wait(1000);evidence.instruction=String(guess.text);console.log('PAINTED_TARGET',evidence.instruction);verify(evidence.instruction.indexOf('Número a obter: ')===0);var depth=pageView.depth;function descendants(root){var found=[root];if(root.children)for(var c of root.children)found=found.concat(descendants(c));return found;}var helpIcon=descendants(bar).find(c=>c.source!==undefined&&String(c.source).endsWith('bar_help.svg'));verify(helpIcon!==undefined);mouseClick(helpIcon,helpIcon.width/2,helpIcon.height/2,Qt.LeftButton,Qt.NoModifier,10);tryCompare(pageView,'depth',depth+1,2000);wait(300);evidence.helpTitle=String(pageView.currentItem.title);verify(evidence.helpTitle==='Adivinha a conta');keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth,2000);wait(300);ActivityInfoTree.startingActivity='';keyClick(Qt.Key_W,Qt.ControlModifier);tryCompare(pageView,'depth',1,2000);verify(pageView.currentItem.isMenu);evidence.menu=true;}
 function cleanupTestCase(){grabImage(pageView).save('__QA_OUTPUT__/instruction.png');console.log('NATIVE_CHALLENGES_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
