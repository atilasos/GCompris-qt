TestCase {
    name: "OriginalClockQrcResources"
    when: activity.visible
    property var copied: []
    function test_resources(){
        var reader=Qt.createQmlObject('import core 1.0; File {}',this);
        for(var file of ["src/activities/clockgame/ActivityConfig.qml", "src/activities/clockgame/ActivityInfo.qml", "src/activities/clockgame/clockgame.js", "src/activities/clockgame/clockgame.svg", "src/activities/clockgame/resource/1/Data.qml", "src/activities/clockgame/resource/2/Data.qml", "src/activities/clockgame/resource/3/Data.qml", "src/activities/clockgame/resource/4/Data.qml", "src/activities/clockgame/resource/5/Data.qml", "src/activities/clockgame/resource/6/Data.qml", "src/activities/clockgame/resource/clock_bg.svg", "src/activities/clockgame/resource/clock_setter.svg", "src/activities/clockgame/resource/clock_zones.svg", "src/core/resource/sounds/completetask.wav", "src/core/resource/sounds/crash.wav"]){
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
