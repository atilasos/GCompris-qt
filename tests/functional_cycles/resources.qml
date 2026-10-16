// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'CycleCanonicalImageResources'
 when:activity.visible
 property var paths: __IMAGES__
 property var observed: []
 Component { id: preview; Image {width:48;height:48;sourceSize.width:64;sourceSize.height:64;fillMode:Image.PreserveAspectFit;z:200} }
 function test_decode(){wait(1200);verify(paths.length>0);for(var i=0;i<paths.length;i++){var url='qrc'+paths[i];var image=preview.createObject(activityBackground,{source:url,x:8+(i%12)*56,y:8+Math.floor(i/12)*56});verify(image!==null);tryCompare(image,'status',Image.Ready,3000);verify(image.sourceSize.width>0&&image.sourceSize.height>0);observed.push({path:paths[i],url:String(image.source),status:image.status,width:image.sourceSize.width,height:image.sourceSize.height});}wait(200);grabImage(pageView).save('__QA_OUTPUT__/resources.png');}
 function cleanupTestCase(){console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,resources:observed}));}
}
