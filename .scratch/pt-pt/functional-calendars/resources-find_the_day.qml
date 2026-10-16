TestCase {
    name: "CalendarOriginalQrcResources"
    when: activity.visible
    property var copied: []
    function test_resources(){
        var reader=Qt.createQmlObject('import core 1.0; File {}',this);
        for(var file of ["src/activities/calendar/ActivityInfo.qml", "src/activities/calendar/ChoiceTable.qml", "src/activities/calendar/MonthGridDelegate.qml", "src/activities/calendar/calendar.js", "src/activities/calendar/calendar.svg", "src/activities/calendar/calendar_dataset.js", "src/activities/fifteen/resource/background.svg", "src/activities/find_the_day/ActivityInfo.qml", "src/activities/find_the_day/FindTheDay.qml", "src/activities/find_the_day/find_the_day.svg", "src/activities/find_the_day/find_the_day_dataset.js", "src/core/resource/bar_ok.svg", "src/core/resource/scroll_down.svg", "src/core/resource/sounds/completetask.wav", "src/core/resource/sounds/crash.wav"]){
            var source="qrc:/gcompris/"+file,target="file://__QA_OUTPUT__/resources/"+file;
            verify(reader.mkpath(target.slice(0,target.lastIndexOf("/"))));
            verify(reader.copy(source,target),file);
            if(file.endsWith(".svg")){
                var image=Qt.createQmlObject('import QtQuick; Image { asynchronous:false }',this);
                image.source=source;tryCompare(image,"status",Image.Ready);image.destroy();
            }
            copied.push(file);
        }
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,resources:copied}));}
}
