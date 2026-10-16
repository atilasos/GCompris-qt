// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:'OrderingVisibleInventory'
    when:true
    property var rows: []
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var c of root.children){var found=find(c,predicate);if(found)return found;}return null;}
    function click(item){verify(item!==null);var p=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);}
    function labels(root){var result=[];function collect(item){if(item.placeholderName==='origin'&&typeof item.elementValue==='string'){var text=find(item,function(child){return child.text!==undefined&&child.visible&&String(child.text)!=='';});verify(text!==null);result.push(String(text.text));return;}if(item.children)for(var child of item.children)collect(child);}collect(root);return result;}
    function test_visible_bags_all_levels(){
        wait(1600);if(!activity.visible){keyClick(Qt.Key_Return);tryCompare(activity,'visible',true,2500);wait(1100);}
        console.log('ORDERING_PUBLIC',activity.activityInfo.shortName(),activity.numberOfLevel,activity.levelFolder);
        var total=items.numberOfLevel;
        for(var level=0;level<total;level++){
            compare(items.currentLevel,level);wait(100);
            rows.push({level:level+1,instruction:items.instruction.text,bag:labels(originPlaceholder).sort()});
            var next=find(bar,function(item){return item.source!==undefined&&String(item.source).endsWith('bar_next.svg');});click(next);tryCompare(items,'currentLevel',(level+1)%total,2000);
        }
    }
    function cleanupTestCase(){console.log('NATIVE_ORDERING_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,rows:rows}));}
}
