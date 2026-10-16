// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "PublicActivityLevelContract"
    when: activity.visible
    property int expectedTotal: 10
    property var evidence: ({})
    function button(node, suffix) {
        if (typeof node.source !== "undefined" && String(node.source).indexOf(suffix) >= 0 && node.visible && node.width > 0) return node;
        if (typeof node.children === "undefined") return null;
        for (var i=0;i<node.children.length;i++) { var found=button(node.children[i],suffix);if(found)return found; }
        return null;
    }
    function test_public_total_and_navigation() {
        wait(1800);
        evidence={initial:activity.currentLevel,total:activity.numberOfLevel,barLevel:bar.level,selector:!!(bar.content.value & bar.content.level),steps:[]};
        grabImage(pageView).save('__QA_OUTPUT__/initial.png');
        verify(evidence.selector,'Activity offers a level selector');
        var next=button(bar,'bar_next.svg');var previous=button(bar,'bar_previous.svg');
        verify(next!==null && previous!==null,'Painted level navigation buttons');
        mouseClick(next,next.width/2,next.height/2);wait(400);
        evidence.steps.push({action:'next',current:activity.currentLevel,bar:bar.level,total:activity.numberOfLevel});
        mouseClick(previous,previous.width/2,previous.height/2);wait(400);
        evidence.steps.push({action:'previous',current:activity.currentLevel,bar:bar.level,total:activity.numberOfLevel});
        grabImage(pageView).save('__QA_OUTPUT__/returned.png');
        compare(evidence.initial,0);compare(evidence.steps[0].current,1);compare(evidence.steps[0].bar,2);
        compare(evidence.steps[1].current,0);compare(evidence.steps[1].bar,1);
        compare(evidence.total,expectedTotal,'Public total matches selectable activity levels');
    }
    function cleanupTestCase(){console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
