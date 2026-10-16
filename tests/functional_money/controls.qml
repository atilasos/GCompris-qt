// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:'MoneyHelpConfigurationAndNavigation'
    when:activity.visible&&items.numberOfLevel>0
    property var denominations: __DENOMINATIONS__
    property var evidence: ({})
__VISIBLE__
__UI__
    function boxes(root){var result=[];function walk(item){if(item.visible&&item.checked!==undefined&&item.text!==undefined&&item.indicatorImageHeight!==undefined)result.push(item);if(item.children)for(var child of item.children)walk(child);}walk(root);return result;}
    function datasetOptions(){clickIcon(bar,'bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true);wait(600);clickText(dialogActivityConfig,'Conjunto de dados');wait(400);return boxes(dialogActivityConfig);}
    function test_visible_controls(){
        wait(1800);checked(activity.activityInfo.title,__TITLE__);checked(items.numberOfLevel,__TOTAL__);
        // Demonstrate every physical navigation key on rendered highlights.
        activityBackground.forceActiveFocus();keyClick(Qt.Key_Right);var first=money(pocketArea.answer).filter(function(row){return row.item.selected;})[0];ensure(first!==undefined);
        keyClick(Qt.Key_Left);var last=money(pocketArea.answer).filter(function(row){return row.item.selected;})[0];ensure(last!==undefined);ensure(last.item!==first.item);keyClick(Qt.Key_Right);
        var wanted=__CHANGE__?sum(money(tuxMoney))-sum(prices()):sum(prices());
        var wrong=money(pocketArea.answer).filter(function(row){return row.cents!==wanted;})[0];ensure(wrong!==undefined);transfer(wrong.source,false,true);checked(answerArea.answer.count,1);
        var panel=openOptions();chooseMode(panel,1);saveOptions();checked(answerArea.answer.count,0);checked(items.currentLevel,0);checked(okButton.visible,true);
        panel=openOptions();checked(panel.modeBox.currentIndex,1);chooseMode(panel,0);saveOptions();checked(okButton.visible,false);
        var options=datasetOptions();checked(options.length,3);var objectives=options.map(function(box){ensure(box.text.length>10);checked(box.checked,true);return String(box.text);});
        click(options[0]);checked(options[0].checked,false);saveOptions();checked(items.numberOfLevel,__REDUCED__);checked(items.currentLevel,0);
        options=datasetOptions();checked(options.length,3);checked(options[0].checked,false);checked(options[1].checked,true);checked(options[2].checked,true);click(options[0]);saveOptions();checked(items.numberOfLevel,__TOTAL__);
        clickIcon(bar,'bar_previous.svg');checked(items.currentLevel,__TOTAL__-1);clickIcon(bar,'bar_next.svg');checked(items.currentLevel,0);
        var depth=pageView.depth;clickIcon(bar,'bar_help.svg');tryCompare(pageView,'depth',depth+1);wait(600);var help=pageView.currentItem;
        checked(help.title,__TITLE__);ensure(help.content.indexOf(activity.activityInfo.manual)>=0);ensure(help.content.indexOf('Click on')<0);ensure(help.content.indexOf('teclado')>=0);grabImage(pageView).save('__QA_OUTPUT__/help.png');
        clickIcon(help,'cancel.svg');tryCompare(pageView,'depth',depth);wait(500);
        // No forceActiveFocus after closing help.
        keyClick(Qt.Key_Right);ensure(money(pocketArea.answer).some(function(row){return row.item.selected;}),'Keyboard focus after help');
        var before=pocketArea.answer.count;keyClick(Qt.Key_Enter);checked(pocketArea.answer.count,before-1);checked(answerArea.answer.count,1);keyClick(Qt.Key_Tab);keyClick(Qt.Key_Space);checked(answerArea.answer.count,0);
        ActivityInfoTree.startingActivity='';if(__ESCAPE__)keyClick(Qt.Key_Escape);else clickIcon(bar,'bar_home.svg');tryCompare(pageView,'depth',1);ensure(pageView.currentItem.isMenu);
        evidence={title:__TITLE__,objectives:objectives,modePersistence:true,datasetPersistence:true,partialRestart:true,previousNextWrap:true,helpPortuguese:true,keyboardAfterHelp:true,exit:__ESCAPE__?'Escape':'Home',menu:true};
    }
    function cleanupTestCase(){console.log('NATIVE_MONEY_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
