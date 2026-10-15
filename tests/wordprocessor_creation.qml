// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "PortugueseTextCreationRoundTrip"
    when: activity.visible && edit.visible
    property var unicodeInput
    property var result: ({})
    SignalSpy {id:saved; target:creationHandler; signalName:"saved"}
    function ensure(value,message) {
        if(!value)console.log("CREATION_ASSERT",message||"",new Error().stack);
        verify(value,message||"");
    }
    function checked(actual,expected,message) {
        if(actual!==expected)console.log("CREATION_ASSERT",JSON.stringify({actual:actual,expected:expected,message:message}),new Error().stack);
        compare(actual,expected,message||"");
    }
    function find(root,predicate) {
        if(predicate(root))return root;
        if(root.children)for(var child of root.children){var found=find(child,predicate);if(found)return found;}
        return null;
    }
    function button(root,text) {
        var item=find(root,function(x){return x.clicked!==undefined && x.text===text && x.visible;});
        ensure(item!==null,"Visible button: "+text);mouseClick(item);
    }
    function barButton(suffix) {
        var item=find(bar,function(x){return x.source!==undefined && String(x.source).endsWith(suffix);});
        ensure(item!==null);mouseClick(item);wait(400);
    }
    function test_save_reload_and_load_portuguese_creation() {
        wait(1600);
        unicodeInput=Qt.createQmlObject('import "file:__QA_SOURCE__/build/functional-input"; UnicodeInput {}',this);
        mouseClick(edit,30,20);
        var sentence="A Inês e o João comem maçãs. À tarde, vão à escola.";
        ensure(unicodeInput.commit(edit,sentence));
        checked(edit.getText(0,edit.length),sentence);
        mouseClick(controls.children[0]);wait(300);
        var formatted=edit.getFormattedText(0,edit.length);
        mouseClick(saveButton);tryCompare(creationHandler,"visible",true);
        var input=find(creationHandler,function(x){return x.placeholderText!==undefined && x.visible;});
        ensure(input!==null);mouseClick(input);
        ensure(unicodeInput.commit(input,"Texto do João"));
        button(creationHandler,"Gravar");
        tryCompare(saved,"count",1,5000);
        tryVerify(function(){return find(creationHandler,function(x){return x.message!==undefined && x.message.indexOf("Gravado")>=0;})!==null;},4000);
        grabImage(activityBackground).save("__QA_OUTPUT__/saved-portuguese.png");
        result.path=creationHandler.fileFullPath;
        wait(1600);button(creationHandler,"OK");tryCompare(creationHandler,"visible",false);
        wait(600);
        barButton("bar_reload.svg");checked(edit.getText(0,edit.length),"");
        mouseClick(loadButton);tryCompare(creationHandler,"visible",true);wait(600);
        var grid=find(creationHandler,function(x){return x.cellWidth!==undefined && x.itemAtIndex!==undefined;});
        ensure(grid!==null);checked(grid.count,1);
        var file=grid.itemAtIndex(0);ensure(file!==null);mouseClick(file);
        button(creationHandler,"Carregar");tryCompare(creationHandler,"visible",false);
        checked(edit.getText(0,edit.length),sentence);
        checked(edit.getFormattedText(0,edit.length),formatted,"Formatting survives save/load");
        result.text=edit.getText(0,edit.length);result.roundTrip=true;
        // The application restores focus after the creation dialog closes.
        keyClick(Qt.Key_End,Qt.ControlModifier);keyClick("!");
        checked(edit.getText(0,edit.length),sentence+"!");
        grabImage(activityBackground).save("__QA_OUTPUT__/loaded-portuguese.png");
    }
    function cleanupTestCase(){console.log("NATIVE_WORDPROCESSOR_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,observation:result}));}
}
