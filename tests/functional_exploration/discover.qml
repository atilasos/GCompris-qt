// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name: 'VisibleExplorationPresentations'
 when: activity.visible
 property var pages: []
 property var evidence: ({})
 Component.onCompleted: {ApplicationSettings.isAudioVoicesEnabled=true;ApplicationSettings.isAudioEffectsEnabled=true;}
 function all(root){var result=[root];if(root.children)for(var child of root.children)result=result.concat(all(child));return result;}
 function click(item){var p=item.mapToItem(pageView,item.width/2,item.height/2);verify(p.x>=0&&p.y>=0&&p.x<pageView.width&&p.y<pageView.height,'Painted control inside viewport');mouseClick(item,item.width/2,item.height/2,Qt.LeftButton,Qt.NoModifier,10);wait(50);}
 function icon(suffix){var image=all(bar).find(child=>child.source!==undefined&&String(child.source).endsWith(suffix)&&child.visible);verify(image!==undefined,suffix);click(image);wait(400);}
 function spots(){return all(activityBackground).filter(node=>node.source!==undefined && /\/(question|key|suitcase|cat|chicken|cow|dog|duck|horse|owl|pig|sheep)\.svg$/.test(String(node.source))&&node.visible&&node.width>0&&node.height>0);}
 function continueSound(){if(audioNeededDialog.active){var button=all(audioNeededDialog.item).find(node=>node.text!==undefined&&String(node.text)===String(audioNeededDialog.item.button2Text)&&node.clicked!==undefined);verify(button!==undefined);click(button);wait(300);}}
 function test_presentations(){
  wait(1200);continueSound();
  evidence={initial:{map:bar.level,stage:score.currentSubLevel,totalStages:score.numberOfSubLevels,totalMaps:activity.numberOfLevel},spots:spots().length};
  for(var map=1;map<=activity.numberOfLevel;map++){
  compare(bar.level,map);compare(score.currentSubLevel,1);
  var cards=spots();verify(cards.length>0);
  for(var i=0;i<cards.length;i++){
   tryCompare(cards[i],'status',Image.Ready,2000);var point=cards[i].mapToItem(pageView,cards[i].width/2,cards[i].height/2);click(cards[i]);tryCompare(descriptionPanel,'visible',true,2000);wait(1300);
   var images=all(descriptionPanel).filter(node=>node.source!==undefined&&String(node.source).endsWith('.webp'));verify(images.length===1);tryCompare(images[0],'status',Image.Ready,2000);
   pages.push({map:map,title:String(descriptionPanel.title),description:String(descriptionPanel.description),image:String(images[0].source),mapImage:String(bg.source),x:point.x/pageView.width,y:point.y/pageView.height,audio:String(activity.audioVoices.source)});
   grabImage(pageView).save('__QA_OUTPUT__/presentation-m'+map+'-'+i+'.png');
   keyClick(Qt.Key_Escape);tryCompare(descriptionPanel,'visible',false,2000);wait(100);
  }
  wait(2200);if(map<activity.numberOfLevel){var steps=0;while(bar.level===map&&steps++<3)icon('bar_next.svg');compare(bar.level,map+1);wait(600);}
  }
  evidence.after={map:bar.level,stage:score.currentSubLevel,okVisible:okButton.visible};grabImage(pageView).save('__QA_OUTPUT__/visited.png');
 }
 function cleanupTestCase(){console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,pages:pages,evidence:evidence}));}
}
