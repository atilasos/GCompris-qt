// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "AdjacentFromVisibleUnitSequence"
    when: activity.visible && bar.level>0
    property int firstLevel: 1
    property int targetLevels: 1
    property bool manual: true
    property var completed: []
    property var puzzles: []
    property int wrong: 0
    property int moves: 0
    function checked(a,b,msg){if(a!==b)console.log("ADJACENT_ASSERT",a,b,msg||"",new Error().stack);compare(a,b,msg||"");}
    function ensure(v,msg){if(!v)console.log("ADJACENT_ASSERT",msg||"",new Error().stack);verify(v,msg||"");}
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var hit=find(child,predicate);if(hit)return hit;}return null;}
    function click(item){ensure(item!==null);var p=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,p.x,p.y);wait(50);}
    function icon(root,suffix){var item=find(root,function(o){return o.visible&&o.source!==undefined&&String(o.source).endsWith(suffix);});ensure(item!==null,suffix);click(item);}
    function shown(tile){var text=find(tile,function(o){return o.text!==undefined&&o.font!==undefined;});ensure(text!==null);return String(text.text);}
    function tiles(flow,question){var result=[];for(var tile of flow.children)if(question?tile.tileChanged!==undefined:tile.mouseHeld!==undefined)result.push(tile);result.sort(function(a,b){return a.y-b.y||a.x-b.x;});return result;}
    function value(text){var clean=text.replace(/\s/g,"").replace(/−/g,"-");ensure(/^-?\d+$/.test(clean),"Integer Portuguese glyphs: "+text);return parseInt(clean,10);}
    function drag(source,target){
        var a=source.mapToItem(pageView,source.width/2,source.height/2),b=target.mapToItem(pageView,target.width/2,target.height/2);
        mousePress(pageView,a.x,a.y);mouseMove(pageView,a.x+15,a.y,60);
        for(var i=1;i<=12;i++)mouseMove(pageView,a.x+(b.x-a.x)*i/12,a.y+(b.y-a.y)*i/12,20);
        mouseRelease(pageView,b.x,b.y);moves++;wait(70);
    }
    function proposal(number){var options=tiles(proposedTilesFlow,false);for(var option of options)if(value(shown(option))===number)return option;fail("Visible proposal "+number);return null;}
    function configure(){
        icon(bar,"bar_activity_config.svg");tryCompare(dialogActivityConfig,"visible",true,2500);wait(900);
        var box=find(dialogActivityConfig,function(o){return o.visible&&o.currentIndex!==undefined&&o.model!==undefined&&o.label!==undefined&&o.label===qsTranslate("ActivityConfig","Validate answers");});
        ensure(box!==null,"Answer mode selector");
        if(box.currentIndex!==(manual?1:0)){click(find(box,function(o){return o.visible&&o.text===box.currentText;}));wait(200);var label=qsTranslate("ActivityConfig",manual?"OK button":"Automatic");click(find(dialogActivityConfig,function(o){return o.visible&&o.text===label&&o.font!==undefined;}));wait(400);}
        checked(box.currentIndex,manual?1:0);dialogActivityConfig.forceActiveFocus();keyClick(Qt.Key_Return);tryCompare(dialogActivityConfig,"visible",false,2500);wait(1100);
        checked(String(ApplicationSettings.loadActivityConfiguration(activity.activityInfo.shortName()).answerMode),manual?"2":"1");
    }
    property var evidence: ({})
    function pressIcon(suffix){
        var hit=find(bar,function(o){return o.visible&&o.source!==undefined&&String(o.source).endsWith(suffix);});ensure(hit!==null,suffix);
        var p=hit.mapToItem(pageView,hit.width/2,hit.height/2);mouseClick(pageView,p.x,p.y);wait(60);
    }
    function clickItem(item){ensure(item!==null);var p=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,p.x,p.y);wait(70);}
    function openConfig(){pressIcon("bar_activity_config.svg");tryCompare(dialogActivityConfig,"visible",true,2500);wait(900);}
    function saveConfig(){dialogActivityConfig.forceActiveFocus();keyClick(Qt.Key_Return);tryCompare(dialogActivityConfig,"visible",false,2500);wait(1100);}
    function datasetOptions(){
        openConfig();var tab=find(dialogActivityConfig,function(o){return o.visible&&o.theme==="settingsButton"&&o.text===qsTranslate("DialogChooseLevel","Dataset");});
        if(tab!==null){clickItem(tab);wait(200);}
        var result=[];function walk(o){if(o.visible&&o.checked!==undefined&&o.indicatorImageHeight!==undefined)result.push(o);if(o.children)for(var child of o.children)walk(child);}walk(dialogActivityConfig);return result;
    }
    function test_controls(){
        wait(1400);checked(activity.numberOfLevel,25);checked(activity.activityInfo.title,"Descobrir os números sequenciais.");
        configure();var question=tiles(questionTilesFlow,true),blank=question.filter(function(t){return shown(t)==="?";})[0];var anchor=question.findIndex(function(t){return shown(t)!=="?";}),index=question.indexOf(blank),expected=value(shown(question[anchor]))+index-anchor;drag(proposal(expected),blank);checked(shown(blank),String(expected));checked(score.currentSubLevel,0);ensure(okButton.visible);
        openConfig();saveConfig();checked(score.currentSubLevel,0);checked(activity.currentLevel,0);
        ensure(tiles(questionTilesFlow,true).some(function(t){return shown(t)==="?";}));checked(okButton.visible,false);
        var options=datasetOptions();checked(options.length,5);ensure(options[0].checked);var objective=String(options[0].text);ensure(objective.length>10);
        clickItem(options[0]);checked(options[0].checked,false);saveConfig();checked(activity.numberOfLevel,21);checked(activity.currentLevel,0);
        options=datasetOptions();checked(options[0].checked,false);checked(String(options[0].text),objective);clickItem(options[0]);saveConfig();checked(activity.numberOfLevel,25);
        pressIcon("bar_previous.svg");checked(activity.currentLevel,25-1);checked(score.currentSubLevel,0);pressIcon("bar_next.svg");checked(activity.currentLevel,0);checked(score.currentSubLevel,0);
        var depth=pageView.depth;pressIcon("bar_help.svg");tryCompare(pageView,"depth",depth+1,2500);wait(800);var help=pageView.currentItem;
        checked(help.title,"Descobrir os números sequenciais.");ensure(help.content.indexOf(activity.activityInfo.manual)>=0);ensure(help.content.indexOf("Click on")<0);ensure(activity.activityInfo.manual.length>30);grabImage(pageView).save("__QA_OUTPUT__/help.png");
        keyClick(Qt.Key_Escape);tryCompare(pageView,"depth",depth,2500);wait(700);
        question=tiles(questionTilesFlow,true);blank=question.filter(function(t){return shown(t)==="?";})[0];anchor=question.findIndex(function(t){return shown(t)!=="?";});index=question.indexOf(blank);expected=value(shown(question[anchor]))+index-anchor;drag(proposal(expected),blank);ensure(okButton.visible);keyClick(Qt.Key_Return);tryCompare(score,"currentSubLevel",1,2500);
        ActivityInfoTree.startingActivity="";pressIcon("bar_home.svg");tryCompare(pageView,"depth",1,2500);ensure(pageView.currentItem.isMenu);
        evidence={title:"Descobrir os números sequenciais.",levels:25,datasetObjective:objective,reduced:21,partialRestart:true,selectorsPersist:true,previousNext:true,helpPortuguese:true,focusAfterHelp:true,home:true};
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
