TestCase {
 name:'SketchRealStrokeUndoRedoSaveAccentedNameNewAndOpen'
 when:activity.visible&&canvasArea.width>0
 property var evidence: ({})
__VISIBLE__
__FILES__
 function snapshot(name){mouseMove(activityBackground,1,activityBackground.height-1);wait(300);return shot(name);}
 function test_flow(){wait(2500);activity.Window.window.requestActivate();wait(500);ensure(!ApplicationInfo.useSoftwareRenderer,'Actual OpenGL');evidence.softwareRenderer=ApplicationInfo.useSoftwareRenderer;evidence.canvas=box(canvasArea);snapshot('initial');drag(canvasArea,250,250,180,80);snapshot('stroke');keyClick(Qt.Key_Z,Qt.ControlModifier);wait(700);snapshot('undo');keyClick(Qt.Key_Y,Qt.ControlModifier);wait(700);snapshot('redo');evidence.savedFiles=[saveDrawing('CRIAÇÃO')];snapshot('saved');keyClick(Qt.Key_N,Qt.ControlModifier);wait(500);if(newImageDialog.active)confirmYes();wait(800);snapshot('new');openDrawing('CRIAÇÃO.png');snapshot('opened');grabImage(canvasArea).save('__QA_OUTPUT__/widget-opened.png');helpAndMenu();}
 function cleanupTestCase(){console.log('NATIVE_CREATION_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
