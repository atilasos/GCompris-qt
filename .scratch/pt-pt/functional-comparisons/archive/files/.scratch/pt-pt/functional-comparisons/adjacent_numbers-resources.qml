TestCase {
    name: "OriginalComparisonQrcResources"
    when: activity.visible
    property var copied: []
    function test_resources(){
        var reader=Qt.createQmlObject('import core 1.0; File {}',this);
        for(var file of ["src/activities/adjacent_numbers/ActivityConfig.qml", "src/activities/adjacent_numbers/ActivityInfo.qml", "src/activities/adjacent_numbers/DraggableTile.qml", "src/activities/adjacent_numbers/DroppableTile.qml", "src/activities/adjacent_numbers/adjacent_numbers.js", "src/activities/adjacent_numbers/adjacent_numbers.svg", "src/activities/adjacent_numbers/resource/1/Data.qml", "src/activities/adjacent_numbers/resource/2/Data.qml", "src/activities/adjacent_numbers/resource/3/Data.qml", "src/activities/adjacent_numbers/resource/4/Data.qml", "src/activities/adjacent_numbers/resource/5/Data.qml", "src/activities/chess/resource/background-wood.svg", "src/activities/path_encoding/resource/arrow.svg", "src/core/resource/sounds/completetask.wav", "src/core/resource/sounds/crash.wav", "src/core/resource/sounds/win.wav"]){
            var source="qrc:/gcompris/"+file,target="file://__QA_OUTPUT__/resources/"+file;
            verify(reader.mkpath(target.slice(0,target.lastIndexOf("/"))));verify(reader.copy(source,target),file);
            if(file.endsWith(".svg")){
                var image=Qt.createQmlObject('import QtQuick; Image { asynchronous:false }',this);image.source=source;
                tryCompare(image,"status",Image.Ready);image.destroy();
            }
            copied.push(file);
        }
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,resources:copied}));}
}
