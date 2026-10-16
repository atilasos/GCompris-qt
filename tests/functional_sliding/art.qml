// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'LocalizedVisibleCoastalArtwork'
 when:activity.visible&&items.numberOfLevel>0
 property var evidence: ({})
__VISIBLE__
 function test_art_selected_and_usable(){wait(1800);for(var level=0;level<4;level++)icon('bar_next.svg');compare(items.currentLevel,4);var initial=board();evidence={activity:mode,initial:initial,expectedSource:'Coastal_Path__VARIANT__.svg'};grabImage(pageView).save('__QA_OUTPUT__/art.png');ensure(initial.tiles.filter(function(tile){return tile.value>0;}).every(function(tile){return tile.source.endsWith('/'+evidence.expectedSource);}),'Visible localized scene source');
  if(mode==='fifteen'){var empty=initial.values.indexOf(0),cell=neighbors(empty).filter(function(candidate){var values=initial.values.slice();values[empty]=values[candidate];values[candidate]=0;return !same(values,target());})[0];evidence.move=slideMove(initial,cell,'click');evidence.repair=slideMove(board(),empty,'key');}
  else {var row=0;while(same(rotateExpected(initial.values,'L',row),target()))row++;evidence.move=rotateMove(initial,'L',row,'click');evidence.repair=rotateMove(board(),'R',row,'click');}
  ensure(same(board().values,initial.values),'Localized art inverse transition');evidence.restored=true;
 }
 function cleanupTestCase(){console.log('NATIVE_SLIDING_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
