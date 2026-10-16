// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 function checkEqual(actual,expected,message){if(actual!==expected)console.log('COMPARE_FAILED',actual,expected,message);compare(actual,expected,message);}
 function checkTrue(value,message){if(!value)console.log('ASSERT_FAILED',message);verify(value,message);}

 name:"PositionControlsAndDatasets"
 when:activity.visible
 property var evidence:({})
 function all(root){var result=[root];if(root.children)for(var child of root.children)result=result.concat(all(child));return result;}
 function click(item,button){var p=item.mapToItem(pageView,item.width/2,item.height/2);checkTrue(p.x>=0 && p.y>=0 && p.x<pageView.width && p.y<pageView.height,'Gesture center inside window');mouseClick(item,item.width/2,item.height/2,button===undefined?Qt.LeftButton:button,Qt.NoModifier,10);wait(30);}
 function icon(suffix){wait(400);var image=all(bar).find(child=>child.source!==undefined && String(child.source).endsWith(suffix));checkTrue(image!==undefined,suffix);click(image);wait(400);}
 function enabledArea(root){return all(root).find(child=>child.acceptedButtons!==undefined && child.enabled!==undefined);}
 function readyHand(){tryCompare(handImage,'opacity',1,2500);tryCompare(enabledArea(leftButton),'enabled',true,2500);tryCompare(enabledArea(rightButton),'enabled',true,2500);tryCompare(handImage,'status',Image.Ready,2000);}
 function hand(){return {image:String(handImage.source).split('/').pop(),rotation:handImage.rotation,mirror:handImage.mirror};}
 function picture(root){
  var images=all(root).filter(child=>child.source!==undefined),boy=images.find(i=>String(i.source).endsWith('/boy.svg')),back=images.find(i=>String(i.source).endsWith('/back_side.svg')),front=images.find(i=>String(i.source).endsWith('/front_side.svg')),lid=images.find(i=>String(i.source).endsWith('/top_side.svg'));
  checkTrue(boy!==undefined && back!==undefined && front!==undefined && lid!==undefined,'Painted child and box faces');
  for(var image of [boy,back,front,lid])tryCompare(image,'status',Image.Ready,1500);
  var b=boy.mapToItem(root,boy.width/2,boy.height/2),c=back.mapToItem(root,back.width/2,back.height/2);
  return {dx:(b.x-c.x)/back.width,dy:(b.y-c.y)/back.height,boy_z:boy.z,front_z:front.z,lid:lid.visible,boy:{x:b.x,y:b.y,width:boy.width,height:boy.height},box:{x:c.x,y:c.y,width:back.width,height:back.height}};
 }
 function relation(view){if(view.dx<-.5)return 'left';if(view.dx>.5)return 'right';if(view.dy<-.6)return 'above';if(view.dy>.5)return 'under';if(!view.lid)return 'inside';return view.boy_z<view.front_z?'behind':'front';}
 function meaning(text){var words=[['à frente','front'],['atrás','behind'],['dentro','inside'],['em cima','above'],['debaixo','under'],['direita','right'],['esquerda','left'],['ao lado','beside']];for(var row of words)if(text.indexOf(row[0])>=0)return row[1];checkTrue(false,'Unknown PT relation '+text);return '';}
 function matches(actual,wanted){return wanted==='beside'?(actual==='left'||actual==='right'):actual===wanted;}
 function animalImage(card){return all(card).find(child=>child.source!==undefined && /\/(fish|monkey)\.svg$/.test(String(child.source)));}
 function animals(){return all(container.contentItem).filter(child=>animalImage(child)!==undefined && child.clicked!==undefined && child.visible && child.width>0);}

 function choices(){return all(dialogActivityConfig).filter(child=>child.indicatorImageHeight!==undefined && child.checked!==undefined && child.text!==undefined && child.visible);}
 function save(){var button=all(dialogActivityConfig).find(child=>child.clicked!==undefined && child.text==='Gravar' && child.visible);checkTrue(button!==undefined);click(button);tryCompare(dialogActivityConfig,'visible',false,2000);wait(600);}
 function test_controls(){
  wait(1000);checkEqual(activity.numberOfLevel,4);var depth=pageView.depth;icon('bar_help.svg');tryCompare(pageView,'depth',depth+1,2000);wait(300);var help=pageView.currentItem;checkTrue(help.content.indexOf('caixa')>=0 && help.content.indexOf('teclado')>=0);evidence.help={title:String(help.title),content:String(help.content)};grabImage(pageView).save('__QA_OUTPUT__/help.png');keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth,2000);wait(500);
  keyClick(Qt.Key_Right);checkTrue(positionViews.currentItem!==null);evidence.focusAfterHelp=true;
  icon('bar_next.svg');checkEqual(activity.currentLevel,1);checkEqual(score.currentSubLevel,0);keyClick(Qt.Key_Right);checkTrue(answerViews.currentItem!==null);icon('bar_previous.svg');checkEqual(activity.currentLevel,0);checkEqual(positionViews.currentItem,null);evidence.navigationReset=true;
  icon('bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2000);wait(350);var rows=choices();checkEqual(rows.length,2);checkTrue(rows[0].checked && rows[1].checked);evidence.datasetLabels=rows.map(row=>String(row.text));click(rows[0]);checkTrue(!rows[0].checked);save();checkEqual(activity.numberOfLevel,2);
  icon('bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2000);wait(350);rows=choices();checkEqual(rows.length,2);checkTrue(!rows[0].checked && rows[1].checked);evidence.persistedSelection=true;grabImage(pageView).save('__QA_OUTPUT__/selection.png');click(rows[0]);save();checkEqual(activity.numberOfLevel,4);evidence.restoredSelection=true;
  icon('bar_previous.svg');checkEqual(activity.currentLevel,3);icon('bar_next.svg');checkEqual(activity.currentLevel,0);evidence.wrap=true;
  evidence.reloadOffered=all(bar).some(child=>child.source!==undefined && String(child.source).endsWith('bar_reload.svg'));
  ActivityInfoTree.startingActivity='';keyClick(Qt.Key_W,Qt.ControlModifier);tryCompare(pageView,'depth',1,2000);checkTrue(pageView.currentItem.isMenu);evidence.menu=true;grabImage(pageView).save('__QA_OUTPUT__/menu.png');
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_ORIENTATION_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
