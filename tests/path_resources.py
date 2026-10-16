#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Generate separate QRC inventory cases; never use matrices to play a game."""
import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ACTIVITIES = ['path_encoding', 'path_encoding_relative', 'path_decoding', 'path_decoding_relative']
EXTRA = ['src/activities/maze/resource/tux_top_south.svg',
         'src/core/resource/sounds/completetask.wav', 'src/core/resource/sounds/crash.wav',
         'src/activities/ballcatch/resource/tuxok.wav']


def paths(activity):
    result = set(EXTRA)
    for name in {'path_encoding', activity}:
        result.update(str(p.relative_to(ROOT)) for p in (ROOT / 'src/activities' / name).rglob('*')
                      if p.is_file() and p.suffix in {'.qml', '.js', '.svg'} and p.name != 'GridPath.qml')
    return sorted(result)


def case(activity):
    return '''TestCase {
    name: "PathResourceInventory"
    when: activity.visible
    property var records: []
    property var datasets: []
    function test_inventory() {
        var reader=Qt.createQmlObject('import core 1.0; File {}',this);
        var files=FILES;
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
            var file="src/activities/ACTIVITY/resource/"+n+"/Data.qml";
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
'''.replace('FILES', json.dumps(paths(activity))).replace('ACTIVITY', activity)


if __name__ == '__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('activity',choices=ACTIVITIES)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    with args.output.open('x') as stream: stream.write(case(args.activity))
