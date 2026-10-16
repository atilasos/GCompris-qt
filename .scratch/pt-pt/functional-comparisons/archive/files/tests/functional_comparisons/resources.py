#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
import argparse
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
EXTRA=['src/activities/chess/resource/background-wood.svg','src/activities/path_encoding/resource/arrow.svg']+[f'src/core/resource/sounds/{name}.wav' for name in ['completetask','win','crash']]


def paths(activity):
    injected={'comparator':'Comparator.qml','adjacent_numbers':'Adjacent_numbers.qml'}[activity]
    return sorted(set(EXTRA)|{str(p.relative_to(ROOT)) for p in (ROOT/'src/activities'/activity).rglob('*') if p.is_file() and p.suffix in {'.qml','.js','.svg'} and p.name!=injected})


def case(activity):
    return '''TestCase {
    name: "OriginalComparisonQrcResources"
    when: activity.visible
    property var copied: []
    function test_resources(){
        var reader=Qt.createQmlObject('import core 1.0; File {}',this);
        for(var file of FILES){
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
'''.replace('FILES',json.dumps(paths(activity)))


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('activity',choices=['comparator','adjacent_numbers']);args=parser.parse_args();print(case(args.activity),end='')
