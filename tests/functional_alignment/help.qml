// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'CorrectFourTokenPortugueseHelp'
 when:activity.visible&&repeater.count>0
 property var evidence: ({})
__VISIBLE__
 function test_help(){wait(1800);icon('bar_help.svg');var help=pageView.currentItem;var manual='Joga com '+(humanBoth?'um amigo':'o Tux')+'. À vez, clica na coluna onde queres deixar cair uma peça. O primeiro jogador a alinhar quatro peças ganha.';evidence={title:String(help.title),content:String(help.content),expected:manual};grabImage(pageView).save('__QA_OUTPUT__/help.png');ensure(help.content.indexOf(manual)>=0,'Portuguese gravity and four-token rule');ensure(help.content.indexOf('3 marcas')<0);if(!humanBoth)ensure(help.content.indexOf('Usa os botões com setas para selecionar manualmente o nível de dificuldade. O Tux joga melhor quando aumentas o nível.')>=0,'Visible level buttons, not board arrow keys');}
 function cleanupTestCase(){console.log('NATIVE_ALIGNMENT_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
