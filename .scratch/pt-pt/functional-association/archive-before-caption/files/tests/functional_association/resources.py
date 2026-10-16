#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Generate original QRC copy and image-readiness checks for shared consumers."""
import json
from pathlib import Path
from inventory import ROOT,NAMES

EXTRA=['src/activities/guesscount/resource/backgroundW01.svg','src/activities/guesscount/resource/backgroundW02.svg']+[f'src/core/resource/sounds/{name}.wav' for name in ('scroll','completetask','crash')]


def paths(activity,root=ROOT):
    files=set(EXTRA)
    for name in {activity,'babymatch'}:
        files.update(str(p.relative_to(root)) for p in (root/'src/activities'/name).rglob('*') if p.is_file() and p.suffix in ('.qml','.js','.svg','.webp') and p.name!='Babymatch.qml')
    return sorted(files)


def case(activity):
    return '''// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:'OriginalAssociationResources'
    when:activity.visible
    property var copied: []
    function test_copy_and_decode_images(){
        var file=Qt.createQmlObject('import core 1.0; File {}',this);
        for(var path of FILES){
            var source='qrc:/gcompris/'+path,target='file://__QA_OUTPUT__/resources/'+path;
            verify(file.mkpath(target.slice(0,target.lastIndexOf('/'))));verify(file.copy(source,target));
            if(/\\.(svg|webp)$/.test(path)){var image=Qt.createQmlObject('import QtQuick; Image { asynchronous:false }',this);image.source=source;tryCompare(image,'status',Image.Ready);image.destroy();}
            copied.push(path);
        }
    }
    function cleanupTestCase(){console.log('NATIVE_ASSOCIATION_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,resources:copied}));}
}
'''.replace('FILES',json.dumps(paths(activity)))


if __name__=='__main__':
    import argparse
    parser=argparse.ArgumentParser();parser.add_argument('activity',choices=NAMES);args=parser.parse_args();print(case(args.activity),end='')
