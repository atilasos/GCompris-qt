// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name: 'FreeDrawingHasNoActivityLevels'

 when: activity.visible
 property var evidence: ({})

    function button(node, suffix) {
        if (typeof node.source !== "undefined" && String(node.source).indexOf(suffix) >= 0 && node.visible && node.width > 0) return node;
        if (typeof node.children === "undefined") return null;
        for (var i=0;i<node.children.length;i++) { var found=button(node.children[i],suffix);if(found)return found; }
        return null;
    }
    function textButton(node, text) {
        if(typeof node.text !== "undefined" && String(node.text)===text && typeof node.clicked === "function" && node.visible && node.width>0)return node;
        if(typeof node.children === "undefined")return null;
        for(var i=0;i<node.children.length;i++){var found=textButton(node.children[i],text);if(found)return found;}
        return null;
    }
    function dismissIntroduction() {
        if(typeof tutorialInstruction !== "undefined" && tutorialInstruction.visible){tutorialInstruction.forceActiveFocus();keyClick(Qt.Key_Return);wait(250);}
    }
 function test_mode_has_no_selector(){
 wait(1800);dismissIntroduction();
 ApplicationSettings.saveActivityConfiguration('polygons',{mode:'free'});
 var gear=button(bar,'bar_activity_config.svg');verify(gear!==null);mouseClick(gear,gear.width/2,gear.height/2);wait(500);
 verify(dialogActivityConfig.visible);var save=textButton(dialogActivityConfig,'Gravar');verify(save!==null);mouseClick(save,save.width/2,save.height/2);wait(700);
evidence={total:activity.numberOfLevel,current:activity.currentLevel,selector:!!(bar.content.value & bar.content.level)};grabImage(pageView).save('__QA_OUTPUT__/no-selector.png');compare(evidence.selector,false);compare(evidence.total,0);}
 function cleanupTestCase(){console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
