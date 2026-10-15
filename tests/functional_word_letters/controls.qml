// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"WordLetterControlsPT"
    when:activity.visible
    property var evidence:({})
    function checked(actual,expected,message) {
        if(actual!==expected)console.log("WORD_CONTROL_FAILURE",JSON.stringify({actual:actual,expected:expected,message:message}));
        compare(actual,expected,message||"");
    }
    function find(item,property,value) {
        if(item[property]!==undefined && item[property]===value && item.visible)return item;
        if(item.children)for(var i=0;i<item.children.length;i++) {
            var result=find(item.children[i],property,value);if(result)return result;
        }
        return null;
    }
    function button(item,suffix) {
        if(item.source!==undefined && String(item.source).endsWith(suffix) && item.visible)return item;
        if(item.children)for(var i=0;i<item.children.length;i++) {
            var result=button(item.children[i],suffix);if(result)return result;
        }
        return null;
    }
    function clickIcon(parent,suffix) {
        wait(200);
        var icon=button(parent,suffix);verify(icon!==null,suffix);
        mouseClick(icon,icon.width/2,icon.height/2,Qt.LeftButton,Qt.NoModifier,50);
    }
    function clickText(parent,text) {
        var item=find(parent,"text",text);verify(item!==null,text);
        mouseClick(item,item.width/2,item.height/2,Qt.LeftButton,Qt.NoModifier,50);
    }
    function test_controls_configuration_restart_and_menu() {
        wait(1900);
        var hangman=activity.activityInfo.shortName()==="hangman";
        checked(items.currentLevel,0);
        verify(items.numberOfLevel>1);
        var title=activity.activityInfo.title;
        verify(title.length>0);
        verify(title.indexOf("Hangman")<0);
        verify(title.indexOf("Letter in")<0);
        clickIcon(bar,"bar_next.svg");tryCompare(items,"currentLevel",1,2000);
        clickIcon(bar,"bar_previous.svg");tryCompare(items,"currentLevel",0,2000);
        wait(300);
        if(hangman) {
            textinput.forceActiveFocus();keyClick("#",Qt.NoModifier,0);
            checked(items.remainingLife,5);
        } else {
            var card=wordsView.itemAtIndex(0);verify(card!==null);
            mouseClick(card,card.width/2,card.height/2,Qt.LeftButton,Qt.NoModifier,50);
            checked(wordsModel.get(0).selected,true);
        }
        var depth=pageView.depth;
        clickIcon(bar,"bar_activity_config.svg");
        tryCompare(pageView,"depth",depth+1,2000);wait(500);
        var config=pageView.currentItem;
        if(hangman) {
            clickText(config,"Mostrar a imagem a descobrir como dica");
            clickText(config,"Dizer as palavras a descobrir (se disponível) quando faltarem três tentativas");
        } else {
            clickText(config,"Apenas 5 palavras");
            clickText(config,"Mista");wait(250);
            clickText(config,"Minúsculas");wait(250);
        }
        grabImage(pageView).save("__QA_OUTPUT__/configuration.png");
        clickText(config,"Gravar");
        tryCompare(pageView,"depth",depth,2000);wait(500);
        checked(items.currentLevel,0);
        if(hangman) {
            checked(items.remainingLife,6);
            checked(items.easyModeImage,false);checked(items.easyModeAudio,false);
            verify(items.guessedText.text.indexOf('#')===-1);
            checked(goodIcon.visible,false);
        } else {
            checked(items.currentMode,5);checked(items.currentLetterCase,Font.AllLowercase);
            checked(wordsModel.count,5);
            checked(score.currentSubLevel,0);
            for(var i=0;i<wordsModel.count;i++)checked(wordsModel.get(i).selected,false);
        }
        clickIcon(bar,"bar_help.svg");tryCompare(pageView,"depth",depth+1,2000);wait(500);
        var help=pageView.currentItem;
        checked(help.title,title);
        verify(help.content.indexOf(activity.activityInfo.description)>=0);
        grabImage(pageView).save("__QA_OUTPUT__/help.png");
        clickIcon(help,"cancel.svg");tryCompare(pageView,"depth",depth,2000);wait(500);
        ActivityInfoTree.startingActivity="";
        clickIcon(bar,"bar_home.svg");tryCompare(pageView,"depth",1,2000);wait(500);
        verify(pageView.currentItem.isMenu);
        grabImage(pageView).save("__QA_OUTPUT__/menu.png");
        evidence={activity:activity.activityInfo.shortName(),title:title,configurationChangedByClicks:true,restarted:true,help:true,navigation:true,menu:true};
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,controls:evidence}));}
}
