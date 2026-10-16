// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:"HandHelpDistinguishesScreenButtonsFromMouseButtons"
 when:activity.visible
 property var semantics:{"main_droite_dessus_0.webp": {"side": "right", "view": "back", "thumb_in_unrotated_photo": "upper", "sha256": "05657aeb43336d513b6724533e79082b149bdf6e6af0680031b601c9bc78e77d"}, "main_droite_paume_0.webp": {"side": "right", "view": "palm", "thumb_in_unrotated_photo": "lower", "sha256": "7ac0058c04f93fd039a2acb06a7548e0a3990fe4074ae694367923380f29f356"}, "main_gauche_dessus_0.webp": {"side": "left", "view": "back", "thumb_in_unrotated_photo": "lower", "sha256": "f588e583051557a4f61a071b836a6091e67fae7a6703f912ab3a9bd44b5d4705"}, "main_gauche_paume_0.webp": {"side": "left", "view": "palm", "thumb_in_unrotated_photo": "upper", "sha256": "e57658199006929a6af8973974197acfa69c7da0cab7c835a1805ecb44e2ab59"}, "poing_droit_dessus_0.webp": {"side": "right", "view": "back", "thumb_in_unrotated_photo": "upper", "sha256": "305784dc75919d340ece5703d107e841376b4fb42965e324fe42c761c49a175a"}, "poing_droit_paume_0.webp": {"side": "right", "view": "palm", "thumb_in_unrotated_photo": "lower", "sha256": "6ae0836358634d700a6d1143c4527b14321c23b332f270a175843b8805f5308f"}, "poing_gauche_dessus_0.webp": {"side": "left", "view": "back", "thumb_in_unrotated_photo": "lower", "sha256": "a6a9a168d9920ddd1e77ee9611d7403f2a13e6de2a799a978af677d21a75dbac"}, "poing_gauche_paume_0.webp": {"side": "left", "view": "palm", "thumb_in_unrotated_photo": "upper", "sha256": "7c31b833b995dfa59a0fb69d550dcda48a07a785a76b60d1950c498115f3a0c7"}}
 property var evidence:({})
 function all(root){var result=[root];if(root.children)for(var child of root.children)result=result.concat(all(child));return result;}
 function click(item,button){var p=item.mapToItem(pageView,item.width/2,item.height/2);verify(p.x>=0 && p.y>=0 && p.x<pageView.width && p.y<pageView.height,'Gesture center inside window');mouseClick(item,item.width/2,item.height/2,button===undefined?Qt.LeftButton:button,Qt.NoModifier,10);wait(30);}
 function icon(suffix){wait(400);var image=all(bar).find(child=>child.source!==undefined && String(child.source).endsWith(suffix));verify(image!==undefined,suffix);click(image);wait(400);}
 function enabledArea(root){return all(root).find(child=>child.acceptedButtons!==undefined && child.enabled!==undefined);}
 function readyHand(){tryCompare(handImage,'opacity',1,2500);tryCompare(enabledArea(leftButton),'enabled',true,2500);tryCompare(enabledArea(rightButton),'enabled',true,2500);tryCompare(handImage,'status',Image.Ready,2000);}
 function hand(){return {image:String(handImage.source).split('/').pop(),rotation:handImage.rotation,mirror:handImage.mirror};}
 function picture(root){
  var images=all(root).filter(child=>child.source!==undefined),boy=images.find(i=>String(i.source).endsWith('/boy.svg')),back=images.find(i=>String(i.source).endsWith('/back_side.svg')),front=images.find(i=>String(i.source).endsWith('/front_side.svg')),lid=images.find(i=>String(i.source).endsWith('/top_side.svg'));
  verify(boy!==undefined && back!==undefined && front!==undefined && lid!==undefined,'Painted child and box faces');
  for(var image of [boy,back,front,lid])tryCompare(image,'status',Image.Ready,1500);
  var b=boy.mapToItem(root,boy.width/2,boy.height/2),c=back.mapToItem(root,back.width/2,back.height/2);
  return {dx:(b.x-c.x)/back.width,dy:(b.y-c.y)/back.height,boy_z:boy.z,front_z:front.z,lid:lid.visible,boy:{x:b.x,y:b.y,width:boy.width,height:boy.height},box:{x:c.x,y:c.y,width:back.width,height:back.height}};
 }
 function relation(view){if(view.dx<-.5)return 'left';if(view.dx>.5)return 'right';if(view.dy<-.6)return 'above';if(view.dy>.5)return 'under';if(!view.lid)return 'inside';return view.boy_z<view.front_z?'behind':'front';}
 function meaning(text){var words=[['à frente','front'],['atrás','behind'],['dentro','inside'],['em cima','above'],['debaixo','under'],['direita','right'],['esquerda','left'],['ao lado','beside']];for(var row of words)if(text.indexOf(row[0])>=0)return row[1];verify(false,'Unknown PT relation '+text);return '';}
 function matches(actual,wanted){return wanted==='beside'?(actual==='left'||actual==='right'):actual===wanted;}
 function animalImage(card){return all(card).find(child=>child.source!==undefined && /\/(fish|monkey)\.svg$/.test(String(child.source)));}
 function animals(){return all(container.contentItem).filter(child=>animalImage(child)!==undefined && child.clicked!==undefined && child.visible && child.width>0);}

 function test_manual(){
  wait(900);readyHand();var skipped=0;
  while(semantics[hand().image].side!=='right'){
   var scoreBefore=score.currentSubLevel;keyClick(Qt.Key_Left);tryCompare(score,'currentSubLevel',scoreBefore+1,1200);tryCompare(score,'isWinAnimationPlaying',false,4500);readyHand();verify(++skipped<4);
  }
  var before=score.currentSubLevel;click(rightButton,Qt.RightButton);compare(score.currentSubLevel,before);evidence.physicalRightIgnored=true;evidence.stimulus=hand();click(rightButton,Qt.LeftButton);tryCompare(score,'currentSubLevel',before+1,1200);tryCompare(score,'isWinAnimationPlaying',false,4500);wait(150);evidence.screenAnswerWorks=true;
  var depth=pageView.depth;icon('bar_help.svg');tryCompare(pageView,'depth',depth+1,2000);wait(350);var help=pageView.currentItem;evidence.help=String(help.content);grabImage(pageView).save('__QA_OUTPUT__/help.png');
  verify(help.content.indexOf('no ecrã')>=0 && help.content.indexOf('«Mão esquerda»')>=0 && help.content.indexOf('«Mão direita»')>=0,'PT manual names the two displayed answers rather than physical mouse buttons');
  keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth,2000);wait(450);ActivityInfoTree.startingActivity='';keyClick(Qt.Key_W,Qt.ControlModifier);tryCompare(pageView,'depth',1,2000);verify(pageView.currentItem.isMenu);evidence.menu=true;
 }
 function cleanupTestCase(){console.log('NATIVE_ORIENTATION_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
