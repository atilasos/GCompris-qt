TestCase {
 name:'EveryOfferedGridLevelAndSublevelNaturalCompletion'
 when:activity.visible&&boardItem.width>0
 property var evidence: ({dataset:__DATASET__,levels:[]})
__VISIBLE__
__ORACLE__
__ACTIONS__
 function test_all_boards(){wait(1900);evidence.selection=chooseDataset(__DATASET__-1);var levelCount=activity.numberOfLevel;ensure(levelCount>0);for(var level=1;level<=levelCount;level++){
  compare(bar.level,level);compare(scoreNumbers()[0],0);var total=scoreNumbers()[1],record={level:level,total:total,boards:[]};evidence.levels.push(record);
  for(var sub=0;sub<total;sub++){compare(bar.level,level);compare(scoreNumbers()[0],sub);var original=screen(),puzzle=visiblePuzzle(original,arithmetic),solution=solveVisible(puzzle);ensure(solvedVisible(puzzle,solution));var board={initial:original,puzzle:puzzle,solution:solution,moves:[]};record.boards.push(board);if(sub===0)board.error=wrongAndRepair(original,puzzle,solution);board.afterError=screen();for(var cell=0;cell<solution.length;cell++){var current=visibleValues(screen(),original);if(current[cell]===0){var move=place(cell,solution[cell],original,cell%2===0?'click':'key');compare(move.after[cell],solution[cell]);board.moves.push(move);if(board.moves.length%5===0)console.log('GRIDS_HEARTBEAT',arithmetic?'calcudoku':'sudoku',__DATASET__,level,sub+1,total,board.moves.length);}}board.completed=screen();ensure(solvedVisible(puzzle,visibleValues(board.completed,original)),'Completed drawn grid meets independent constraints');board.scoreAfter=scoreNumbers();compare(board.scoreAfter[0],sub+1);compare(board.scoreAfter[1],total);grabImage(pageView).save('__QA_OUTPUT__/level-'+level+'-board-'+(sub+1)+'.png');tryCompare(score,'isWinAnimationPlaying',false,6500);
   if(sub+1===total){tryVerify(function(){return bonus.opacity>0.5&&String(bonus.source).endsWith('/flower_good.svg');},4000);record.bonus={source:String(bonus.source),opacity:bonus.opacity};grabImage(pageView).save('__QA_OUTPUT__/level-'+level+'-bonus.png');tryCompare(bonus,'isPlaying',false,9000);wait(350);compare(bar.level,level%levelCount+1);compare(scoreNumbers()[0],0);record.continuation=screen();}else{wait(350);compare(bar.level,level);compare(scoreNumbers()[0],sub+1);board.next=screen();}
   console.log('GRIDS_PROGRESS',arithmetic?'calcudoku':'sudoku',__DATASET__,level,levelCount,sub+1,total);
  }
 }compare(bar.level,1);compare(scoreNumbers()[0],0);}
 function cleanupTestCase(){console.log('NATIVE_GRIDS_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
