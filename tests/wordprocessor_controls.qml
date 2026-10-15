// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "PortugueseWordprocessorControls"
    when: activity.visible && edit.visible
    property var unicodeInput
    property var observations: []
    property var player
    SignalSpy {id:done;target:activity.audioVoices;signalName:"done"}
    function ensure(value,message) {
        if(!value)console.log("WORD_CONTROL_ASSERT",message||"",new Error().stack);
        verify(value,message||"");
    }
    function checked(actual,expected,message) {
        if(actual!==expected)console.log("WORD_CONTROL_ASSERT",JSON.stringify({actual:actual,expected:expected,message:message}),new Error().stack);
        compare(actual,expected,message||"");
    }
    function find(root,predicate) {
        if(predicate(root))return root;
        if(root.children)for(var child of root.children){var found=find(child,predicate);if(found)return found;}
        return null;
    }
    function media(root) {
        if(root.position!==undefined && root.playbackState!==undefined && root.duration!==undefined)return root;
        if(root.data)for(var child of root.data){var found=media(child);if(found)return found;}
        return null;
    }
    function clickText(root,text) {
        var item=find(root,function(x){return x.clicked!==undefined && x.text===text && x.visible;});
        ensure(item!==null,"Button "+text);mouseClick(item);
    }
    function icon(root,suffix) {
        wait(1600);
        var item=find(root,function(x){return x.source!==undefined && String(x.source).endsWith(suffix);});
        ensure(item!==null,"Icon "+suffix);mouseClick(item);
    }
    function test_audio_settings_and_help_focus() {
        wait(1600);
        unicodeInput=Qt.createQmlObject('import "file:__QA_SOURCE__/build/functional-input"; UnicodeInput {}',this);
        ApplicationSettings.isAudioVoicesEnabled=true;
        player=media(activity.audioVoices);ensure(player!==null);
        checked(controls.children[0].text,"Título");
        checked(controls.children[1].text,"Subtítulo");
        checked(controls.children[2].text,"Parágrafo");
        for(var enabled of [false,true,false]) {
            var depth=pageView.depth;
            icon(bar,"bar_activity_config.svg");tryCompare(pageView,"depth",depth+1);wait(600);
            var checkbox=find(pageView.currentItem,function(x){return x.checked!==undefined && x.text==="Tocar o som dos caracteres quando carregados";});
            ensure(checkbox!==null);
            if(checkbox.checked!==enabled)mouseClick(checkbox);
            checked(checkbox.checked,enabled);
            clickText(pageView.currentItem,"Gravar");tryCompare(pageView,"depth",depth);wait(1800);
            checked(items.audioMode,enabled);
            checked(ApplicationSettings.loadActivityConfiguration("baby_wordprocessor").audioMode,enabled?"true":"false");
            mouseClick(edit,30,20);keyClick(Qt.Key_A,Qt.ControlModifier);keyClick(Qt.Key_Backspace);
            checked(edit.getText(0,edit.length),"");
            var before=String(activity.audioVoices.source);
            ensure(unicodeInput.commit(edit,"ç"));checked(edit.getText(0,edit.length),"ç");
            if(enabled) {
                tryVerify(function(){return String(activity.audioVoices.source).endsWith("/pt/alphabet/U00E7.ogg") && player.playbackState===1 && player.position>0 && player.duration>0 && player.hasAudio;},5000);
                observations.push({audioMode:true,source:String(activity.audioVoices.source),position:player.position,duration:player.duration,hasAudio:player.hasAudio});
                done.clear();tryVerify(function(){return done.count>0;},10000);
            } else {wait(400);checked(String(activity.audioVoices.source),before);observations.push({audioMode:false,unchangedSource:true});}
            icon(bar,"bar_help.svg");tryCompare(pageView,"depth",depth+1);wait(600);
            var help=pageView.currentItem;
            ensure(help.content.indexOf("Subtítulo")>=0,"Help agrees with the button spelling");
            grabImage(pageView).save("__QA_OUTPUT__/help.png");
            icon(help,"cancel.svg");tryCompare(pageView,"depth",depth);wait(600);
            keyClick(Qt.Key_End,Qt.ControlModifier);keyClick("!");checked(edit.getText(0,edit.length),"ç!");
        }
        ActivityInfoTree.startingActivity="";icon(bar,"bar_home.svg");
        tryCompare(pageView,"depth",1);ensure(pageView.currentItem.isMenu);
    }
    function cleanupTestCase(){console.log("NATIVE_WORDPROCESSOR_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,observations:observations}));}
}
