#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Archive exact phases physically; consumers can audit without Git or old paths."""
import argparse,hashlib,json,subprocess,zipfile
from pathlib import Path
from phase import verify_source
if not __debug__:raise SystemExit('Alignment validation requires assertions; Python -O rejected')
ROOT=Path(__file__).resolve().parents[2]
SHARED_REVISION='395456d94dbfef3a0716f8c43f6885961c2f1f24'

def archive(roots,output):
 sources={name:verify_source(root) for name,root in roots.items()};paths=set(sources['baseline']['files']);assert all(set(value['files'])==paths for value in sources.values())
 assert {name for name in paths if sources['baseline']['files'][name]!=sources['help']['files'][name]}=={'poqm/pt/gcompris_qt.po'}
 assert {name for name in paths if sources['help']['files'][name]!=sources['rules']['files'][name]}=={'src/activities/tic_tac_toe/TicTacToe.qml','src/activities/align4_2players/align4.js'}
 assert {name for name in paths if sources['rules']['files'][name]!=sources['final']['files'][name]}=={'src/activities/align4_2players/Align42players.qml','src/activities/align4_2players/align4.js'}
 shared={}
 for activity,qml in [('bargame','Bargame.qml'),('checkers','Checkers.qml'),('nine_men_morris','NineMenMorris.qml')]:
  for filename in [qml,'ActivityInfo.qml']:
   name='src/activities/'+activity+'/'+filename;shared[name]=subprocess.check_output(['git','-C',str(ROOT),'show',SHARED_REVISION+':'+name])
 sources['shared-consumers']={'revision':SHARED_REVISION,'files':{name:hashlib.sha256(raw).hexdigest() for name,raw in shared.items()}}
 with zipfile.ZipFile(output/'source-tree.zip','x',zipfile.ZIP_DEFLATED) as bundle:
  for phase,value in sources.items():
   for name,digest in sorted(value['files'].items()):
    raw=shared[name] if phase=='shared-consumers' else (roots[phase]/name).read_bytes();assert hashlib.sha256(raw).hexdigest()==digest
    entry=zipfile.ZipInfo(phase+'/'+name,date_time=(2026,1,1,0,0,0));entry.compress_type=zipfile.ZIP_DEFLATED;bundle.writestr(entry,raw)
 (output/'source-phases.json').write_text(json.dumps(sources,indent=2)+'\n');print(json.dumps({'source_sha256':hashlib.sha256((output/'source-tree.zip').read_bytes()).hexdigest(),'files':sum(len(value['files']) for value in sources.values())}))
if __name__=='__main__':
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--baseline',type=Path,required=True);parser.add_argument('--help-source',type=Path,required=True);parser.add_argument('--rules',type=Path,required=True);parser.add_argument('--final',type=Path,required=True);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args();archive({'baseline':args.baseline,'help':args.help_source,'rules':args.rules,'final':args.final},args.output)
