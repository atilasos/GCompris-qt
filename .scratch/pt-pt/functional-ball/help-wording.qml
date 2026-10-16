// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'CatchHelpDescribesCoordinationAndDrawnHands'
 when:activity.visible
 property var evidence: ({})
 function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var result=find(child,predicate);if(result)return result;}return null;}
 function click(item){verify(item!==null);var p=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);}
 function test_help_wording(){
  wait(1200);keyClick(Qt.Key_Return);tryCompare(message,'visible',false,2000);wait(1700);var depth=pageView.depth;
  click(find(bar,function(o){return o.visible&&o.source!==undefined&&String(o.source).endsWith('bar_help.svg');}));tryCompare(pageView,'depth',depth+1,2500);wait(500);var help=pageView.currentItem;
  evidence={title:help.title,content:help.content,goal:help.content.indexOf('Sincronizar os movimentos das mãos esquerda e direita.')>=0,manual:help.content.indexOf('Num ecrã tátil, toca nas duas mãos desenhadas ao mesmo tempo.')>=0};grabImage(pageView).save('__QA_OUTPUT__/help.png');compare(help.title,'Enviar a bola para o Tux');verify(evidence.goal&&evidence.manual,'Goal and touch instruction explain the visible coordination exercise');
 }
 function cleanupTestCase(){console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
