// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'FifteenPortugueseVisibleHelp'
 when:activity.visible&&items.numberOfLevel>0
 property var evidence: ({})
__VISIBLE__
 function test_visible_help(){wait(1800);icon('bar_help.svg');var help=pageView.currentItem;evidence={title:String(help.title),content:String(help.content)};grabImage(pageView).save('__QA_OUTPUT__/help.png');ensure(help.title==='O jogo dos quinze');ensure(help.content.indexOf('Clica ou arrasta uma peça junto ao espaço vazio para a mover para esse espaço.')>=0,'Precise Portuguese movement instruction');ensure(help.content.indexOf('movrt')<0);}
 function cleanupTestCase(){console.log('NATIVE_SLIDING_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
