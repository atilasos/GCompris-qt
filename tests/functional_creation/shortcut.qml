TestCase {
 name:'AdvertisedSaveShortcutFromFreshDrawing'
 when:activity.visible&&canvasArea.width>0
 property var evidence: ({})
__VISIBLE__
 function test_shortcut(){wait(2500);evidence.softwareRenderer=ApplicationInfo.useSoftwareRenderer;ensure(!evidence.softwareRenderer,'OpenGL required');evidence.focusBefore={activity:activity.activeFocus,page:activityBackground.activeFocus};drag(canvasArea,220,200,140,80);shot('drawn');evidence.focusAfter={activity:activity.activeFocus,page:activityBackground.activeFocus};keyClick(Qt.Key_S,Qt.ControlModifier);wait(900);evidence.shortcutVisible=creationHandler.visible;shot('shortcut');if(!creationHandler.visible){click(find(filesPanel,function(o){return o.source!==undefined&&String(o.source).endsWith('/filesMenu.svg');}));wait(400);button(filesPanel,'Guardar a tua imagem');tryCompare(creationHandler,'visible',true);evidence.guiSaveVisible=creationHandler.visible;shot('gui-save');}ensure(evidence.shortcutVisible,'Advertised Ctrl+S opens save dialog from initial creation');}
 function cleanupTestCase(){console.log('NATIVE_CREATION_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
