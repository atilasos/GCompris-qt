// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'PenaltyHelpPointsToGoalAndExplainsDelay'
 when:activity.visible
 property var evidence: ({})
 function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var result=find(child,predicate);if(result)return result;}return null;}
 function test_help(){
  wait(1700);var item=find(bar,function(o){return o.visible&&o.source!==undefined&&String(o.source).endsWith('bar_help.svg');});verify(item!==null);var p=item.mapToItem(pageView,item.width/2,item.height/2),depth=pageView.depth;mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);tryCompare(pageView,'depth',depth+1,2500);wait(500);var help=pageView.currentItem;
  evidence={title:help.title,content:help.content,goal:help.content.indexOf('Faz duplo clique ou toca duas vezes num dos lados da baliza para rematar.')>=0,delay:help.content.indexOf('Se o segundo clique demorar demasiado, o Tux apanha a bola.')>=0};grabImage(pageView).save('__QA_OUTPUT__/help.png');compare(help.title,'Grande penalidade');verify(evidence.goal&&evidence.delay,'Help must name goal target and timing, rather than the ball');
 }
 function cleanupTestCase(){console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
