// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:'FractionsControls'
    when:true
    property var evidence: ({})
    function check(a,b,message){if(a!==b)console.log('FRACTIONS_CONTROL_ASSERT',a,b,message||'',new Error().stack);compare(a,b,message||'');}
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var hit=find(child,predicate);if(hit)return hit;}return null;}
    function click(item){verify(item!==null);var p=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);wait(20);}
    function button(suffix){click(find(bar,function(item){return item.source!==undefined&&String(item.source).endsWith(suffix);}));}
    function label(root){return Number(find(root,function(item){return item.text!==undefined&&item.visible&&/^\d+$/.test(String(item.text));}).text);}
    function checkbox(){return find(dialogActivityConfig,function(item){return item.indicatorImageHeight!==undefined&&item.checked!==undefined;});}
    function save(){dialogActivityConfig.forceActiveFocus();keyClick(Qt.Key_Return);tryCompare(dialogActivityConfig,'visible',false,2500);wait(1100);}
    function partialInput(){
        check(label(numeratorText),0);
        if(activity.mode==='findFraction'){click(find(numeratorText,function(item){return item.source!==undefined&&String(item.source).endsWith('bar_next.svg');}));}
        else{
            var chart=find(chartDisplay,function(item){return item.pieSeries!==undefined;});verify(chart!==null);
            var slice=chart.pieSeries.at(0),angle=(slice.startAngle+slice.angleSpan/2)*Math.PI/180,plot=chart.plotArea,r=Math.min(plot.width,plot.height)*0.27;
            var p=chart.mapToItem(pageView,plot.x+plot.width/2+Math.sin(angle)*r,plot.y+plot.height/2-Math.cos(angle)*r);
            mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);wait(60);
        }
        check(label(numeratorText),1);check(score.currentSubLevel,0);
    }
    function test_dataset_restart_navigation_help_focus_menu(){
        wait(1800);if(!activity.visible){keyClick(Qt.Key_Return);tryCompare(activity,'visible',true,2500);wait(1100);}
        var total=activity.mode==='selectPie'?18:12;
        check(activity.numberOfLevel,total);partialInput();
        button('bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2500);wait(1100);save();
        check(label(numeratorText),0);check(items.currentLevel,0);check(score.currentSubLevel,0);
        button('bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2500);wait(1100);
        var first=checkbox();verify(first!==null&&first.checked);var objective=first.text;
        click(first);check(first.checked,false);save();check(activity.numberOfLevel,total-2);
        check(ApplicationSettings.ignoredLevels(activity.activityInfo.shortName()).length,1);
        button('bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2500);wait(1100);first=checkbox();check(first.checked,false);check(first.text,objective);click(first);save();check(activity.numberOfLevel,total);
        button('bar_previous.svg');check(items.currentLevel,total-1);check(score.currentSubLevel,0);button('bar_next.svg');check(items.currentLevel,0);check(score.currentSubLevel,0);
        var depth=pageView.depth;button('bar_help.svg');tryCompare(pageView,'depth',depth+1,2500);wait(1100);var help=pageView.currentItem;
        check(help.title,activity.mode==='selectPie'?'Criar as frações':'Descobrir as frações');verify(help.content.indexOf(activity.activityInfo.manual)>=0);verify(activity.activityInfo.manual.length>40);verify(help.content.indexOf('A shape split')<0);
        grabImage(pageView).save('__QA_OUTPUT__/help.png');
        evidence={mode:activity.mode,levels:total,reducedLevels:total-2,firstDataset:objective,configurationSaved:true,restartClearedInput:true,previousNext:true,title:help.title,manual:activity.activityInfo.manual};
        click(find(help,function(item){return item.source!==undefined&&String(item.source).endsWith('cancel.svg');}));tryCompare(pageView,'depth',depth,2500);wait(1100);activityBackground.forceActiveFocus();verify(activityBackground.activeFocus);partialInput();evidence.inputAfterHelp=true;
        ActivityInfoTree.startingActivity='';if(activity.mode==='findFraction'){keyClick(Qt.Key_Escape);evidence.exit='Escape';}else{button('bar_home.svg');evidence.exit='Home';}
        tryCompare(pageView,'depth',1,2500);verify(pageView.currentItem.isMenu);evidence.menu=true;
    }
    function cleanupTestCase(){console.log('NATIVE_FRACTIONS_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
