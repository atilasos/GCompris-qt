TestCase {
 name:'StrictPortugueseVisibleKinship'
 when:activity.visible&&nodeRepeater.count>0
 property var records: []
__VISIBLE__
__ORACLE__
 function test_kinship_words(){wait(1900);var lexicon=['Pai','Mãe','Filho','Filha','Avô','Avó','Neto','Neta','Irmão','Irmã','Tio','Tia','Sobrinho','Sobrinha','Primo','Prima','Sogro','Sogra','Genro','Nora','Cunhado','Cunhada'];for(var i=0;i<18;i++){var s=screen(),g=kinGraph(s),record={screen:s,graph:g};records.push(record);grabImage(pageView).save('__QA_OUTPUT__/level-'+(i+1)+'.png');if(activity.mode==='family'){var expected=familyAnswer(s,g);record.expected=expected;for(var option of s.options)verify(lexicon.indexOf(option)>=0,'PT kinship label: '+option);verify(s.options.indexOf(expected.label)>=0,'Visible graph relation '+expected.label);}else{var question=s.question.split(': ').pop();record.question=question;verify(lexicon.indexOf(question)>=0,'PT requested kinship '+question);record.pairs=pairChoices(g,question);verify(record.pairs.length>0,'Request has independent visible graph pair');}icon('bar_next.svg');}compare(bar.level,1);}
 function cleanupTestCase(){console.log('NATIVE_FAMILY_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,records:records}));}
}
