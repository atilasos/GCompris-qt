// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name: 'WaterVisiblePortugueseWording'
 when: activity.visible
 property var evidence: ({intro:[]})
 function all(root){var out=[root];if(root.children)for(var child of root.children)out=out.concat(all(child));return out;}
 function text(root){return all(root).filter(c=>c.visible&&c.text!==undefined&&String(c.text).length>70).map(c=>String(c.text));}
 function test_wording(){
  wait(1200);verify(message.visible);
  for(var i=0;i<4;i++){var visible=text(message);compare(visible.length,1);evidence.intro.push(visible[0]);grabImage(pageView).save('__QA_OUTPUT__/intro-'+i+'.png');keyClick(Qt.Key_Space);wait(300);}
  tryCompare(message,'visible',false,2000);var depth=pageView.depth;
  var icon=all(bar).find(c=>c.source!==undefined&&String(c.source).endsWith('bar_help.svg'));verify(icon!==undefined);var p=icon.mapToItem(pageView,icon.width/2,icon.height/2);mouseClick(pageView,p.x,p.y);tryCompare(pageView,'depth',depth+1,2000);wait(300);var help=pageView.currentItem;evidence.help={title:String(help.title),content:String(help.content)};grabImage(pageView).save('__QA_OUTPUT__/help.png');
  verify(evidence.intro[3].indexOf('Quando o Tux estiver em casa')>=0&&evidence.intro[3].indexOf('torre tiver água')>=0,'Instructions explain the actual shower prerequisites');verify(evidence.intro[3].indexOf('antes do Tux')<0,'There is no deadline before arrival');
 }
 function cleanupTestCase(){console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
