#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Verify physical frozen inputs, observed exits and visible geometric games."""
import argparse,hashlib,io,json,sys,zipfile
from pathlib import Path,PurePosixPath
from oracle import outcome,play
if not __debug__:raise SystemExit('Alignment evidence requires assertions; Python -O rejected')
ROOT=Path(__file__).resolve().parent
DEFAULT=ROOT.parent.parent/'.scratch/pt-pt/functional-alignment'
CAPTURE_SHA='fe9a298386bf1e943d081cfb0f8f0ceee2d20912945ee4c7aa8e2de5f1fe65f9'
SOURCE_SHA='a6848753cde4b3c546aaf13a5a16ef189ad71e8c8daa7b1d6bd4ef6b78eadddd'
REVISIONS={'baseline':'395456d94dbfef3a0716f8c43f6885961c2f1f24','help':'db9a2095e8cf5242dc89361423d503626ef04dbf','rules':'76844cb3a8213bcf349585c2a35fea8e79caa817','final':'e2b86fe45c81eb2e9b25b051ee73657d4cdd0023','shared-consumers':'395456d94dbfef3a0716f8c43f6885961c2f1f24'}
BASELINE=['align-ai-old-draw-diagnostic','align-ai-preview-diagnostic','align-ai-wait-diagnostic','align-friend-draw-diagnostic','align-friend-help-red','align-friend-help-red-parse-diagnostic','align-help-first-red','align-help-red','align-help-red-parse-diagnostic','align-tracer','align-tracer-parse-diagnostic','tic-ai-complete','tic-friend-complete','tic-tracer','tic-tracer-parse-diagnostic']
HELP=['align-help-green','align-friend-help-green','tic-contract-red','draw-first-red','draw-second-red','draw-first-turn-diagnostic','draw-second-turn-diagnostic']
RULES=['align-ai-complete','align-ai-controls','align-friend-complete','align-friend-key-diagnostic','align-friend-key-diagnostic2','draw-first-green','draw-second-green','keyboard-ai-initial-control','keyboard-ai-red','keyboard-help-observation','keyboard-red','tic-ai-controls','tic-friend-controls','tic-contract-green']
FINAL=['keyboard-green','keyboard-ai-green','align-friend-controls']
NEGATIVE={*[name for name in BASELINE+HELP+RULES+FINAL if 'diagnostic' in name or name.endswith('-red')],'align-help-first-red'}
CASES={name:{'phase':phase,'expected_outer':int(name in NEGATIVE),'expected_native':137 if 'parse-diagnostic' in name else 0} for phase,names in [('baseline',BASELINE),('help',HELP),('rules',RULES),('final',FINAL)] for name in names}

def sha(raw):return hashlib.sha256(raw).hexdigest()
def read(path):return json.loads(path.read_text())
def safe(name):
 path=PurePosixPath(name);assert not path.is_absolute() and '..' not in path.parts and str(path)==name,'Unsafe artifact path'
