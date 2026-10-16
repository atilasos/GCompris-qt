#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit frozen bytes, drawn constraints, finite coverage and real UI receipts."""
import argparse,collections,hashlib,json,re,sys,zipfile,xml.etree.ElementTree as ET
from pathlib import Path,PurePosixPath
from oracle import from_screen,valid
from static_data import dataset,fixed_fingerprint,drawn_fingerprint
if not __debug__:raise SystemExit('Grids evidence requires assertions; Python -O rejected')
ROOT=Path(__file__).resolve().parent.parent.parent
CAPTURE_SHA='d5332fa4e421521e55a67e1e3da85790e64716fefd5055a5005a67865603a8e7'
REVISIONS={'baseline':'1061af56417228aa27d123dd4aaa69eb7b5e256a','final':'d740510aa8a87611d28e4776e64c8345fc4b2a64'}
DIAGNOSTIC=['sudoku-inventory','calcudoku-inventory']
INVENTORY=['sudoku-inventory-v2','calcudoku-inventory-v2']
TRACERS=['sudoku-tracer','calcudoku-tracer']
GAMES=['sudoku-dataset-'+str(i) for i in range(1,5)]+['calcudoku-dataset-'+str(i) for i in range(1,6)]
FINAL=['sudoku-help-green','sudoku-controls','calcudoku-controls']
NAMES=[*DIAGNOSTIC,*INVENTORY,*TRACERS,*GAMES,'sudoku-help-red',*FINAL]
def sha(raw):return hashlib.sha256(raw).hexdigest()
def safe(name):
 path=PurePosixPath(name);assert not path.is_absolute() and '..' not in path.parts and str(path)==name,'Unsafe capsule path'
