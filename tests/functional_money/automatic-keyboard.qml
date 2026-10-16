// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: 'AutomaticMoneyKeyboardRemainsUsable'
    when: activity.visible && items.numberOfLevel>0
    property var denominations: __DENOMINATIONS__
    property var evidence: ({})
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var result=find(child,predicate);if(result)return result;}return null;}
    function price(text){var value=String(text).replace(/[\s.€]/g,'').split(',');return Number(value[0])*100+Number(value[1]||0);}
    function coin(item){return denominations[String(item.source).split('/').pop()];}
    function click(item){var point=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,point.x,point.y,Qt.LeftButton,Qt.NoModifier,0);}
    function test_incorrect_payment_can_be_removed_by_real_keyboard(){
        wait(1800);verify(!okButton.visible,'Automatic validation is exposed');
        var total=0;for(var i=0;i<store.count;i++)total+=price(find(store.itemAt(i),function(item){return item.text!==undefined&&item.visible&&String(item.text).length>0;}).text);
        var chosen=null;
        for(i=0;i<pocketArea.answer.count;i++){var item=pocketArea.answer.itemAt(i);if(coin(item)!==total){chosen=item;break;}}
        verify(chosen!==null);var paid=coin(chosen);click(chosen);wait(700);
        compare(answerArea.answer.count,1);verify(!bonus.isPlaying);
        activityBackground.forceActiveFocus();keyClick(Qt.Key_Tab);keyClick(Qt.Key_Space);wait(500);
        evidence={displayedPriceCents:total,selectedCents:paid,afterKeyboardUndo:answerArea.answer.count};
        compare(answerArea.answer.count,0,'Tab and Space remove a wrong automatic payment');
    }
    function cleanupTestCase(){console.log('NATIVE_MONEY_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
