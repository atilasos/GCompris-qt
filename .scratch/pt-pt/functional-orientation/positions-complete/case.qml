// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 function checkEqual(actual,expected,message){if(actual!==expected)console.log('COMPARE_FAILED',actual,expected,message);compare(actual,expected,message);}
 function checkTrue(value,message){if(!value)console.log('ASSERT_FAILED',message);verify(value,message);}

 id:campaign
 name:"VisibleChildBoxRelations"
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

 function options(textMode){var grid=textMode?answerViews:positionViews;return grid.contentItem.children.filter(child=>child.selectCurrentItem!==undefined && child.width>0 && child.height>0);}
 function keyboardSelect(grid,target){
  if(grid.currentItem===null)keyClick(Qt.Key_Right);
  var steps=0;
  while(grid.currentItem!==target){
   var before=grid.currentItem;checkTrue(before!==null);var a=before.mapToItem(activityBackground,before.width/2,before.height/2),b=target.mapToItem(activityBackground,target.width/2,target.height/2);
   keyClick(Math.abs(a.y-b.y)>before.height/2?(b.y>a.y?Qt.Key_Down:Qt.Key_Up):(b.x>a.x?Qt.Key_Right:Qt.Key_Left));
   checkTrue(grid.currentItem!==before,'One arrow changes visible selection toward target');checkTrue(++steps<12);
  }
 }
 function test_every_position(){
  wait(1000);checkEqual(activity.numberOfLevel,4);var plan=[6,6,7,7];
  for(var level=0;level<4;level++){
   checkEqual(activity.currentLevel,level);var textMode=level%2===1;
   for(var question=0;question<plan[level];question++){
    wait(100);var candidates=options(textMode);checkTrue(candidates.length>=3);var requested=textMode?picture(currentPosition):String(questionPanel.textItem.text),want=textMode?relation(requested):meaning(requested);
    var visible=candidates.map(child=>textMode?String(child.text):picture(child));var found=[];
    for(var i=0;i<visible.length;i++)if(textMode?matches(want,meaning(visible[i])):matches(relation(visible[i]),want))found.push(i);
    checkEqual(found.length,1,'Exactly one independent visible relation matches');var index=found[0],wrong=null;
    if(question===0){
     var bad=(index+1)%candidates.length;click(candidates[bad]);click(okButton);tryCompare(errorRectangle.errorAnimation,'running',true,1200);checkEqual(score.currentSubLevel,question);wrong={index:bad,choice:visible[bad]};tryCompare(errorRectangle.errorAnimation,'running',false,3500);wait(100);
    }
    var keyboard=question%2===0,grid=textMode?answerViews:positionViews;
    if(keyboard)keyboardSelect(grid,candidates[index]);else click(candidates[index]);
    grabImage(activityBackground).save('__QA_OUTPUT__/position-'+(level+1)+'-'+(question+1)+'.png');
    if(keyboard)keyClick(question%3===0?Qt.Key_Space:Qt.Key_Return);else click(okButton);
    tryCompare(score,'currentSubLevel',question+1,1200);tryCompare(score,'isWinAnimationPlaying',false,4500);wait(120);
    completed.push({level:level+1,question:question+1,mode:textMode?'picture-to-text':'text-to-picture',requested:requested,options:visible,index:index,input:keyboard?'keyboard':'mouse',wrong:wrong});console.log('ORIENTATION_POSITION',JSON.stringify(completed[completed.length-1]));
   }
   tryCompare(bonus,'isPlaying',true,1200);tryCompare(activity,'currentLevel',(level+1)%4,10000);wait(150);
  }
  checkEqual(wins,4);
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(activityBackground).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_ORIENTATION_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,wins:wins}));}
}
