TestCase {
 name:'OneVisibleGridSolvedByIndependentConstraints'
 when:activity.visible&&boardItem.width>0
 property var evidence: ({moves:[]})
__VISIBLE__
__ORACLE__
__ACTIONS__
 function test_one_grid(){wait(1900);evidence.selection=chooseDataset(__DATASET__-1);var original=screen();evidence.initial=original;var puzzle=visiblePuzzle(original,arithmetic);evidence.puzzle=puzzle;var solution=solveVisible(puzzle);ensure(solvedVisible(puzzle,solution));evidence.solution=solution;evidence.error=wrongAndRepair(original,puzzle,solution);for(var i=0;i<solution.length;i++){var current=visibleValues(screen(),original);if(current[i]===0){var move=place(i,solution[i],original,i%2===0?'click':'key');compare(move.after[i],solution[i]);evidence.moves.push(move);}}evidence.completed=screen();ensure(solvedVisible(puzzle,visibleValues(evidence.completed,original)),'Independent completed drawn grid');var progress=scoreNumbers();compare(progress[0],1);evidence.scoreAfter=progress;grabImage(pageView).save('__QA_OUTPUT__/completed.png');tryCompare(score,'isWinAnimationPlaying',false,6500);wait(350);evidence.next=screen();compare(scoreNumbers()[0],1);}
 function cleanupTestCase(){console.log('NATIVE_GRIDS_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