def audit(base):
 base=Path(base);raw=(base/'capture.json').read_bytes();assert sha(raw)==CAPTURE_SHA,'Immutable capture changed';capture=json.loads(raw);assert capture['format']==1 and capture['cases']==CASES
 for name,digest in capture['files'].items():
  safe(name);path=base/name;assert not any(parent.is_symlink() for parent in [path,*path.parents]),'Symlink evidence';assert sha(path.read_bytes())==digest,'Changed artifact '+name
 archive=(base/'source-tree.zip').read_bytes();assert sha(archive)==SOURCE_SHA,'Immutable source archive changed';phases=read(base/'source-phases.json');assert {k:v['revision'] for k,v in phases.items()}==REVISIONS
 with zipfile.ZipFile(io.BytesIO(archive)) as bundle:
  names=bundle.namelist();assert len(names)==len(set(names))==982;assert set(names)=={phase+'/'+name for phase,value in phases.items() for name in value['files']};content={name:bundle.read(name) for name in names}
 for phase,value in phases.items():
  assert len(value['files'])==(6 if phase=='shared-consumers' else 244)
  for name,digest in value['files'].items():safe(name);assert sha(content[phase+'/'+name])==digest
 def original(name,phase):return content[phase+'/'+name]
 def changes(a,b):return {name for name in phases[a]['files'] if original(name,a)!=original(name,b)}
 assert changes('baseline','help')=={'poqm/pt/gcompris_qt.po'}
 assert changes('help','rules')=={'src/activities/tic_tac_toe/TicTacToe.qml','src/activities/align4_2players/align4.js'}
 assert changes('rules','final')=={'src/activities/align4_2players/Align42players.qml','src/activities/align4_2players/align4.js'}
 assert b'items.grid.forceLayout();' in original('src/activities/align4_2players/align4.js','final')
 identities={}
 for phase in ['baseline','rules','final']:
  directory=base/('identities-'+phase);snapshot_raw=(directory/'snapshot-manifest.json').read_bytes();snapshot=json.loads(snapshot_raw);assert len(snapshot['files'])==269
  resources=read(directory/'resources.json');assert resources['revision']==REVISIONS[phase] and read(directory/'source-manifest.json')==phases[phase]
  assert resources['inspector_source_sha256']==sha(original('tools/pt-pt-audio/rcc_inventory.cpp',phase))
  assert set(resources['canonical'])=={'tic_tac_toe','tic_tac_toe_2players','align4','align4_2players','core'}
  for activity,report in resources['canonical'].items():
   prefix='src/core/' if activity=='core' else 'src/activities/'+activity+'/'
   paths={name for name in phases[phase]['files'] if name.startswith(prefix)};assert len(report['files'])==len(paths) and {row['path'] for row in report['files']}=={':/gcompris/'+name for name in paths}
   for row in report['files']:
    raw=original(row['path'].removeprefix(':/gcompris/'),phase);assert row['sha256']==sha(raw) and row['bytes']==len(raw)
   assert report['rcc_sha256']==snapshot['files']['share/gcompris-qt/rcc/'+activity+'.rcc']
  assert len(resources['audio'])==4
  for row in resources['audio']:assert row['decode_exit_code']==0 and row['sha256']==sha(original(row['path'],phase))
  origin=read(directory/'origin-snapshot-manifest.json');assert len(origin['files'])==269 and origin['files']['bin/gcompris-qt']==snapshot['files']['bin/gcompris-qt']
  identities[sha(snapshot_raw)]=snapshot
 data=read(base/'data.json');assert data['datasets']==[] and data['ai_levels']=={'tic_tac_toe':5,'align4':6} and data['primary_games']==42
 counts={'games':0,'placements':0,'controls':0,'draws':0,'player1_wins':0,'player2_wins':0};inputs=set();receipts={}
 def board(values,gravity):assert len(values)==(42 if gravity else 9) and all(type(v)==int and v in [0,1,2] for v in values)
 def observed(record,gravity):
  values=record['values'];board(values,gravity);cols=7 if gravity else 3;tiles=record['tiles'];assert len(tiles)==len(values) and {tile['cell'] for tile in tiles}==set(range(len(values)))
  for tile in tiles:
   cell=tile['cell'];player=values[cell];assert tile['player']==player and tile['width']>0 and tile['height']>0
   assert abs(tile['x']-(cell%cols)*(tile['width']+tile['spacing']))<1 and abs(tile['y']-(cell//cols)*(tile['height']+tile['spacing']))<1
   suffix=('/stone_'+str(player)+'.svg') if gravity else '/cross.svg' if player==1 else '/circle.svg'
   assert tile['source']=='' if player==0 else tile['source'].endswith(suffix) or (gravity and tile['source'].endswith('/win'+str(player)+'.svg'))
 def terminal(values,gravity):return outcome(values,7 if gravity else 3,6 if gravity else 3,4 if gravity else 3)
 def transition(row,gravity):
  board(row['before'],gravity);board(row['after'],gravity);assert terminal(row['before'],gravity) is None
  assert row['after']==play(row['before'],row['location'],row['player'],7 if gravity else 3,6 if gravity else 3,gravity)
 for name,contract in CASES.items():
  directory=base/name;raw=(directory/'result.json').read_bytes();r=json.loads(raw);phase=contract['phase'];status=read(directory/'launcher-status.json');outer=read(directory/'supervisor-exit.json');tool=read(directory/'tool-exit.json')
  assert status['kind']=='observed-subprocess-exit' and outer['kind']=='observed-supervisor-subprocess-exit' and tool['kind']=='observed-exec-tool-return'
  assert status['exit_code']==outer['exit_code']==tool['exit_code']==contract['expected_outer']
  assert type(tool['session_id'])==int and tool['session_id']>0 and 5<=len(tool['chunk_id'])<=6
  assert status['native_receipt_sha256']==outer['native_receipt_sha256']==tool['native_receipt_sha256']==sha(raw)
  assert r['case_sha256']==status['case_sha256']==outer['case_sha256']==tool['case_sha256']==sha((directory/'case.qml').read_bytes())
  assert outer['launcher_status_sha256']==tool['launcher_status_sha256']==sha((directory/'launcher-status.json').read_bytes())
  assert outer['supervisor_sha256']==sha(original('tools/run-native-qml-supervised.py',phase)) and status['launcher_sha256']==r['runner_sha256']==sha(original('tools/run-native-qml-case.py',phase))
  assert r['source_sha256']==sha(original('src/activities/'+r['qml_file'],phase)) and r['portuguese_catalogue_sha256']==sha(original('poqm/pt/gcompris_qt.po',phase))
  assert r['exit_code']==contract['expected_native'] and r['passed']==(contract['expected_outer']==0) and not r['timeout'] and r['private_file_ownership_verified']
  assert r['network']=='docker-none' and r['locale']=='pt_PT' and r['runtime_uid']==r['runtime_gid']==1000
  assert r['offline_image_id']=='sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b'
  gravity=r['activity'].startswith('align4');two=r['activity'].endswith('2players');qml='align4_2players/Align42players.qml' if gravity else 'tic_tac_toe/TicTacToe.qml';assert r['qml_file']==qml
  snapshot=identities[r['resource_manifest_sha256']];effective=dict(snapshot['files']);effective['share/gcompris-qt/rcc/'+qml.split('/')[0]+'.rcc']=r['private_rcc_sha256'];effective['share/gcompris-qt/translations/gcompris_qt_pt.qm']=r['private_qm_sha256'];assert r['resource_files_sha256']==effective and r['binary_sha256']==effective['bin/gcompris-qt']
  for screen in r['screenshots']:safe(screen['file']);assert sha((directory/screen['file']).read_bytes())==screen['sha256']
  receipts[name]=r
  if 'parse-diagnostic' in name:
   assert r['case_result'] is None and r['qml_errors'];continue
  assert not r['qml_errors'];record=r['case_result'];assert record['failures']==contract['expected_outer']
  if name.endswith('-complete'):
   wanted=10 if two or not gravity else 12;games=record['games'];assert len(games)==wanted;scores=[0,0]
   if not two:assert [(game['level'],game['starter']) for game in games]==[(level,starter) for level in range(1,(6 if gravity else 5)+1) for starter in [1,2]]
   else:assert [(game['scenario']['orientation'],game['starter']) for game in games]==[(orientation,starter) for orientation in [0,1,2,3,'draw'] for starter in [1,2]]
   for game in games:
    observed(game['initial'],gravity);observed(game['final'],gravity);previous=game['initial']['values'];board(previous,gravity);assert terminal(previous,gravity) is None and game['scoresBefore']==scores
    assert previous.count(0)==len(previous)-(1 if not two and game['starter']==2 else 0)
    if not two and game['starter']==2:assert previous.count(2)==1
    player=game['starter'] if two else 1;assert game['moves'],'Empty native route'
    for move in game['moves']:
     assert move['before']==previous and move['player']==player;transition(move,gravity);previous=move['after'];player=3-player;inputs.add(move['input']);counts['placements']+=1
    assert previous==game['final']['values'];result=terminal(previous,gravity);assert result==game['outcome'] and result is not None and game['finishedClickUnchanged']
    if two:assert result==(0 if game['scenario']['draw'] else game['starter'])
    if result:scores[result-1]+=1;counts['player'+str(result)+'_wins']+=1
    else:counts['draws']+=1
    assert game['scoresAfter']==scores and game['bonus'].endswith('/flower_'+('good' if result and (two or result==1) else 'bad')+'.svg');counts['games']+=1
  elif name.endswith('-controls'):
   e=record['evidence'];assert e['menu'] and e['focusAfterHelp'] and e['pieceKeyboardExposed']==gravity;transition(e['afterHelp'],gravity)
   assert e['noLevelSelector'] if two else e['wrap'];assert e['publicLevels']==(1 if gravity else 0) if two else e['publicLevels']==(6 if gravity else 5)
   assert sum(v!=0 for v in e['restart']['before']['values'])>sum(v!=0 for v in e['restart']['after']['board']['values'])
   for row in e['partial']:transition(row,gravity)
   for row in e['illegal']:assert row['before']==row['after'] and row['turnBefore']==row['turnAfter']
   if not gravity or two:assert len(e['illegal'])==1
   if gravity:
    assert len(e['keyboard'])==14
    for row in e['keyboard']:assert row['after']==(row['before']+(-1 if row['key']==16777234 else 1))%7
    transition(e['keyboardDrop'],gravity);assert 'alinhar quatro peças ganha.' in e['help']['content']
   counts['controls']+=1
  elif name in ['draw-first-green','draw-second-green']:
   e=record['evidence'];assert len(e['moves'])==42 and e['complete'] and e['lastNonterminal']['pieces']==41 and e['lastNonterminal']['bonusOpacity']==0;previous=e['initial']['initial']['values'];assert previous==[0]*42
   for row in e['moves']:assert row['before']==previous;transition(row,True);previous=row['after']
   assert previous==e['final']['values'] and terminal(previous,True)==0
  elif name in ['keyboard-green','keyboard-ai-green']:
   e=record['evidence'];samples=e['samples'];assert samples[0]['column']==samples[1]['column'];column=samples[1]['column']
   for i in range(3):
    expected=(column-1)%7;assert all(row['column']==expected for row in samples[2+4*i:6+4*i]);column=expected
   assert e['drop']['location']==column;transition(e['drop'],True)
 assert counts['games']==42 and counts['controls']==4 and inputs=={'click','key','AI'}
 for prefix in ['align-help','align-friend-help','tic-contract','draw-first','draw-second','keyboard','keyboard-ai']:
  assert receipts[prefix+'-red']['case_sha256']==receipts[prefix+'-green']['case_sha256'],'Red/green case differs '+prefix
 assert receipts['tic-contract-red']['case_result']['evidence']['publicLevels']==0 and receipts['tic-contract-green']['case_result']['evidence']['publicLevels']==5
 for name in ['align-help-green','align-friend-help-green']:assert 'alinhar quatro peças ganha.' in receipts[name]['case_result']['evidence']['content']
 return {'cases':len(CASES),**counts,'source_files':982,'snapshot_files':269,'wav_decoded':4,'scope':'Composite Linux software evidence: baseline20 tic games; rules22 align games; final layout directed both consumers and friend controls. Windows, physical input/audio and teacher acceptance pending.'}
if __name__=='__main__':
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--evidence',type=Path,default=DEFAULT);args=parser.parse_args()
 try:print(json.dumps(audit(args.evidence),indent=2))
 except (AssertionError,OSError,ValueError,KeyError,zipfile.BadZipFile) as error:print('Alignment evidence rejected: '+str(error),file=sys.stderr);raise SystemExit(1)
