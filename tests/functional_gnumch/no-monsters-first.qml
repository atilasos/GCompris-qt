// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:"GnumchMonsterSettingAfterPreviousLevel"
 when:activity.visible && gridNumbers.count===36
 property var evidence:({})
__VISIBLE__
 function find(root,suffix){if(root.source!==undefined && String(root.source).endsWith(suffix))return root;if(root.children)for(var child of root.children){var value=find(child,suffix);if(value)return value;}return null;}
 function test_first_level_remains_free_of_monsters_after_recovery() {
  wait(1800);compare(items.currentLevel,1);
  var button=find(bar,'bar_previous.svg');verify(button!==null);mouseClick(button);wait(700);compare(items.currentLevel,0);
  var request=prompt(),wrong=-1;
  for(var i=0;i<36;i++)if(!correct(visibleCell(i),request)){wrong=i;break;}
  verify(wrong>=0);verify(go(wrong,false));eat(false);tryCompare(warning,'opacity',1,1000);
  keyClick(Qt.Key_Return);tryCompare(warning,'opacity',0,1000);wait(600);
  var began=Date.now(),sightings=0,caught=false;
  while(Date.now()-began<13500){wait(100);for(var monster of monsters.children)if(monster.opacity>0.99)sightings++;if(warning.opacity>0)caught=true;}
  evidence={level:items.currentLevel+1,prompt:request,elapsed:Date.now()-began,visibleMonsterSamples:sightings,caught:caught};
  compare(sightings,0,"The first dataset level explicitly has monsters disabled");verify(!caught);
 }
 function cleanupTestCase(){console.log('NATIVE_GNUMCH_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
