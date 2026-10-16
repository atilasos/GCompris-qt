TestCase {
 name:'EveryFamilyDrawingNaturalCompletion'
 when:activity.visible&&nodeRepeater.count>0
 property var records: []
__VISIBLE__
__ORACLE__
 function feedback(kind){tryVerify(function(){return bonus.opacity>0.5&&String(bonus.source).endsWith('/lion_'+kind+'.svg');},3500);var r={source:String(bonus.source),opacity:bonus.opacity};tryCompare(bonus,'isPlaying',false,9000);wait(350);return r;}
 function pairInput(pair){click(nodeRepeater.itemAt(pair[0]));wait(180);compare(String(nodeRepeater.itemAt(pair[0]).border.color),'#e77936');click(nodeRepeater.itemAt(pair[1]));}
 function test_all_drawings(){wait(1900);compare(activity.numberOfLevel,18);for(var level=1;level<=18;level++){
  compare(bar.level,level);var s=screen(),g=kinGraph(s),record={screen:s,graph:g,completions:[]};records.push(record);var wanted=level===18?1:level+1;
  if(activity.mode==='family'){var expected=familyAnswer(s,g);record.expected=expected;var index=s.options.indexOf(expected.label);verify(index>=0,'Independent visible relation '+expected.label);var wrong=(index+1)%s.options.length;click(answersChoice.itemAt(wrong));record.wrong={index:wrong,label:s.options[wrong],bonus:feedback('bad')};compare(bar.level,level);record.afterWrong=screen();click(answersChoice.itemAt(index));var good=feedback('good');compare(bar.level,wanted);record.completions.push({index:index,label:s.options[index],bonus:good,nextLevel:bar.level});}
  else{var question=s.question.split(': ').pop(),pairs=pairChoices(g,question);record.question=question;record.pairs=pairs;verify(pairs.length>0,'Independent visible pairs');var wrong=null;for(var a=0;a<s.people.length&&!wrong;a++)for(var b=a+1;b<s.people.length&&!wrong;b++)if(!pairs.some(function(pair){return pair[0]===a&&pair[1]===b;}))wrong=[a,b];verify(wrong!==null);click(nodeRepeater.itemAt(0));wait(100);compare(String(nodeRepeater.itemAt(0).border.color),'#e77936');click(nodeRepeater.itemAt(0));wait(150);compare(String(nodeRepeater.itemAt(0).border.color),'#373737');record.samePersonDeselect=true;pairInput(wrong);record.wrong={pair:wrong,bonus:feedback('bad')};compare(bar.level,level);record.afterWrong=screen();
   for(var pair of pairs){pairInput(pair);var good=feedback('good');compare(bar.level,wanted);record.completions.push({pair:pair,bonus:good,nextLevel:bar.level});if(record.completions.length<pairs.length){icon('bar_previous.svg');compare(bar.level,level);compare(screen().question,s.question);}}
  }
  console.log('FAMILY_PROGRESS',String(activity.mode),level,18,record.completions.length);grabImage(pageView).save('__QA_OUTPUT__/level-'+level+'.png');
 }compare(bar.level,1);}
 function cleanupTestCase(){console.log('NATIVE_FAMILY_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,records:records}));}
}
