// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: 'OrderingControls'
    when: true
    property var evidence: ({})
    File { id: resourceReader }
    function find(root,predicate) {
        if(predicate(root)) return root;
        if(root.children)for(var child of root.children){var found=find(child,predicate);if(found)return found;}
        return null;
    }
    function click(item) {
        verify(item!==null);var p=item.mapToItem(pageView,item.width/2,item.height/2);
        mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);
    }
    function button(suffix) {click(find(bar,function(item){return item.source!==undefined&&String(item.source).endsWith(suffix);}));}
    function checkbox() {return find(dialogActivityConfig,function(item){return item.indicatorImageHeight!==undefined && item.checked!==undefined;});}
    function save() {dialogActivityConfig.forceActiveFocus();keyClick(Qt.Key_Return);tryCompare(activity,'visible',true,2500);wait(1100);}
    function test_configuration_restart_navigation_help_menu() {
        wait(1600);if(!activity.visible){keyClick(Qt.Key_Return);tryCompare(activity,'visible',true,2500);wait(1100);}
        var totals={numbers:8,alphabets:8,sentences:20}, reduced={numbers:7,alphabets:6,sentences:10};
        tryCompare(activityBackground,'status',Image.Ready,2500);
        var backdrop=resourceReader.read(String(activityBackground.source));verify(backdrop.indexOf('<svg')>=0);

        compare(activity.numberOfLevel,totals[activity.mode]);
        var card=find(originPlaceholder,function(item){return item.placeholderName==='origin'&&typeof item.elementValue==='string';});
        verify(card!==null);
        var from=card.mapToItem(pageView,card.width/2,card.height/2),to=targetPlaceholder.mapToItem(pageView,targetPlaceholder.width-25,targetPlaceholder.height-25);
        mousePress(pageView,from.x,from.y,Qt.LeftButton,Qt.NoModifier,0);mouseMove(pageView,from.x+15,from.y+15,30);mouseMove(pageView,from.x+30,from.y+30,30);mouseMove(pageView,to.x,to.y,30);mouseRelease(pageView,to.x,to.y,Qt.LeftButton,Qt.NoModifier,30);wait(600);
        compare(items.targetListModel.count,1);

        button('bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2500);wait(1100);
        var first=checkbox();verify(first!==null);verify(first.checked);
        var label=first.text, before=dialogActivityConfig.chosenLevels.slice();
        click(first);compare(first.checked,false);compare(dialogActivityConfig.chosenLevels.length,before.length-1);
        save();compare(activity.numberOfLevel,reduced[activity.mode]);compare(items.currentLevel,0);
        button('bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true,2500);wait(1100);
        first=checkbox();compare(first.text,label);compare(first.checked,false);
        compare(activity.activityInfo.currentLevels.length,before.length-1);
        compare(ApplicationSettings.ignoredLevels(activity.activityInfo.shortName()).length,1);
        evidence={configurationSaved:true,restartClearedPartial:true,persistentIgnoredDatasets:ApplicationSettings.ignoredLevels(activity.activityInfo.shortName()),firstDataset:label,allLevels:totals[activity.mode],reducedLevels:reduced[activity.mode]};
        click(first);save();compare(activity.numberOfLevel,totals[activity.mode]);compare(items.targetListModel.count,0);
        button('bar_previous.svg');compare(items.currentLevel,totals[activity.mode]-1);
        button('bar_next.svg');compare(items.currentLevel,0);
        var depth=pageView.depth;button('bar_help.svg');tryCompare(pageView,'depth',depth+1,2500);wait(1100);
        var help=pageView.currentItem;compare(help.title,activity.activityInfo.title);verify(help.content.indexOf(activity.activityInfo.manual)>=0);
        verify(help.content.indexOf('Drag and drop')<0);verify(activity.activityInfo.manual.length>20);
        grabImage(pageView).save('__QA_OUTPUT__/help.png');evidence.title=help.title;evidence.manual=activity.activityInfo.manual;
        click(find(help,function(item){return item.source!==undefined&&String(item.source).endsWith('cancel.svg');}));tryCompare(pageView,'depth',depth,2500);wait(1100);
        activityBackground.forceActiveFocus();verify(activityBackground.activeFocus);
        ActivityInfoTree.startingActivity='';button('bar_home.svg');tryCompare(pageView,'depth',1,2500);verify(pageView.currentItem.isMenu);
        evidence.help=true;evidence.navigation=true;evidence.menu=true;
        evidence.background={url:String(activityBackground.source),status:activityBackground.status,svg:backdrop};
    }
    function cleanupTestCase(){console.log('NATIVE_ORDERING_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
