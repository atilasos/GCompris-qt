// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:'MoneyHelpConfigurationAndNavigation'
    when:activity.visible&&items.numberOfLevel>0
    property var denominations: {"c1c.svg": 1, "c2c.svg": 2, "c5c.svg": 5, "c10c.svg": 10, "c20c.svg": 20, "c50c.svg": 50, "c1e.svg": 100, "c2e.svg": 200, "n5e.svg": 500, "n10e.svg": 1000, "n20e.svg": 2000, "n50e.svg": 5000, "n100e.svg": 10000, "n200e.svg": 20000, "n500e.svg": 50000}
    property var evidence: ({})
    function ensure(value,message){if(!value){console.log('MONEY_ASSERT',message,new Error().stack);grabImage(pageView).save('__QA_OUTPUT__/failure.png');}verify(value,message||'');}
    function checked(a,b,message){if(a!==b)console.log('MONEY_COMPARE',a,b,message,new Error().stack);compare(a,b,message||'');}
    function click(item){ensure(item!==null);var point=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,point.x,point.y,Qt.LeftButton,Qt.NoModifier,0);wait(60);}
    function cents(text){var value=String(text).replace(/[\s.€]/g,'');ensure(/^\d+(,\d{2})?$/.test(value),'Portuguese price '+text);var parts=value.split(',');return Number(parts[0])*100+Number(parts[1]||0);}
    function coin(item){var source=String(item.source);var value=denominations[source.split('/').pop()];ensure(value!==undefined,'Known visible denomination '+source);return {item:item,source:source,cents:value};}
    function money(repeater){var result=[];for(var i=0;i<repeater.count;i++){var item=repeater.itemAt(i);ensure(item.visible&&item.width>0);tryCompare(item,'status',1,3000);result.push(coin(item));}return result;}
    function prices(){var result=[];for(var i=0;i<store.count;i++){var image=store.itemAt(i);tryCompare(image,'status',1,3000);var label=find(image,function(item){return item.text!==undefined&&item.visible&&String(item.text).length>0;});ensure(label!==null);result.push({text:String(label.text),cents:cents(label.text),image:String(image.source)});}return result;}
    function sum(rows){return rows.reduce(function(total,row){return total+row.cents;},0);}
    function solve(rows,wanted){
        var sorted=rows.slice().sort(function(a,b){return b.cents-a.cents;}),failed={};
        function visit(index,left){
            if(left===0)return [];
            if(index===sorted.length||left<0)return null;
            var key=index+'|'+left;if(failed[key])return null;
            var included=visit(index+1,left-sorted[index].cents);
            if(included!==null)return [sorted[index].source].concat(included);
            var excluded=visit(index+1,left);if(excluded!==null)return excluded;
            failed[key]=true;return null;
        }
        return visit(0,wanted);
    }
    function transfer(source,fromAnswer,keyboard){
        var from=fromAnswer?answerArea.answer:pocketArea.answer,to=fromAnswer?pocketArea.answer:answerArea.answer;
        var selected=money(from).filter(function(row){return row.source===source;})[0];ensure(selected!==undefined);
        var before=from.count,other=to.count;
        if(keyboard){
            activityBackground.forceActiveFocus();
            function highlighted(){return money(from).some(function(row){return row.item.selected;});}
            for(var tab=0;tab<3&&!highlighted();tab++)keyClick(Qt.Key_Tab);
            ensure(highlighted(),'Requested visible money area gets keyboard highlight');
            for(var step=0;step<from.count+1;step++){
                var focused=money(from).filter(function(row){return row.item.selected;})[0];
                if(focused&&focused.source===source)break;
                keyClick(Qt.Key_Right);
            }
            ensure(money(from).some(function(row){return row.item.selected&&row.source===source;}));
            keyClick(fromAnswer?Qt.Key_Space:Qt.Key_Return);
        }else click(selected.item);
        wait(400);checked(from.count,before-1,'One real transfer');checked(to.count,other+1);
    }
    function clearAnswer(){while(answerArea.answer.count)transfer(String(answerArea.answer.itemAt(0).source),true,false);}

    function find(root,predicate) {
        if(predicate(root))return root;
        if(root.children)for(var child of root.children){var result=find(child,predicate);if(result)return result;}
        return null;
    }
    function clickIcon(root,suffix) {
        wait(400);
        var button=find(root,function(item){return item.source!==undefined && String(item.source).endsWith(suffix);});
        verify(button!==null,"Icon "+suffix);mouseClick(button);
    }
    function clickText(root,text) {
        var button=find(root,function(item){return item.clicked!==undefined && item.text===text && item.visible;});
        verify(button!==null,"Button "+text);mouseClick(button);
    }
    function openOptions() {
        clickIcon(bar,"bar_activity_config.svg");tryCompare(dialogActivityConfig,"visible",true);wait(600);
        clickText(dialogActivityConfig,"Opções");wait(300);
        return find(dialogActivityConfig,function(item){return item.modeBox!==undefined || item.speedSlider!==undefined;});
    }
    function saveOptions() {
        clickText(dialogActivityConfig,"Gravar");tryCompare(dialogActivityConfig,"visible",false);wait(2400);
    }
    function chooseMode(panel,index) {
        verify(panel!==null);
        var box=panel.modeBox;
        var label=find(box,function(item){return item.text!==undefined && item.text===box.currentText && item.visible;});
        verify(label!==null);mouseClick(label);wait(200);
        var previous=box.currentIndex;
        for(var step=0;step<Math.abs(index-previous);step++)keyClick(index>previous?Qt.Key_Right:Qt.Key_Left);
        keyClick(Qt.Key_Return);wait(250);compare(box.currentIndex,index);
    }

    function boxes(root){var result=[];function walk(item){if(item.visible&&item.checked!==undefined&&item.text!==undefined&&item.indicatorImageHeight!==undefined)result.push(item);if(item.children)for(var child of item.children)walk(child);}walk(root);return result;}
    function datasetOptions(){clickIcon(bar,'bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true);wait(600);clickText(dialogActivityConfig,'Conjunto de dados');wait(400);return boxes(dialogActivityConfig);}
    function test_visible_controls(){
        wait(1800);checked(activity.activityInfo.title,"Dinheiro");checked(items.numberOfLevel,23);
        // Demonstrate every physical navigation key on rendered highlights.
        activityBackground.forceActiveFocus();keyClick(Qt.Key_Right);var first=money(pocketArea.answer).filter(function(row){return row.item.selected;})[0];ensure(first!==undefined);
        keyClick(Qt.Key_Left);var last=money(pocketArea.answer).filter(function(row){return row.item.selected;})[0];ensure(last!==undefined);ensure(last.item!==first.item);keyClick(Qt.Key_Right);
        var wanted=false?sum(money(tuxMoney))-sum(prices()):sum(prices());
        var wrong=money(pocketArea.answer).filter(function(row){return row.cents!==wanted;})[0];ensure(wrong!==undefined);transfer(wrong.source,false,true);checked(answerArea.answer.count,1);
        var panel=openOptions();chooseMode(panel,1);saveOptions();checked(answerArea.answer.count,0);checked(items.currentLevel,0);checked(okButton.visible,true);
        panel=openOptions();checked(panel.modeBox.currentIndex,1);chooseMode(panel,0);saveOptions();checked(okButton.visible,false);
        var options=datasetOptions();checked(options.length,3);var objectives=options.map(function(box){ensure(box.text.length>10);checked(box.checked,true);return String(box.text);});
        click(options[0]);checked(options[0].checked,false);saveOptions();checked(items.numberOfLevel,16);checked(items.currentLevel,0);
        options=datasetOptions();checked(options.length,3);checked(options[0].checked,false);checked(options[1].checked,true);checked(options[2].checked,true);click(options[0]);saveOptions();checked(items.numberOfLevel,23);
        clickIcon(bar,'bar_previous.svg');checked(items.currentLevel,23-1);clickIcon(bar,'bar_next.svg');checked(items.currentLevel,0);
        var depth=pageView.depth;clickIcon(bar,'bar_help.svg');tryCompare(pageView,'depth',depth+1);wait(600);var help=pageView.currentItem;
        checked(help.title,"Dinheiro");ensure(help.content.indexOf(activity.activityInfo.manual)>=0);ensure(help.content.indexOf('Click on')<0);ensure(help.content.indexOf('teclado')>=0);grabImage(pageView).save('__QA_OUTPUT__/help.png');
        clickIcon(help,'cancel.svg');tryCompare(pageView,'depth',depth);wait(500);
        // No forceActiveFocus after closing help.
        keyClick(Qt.Key_Right);ensure(money(pocketArea.answer).some(function(row){return row.item.selected;}),'Keyboard focus after help');
        var before=pocketArea.answer.count;keyClick(Qt.Key_Enter);checked(pocketArea.answer.count,before-1);checked(answerArea.answer.count,1);keyClick(Qt.Key_Tab);keyClick(Qt.Key_Space);checked(answerArea.answer.count,0);
        ActivityInfoTree.startingActivity='';if(false)keyClick(Qt.Key_Escape);else clickIcon(bar,'bar_home.svg');tryCompare(pageView,'depth',1);ensure(pageView.currentItem.isMenu);
        evidence={title:"Dinheiro",objectives:objectives,modePersistence:true,datasetPersistence:true,partialRestart:true,previousNextWrap:true,helpPortuguese:true,keyboardAfterHelp:true,exit:false?'Escape':'Home',menu:true};
    }
    function cleanupTestCase(){console.log('NATIVE_MONEY_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
