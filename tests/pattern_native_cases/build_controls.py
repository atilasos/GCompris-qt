#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Build separate controls cases without changing primary case bytes."""
import argparse
from pathlib import Path
ROOT=Path(__file__).resolve().parent

def generated(adapter):
    shared=(ROOT/'common.js').read_text().split('function test_all_current_patterns() {',1)[0]
    head='''// SPDX-License-Identifier: GPL-3.0-or-later
// Prepared controls case, not a native success receipt.
TestCase {
    id: qa
    name: 'VisiblePatternPublicControls'
    when: activity.visible && activity.numberOfLevel>0
    property var boards: []
    property var evidence: ({})
    property var registry: ({})
    property int wins: 0
    property int actions: 0
    property string activityName: ''
    Connections {target: bonus; function onWin() {qa.wins++;}}
'''
    return head+'\n'.join([(ROOT/'planner.js').read_text(),(ROOT/(adapter+'.js')).read_text(),shared,(ROOT/'controls.js').read_text()])+'\n}\n'

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check',action='store_true')
    args=parser.parse_args()
    for adapter in ['redraw','mosaic']:
        path=ROOT/('controls-'+adapter+'.qml')
        expected=generated(adapter)
        if args.check:
            if not path.is_file() or path.read_text()!=expected:
                raise SystemExit('Generated controls case differs: '+str(path))
        else:path.write_text(expected)
