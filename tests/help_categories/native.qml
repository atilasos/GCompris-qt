// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"NativeTranslatedHelpCategories"
    when:items.numberOfLevel>0 && activity.visible
    property var evidence: ({})
    function helpButton(item) {
        if(item.source!==undefined && String(item.source).endsWith('bar_help.svg'))return item;
        if(item.children)for(var i=0;i<item.children.length;i++){var found=helpButton(item.children[i]);if(found)return found;}
        return null;
    }
    function scroller(item) {
        if(item.contentY!==undefined && item.contentHeight!==undefined && item.flickableDirection!==undefined)return item;
        if(item.children)for(var i=0;i<item.children.length;i++){var found=scroller(item.children[i]);if(found)return found;}
        return null;
    }
    function test_categories_are_localized_and_filter_ids_unchanged() {
        wait(1600);
        var id=activity.activityInfo.shortName();var original=activity.activityInfo.section;
        var labels={"memory-wordnumber":"Matemática, Numeração",maze:"Diversão, Labirintos"};
        var button=helpButton(bar);verify(button!==null);var depth=pageView.depth;
        mouseClick(button,button.width/2,button.height/2);
        tryCompare(pageView,"depth",depth+1,2000);wait(600);
        var help=pageView.currentItem;
        var footer="<b>Secção: </b>"+labels[id]+" ("+id+")";
        if(help.content.indexOf(footer)<0)console.log("NATIVE_CATEGORY_FAILURE",help.content,footer);
        compare(activity.activityInfo.section,original,"Filter IDs are unchanged");
        var flick=scroller(help);
        if(flick!==null) {
            for(var tries=0;tries<4 && flick.contentY<flick.contentHeight-flick.height-2;tries++) {
                mouseDrag(flick,flick.width*0.5,flick.height*0.8,0,-flick.height*0.65,Qt.LeftButton,Qt.NoModifier,100);
                wait(400);
            }
        }
        grabImage(pageView).save("__QA_OUTPUT__/translated-footer.png");
        evidence={activity:id,filterIds:original,footer:footer,content:help.content};
        verify(help.content.indexOf(footer)>=0,"Translated category names are shown in the real help");
    }
    function cleanupTestCase(){console.log("NATIVE_CATEGORIES_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
