TestCase {
    name: "OriginalAlgorithmQrcResources"
    when: activity.visible
    property var copied: []
    function test_resources(){
        var reader=Qt.createQmlObject('import core 1.0; File {}',this);
        for(var file of ["src/activities/algorithm/ActivityInfo.qml", "src/activities/algorithm/algorithm.js", "src/activities/algorithm/algorithm.svg", "src/activities/algorithm/resource/desert_scene.svg", "src/activities/enumerate/resource/apple.svg", "src/activities/enumerate/resource/banana.svg", "src/activities/enumerate/resource/cherries.svg", "src/activities/enumerate/resource/lemon.svg", "src/activities/enumerate/resource/orange.svg", "src/activities/enumerate/resource/pear.svg", "src/activities/enumerate/resource/pineapple.svg", "src/activities/enumerate/resource/plum.svg", "src/activities/enumerate/resource/question_mark.svg", "src/core/resource/sounds/bleep.wav", "src/core/resource/sounds/brick.wav", "src/core/resource/sounds/completetask.wav"]){
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
