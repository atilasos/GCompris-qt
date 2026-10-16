// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:"GraduatedPortugueseMeaning"
 when:activity.visible && ruler.children.length>3
 property var evidence:({})
__VISIBLE__
 function test_instruction_help_and_dataset_labels() {
  wait(1200);evidence.instruction=String(instructionPanel.textItem.text);
  grabImage(pageView).save('__QA_OUTPUT__/instruction.png');var depth=pageView.depth;
  icon(bar,'bar_help.svg');tryCompare(pageView,'depth',depth+1,2000);wait(400);
  evidence.help=String(pageView.currentItem.content);evidence.title=String(pageView.currentItem.title);grabImage(pageView).save('__QA_OUTPUT__/help.png');
  keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth,2000);wait(300);
  icon(bar,'bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2000);wait(500);
  evidence.datasets=descendants(dialogActivityConfig).filter(child=>child.checked!==undefined && child.text!==undefined).map(child=>String(child.text));
  grabImage(pageView).save('__QA_OUTPUT__/datasets.png');keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth,2000);wait(300);
  console.log('GRADUATED_PORTUGUESE',JSON.stringify(evidence));
  if(activity.activityMode==='tick2number') {
   compare(evidence.instruction,'Encontra o número indicado.');
   verify(evidence.help.indexOf('Delete: limpar a resposta')>=0);
  } else verify(evidence.help.indexOf('Setas Esquerda e Direita: mover o cursor')>=0);
  verify(evidence.datasets.some(text=>text.indexOf('0 e 20')>=0));
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_GRADUATED_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
