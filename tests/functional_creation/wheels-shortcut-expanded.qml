TestCase {
 name:'AdvertisedSaveShortcutFromFreshDrawing'
 when:activity.visible&&canvasArea.width>0
 property var evidence: ({})
 function ensure(ok,msg){if(!ok){grabImage(pageView).save('__QA_OUTPUT__/failure-scene.png');console.log('CREATION_ASSERT',msg);}verify(ok,msg);}
 function all(root,predicate){var out=[];function walk(o){if(!o)return;if(predicate(o))out.push(o);if(o.children)for(var c of o.children)walk(c);}walk(root);return out;}
 function drawn(o){if(!o||!o.visible||o.width<=0||o.height<=0)return false;for(var p=o;p;p=p.parent)if(p.visible===false||p.opacity===0)return false;var q=o.mapToItem(pageView,o.width/2,o.height/2);if(q.x<0||q.y<0||q.x>=pageView.width||q.y>=pageView.height)return false;for(var a=o.parent;a&&a!==pageView;a=a.parent)if(a.clip){var v=o.mapToItem(a,o.width/2,o.height/2);if(v.x<0||v.y<0||v.x>=a.width||v.y>=a.height)return false;}return true;}
 function find(root,p){var a=all(root,function(o){return drawn(o)&&p(o);});ensure(a.length>0,'Visible control exists');return a[0];}
 function click(o){ensure(drawn(o),'Actual click lies in rendered scene');mouseClick(o,o.width/2,o.height/2);wait(180);}
 function icon(name){var o=find(bar,function(o){return o.source!==undefined&&String(o.source).endsWith('/'+name);});click(o);wait(1900);}
 function button(root,text){click(find(root,function(o){return o.text!==undefined&&String(o.text)===text&&o.clicked!==undefined;}));}
 function box(o){var p=o.mapToItem(pageView,0,0);return {x:p.x,y:p.y,width:o.width,height:o.height};}
 function shot(name){var im=grabImage(pageView);im.save('__QA_OUTPUT__/'+name+'.png');return im;}
 function sample(im,o,x,y){var p=o.mapToItem(pageView,x,y);return String(im.pixel(Math.round(p.x),Math.round(p.y)));}
 function drag(o,x,y,dx,dy){mousePress(o,x,y);for(var i=1;i<=12;i++){mouseMove(o,x+dx*i/12,y+dy*i/12,25);wait(25);}mouseRelease(o,x+dx,y+dy);wait(700);}

 function test_shortcut(){wait(2500);evidence.softwareRenderer=ApplicationInfo.useSoftwareRenderer;ensure(!evidence.softwareRenderer,'OpenGL required');evidence.focusBefore={activity:activity.activeFocus,page:activityBackground.activeFocus};click(playButton);wait(1000);click(playButton);wait(1000);shot('drawn');evidence.focusAfter={activity:activity.activeFocus,page:activityBackground.activeFocus};keyClick(Qt.Key_S,Qt.ControlModifier);wait(900);evidence.shortcutVisible=creationHandler.visible;shot('shortcut');if(!creationHandler.visible){if('drawing_wheels'==='sketch'){click(find(filesPanel,function(o){return o.source!==undefined&&String(o.source).endsWith('/filesMenu.svg');}));wait(400);button(filesPanel,'Guardar a tua imagem');}else{click(fileButton);wait(400);button(filePanel,'Guardar a tua imagem');}tryCompare(creationHandler,'visible',true);evidence.guiSaveVisible=creationHandler.visible;shot('gui-save');}ensure(evidence.shortcutVisible,'Advertised Ctrl+S opens save dialog from initial creation');}
 function cleanupTestCase(){console.log('NATIVE_CREATION_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
