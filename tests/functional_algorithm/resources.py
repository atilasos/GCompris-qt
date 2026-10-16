#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
FRUITS=['apple','banana','cherries','lemon','orange','pear','pineapple','plum','question_mark']
EXTRA=[f'src/activities/enumerate/resource/{name}.svg' for name in FRUITS]+[f'src/core/resource/sounds/{name}.wav' for name in ['completetask','brick','bleep']]


def paths():
    return sorted(set(EXTRA)|{str(p.relative_to(ROOT)) for p in (ROOT/'src/activities/algorithm').rglob('*') if p.is_file() and p.suffix in {'.qml','.js','.svg'} and p.name!='Algorithm.qml'})


def case():
    return '''TestCase {
    name: "OriginalAlgorithmQrcResources"
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
'''.replace('FILES',json.dumps(paths()))


if __name__=='__main__':print(case(),end='')
