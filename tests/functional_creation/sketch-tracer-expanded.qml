TestCase {
 name:'SketchRealStrokeUndoRedoSaveAccentedNameNewAndOpen'
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

 function typeText(s){for(var c of s){if(c==='Ç')keyClick(Qt.Key_Ccedilla);else if(c==='Ã')keyClick(Qt.Key_Atilde);else if(c==='Á')keyClick(Qt.Key_Aacute);else if(c==='É')keyClick(Qt.Key_Eacute);else{ensure(c.charCodeAt(0)<128,'ASCII key or explicit Qt enum only');keyClick(c);}wait(30);}}
 function saveDrawing(name){keyClick(Qt.Key_S,Qt.ControlModifier);wait(650);evidence.saveDialogVisible=creationHandler.visible;shot('save-request');tryCompare(creationHandler,'visible',true);var field=find(creationHandler,function(o){return o.placeholderText!==undefined&&o.cursorPosition!==undefined;});click(field);typeText(name);evidence.fileNameTyped=String(field.text);shot('save-name');compare(String(field.text),name);var path=String(creationHandler.sharedDirectoryPath)+name+(creationHandler.svgMode?'.svg':'.png');shot('save-dialog');button(creationHandler,'Gravar');wait(500);shot('save-success');button(creationHandler,'OK');tryCompare(creationHandler,'visible',false,5000);wait(800);return path;}
 function openDrawing(name){keyClick(Qt.Key_O,Qt.ControlModifier);tryCompare(creationHandler,'visible',true);wait(800);click(find(creationHandler,function(o){return o.text!==undefined&&o.font!==undefined&&String(o.text)===name;}));shot('open-dialog');button(creationHandler,'Carregar');tryCompare(creationHandler,'visible',false,5000);wait(1000);}
 function confirmYes(){tryCompare(newImageDialog,'active',true);wait(500);button(newImageDialog.item,'Sim');tryCompare(newImageDialog,'active',false,5000);wait(800);}
 function helpAndMenu(){var depth=pageView.depth;icon('bar_help.svg');tryCompare(pageView,'depth',depth+1);evidence.help={title:String(pageView.currentItem.title),content:String(pageView.currentItem.content)};shot('help');keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth);wait(1900);ActivityInfoTree.startingActivity='';icon('bar_home.svg');tryCompare(pageView,'depth',1);ensure(pageView.currentItem.isMenu,'Stable menu after saved creation');wait(1900);ensure(pageView.currentItem.isMenu);shot('menu');evidence.menu=true;}

 function snapshot(name){mouseMove(activityBackground,1,activityBackground.height-1);wait(300);return shot(name);}
 function test_flow(){wait(2500);activity.Window.window.requestActivate();wait(500);ensure(!ApplicationInfo.useSoftwareRenderer,'Actual OpenGL');evidence.softwareRenderer=ApplicationInfo.useSoftwareRenderer;evidence.canvas=box(canvasArea);snapshot('initial');drag(canvasArea,250,250,180,80);snapshot('stroke');keyClick(Qt.Key_Z,Qt.ControlModifier);wait(700);snapshot('undo');keyClick(Qt.Key_Y,Qt.ControlModifier);wait(700);snapshot('redo');evidence.savedFiles=[saveDrawing('CRIAÇÃO')];snapshot('saved');keyClick(Qt.Key_N,Qt.ControlModifier);wait(500);if(newImageDialog.active)confirmYes();wait(800);snapshot('new');openDrawing('CRIAÇÃO.png');snapshot('opened');grabImage(canvasArea).save('__QA_OUTPUT__/widget-opened.png');helpAndMenu();}
 function cleanupTestCase(){console.log('NATIVE_CREATION_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
