// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 id: controls
 name: 'ExplorationControlsAndPortugueseHelp'
 when:activity.visible
 property var evidence: ({})
 function all(root){var result=[root];if(root.children)for(var child of root.children)result=result.concat(all(child));return result;}
 function click(item){var p=item.mapToItem(pageView,item.width/2,item.height/2);verify(p.x>=0&&p.y>=0&&p.x<pageView.width&&p.y<pageView.height,'Painted control inside viewport');mouseClick(item,item.width/2,item.height/2,Qt.LeftButton,Qt.NoModifier,10);wait(50);}
 function icon(suffix){var image=all(bar).find(child=>child.source!==undefined&&String(child.source).endsWith(suffix)&&child.visible);verify(image!==undefined,suffix);click(image);wait(400);}
 function spots(){return all(activityBackground).filter(node=>node.source!==undefined && /\/(question|key|suitcase|cat|chicken|cow|dog|duck|horse|owl|pig|sheep)\.svg$/.test(String(node.source))&&node.visible&&node.width>0&&node.height>0);}
 function continueSound(){if(audioNeededDialog.active){var button=all(audioNeededDialog.item).find(node=>node.text!==undefined&&String(node.text)===String(audioNeededDialog.item.button2Text)&&node.clicked!==undefined);verify(button!==undefined);click(button);wait(300);}}

 function stars(){return all(activityBackground).filter(node=>node.source!==undefined&&String(node.source).endsWith('/star.png')&&node.visible).length;}
 function test_controls(){
  wait(1200);evidence.audioNotice=audioNeededDialog.active;continueSound();
  var initialDepth=pageView.depth;icon('bar_help.svg');tryCompare(pageView,'depth',initialDepth+1,2000);wait(300);
  var help=pageView.currentItem;evidence.help={title:String(help.title),content:String(help.content)};verify(evidence.help.title.length>0&&evidence.help.content.length>0);var id=activity.activityInfo.shortName();if(id==='explore_world_animals')verify(!evidence.help.content.includes('o som que faz'),'World-animal help does not promise untaught animal sounds');if(id==='explore_farm_animals')verify(!evidence.help.content.includes('ponto de interrogação'),'Farm help describes the actual animal pictures');grabImage(pageView).save('__QA_OUTPUT__/help.png');
  keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',initialDepth,2000);tryCompare(pageView,'busy',false,2000);wait(80);evidence.afterHelp={depth:pageView.depth,phase:score.currentSubLevel,progress:progressbar.currentSubLevel,total:progressbar.numberOfSubLevels};
  var card=spots()[0];verify(card!==undefined);evidence.firstCard={source:String(card.source),visible:card.visible,x:card.x,y:card.y,width:card.width,height:card.height};click(card);evidence.afterClick=descriptionPanel.visible;tryCompare(descriptionPanel,'visible',true,2000);wait(1300);keyClick(Qt.Key_Escape);tryCompare(descriptionPanel,'visible',false,2000);compare(pageView.depth,initialDepth);evidence.focusAfterHelp=true;compare(stars(),1);
  icon('bar_reload.svg');compare(stars(),0);compare(score.currentSubLevel,1);compare(bar.level,1);evidence.partialReload=true;
  icon('bar_next.svg');compare(bar.level,1);compare(score.currentSubLevel,2);icon('bar_previous.svg');compare(bar.level,1);compare(score.currentSubLevel,1);evidence.phaseNavigation=true;
  icon('bar_previous.svg');compare(bar.level,activity.numberOfLevel);compare(score.currentSubLevel,score.numberOfSubLevels);icon('bar_next.svg');compare(bar.level,1);compare(score.currentSubLevel,1);evidence.wrap=true;
  var before={map:bar.level,stage:score.currentSubLevel};keyClick(Qt.Key_A);compare(bar.level,before.map);compare(score.currentSubLevel,before.stage);evidence.unsupportedKeyIgnored=true;
  evidence.configurationOffered=!!(bar.content.value&bar.content.activityConfig);compare(evidence.configurationOffered,false);grabImage(pageView).save('__QA_OUTPUT__/controls.png');
  ActivityInfoTree.startingActivity='';keyClick(Qt.Key_W,Qt.ControlModifier);tryCompare(pageView,'depth',1,2000);tryCompare(pageView,'busy',false,2000);verify(pageView.currentItem.isMenu);evidence.menu=true;grabImage(pageView).save('__QA_OUTPUT__/menu.png');
 }
 function cleanupTestCase(){if(qtest_results.failCount)grabImage(pageView).save('__QA_OUTPUT__/failure.png');console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
