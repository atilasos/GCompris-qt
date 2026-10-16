#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Archive exact frozen sources physically; audit never needs Git or the old tree."""
import argparse,hashlib,json,zipfile
from pathlib import Path
from phase import verify_source
if not __debug__:raise SystemExit('Sliding validation requires assertions; Python -O rejected')
ROOT=Path(__file__).resolve().parents[2]

def archive(baseline,final,localized,output):
    sources={'baseline':verify_source(baseline),'final':verify_source(final),'localized':verify_source(localized)}
    assert set(sources['baseline']['files'])==set(sources['final']['files'])
    changed=[name for name in sources['baseline']['files'] if sources['baseline']['files'][name]!=sources['final']['files'][name]]
    assert changed==['poqm/pt/gcompris_qt.po']
    assert set(sources['localized']['files'])-set(sources['final']['files'])=={'src/activities/fifteen/resource/Coastal_Path-pt.svg'}
    assert [name for name in sources['final']['files'] if sources['final']['files'][name]!=sources['localized']['files'][name]]==['src/activities/fifteen/Fifteen.qml']
    with zipfile.ZipFile(output/'source-tree.zip','x',zipfile.ZIP_DEFLATED) as bundle:
        for phase,root in [('baseline',baseline),('final',final),('localized',localized)]:
            for name,digest in sorted(sources[phase]['files'].items()):
                content=(root/name).read_bytes();assert hashlib.sha256(content).hexdigest()==digest
                entry=zipfile.ZipInfo(phase+'/'+name,date_time=(2026,1,1,0,0,0));entry.compress_type=zipfile.ZIP_DEFLATED;bundle.writestr(entry,content)
    (output/'source-phases.json').write_text(json.dumps(sources,indent=2)+'\n')
    print(json.dumps({'source_sha256':hashlib.sha256((output/'source-tree.zip').read_bytes()).hexdigest(),'files':sum(len(value['files']) for value in sources.values())}))

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--baseline',type=Path,required=True);parser.add_argument('--final',type=Path,required=True);parser.add_argument('--output',type=Path,required=True);parser.add_argument('--localized',type=Path,required=True);args=parser.parse_args();archive(args.baseline,args.final,args.localized,args.output)
