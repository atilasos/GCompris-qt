// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 function checkEqual(actual,expected,message){if(actual!==expected)console.log('COMPARE_FAILED',actual,expected,message);compare(actual,expected,message);}
 function checkTrue(value,message){if(!value)console.log('ASSERT_FAILED',message);verify(value,message);}

 id:campaign
 name:"VisibleAnimalsAndMouseButtons"
 when:activity.visible
 property var completed:[]
 property int wins:0
 Connections {target:bonus;function onWin(){campaign.wins++;}}
 function all(root){var result=[root];if(root.children)for(var child of root.children)result=result.concat(all(child));return result;}
 function click(item,button){var p=item.mapToItem(activityBackground,item.width/2,item.height/2);checkTrue(p.x>=0 && p.y>=0 && p.x<activityBackground.width && p.y<activityBackground.height,'Gesture center inside window');mouseClick(activityBackground,p.x,p.y,button===undefined?Qt.LeftButton:button,Qt.NoModifier,10);wait(30);}
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

 function center(item){var p=item.mapToItem(activityBackground,item.width/2,item.height/2);return {x:p.x,y:p.y};}
 function test_all_animals(){
  wait(1000);checkTrue(center(leftAreaTarget).x<center(rightAreaTarget).x);checkTrue(String(leftAreaTarget.source).endsWith('/pond.svg'));checkTrue(String(rightAreaTarget.source).endsWith('/tree.svg'));
  var plan=[5,7,10];
  for(var level=0;level<3;level++){
   checkEqual(activity.currentLevel,level);var cards=animals();checkEqual(cards.length,plan[level]);
   for(var question=0;question<cards.length;question++){
    var card=cards[question],image=animalImage(card);tryCompare(image,'status',Image.Ready,2000);var kind=String(image.source).split('/').pop(),fish=kind==='fish.svg';checkTrue(fish || kind==='monkey.svg');
    var target=fish?leftAreaTarget:rightAreaTarget,button=fish?Qt.LeftButton:Qt.RightButton,wrong=null,start=center(card);
    if(question===0){
     var oldParent=card.parent;click(card,fish?Qt.RightButton:Qt.LeftButton);tryCompare(cross,'visible',true,500);checkTrue(card.visible);checkEqual(card.parent,oldParent);checkEqual(center(card).x,start.x);checkEqual(center(card).y,start.y);wrong={button:fish?'right':'left',unchanged:true};tryCompare(cross,'visible',false,2000);
    }
    grabImage(activityBackground).save('__QA_OUTPUT__/animal-'+(level+1)+'-'+(question+1)+'.png');
    click(card,button);checkEqual(card.parent,target);var highlight=fish?leftClickDisplayMouse:rightClickDisplayMouse;checkTrue(highlight.opacity>0,'Correct physical button display lights up');wait(850);var destination=center(card),bounds={x:target.mapToItem(activityBackground,0,0).x,y:target.mapToItem(activityBackground,0,0).y,width:target.width,height:target.height};
    checkTrue(destination.x>=bounds.x && destination.x<=bounds.x+bounds.width && destination.y>=bounds.y && destination.y<=bounds.y+bounds.height,'Animal visibly arrives in target');tryCompare(card,'visible',false,1500);
    completed.push({level:level+1,question:question+1,image:kind,button:fish?'left':'right',home:fish?'pond':'tree',start:start,destination:destination,bounds:bounds,wrong:wrong});console.log('ORIENTATION_ANIMAL',JSON.stringify(completed[completed.length-1]));
   }
   tryCompare(bonus,'isPlaying',true,1500);tryCompare(activity,'currentLevel',(level+1)%3,10000);wait(200);
  }
  checkEqual(wins,3);
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(activityBackground).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_ORIENTATION_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,wins:wins}));}
}
