// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name: "DirectMazeLevel18"
 when: activity.visible
 function test_direct_level_has_drawn_board() {
  wait(1600);compare(activity.currentLevel,17);
  verify(maze.rows>0,"A directly opened level has a nonempty drawn board");
  compare(maze.columns,18);verify(mazeRepeater.count>0);
  verify(isFinite(player.x) && isFinite(player.y));
 }
 function cleanupTestCase(){console.log("NATIVE_MAZE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,level:activity.currentLevel+1,rows:maze.rows,columns:maze.columns}));}
}
