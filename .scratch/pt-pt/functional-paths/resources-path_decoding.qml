TestCase {
    name: "PathResourceInventory"
    when: activity.visible
    property var records: []
    property var datasets: []
    function test_inventory() {
        var reader=Qt.createQmlObject('import core 1.0; File {}',this);
        var files=["src/activities/ballcatch/resource/tuxok.wav", "src/activities/maze/resource/tux_top_south.svg", "src/activities/path_decoding/ActivityInfo.qml", "src/activities/path_decoding/PathDecoding.qml", "src/activities/path_decoding/path_decoding.svg", "src/activities/path_decoding/resource/1/Data.qml", "src/activities/path_decoding/resource/2/Data.qml", "src/activities/path_decoding/resource/3/Data.qml", "src/activities/path_decoding/resource/4/Data.qml", "src/activities/path_encoding/ActivityInfo.qml", "src/activities/path_encoding/Block.qml", "src/activities/path_encoding/MapView.qml", "src/activities/path_encoding/MoveBar.qml", "src/activities/path_encoding/MoveButtons.qml", "src/activities/path_encoding/PathEncoding.qml", "src/activities/path_encoding/Tux.qml", "src/activities/path_encoding/path.js", "src/activities/path_encoding/path_encoding.svg", "src/activities/path_encoding/resource/1/Data.qml", "src/activities/path_encoding/resource/2/Data.qml", "src/activities/path_encoding/resource/3/Data.qml", "src/activities/path_encoding/resource/4/Data.qml", "src/activities/path_encoding/resource/arrow.svg", "src/activities/path_encoding/resource/bush.svg", "src/activities/path_encoding/resource/flag.svg", "src/activities/path_encoding/resource/grass.svg", "src/activities/path_encoding/resource/rock.svg", "src/activities/path_encoding/resource/tree.svg", "src/activities/path_encoding/resource/water.svg", "src/core/resource/sounds/completetask.wav", "src/core/resource/sounds/crash.wav"];
        for(var file of files) {
            var source="qrc:/gcompris/"+file;
            var target="file://__QA_OUTPUT__/resources/"+file;
            verify(reader.mkpath(target.slice(0,target.lastIndexOf("/"))),file+" directory");
            verify(reader.copy(source,target),file+" QRC bytes");
            if(file.endsWith(".svg")) {
                var image=Qt.createQmlObject('import QtQuick; Image { asynchronous: false }',this);
                image.source=source;tryCompare(image,"status",Image.Ready);image.destroy();
            }
            records.push(file);
        }
        for(var n=1;n<=4;n++) {
            var file="src/activities/path_decoding/resource/"+n+"/Data.qml";
            var component=Qt.createComponent("qrc:/gcompris/"+file);
            compare(component.status,Component.Ready,component.errorString());
            var object=component.createObject(this);verify(object!==null);
            var matrices=[];
            for(var entry of object.data)matrices.push(entry.path);
            datasets.push({source:file,matrices:matrices});object.destroy();
        }
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,resources:records,datasets:datasets}));}
}
