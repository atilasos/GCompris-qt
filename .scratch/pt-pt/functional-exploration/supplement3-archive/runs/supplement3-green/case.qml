// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name: 'ColosseumHistoricalMeaning'
 when:activity.visible
 property var targets: [{"image": "qrc:/gcompris/src/activities/explore_monuments/resource/wonders/colosseum.webp", "map": 1, "title": "Coliseu", "x": 0.505, "y": 0.44375, "old": "O Coliseu é um dos edifícios mais reconhecidos da Roma clássica. Mesmo 2 000 anos após a sua construção, e apesar dos séculos em que foi abandonado e pilhado para obter materiais de construção, continua a ser imediatamente reconhecível. É um modelo clássico dos estádios atuais. Foi o primeiro anfiteatro permanente de Roma e a arena mais impressionante que o mundo clássico conhecera até então.", "new": "O Coliseu é um dos edifícios mais reconhecidos da Roma clássica. Mesmo 2 000 anos após a sua construção, e apesar dos séculos em que foi abandonado e pilhado para obter materiais de construção, continua a ser imediatamente reconhecível. É um modelo clássico dos estádios atuais. É um dos grandes anfiteatros da Roma antiga."}]
 property var pages: []
 function all(root){var result=[root];if(root.children)for(var child of root.children)result=result.concat(all(child));return result;}
 function click(item){var p=item.mapToItem(pageView,item.width/2,item.height/2);verify(p.x>=0&&p.y>=0&&p.x<pageView.width&&p.y<pageView.height,'Painted control inside viewport');mouseClick(item,item.width/2,item.height/2,Qt.LeftButton,Qt.NoModifier,10);wait(50);}
 function icon(suffix){var image=all(bar).find(child=>child.source!==undefined&&String(child.source).endsWith(suffix)&&child.visible);verify(image!==undefined,suffix);click(image);wait(400);}
 function spots(){return all(activityBackground).filter(node=>node.source!==undefined && /\/(question|key|suitcase|cat|chicken|cow|dog|duck|horse|owl|pig|sheep)\.svg$/.test(String(node.source))&&node.visible&&node.width>0&&node.height>0);}
 function continueSound(){if(audioNeededDialog.active){var button=all(audioNeededDialog.item).find(node=>node.text!==undefined&&String(node.text)===String(audioNeededDialog.item.button2Text)&&node.clicked!==undefined);verify(button!==undefined);click(button);wait(300);}}

 function test_colosseum_does_not_claim_false_priority(){
  wait(1200);continueSound();
  for(var map=1;map<=1;map++){
   compare(bar.level,map);compare(score.currentSubLevel,1);
   for(var lesson of targets.filter(row=>row.map===map)){
    var card=spots().find(node=>{var point=node.mapToItem(pageView,node.width/2,node.height/2);return Math.abs(point.x/pageView.width-lesson.x)<0.005&&Math.abs(point.y/pageView.height-lesson.y)<0.005;});verify(card!==undefined);click(card);tryCompare(descriptionPanel,'visible',true,2000);wait(1300);
    var image=all(descriptionPanel).find(node=>node.source!==undefined&&String(node.source).endsWith('.webp'));verify(image!==undefined);tryCompare(image,'status',Image.Ready,2000);compare(String(image.source),lesson.image);
    pages.push({image:String(image.source),title:String(descriptionPanel.title),description:String(descriptionPanel.description),map:map});grabImage(pageView).save('__QA_OUTPUT__/supplement-m'+map+'-'+(pages.length-1)+'.png');
    keyClick(Qt.Key_Escape);tryCompare(descriptionPanel,'visible',false,2000);
   }
   if(map<1){var attempts=0;while(bar.level===map&&attempts++<3)icon('bar_next.svg');compare(bar.level,map+1);wait(500);}
  }
  compare(pages.length,1);verify(pages.every(page=>page.description===targets.find(row=>row.image===page.image).new),'Geography, geology and dwellings preserve the source meaning in PT-PT');
 }
 function cleanupTestCase(){console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,pages:pages}));}
}
