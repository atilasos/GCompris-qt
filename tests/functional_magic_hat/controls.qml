// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:'MagicHatHelpDatasetPersistenceAndRestart'
    when:activity.visible&&items.numberOfLevel>0
    property var evidence: ({})
__VISIBLE__
    function icon(root,suffix){wait(1800);var button=find(root,function(item){return item.source!==undefined&&String(item.source).endsWith(suffix)&&item.visible;});ensure(button!==null,'Icon '+suffix);click(button);wait(1800);}
    function button(root,text){var found=find(root,function(item){return item.clicked!==undefined&&item.text===text&&item.visible;});ensure(found!==null,text);click(found);}
    function boxes(root){var result=[];function walk(item){if(item.visible&&item.checked!==undefined&&item.text!==undefined&&item.indicatorImageHeight!==undefined)result.push(item);if(item.children)for(var child of item.children)walk(child);}walk(root);return result;}
    function configuration(){icon(bar,'bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true);wait(300);return boxes(dialogActivityConfig);}
    function save(){button(dialogActivityConfig,'Gravar');tryCompare(dialogActivityConfig,'visible',false);wait(2200);}
    function test_controls(){
        wait(1800);var title=mode==='plus'?'O chapéu do mágico (adição)':'O chapéu do mágico (subtração)';compare(activity.activityInfo.title,title);compare(items.numberOfLevel,41);
        click(theHat);tryCompare(okButton,'enabled',true,12000);click(repeaterAnswerRow.itemAt(0).repeaterStars.itemAt(0).starFixed);compare(rows(repeaterAnswerRow)[0].count,1);
        var options=configuration();compare(options.length,9);var objectives=options.map(function(option){ensure(option.text.length>10);compare(option.checked,true);return String(option.text);});save();compare(items.currentLevel,0);compare(okButton.enabled,false);ensure(rows(repeaterAnswerRow).every(function(row){return row===null||row.count===0;}));
        options=configuration();click(options[0]);compare(options[0].checked,false);save();compare(items.numberOfLevel,39);
        options=configuration();compare(options[0].checked,false);for(var index=1;index<options.length;index++)compare(options[index].checked,true);click(options[0]);save();compare(items.numberOfLevel,41);
        icon(bar,'bar_previous.svg');compare(items.currentLevel,40);icon(bar,'bar_next.svg');compare(items.currentLevel,0);icon(bar,'bar_next.svg');compare(items.currentLevel,1);icon(bar,'bar_previous.svg');compare(items.currentLevel,0);
        var depth=pageView.depth;icon(bar,'bar_help.svg');tryCompare(pageView,'depth',depth+1);var help=pageView.currentItem;compare(help.title,title);ensure(help.content.indexOf(activity.activityInfo.manual)>=0);ensure(help.content.indexOf('Click on')<0);ensure(help.content.indexOf('cartola')>=0,'Portuguese manual uses cartola');grabImage(pageView).save('__QA_OUTPUT__/help.png');keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth);wait(1800);
        click(theHat);tryCompare(okButton,'enabled',true,12000);click(repeaterAnswerRow.itemAt(0).repeaterStars.itemAt(0).starFixed);compare(rows(repeaterAnswerRow)[0].count,1);
        ActivityInfoTree.startingActivity='';if(mode==='plus')keyClick(Qt.Key_Escape);else icon(bar,'bar_home.svg');tryCompare(pageView,'depth',1);ensure(pageView.currentItem.isMenu);
        evidence={title:title,objectives:objectives,restartPartial:true,datasetPersistence:true,levelsBefore:41,levelsAfterExclusion:39,previousNextWrap:true,helpPortuguese:true,helpEscape:true,inputAfterHelp:true,menu:true};
    }
    function cleanupTestCase(){console.log('NATIVE_MAGIC_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
