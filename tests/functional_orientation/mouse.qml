// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 id:campaign
 name:"VisibleAnimalsAndMouseButtons"
 when:activity.visible
 property var completed:[]
 property int wins:0
 Connections {target:bonus;function onWin(){campaign.wins++;}}
__VISIBLE__
 function center(item){var p=item.mapToItem(activityBackground,item.width/2,item.height/2);return {x:p.x,y:p.y};}
 function test_all_animals(){
  wait(1000);verify(center(leftAreaTarget).x<center(rightAreaTarget).x);verify(String(leftAreaTarget.source).endsWith('/pond.svg'));verify(String(rightAreaTarget.source).endsWith('/tree.svg'));
  var plan=[5,7,10];
  for(var level=0;level<3;level++){
   compare(activity.currentLevel,level);var cards=animals();compare(cards.length,plan[level]);
   for(var question=0;question<cards.length;question++){
    var card=cards[question],image=animalImage(card);tryCompare(image,'status',Image.Ready,2000);var kind=String(image.source).split('/').pop(),fish=kind==='fish.svg';verify(fish || kind==='monkey.svg');
    var target=fish?leftAreaTarget:rightAreaTarget,button=fish?Qt.LeftButton:Qt.RightButton,wrong=null,start=center(card);
    if(question===0){
     var oldParent=card.parent;click(card,fish?Qt.RightButton:Qt.LeftButton);tryCompare(cross,'visible',true,500);verify(card.visible);compare(card.parent,oldParent);compare(center(card).x,start.x);compare(center(card).y,start.y);wrong={button:fish?'right':'left',unchanged:true};tryCompare(cross,'visible',false,2000);
    }
    grabImage(activityBackground).save('__QA_OUTPUT__/animal-'+(level+1)+'-'+(question+1)+'.png');
    click(card,button);compare(card.parent,target);var highlight=fish?leftClickDisplayMouse:rightClickDisplayMouse;verify(highlight.opacity>0,'Correct physical button display lights up');wait(850);var destination=center(card),bounds={x:target.mapToItem(activityBackground,0,0).x,y:target.mapToItem(activityBackground,0,0).y,width:target.width,height:target.height};
    verify(destination.x>=bounds.x && destination.x<=bounds.x+bounds.width && destination.y>=bounds.y && destination.y<=bounds.y+bounds.height,'Animal visibly arrives in target');tryCompare(card,'visible',false,1500);
    completed.push({level:level+1,question:question+1,image:kind,button:fish?'left':'right',home:fish?'pond':'tree',start:start,destination:destination,bounds:bounds,wrong:wrong});console.log('ORIENTATION_ANIMAL',JSON.stringify(completed[completed.length-1]));
   }
   tryCompare(bonus,'isPlaying',true,1500);tryCompare(activity,'currentLevel',(level+1)%3,10000);wait(200);
  }
  compare(wins,3);
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(activityBackground).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_ORIENTATION_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,wins:wins}));}
}
