// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 id: campaign
 name: 'LearnFromVisiblePresentationsAndCompleteQuizzes'
 when: activity.visible
 property var playbacks: []
 property var pages: []
 property var questions: []
 property var transitions: []
 property var evidence: ({wins:0})
 property int readyEvents: 0
 Component.onCompleted: {ApplicationSettings.isAudioVoicesEnabled=true;ApplicationSettings.isAudioEffectsEnabled=true;}
 Connections {target:activity.audioVoices;function onSourceChanged(){var source=String(activity.audioVoices.source);if(source)campaign.playbacks.push(source);}}
 Connections {target:bonus;function onWin(){campaign.evidence.wins++;}}
 Connections {target:progressbar;function onStop(){campaign.readyEvents++;}}
 function all(root){var result=[root];if(root.children)for(var child of root.children)result=result.concat(all(child));return result;}
 function click(item){var p=item.mapToItem(pageView,item.width/2,item.height/2);verify(p.x>=0&&p.y>=0&&p.x<pageView.width&&p.y<pageView.height,'Painted control inside viewport');mouseClick(item,item.width/2,item.height/2,Qt.LeftButton,Qt.NoModifier,10);wait(50);}
 function icon(suffix){var image=all(bar).find(child=>child.source!==undefined&&String(child.source).endsWith(suffix)&&child.visible);verify(image!==undefined,suffix);click(image);wait(400);}
 function spots(){return all(activityBackground).filter(node=>node.source!==undefined && /\/(question|key|suitcase|cat|chicken|cow|dog|duck|horse|owl|pig|sheep)\.svg$/.test(String(node.source))&&node.visible&&node.width>0&&node.height>0);}
 function continueSound(){if(audioNeededDialog.active){var button=all(audioNeededDialog.item).find(node=>node.text!==undefined&&String(node.text)===String(audioNeededDialog.item.button2Text)&&node.clicked!==undefined);verify(button!==undefined);click(button);wait(300);}}

 function factsFor(map,cards){
  var learned=[];
  for(var i=0;i<cards.length;i++){
   tryCompare(cards[i],'status',Image.Ready,2000);var point=cards[i].mapToItem(pageView,cards[i].width/2,cards[i].height/2);click(cards[i]);tryCompare(descriptionPanel,'visible',true,2000);wait(1300);
   var image=all(descriptionPanel).find(node=>node.source!==undefined&&String(node.source).endsWith('.webp'));verify(image!==undefined);tryCompare(image,'status',Image.Ready,2000);
   var page={map:map,title:String(descriptionPanel.title),description:String(descriptionPanel.description),image:String(image.source),mapImage:String(bg.source),x:point.x/pageView.width,y:point.y/pageView.height,audio:String(activity.audioVoices.source)};
   pages.push(page);learned.push(page);grabImage(pageView).save('__QA_OUTPUT__/presentation-m'+map+'-'+i+'.png');
   keyClick(Qt.Key_Escape);tryCompare(descriptionPanel,'visible',false,2000);wait(100);
  }
  return learned;
 }
 function meaning(prompt,learned){
  var normal=text=>text.toLowerCase().replace(/^(a|o|as|os) /,'').replace(/[.,]/g,'');var named=learned.filter(page=>normal(page.title)===normal(prompt)||normal(page.title.split(',')[0])===normal(prompt));if(named.length===1)return named[0];
  var rules=[[/lã/,'Ovelha'],[/lama/,'Porco'],[/noite|noturn|nocturn/,'Coruja'],[/lobo/,'Cão'],[/crista|ovos/,'Galinha'],[/ratos|roedores|ronron/,'Gato'],[/nadar|nada|água|membrana/,'Pato'],[/leite|paladar|odores|papilas|sabores|20[ \u00a0]?000/,'Vaca'],[/correr|equilíbrio|cascos|relinch/,'Cavalo']];
  var matches=rules.filter(rule=>rule[0].test(prompt.toLowerCase())).map(rule=>rule[1]);verify(matches.length===1,'Question must follow a unique taught fact: '+prompt);return learned.find(page=>page.title===matches[0]);
 }
 function atPosition(page){var cards=spots();return cards.find(card=>{var p=card.mapToItem(pageView,card.width/2,card.height/2);return Math.abs(p.x/pageView.width-page.x)<0.005&&Math.abs(p.y/pageView.height-page.y)<0.005;});}
 function quiz(map,stage,learned,audio){
  compare(score.currentSubLevel,stage);compare(progressbar.currentSubLevel,0);compare(progressbar.numberOfSubLevels,learned.length);
  for(var n=0;n<learned.length;n++){
   wait(250);var prompt=audio?'':String(questionPanel.textItem.text);var sound=audio?String(activity.audioVoices.source):'';
   evidence.pendingPrompt=prompt;var chosen=audio?learned.find(page=>page.audio===sound):meaning(prompt,learned);verify(chosen!==undefined,'Question is solvable from the presentations: '+prompt+' '+sound);
   var row={map:map,stage:stage,kind:audio?'audio':'text',prompt:prompt,audio:sound,selected:chosen.title,x:chosen.x,y:chosen.y,before:progressbar.currentSubLevel};
   if(n===0){
    var wrong=learned.find(page=>page.title!==chosen.title);var wrongCard=atPosition(wrong);verify(wrongCard!==undefined);click(wrongCard);wait(150);row.wrong={selected:wrong.title,unchanged:progressbar.currentSubLevel===row.before};compare(progressbar.currentSubLevel,row.before);grabImage(pageView).save('__QA_OUTPUT__/wrong-m'+map+'-s'+stage+'.png');tryCompare(errorRectangle,'opacity',0,2500);wait(80);
    if(audio){click(repeatItem);wait(250);compare(String(activity.audioVoices.source),sound);row.repeated=true;}
   }
   var card=atPosition(chosen);verify(card!==undefined);var events=readyEvents;click(card);tryVerify(()=>progressbar.currentSubLevel===row.before+1,2000);row.after=progressbar.currentSubLevel;questions.push(row);
   if(n===learned.length-1){grabImage(pageView).save('__QA_OUTPUT__/quiz-complete-m'+map+'-s'+stage+'.png');tryVerify(()=>score.currentSubLevel!==stage||bar.level!==map,8000);transitions.push({map:map,stage:stage,nextMap:bar.level,nextStage:score.currentSubLevel,natural:true});}
   else {tryVerify(()=>readyEvents>events,2500);}
  }
 }
 function test_complete_all_visible_stages(){
  wait(1200);continueSound();var id=activity.activityInfo.shortName();var expected=id==='explore_monuments'?[7,11,10,7,10,4,6,6,4]:id==='explore_world_animals'?[5,5,5]:[9];var audio=id==='explore_farm_animals'||id==='explore_world_music';
  compare(activity.numberOfLevel,expected.length);
  for(var map=1;map<=expected.length;map++){
   compare(bar.level,map);compare(score.currentSubLevel,1);var cards=spots();compare(cards.length,expected[map-1]);var wins=evidence.wins;grabImage(pageView).save('__QA_OUTPUT__/map-m'+map+'.png');var learned=factsFor(map,cards);tryVerify(()=>evidence.wins>wins&&okButton.visible,5000);click(okButton);wait(350);compare(score.currentSubLevel,2);
   if(audio)quiz(map,2,learned,true);
   quiz(map,audio?3:2,learned,false);
  }
  compare(bar.level,1);compare(score.currentSubLevel,1);grabImage(pageView).save('__QA_OUTPUT__/natural-wrap.png');evidence.naturalWrap=true;verify(questions.every(row=>!/(amostras de sabor|nocturn)/.test(row.prompt)),'Question wording uses PT-PT current spelling and taught meaning');
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,pages:pages,questions:questions,transitions:transitions,evidence:evidence,playbacks:playbacks}));}
}