def audit(capsule):
 raw=(capsule/'capture.json').read_bytes();assert sha(raw)==CAPTURE_SHA,'Immutable grids capsule changed';capture=json.loads(raw);assert capture['format']==1 and set(capture['cases'])==set(NAMES) and set(capture['phases'])==set(REVISIONS)
 for path in [capsule,capsule/'capture.json',capsule/'objects.zip']:assert not path.is_symlink()
 with zipfile.ZipFile(capsule/'objects.zip') as bundle:
  names=bundle.namelist();assert len(names)==len(set(names))==len(capture['objects']) and set(names)=={'objects/'+digest for digest in capture['objects']};objects={name.removeprefix('objects/'):bundle.read(name) for name in names}
 for digest,raw in objects.items():assert sha(raw)==digest,'Physical object bytes altered'
 used=set()
 def blob(digest):used.add(digest);return objects[digest]
 def artifact(name):safe(name);return blob(capture['files'][name])
 def js(name):return json.loads(artifact(name))
 for name in capture['files']:artifact(name)
 for module in ['oracle.py','static_data.py']:assert sha(Path(__file__).with_name(module).read_bytes())==capture['files']['harness/'+module],'External pure module differs from capsule'
 sources={};snapshots={};canonical_count=0;extraction_count=0;audio_count=0
 def verify_rcc(report,phase,activity,patched=None,case_name=None):
  nonlocal extraction_count
  assert blob(report['rcc_sha256']).startswith(b'qres'),'Not physical RCC';prefix='src/core/' if activity=='core' else 'src/activities/'+activity+'/';wanted={name for name in sources[phase] if name.startswith(prefix)};assert len(report['files'])==len(wanted) and {row['path'] for row in report['files']}=={':/gcompris/'+name for name in wanted}
  qml='src/activities/'+activity+'/'+('Sudoku.qml' if activity=='sudoku' else 'Calcudoku.qml')
  for row in report['files']:
   path=row['path'].removeprefix(':/gcompris/');safe(path);raw=blob(row['sha256']);assert len(raw)==row['bytes'] and raw==(patched if patched is not None and path==qml else blob(sources[phase][path])),'Qt extraction differs from source/exact case'
   if case_name:assert raw==artifact('cases/'+case_name+'/resources/extracted/'+row['path'].removeprefix(':/'))
   extraction_count+=1
 for phase,value in capture['phases'].items():
  assert value['revision']==value['source']['revision']==REVISIONS[phase];sources[phase]=value['source']['files']
  for name,digest in sources[phase].items():safe(name);blob(digest)
  snapshot_raw=blob(value['snapshot_manifest']);snapshot=json.loads(snapshot_raw);assert len(snapshot['files'])==269;snapshots[sha(snapshot_raw)]=snapshot
  assert set(value['canonical'])=={'sudoku','calcudoku','core'}
  for activity,report in value['canonical'].items():assert report['rcc_sha256']==snapshot['files']['share/gcompris-qt/rcc/'+activity+'.rcc'];verify_rcc(report,phase,activity);canonical_count+=1
  assert len(value['audio'])==6
  for row in value['audio']:assert row['decode_exit_code']==0 and row['sha256']==sources[phase][row['path']];audio_count+=1
 assert set(sources['baseline'])==set(sources['final']) and {name for name in sources['baseline'] if sources['baseline'][name]!=sources['final'][name]}=={'poqm/pt/gcompris_qt.po'}
 assert b'deve aparecem apenas' in blob(sources['baseline']['poqm/pt/gcompris_qt.po']) and b'deve aparecer apenas' in blob(sources['final']['poqm/pt/gcompris_qt.po'])
 origin=json.loads(blob(capture['origin_snapshot_manifest']));assert len(origin['files'])==269
 static={}
 for activity,count in [('sudoku',4),('calcudoku',5)]:
  info=blob(sources['baseline']['src/activities/'+activity+'/ActivityInfo.qml']).decode();declared=re.search(r'levels:\s*\[(.*?)\]',info,re.S);assert re.findall(r'"(\d+)"',declared[1])==[str(i) for i in range(1,count+1)]
  for index in range(1,count+1):static[(activity,index)]=dataset(blob(sources['baseline']['src/activities/'+activity+'/resource/'+str(index)+'/Data.qml']).decode())
 def values(screen,initial,arithmetic):
  n=initial['size'];symbols=[p['source'] for p in initial['palette']];result=[0]*(n*n)
  for cell in screen['cells']:
   index=round(cell['y']/cell['height'])*n+round(cell['x']/cell['width']);source=cell['source']
   if source:result[index]=int(source.rsplit('/',1)[-1].removesuffix('.svg')) if arithmetic else symbols.index(source)+1
  return result
 def placement(move,current,puzzle,clearing=False):
  assert move['before']==current and move['input'] in ['click','key'];cell=move['cell'];value=move['value'];assert 0<=cell<len(current) and 1<=value<=puzzle['n'];expected=current.copy();expected[cell]=0 if clearing else value;assert move['after']==expected,'UI action changes only requested cell';assert not puzzle['givens'][cell],'Attempted editable move on fixed clue';return move['after']
 def error_route(error,current,puzzle):
  if error['preparation']:current=placement(error['preparation'],current,puzzle)
  wrong=error['attempt'];assert wrong['before']==wrong['after']==current and '#eb7878' in wrong['colors'];cell=wrong['cell'];n=puzzle['n'];assert not current[cell] and any(current[i]==wrong['value'] and (i//n==cell//n or i%n==cell%n) for i in range(n*n) if i!=cell),'Attempted error is independently conflicting'
  assert error['clearing'] is None;return placement(error['repair'],current,puzzle)
 receipts={};counts={'boards':0,'fixed_boards':0,'generated_boards':0,'levels':0,'error_repair':0,'controls':0,'placements':0};operators=set();representations=set();region_sizes=set();inputs=set()
 for name in NAMES:
  prefix='cases/'+name+'/';r=js(prefix+'result.json');status=js(prefix+'launcher-status.json');outer=js(prefix+'supervisor-exit.json');tool=js(prefix+'tool-exit.json');phase='final' if name in FINAL else 'baseline';bad=int(name in DIAGNOSTIC or name=='sudoku-help-red');contract=capture['cases'][name];assert contract['phase']==phase and contract['expected_outer']==bad
  assert r['exit_code']==0 and not r['timeout'] and r['passed']==(bad==0) and r['private_file_ownership_verified'] and r['deployment_retained'] and not r['qml_errors']
  assert status['kind']=='observed-subprocess-exit' and outer['kind']=='observed-supervisor-subprocess-exit' and tool['kind']=='observed-exec-tool-return';assert status['exit_code']==outer['exit_code']==tool['exit_code']==bad
  assert status['native_receipt_sha256']==outer['native_receipt_sha256']==tool['native_receipt_sha256']==sha(artifact(prefix+'result.json'))
  assert status['case_sha256']==outer['case_sha256']==tool['case_sha256']==r['case_sha256']==sha(artifact(prefix+'case.qml')) and outer['launcher_status_sha256']==tool['launcher_status_sha256']==sha(artifact(prefix+'launcher-status.json')) and tool['session_id']>0 and len(tool['chunk_id'])>=5
  assert status['launcher_sha256']==r['runner_sha256']==sources[phase]['tools/run-native-qml-case.py'] and outer['supervisor_sha256']==sources[phase]['tools/run-native-qml-supervised.py']
  activity=r['activity'];arithmetic=activity=='calcudoku';qml='src/activities/'+activity+'/'+('Calcudoku.qml' if arithmetic else 'Sudoku.qml');assert activity in ['sudoku','calcudoku'] and r['source_sha256']==sources[phase][qml] and r['portuguese_catalogue_sha256']==sources[phase]['poqm/pt/gcompris_qt.po']
  assert r['runtime_uid']==r['runtime_gid']==1000 and r['network']=='docker-none' and r['locale']=='pt_PT' and r['qml_file']==qml.removeprefix('src/activities/') and r['offline_image_id']=='sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b'
  snapshot=snapshots[r['resource_manifest_sha256']];effective=dict(snapshot['files']);effective['share/gcompris-qt/rcc/'+activity+'.rcc']=r['private_rcc_sha256'];effective['share/gcompris-qt/translations/gcompris_qt_pt.qm']=r['private_qm_sha256'];assert r['resource_files_sha256']==effective and r['binary_sha256']==origin['files']['bin/gcompris-qt']==effective['bin/gcompris-qt']
  physical=js(prefix+'resources/physical.json');assert physical['rcc_sha256']==r['private_rcc_sha256']==sha(artifact(prefix+'resources/'+activity+'.rcc')) and physical['qm_sha256']==r['private_qm_sha256']==sha(artifact(prefix+'resources/gcompris_qt_pt.qm')) and physical['inspector_source_sha256']==sources[phase]['tools/pt-pt-audio/rcc_inventory.cpp']
  assert artifact(prefix+'resources/gcompris_qt_pt.qm').startswith(bytes.fromhex('3cb86418caef9c95cd211cbf60a1bddd'));assert sha(artifact(prefix+'resources/catalogue.ts'))==physical['catalogue_ts_sha256'] and ET.fromstring(artifact(prefix+'resources/catalogue.ts')).tag=='TS'
  text=blob(sources[phase][qml]).decode();closing=re.search(r'\n    }\s*\n}\s*$',text);fragment=artifact(prefix+'case.qml').decode().replace('__QA_OUTPUT__',contract['historical_output']).replace('__QA_SOURCE__',capture['phases'][phase]['historical_source_root']);patched=('import QtTest\n'+text[:closing.start()]+'\n'+fragment+text[closing.start():]).encode();verify_rcc(physical,phase,activity,patched,name)
  for image in r['screenshots']:assert sha(artifact(prefix+image['file']))==image['sha256']
  c=r['case_result'];assert c['failures']==bad;receipts[name]=r;e=c['evidence']
  if name in DIAGNOSTIC:assert e['records']==[];continue
  if name in INVENTORY:
   count=5 if arithmetic else 4;assert len(e['datasets'])==count and all(item['label'].startswith('Grelhas') for item in e['datasets']);expected_records=sum(len(static[(activity,i)]) for i in range(1,count+1));assert len(e['records'])==expected_records
   for record in e['records']:
    level=static[(activity,record['dataset'])][record['level']-1];assert record['publicLevels']==len(static[(activity,record['dataset'])]) and record['score']==['0/'+str(level['length'] if level.get('random') else len(level['data']))];from_screen(record,arithmetic)
  elif name in GAMES:
   index=int(name.rsplit('-',1)[-1]);expected_levels=static[(activity,index)];assert e['dataset']==index and len(e['levels'])==len(expected_levels);assert [item['checked'] for item in e['selection']]==[i==index-1 for i in range(5 if arithmetic else 4)]
   for ordinal,level in enumerate(e['levels'],1):
    definition=expected_levels[ordinal-1];total=definition['length'] if definition.get('random') else len(definition['data']);assert level['level']==ordinal and level['total']==len(level['boards'])==total,'Finite coverage missing';observed=[]
    for sub,board in enumerate(level['boards']):
     initial=board['initial'];assert initial['level']==ordinal and initial['publicLevels']==len(expected_levels) and initial['score']==[str(sub)+'/'+str(total)];puzzle=from_screen(initial,arithmetic);assert puzzle==board['puzzle'] and valid(puzzle,board['solution']);current=puzzle['givens'].copy()
     if sub==0:current=error_route(board['error'],current,puzzle);counts['error_repair']+=1
     else:assert 'error' not in board
     assert values(board['afterError'],initial,arithmetic)==current
     for move in board['moves']:current=placement(move,current,puzzle);inputs.add(move['input']);counts['placements']+=1
     completed=values(board['completed'],initial,arithmetic);assert current==completed==board['solution'] and valid(puzzle,completed),'Drawn completion violates independent mathematics';assert board['scoreAfter']==[sub+1,total] and board['completed']['score']==[str(sub+1)+'/'+str(total)]
     if sub+1<total:assert board['next']['level']==ordinal and board['next']['score']==[str(sub+1)+'/'+str(total)]
     observed.append(drawn_fingerprint(initial));counts['boards']+=1;counts['generated_boards' if arithmetic else 'fixed_boards']+=1;region_sizes.add(puzzle['n'])
     if arithmetic:
      assert definition['random'] and puzzle['n']==definition['size'];allowed=set({'+':'+','-':'−','*':'×',':':'∕'}[op] for op in definition['operators']);assert all(cage['op'] in allowed or cage['op']=='' for cage in puzzle['cages']);operators.update(cage['op'] for cage in puzzle['cages'] if cage['op'])
      for cage in puzzle['cages']:
       if len(cage['cells'])>2:assert cage['op'] in ['+','×']
     else:
      representations.update('digits' if p['source'].rsplit('/',1)[-1][0].isdigit() else 'symbols' for p in initial['palette'])
    if not arithmetic:assert collections.Counter(observed)==collections.Counter(fixed_fingerprint(board,definition['symbols']) for board in definition['data']),'Not every fixed clue board was played'
    assert level['bonus']['source'].endswith('/flower_good.svg') and level['bonus']['opacity']>0.5 and level['continuation']['level']==ordinal%len(expected_levels)+1 and level['continuation']['score'][0].startswith('0/');counts['levels']+=1
  elif name in TRACERS:
   initial=e['initial'];puzzle=from_screen(initial,arithmetic);assert puzzle==e['puzzle'] and valid(puzzle,e['solution']);current=error_route(e['error'],puzzle['givens'],puzzle)
   for move in e['moves']:current=placement(move,current,puzzle)
   assert current==values(e['completed'],initial,arithmetic) and valid(puzzle,current) and e['scoreAfter'][0]==1 and e['next']['score'][0].startswith('1/')
  elif name.endswith('controls'):
   assert e['persisted'] and e['focusAfterHelp'] and e['menu'];assert [item['checked'] for item in e['selection']]==([False,False,False,True,True] if arithmetic else [False,True,True,False]);assert e['first']['publicLevels']==(2 if arithmetic else 5) and e['first']['size']==e['nextWrap']['size']==4 and e['previousWrap']['size']==e['boundary']['size']==5
   initial=e['initial'];puzzle=from_screen(initial,arithmetic)
   if not arithmetic:assert e['givenBlocked']['before']==e['givenBlocked']['after']==puzzle['givens'] and puzzle['givens'][e['givenBlocked']['cell']]>0
   current=placement(e['partial'],puzzle['givens'],puzzle);current=placement(e['cleared'],current,puzzle,True);current=placement(e['reentered'],current,puzzle);assert from_screen(e['reload'],arithmetic)==puzzle;placement(e['focusMove'],puzzle['givens'],puzzle);assert 'linha' in e['help']['content'] and 'coluna' in e['help']['content'];counts['controls']+=1
  elif name=='sudoku-help-red':assert 'deve aparecem' in e['content']
  elif name=='sudoku-help-green':
   assert e['title']=='Sudoku' and 'deve aparecer apenas uma vez' in e['content'] and 'deve aparecem' not in e['content'] and e['focusAfterHelp'];initial=e['afterHelp'];placement(e['input'],from_screen(initial,False)['givens'],from_screen(initial,False))
 assert receipts['sudoku-help-red']['case_sha256']==receipts['sudoku-help-green']['case_sha256']
 assert counts['boards']==168 and counts['fixed_boards']==68 and counts['generated_boards']==100 and counts['levels']==counts['error_repair']==18 and counts['controls']==2 and inputs=={'click','key'} and operators==set('+−×∕') and representations=={'digits','symbols'} and region_sizes=={3,4,5,9}
 assert canonical_count==6 and audio_count==12 and used==set(objects),'Unaccounted objects'
 return {**counts,'cases':len(NAMES),'snapshot_files':269,'physical_canonical_rcc':canonical_count,'physical_override_rcc_qm':len(NAMES),'qt_extractions':extraction_count,'scope':'Finite Linux composite:168 baseline boards, exact final help correction and two final controls; generated space, Windows, hardware, listening, teacher review and stability83 remain pending.'}
if __name__=='__main__':
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--capsule',type=Path,default=ROOT/'.scratch/pt-pt/functional-grids/capsule');args=parser.parse_args()
 try:print(json.dumps(audit(args.capsule),indent=2))
 except (AssertionError,OSError,ValueError,KeyError,IndexError,zipfile.BadZipFile,ET.ParseError) as error:print('Grids evidence rejected: '+str(error),file=sys.stderr);raise SystemExit(1)
