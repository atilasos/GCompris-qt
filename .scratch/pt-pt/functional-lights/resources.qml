TestCase {
    name: "OriginalClockQrcResources"
    when: activity.visible
    property var copied: []
    function test_resources(){
        var reader=Qt.createQmlObject('import core 1.0; File {}',this);
        for(var file of ["src/activities/ballcatch/resource/tux.svg", "src/activities/family/resource/background.svg", "src/activities/lightsoff/ActivityInfo.qml", "src/activities/lightsoff/lightsoff.js", "src/activities/lightsoff/lightsoff.svg", "src/activities/lightsoff/resource/1/Data.qml", "src/activities/lightsoff/resource/2/Data.qml", "src/activities/lightsoff/resource/3/Data.qml", "src/activities/lightsoff/resource/4/Data.qml", "src/activities/lightsoff/resource/5/Data.qml", "src/activities/lightsoff/resource/6/Data.qml", "src/activities/lightsoff/resource/7/Data.qml", "src/activities/lightsoff/resource/8/Data.qml", "src/activities/lightsoff/resource/9/Data.qml", "src/activities/lightsoff/resource/back.svg", "src/activities/lightsoff/resource/grass.svg", "src/activities/lightsoff/resource/off.svg", "src/activities/lightsoff/resource/on.svg", "src/activities/menu/resource/all.svg", "src/core/resource/sounds/completetask.wav", "src/core/resource/sounds/crash.wav", "src/core/resource/sounds/scroll.wav"]){
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
