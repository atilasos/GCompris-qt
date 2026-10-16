TestCase {
 name:'EveryFixedDrawingAssetActuallyLoadsInQt'
 when:activity.visible&&canvasArea.width>0
 property var evidence: ({images:[]})
 property var fixedAssets: __ASSETS__
__VISIBLE__
 Image { id:resourceProbe;parent:activityBackground;width:200;height:200;anchors.centerIn:parent;fillMode:Image.PreserveAspectFit;z:500 }
 function test_images(){wait(2500);activity.Window.window.requestActivate();wait(400);ensure(!ApplicationInfo.useSoftwareRenderer);for(var i=0;i<fixedAssets.length;i++){resourceProbe.source=fixedAssets[i];tryCompare(resourceProbe,'status',Image.Ready,7000);ensure(resourceProbe.implicitWidth>0&&resourceProbe.implicitHeight>0,'Resource has real dimensions');wait(15);var image='resource-'+i+'.png';grabImage(resourceProbe).save('__QA_OUTPUT__/'+image);var row={source:fixedAssets[i],status:resourceProbe.status,width:resourceProbe.implicitWidth,height:resourceProbe.implicitHeight,image:image,geometry:box(resourceProbe)};if(i%10===0||i+1===fixedAssets.length){shot('context-'+i);row.context='context-'+i+'.png';}evidence.images.push(row);if(i%10===0)console.log('CREATION_RESOURCE_PROGRESS',i+1,fixedAssets.length);}}
 function cleanupTestCase(){console.log('NATIVE_CREATION_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
