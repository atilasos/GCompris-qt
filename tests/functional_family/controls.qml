TestCase {
 name:'FamilyNavigationPartialSelectionHelpFocusAndMenu'
 when:activity.visible&&nodeRepeater.count>0
 property var evidence: ({})
__VISIBLE__
__ORACLE__
 function test_controls(){wait(1900);var initial=screen();evidence.initial=initial;compare(activity.numberOfLevel,18);icon('bar_previous.svg');compare(bar.level,18);evidence.previousWrap=screen();icon('bar_next.svg');compare(bar.level,1);evidence.nextWrap=screen();icon('bar_next.svg');compare(bar.level,2);icon('bar_previous.svg');compare(bar.level,1);evidence.navigation=true;
  for(var suffix of ['bar_reload.svg','bar_activity_config.svg'])verify(find(bar,function(node){return node.source!==undefined&&String(node.source).endsWith(suffix)&&drawn(node);})===null,'No exposed '+suffix);evidence.reloadExposed=false;evidence.configurationExposed=false;
  if(activity.mode==='find_relative'){click(nodeRepeater.itemAt(0));wait(150);compare(String(nodeRepeater.itemAt(0).border.color),'#e77936');evidence.partial=screen();icon('bar_next.svg');compare(bar.level,2);icon('bar_previous.svg');compare(bar.level,1);var reset=screen();verify(reset.people.every(function(person){return person.border==='#373737';}));evidence.partialReset=reset;}
  var depth=pageView.depth;icon('bar_help.svg');tryCompare(pageView,'depth',depth+1);var help=pageView.currentItem;compare(help.title,activity.mode==='family'?'Família':'Indicar os parentes');verify(help.content.indexOf('árvore genealógica')>=0);verify(help.content.indexOf('anel')>=0);verify(help.content.indexOf('A family tree')<0);evidence.help={title:String(help.title),content:String(help.content)};grabImage(pageView).save('__QA_OUTPUT__/help.png');keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth);wait(1900);
  var s=screen(),g=kinGraph(s);evidence.afterHelp=s;if(activity.mode==='family'){var answer=familyAnswer(s,g);var selected=s.options.indexOf(answer.label);verify(selected>=0);evidence.selection={index:selected,label:answer.label};click(answersChoice.itemAt(selected));}else{var pairs=pairChoices(g,s.question.split(': ').pop());verify(pairs.length>0);var pair=[pairs[0][1],pairs[0][0]];evidence.selection={pair:pair};click(nodeRepeater.itemAt(pair[0]));wait(180);click(nodeRepeater.itemAt(pair[1]));}tryVerify(function(){return bonus.opacity>0.5&&String(bonus.source).endsWith('/lion_good.svg');},3500);evidence.bonus=String(bonus.source);tryCompare(bonus,'isPlaying',false,9000);compare(bar.level,2);evidence.focusAfterHelp=true;
  ActivityInfoTree.startingActivity='';icon('bar_home.svg');tryCompare(pageView,'depth',1);verify(pageView.currentItem.isMenu);evidence.menu=true;grabImage(pageView).save('__QA_OUTPUT__/menu.png');
 }
 function cleanupTestCase(){console.log('NATIVE_FAMILY_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
