TestCase {
 name:'StrictPortugueseGridHelpAndEscapeFocus'
 when:activity.visible&&boardItem.width>0
 property var evidence: ({})
__VISIBLE__
__ORACLE__
__ACTIONS__
 function test_help(){wait(1900);evidence.selection=chooseDataset(0);var depth=pageView.depth;icon('bar_help.svg');tryCompare(pageView,'depth',depth+1);var help=pageView.currentItem;evidence.title=String(help.title);evidence.content=String(help.content);grabImage(pageView).save('__QA_OUTPUT__/help.png');compare(help.title,arithmetic?'Calcudoku':'Sudoku');ensure(help.content.indexOf('linha')>=0&&help.content.indexOf('coluna')>=0);if(arithmetic)ensure(help.content.indexOf('operador')>=0);else{ensure(help.content.indexOf('deve aparecem')<0,'Infinitive after deve');ensure(help.content.indexOf('deve aparecer apenas uma vez')>=0,'PT instruction uses infinitive');}keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth);wait(1900);var original=screen(),puzzle=visiblePuzzle(original,arithmetic),solution=solveVisible(puzzle),cell=puzzle.givens.indexOf(0);ensure(cell>=0);evidence.afterHelp=original;evidence.input=place(cell,solution[cell],original,'key');compare(evidence.input.after[cell],solution[cell]);grabImage(pageView).save('__QA_OUTPUT__/focus.png');evidence.focusAfterHelp=true;}
 function cleanupTestCase(){console.log('NATIVE_GRIDS_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
