#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
import argparse
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
EXTRA=['src/activities/fifteen/resource/background.svg','src/core/resource/sounds/completetask.wav','src/core/resource/sounds/crash.wav','src/core/resource/scroll_down.svg','src/core/resource/bar_ok.svg']


def resources(activity):
    paths=set(EXTRA)
    for name in {'calendar',activity}:
        paths.update(str(p.relative_to(ROOT)) for p in (ROOT/'src/activities'/name).rglob('*') if p.is_file() and p.suffix in {'.qml','.js','.svg'} and p.name!='Calendar.qml')
    return sorted(paths)


def case(activity):
    return '''TestCase {
    name: "CalendarOriginalQrcResources"
    when: activity.visible
    property var copied: []
    function test_resources(){
        var reader=Qt.createQmlObject('import core 1.0; File {}',this);
        for(var file of FILES){
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
'''.replace('FILES',json.dumps(resources(activity)))


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('activity',choices=['calendar','find_the_day']);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    with a.output.open('x') as stream:stream.write(case(a.activity))
