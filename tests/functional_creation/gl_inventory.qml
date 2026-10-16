TestCase {
 name:'PrivateOpenGLCanvasInventory'
 when:activity.visible&&activityBackground.width>0
 property var evidence: ({})
 function test_visible_canvas(){wait(2500);evidence.softwareRenderer=ApplicationInfo.useSoftwareRenderer;verify(!evidence.softwareRenderer,'Activity must actually use OpenGL, without forcing enabled');evidence.publicLevels=activity.numberOfLevel;evidence.scene={width:pageView.width,height:pageView.height};evidence.canvas={width:canvasArea.width,height:canvasArea.height};verify(canvasArea.width>0&&canvasArea.height>0);grabImage(pageView).save('__QA_OUTPUT__/scene.png');grabImage(canvasArea).save('__QA_OUTPUT__/canvas.png');var rows=[];function walk(o){if(!o)return;if(o.visible&&o.width>0&&o.height>0){var r={type:String(o),width:o.width,height:o.height};if(o.text!==undefined&&o.font!==undefined)r.text=String(o.text);if(o.source!==undefined)r.source=String(o.source);if(o.color!==undefined)r.color=String(o.color);if(r.text||r.source)rows.push(r);}if(o.children)for(var c of o.children)walk(c);}walk(activityBackground);evidence.drawn=rows;}
 function cleanupTestCase(){console.log('NATIVE_CREATION_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
