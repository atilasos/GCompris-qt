// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:"CandyImagesDecodedByQt"
 when:activity.visible
 property var evidence:({images:[]})
__VISIBLE__
 function test_images(){
  wait(1000);
  for(var widget of [girlWidget,boyWidget,candyWidget,basketWidget]){
   tryCompare(widget.element,'status',Image.Ready,2500);verify(widget.element.width>0 && widget.element.height>0);
   evidence.images.push({source:String(widget.element.source),status:widget.element.status,width:widget.element.width,height:widget.element.height});
  }
  placeChildren();var child=boxes()[0];drag(candyWidget,child.area,child.area.width/2,child.area.height/2);compare(candies(child).length,1);tryCompare(candies(child)[0],'status',Image.Ready,2500);tryCompare(child.childImage,'status',Image.Ready,2500);
  evidence.drawnChildAndCandy=true;grabImage(activityBackground).save('__QA_OUTPUT__/painted.png');
 }
 function cleanupTestCase(){console.log('NATIVE_SHARE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
