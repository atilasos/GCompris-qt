// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"MemoryNumberNameHelpMatchesCards"
    when:items.numberOfLevel>0 && activity.visible
    function button(item) {
        if(item.source!==undefined && String(item.source).endsWith('bar_help.svg'))return item;
        if(item.children)for(var i=0;i<item.children.length;i++){var found=button(item.children[i]);if(found)return found;}
        return null;
    }
    function test_help_describes_digits_and_number_names() {
        wait(1600);
        compare(activity.activityInfo.description,"Vira as cartas para associar o numeral ao respetivo número por extenso.");
        verify(activity.activityInfo.manual.indexOf("algarismos")>=0);
        verify(activity.activityInfo.manual.indexOf("imagens")<0);
        var help=button(bar);verify(help!==null);var depth=pageView.depth;
        mouseClick(help,help.width/2,help.height/2);tryCompare(pageView,"depth",depth+1,2000);wait(600);
        verify(pageView.currentItem.content.indexOf("algarismos")>=0);
        grabImage(pageView).save("__QA_OUTPUT__/number-name-help.png");
    }
    function cleanupTestCase(){console.log("NATIVE_MEMORY_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,description:activity.activityInfo.description,manual:activity.activityInfo.manual}));}
}
