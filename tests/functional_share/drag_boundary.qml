// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:"HiddenCounterSidebarCoordinates"
 when:activity.visible
 property var evidence:({})
__VISIBLE__
 function test_drag_after_next_question(){
  wait(1000);mode(false);placeChildren();compare(boxes().length,2);
  var box=boxes()[1],before=candies(box).length;
  evidence={instruction:String(instructionPanel.textItem.text),before:view(),sourcePosition:candyWidget.mapToItem(activityBackground,0,0),destination:box.area.mapToItem(activityBackground,box.area.width/2,box.area.height/2)};
  drag(candyWidget,box.area,box.area.width/2,box.area.height/2);
  evidence.after=view();grabImage(activityBackground).save('__QA_OUTPUT__/after.png');
  compare(candies(box).length,before+1,'One sidebar candy dragged to painted destination');
 }
 function cleanupTestCase(){console.log('NATIVE_SHARE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
