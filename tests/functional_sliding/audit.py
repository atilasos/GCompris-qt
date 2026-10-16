#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Check physical archives and visible 4×4 transitions, without Git or old paths."""
import argparse,hashlib,io,json,re,sys,zipfile
import xml.etree.ElementTree as ET
from pathlib import Path,PurePosixPath
from oracle import slide,rotate,solved
if not __debug__:raise SystemExit('Sliding evidence requires assertions; Python -O rejected')
ROOT=Path(__file__).resolve().parents[2]
CAPTURE_SHA='6c8116d92d2e6e985e61b3044ede6fabc3d7408ee9227e4584871bca77264a44'
SOURCE_SHA='0dbb69f4ce949cd038430087c48ae3190c8cbef7b0e3de2f8eb60dc7c2872c08'
BASELINE='ad2db30351cafa5d9adc4c79794969a86d36537e'
FINAL='6f50272eefa3c7dcbf58092b300f60e1b12ac86b'
LOCALIZED='9bae42ea54aeaf5267e8be36bf78194f124178bc'
NAMES=['fifteen-tracer','sixteen-tracer','fifteen-complete','sixteen-complete','help-red','help-green','fifteen-menu-diagnostic','sixteen-menu-diagnostic','fifteen-menu-diagnostic2','sixteen-menu-diagnostic2','fifteen-menu-diagnostic3','sixteen-menu-diagnostic3','fifteen-controls','sixteen-controls','fifteen-partial-restart','fifteen-art-red','sixteen-art-red','fifteen-art-green','sixteen-art-green','art-english-fallback']
OLD=set(NAMES[:5]);NEGATIVE={'help-red','fifteen-art-red','sixteen-art-red',*[name for name in NAMES if 'diagnostic' in name]}
NEW_TEXT='Clica ou arrasta uma peça junto ao espaço vazio para a mover para esse espaço.'

def sha(data):return hashlib.sha256(data).hexdigest()
def read(path):return json.loads(path.read_text())
def safe(name):
 path=PurePosixPath(name);assert not path.is_absolute() and '..' not in path.parts and str(path)==name,'Unsafe archive path'
def audit(base):
 base=Path(base);raw=(base/'capture.json').read_bytes();assert sha(raw)==CAPTURE_SHA,'Immutable capture changed';capture=json.loads(raw);assert capture['format']==1 and set(capture['cases'])==set(NAMES)
 for name,digest in capture['files'].items():
  safe(name);path=base/name;assert not any(parent.is_symlink() for parent in [path,*path.parents]),'Symlink evidence';assert sha(path.read_bytes())==digest,'Changed artifact '+name
 archive=(base/'source-tree.zip').read_bytes();assert sha(archive)==SOURCE_SHA,'Immutable source archive changed';phases=read(base/'source-phases.json');assert {key:value['revision'] for key,value in phases.items()}=={'baseline':BASELINE,'final':FINAL,'localized':LOCALIZED}
 with zipfile.ZipFile(io.BytesIO(archive)) as bundle:
  names=bundle.namelist();assert len(names)==len(set(names));assert set(names)=={phase+'/'+name for phase,value in phases.items() for name in value['files']}
  content={name:bundle.read(name) for name in names}
 for phase,value in phases.items():
  for name,digest in value['files'].items():safe(name);assert sha(content[phase+'/'+name])==digest
 def original(name,phase='final'):return content[phase+'/'+name]
 assert len(phases['final']['files'])==224
 assert [name for name in phases['baseline']['files'] if original(name,'baseline')!=original(name)]==['poqm/pt/gcompris_qt.po']
 assert NEW_TEXT in original('poqm/pt/gcompris_qt.po').decode() and 'movrt para o espaço vazio.' in original('poqm/pt/gcompris_qt.po','baseline').decode()
 qml=original('src/activities/fifteen/Fifteen.qml').decode();assert 'property int numberOfLevel: 14' in qml
 data=read(base/'data.json');assert len(data['levels'])==14 and data['datasets']==[]
 for i,row in enumerate(data['levels'],1):assert row=={'level':i,'representation':'numbers-and-image' if i%2 else 'image-only','scene':'Fishing_Boat_Scene.svg' if i<5 else 'Coastal_Path.svg','initial_misplaced_threshold_fifteen':i+1,'initial_rotations_sixteen':i+1}
 identities={}
 for identity,phase in [('identities','final'),('identities-localized','localized')]:
  snapshot_raw=(base/identity/'snapshot-manifest.json').read_bytes();snapshot=json.loads(snapshot_raw);assert len(snapshot['files'])==269
  resources=read(base/identity/'resources.json');assert resources['revision']==phases[phase]['revision'] and resources['inspector_source_sha256']==sha(original('tools/pt-pt-audio/rcc_inventory.cpp',phase))
  assert read(base/identity/'source-manifest.json')==phases[phase]
  assert set(resources['canonical'])=={'fifteen','sixteen','core'}
  for name,value in resources['canonical'].items():
   prefix='src/core/' if name=='core' else 'src/activities/'+name+'/'
   wanted={path for path in phases[phase]['files'] if path.startswith(prefix)}
   assert {row['path'] for row in value['files']}=={':/gcompris/'+path for path in wanted} and len(value['files'])==len(wanted)
   for row in value['files']:
    actual=original(row['path'].removeprefix(':/gcompris/'),phase);assert row['sha256']==sha(actual) and row['bytes']==len(actual)
   assert value['rcc_sha256']==snapshot['files']['share/gcompris-qt/rcc/'+name+'.rcc']
  assert len(resources['audio'])==2
  for row in resources['audio']:assert row['decode_exit_code']==0 and row['sha256']==sha(original(row['path'],phase))
  identities[phase]=(snapshot_raw,snapshot)
 localized_path='src/activities/fifteen/resource/Coastal_Path-pt.svg'
 assert set(phases['localized']['files'])-set(phases['final']['files'])=={localized_path}
 assert [name for name in phases['final']['files'] if original(name)!=original(name,'localized')]==['src/activities/fifteen/Fifteen.qml']
 before=list(ET.fromstring(original('src/activities/fifteen/resource/Coastal_Path.svg')).iter());after=list(ET.fromstring(original(localized_path,'localized')).iter());assert len(before)==len(after)
 changes=[]
 for a,b in zip(before,after):
  assert (a.tag,a.attrib,a.tail)==(b.tag,b.attrib,b.tail)
  if a.text!=b.text:changes.append((a.attrib.get('id'),a.text,b.text))
 assert changes==[('tspan137','Miles','milhas'),('tspan138','Coast','Rota'),('tspan139','Path','Costeira')]
 assert [node.text for node in after if node.tag.endswith('tspan')]==['125','milhas','Rota','Costeira']
 art=read(base/'art-labels.json');assert art['helper_sha256']==sha((base/'art_bounds.cpp').read_bytes())
 assert {row['id'] for row in art['bounds']}=={'text136','text137','text138','text139'}
 for row in art['bounds']:
  left,top,right,bottom=(590,739,667,800) if row['id'] in ['text136','text137'] else (242,440,329,501)
  assert left<=row['x'] and top<=row['y'] and row['width']>0 and row['height']>0 and row['x']+row['width']<=right and row['y']+row['height']<=bottom
  assert row['x']+row['width']<810 or row['y']+row['height']<810,'Text cannot disappear into blank source tile'
 def board(values,mode):assert len(values)==16 and sorted(values)==list(range(16) if mode=='fifteen' else range(1,17))
 def observed(record,mode,level,localized=False):
  values=record['values'];board(values,mode);assert len(record['tiles'])==16 and {tile['cell'] for tile in record['tiles']}==set(range(16))
  for tile in record['tiles']:
   cell=tile['cell'];value=values[cell];assert tile['value']==value and tile['width']>0 and tile['height']>0 and tile['x']==(cell%4)*tile['width'] and tile['y']==(cell//4)*tile['height']
   if value:
    assert tile['crop']=={'column':(value-1)%4,'row':(value-1)//4} and tile['source'].endswith('/'+(data['levels'][level-1]['scene'].replace('.svg','-pt.svg') if localized and level>=5 else data['levels'][level-1]['scene']))
    assert tile['text']==(str(value) if level%2 else '')
   else:assert tile['source']=='' and tile['crop'] is None and tile['text']==''
 def transition(row,mode):
  board(row['before'],mode);board(row['after'],mode)
  expected=slide(row['before'],row['cell']) if mode=='fifteen' else rotate(row['before'],row['direction'],row['index']);assert row['after']==expected
 counts={'levels':0,'moves':0,'detour_moves':0,'assisted_levels':0,'unassisted_levels':0,'controls':0};inputs=set();directions=set()
 receipts={}
 for name in NAMES:
  directory=base/name;raw=(directory/'result.json').read_bytes();result=json.loads(raw);status=read(directory/'launcher-status.json');outer=read(directory/'supervisor-exit.json');tool=read(directory/'tool-exit.json');phase='baseline' if name in OLD else 'localized' if name.endswith('art-green') or name=='art-english-fallback' else 'final';expected=1 if name in NEGATIVE else 0
  assert capture['cases'][name]=={'phase':phase,'expected_outer':expected}
  assert status['kind']=='observed-subprocess-exit' and outer['kind']=='observed-supervisor-subprocess-exit' and tool['kind']=='observed-exec-tool-return'
  assert status['exit_code']==outer['exit_code']==tool['exit_code']==expected
  assert status['native_receipt_sha256']==outer['native_receipt_sha256']==tool['native_receipt_sha256']==sha(raw)
  assert status['case_sha256']==outer['case_sha256']==tool['case_sha256']==result['case_sha256']==sha((directory/'case.qml').read_bytes())
  assert outer['launcher_status_sha256']==tool['launcher_status_sha256']==sha((directory/'launcher-status.json').read_bytes())
  assert outer['supervisor_sha256']==sha(original('tools/run-native-qml-supervised.py',phase)) and status['launcher_sha256']==result['runner_sha256']==sha(original('tools/run-native-qml-case.py',phase))
  assert result['source_sha256']==sha(original('src/activities/fifteen/Fifteen.qml',phase)) and result['portuguese_catalogue_sha256']==sha(original('poqm/pt/gcompris_qt.po',phase))
  assert result['exit_code']==0 and result['passed']==(expected==0) and not result['timeout'] and result['private_file_ownership_verified']
  assert result['network']=='docker-none' and result['locale']==('en_US' if name=='art-english-fallback' else 'pt_PT') and result['runtime_uid']==result['runtime_gid']==1000
  snapshot_raw,snapshot=identities['localized' if phase=='localized' else 'final']
  assert result['qml_file']=='fifteen/Fifteen.qml' and result['resource_manifest_sha256']==sha(snapshot_raw)
  effective=dict(snapshot['files']);effective['share/gcompris-qt/rcc/fifteen.rcc']=result['private_rcc_sha256'];effective['share/gcompris-qt/translations/gcompris_qt_pt.qm']=result['private_qm_sha256'];assert result['resource_files_sha256']==effective and result['binary_sha256']==effective['bin/gcompris-qt']
  for screen in result['screenshots']:assert sha((directory/screen['file']).read_bytes())==screen['sha256']
  mode=result['activity'];record=result['case_result'];assert record['failures']==(0 if name.endswith('diagnostic3') else expected);receipts[name]=result
  if name.endswith('diagnostic3'):assert len(result['qml_errors'])==1 and result['qml_errors'][0].startswith('qml: NATIVE_SLIDING_RESULT ') and 'ReferenceError: ActivityInfoTree is not defined' in record['evidence']['contextError']
  else:assert not result['qml_errors']
  if name.endswith('-complete'):
   assert len(record['levels'])==14
   for i,level in enumerate(record['levels'],1):
    assert level['level']==i and level['assisted']==(mode=='sixteen');observed(level['initial'],mode,i);observed(level['final'],mode,i);assert not solved(level['initial']['values'],mode) and solved(level['final']['values'],mode)
    assert len(level['detour'])==2 and level['detour'][0]['before']==level['initial']['values'] and level['detour'][1]['after']==level['initial']['values']
    for row in level['detour']:transition(row,mode);assert not solved(row['after'],mode);counts['detour_moves']+=1
    assert level['detour'][0]['after']==level['detour'][1]['before'];previous=level['initial']['values'];assert level['moves'],'Empty native route'
    for row in level['moves']:
     assert row['before']==previous;transition(row,mode);previous=row['after'];inputs.add(row['input'])
     if mode=='sixteen':assert row['hint']=={'direction':row['direction'],'index':row['index'],'color':'#804280ff'};directions.add(row['direction'])
     counts['moves']+=1
    assert previous==level['final']['values'] and level['goodBonus'].endswith('/flower_good.svg')
    assert (directory/f'level-{i}.png').is_file();counts['levels']+=1;counts['assisted_levels' if mode=='sixteen' else 'unassisted_levels']+=1
  elif name.endswith('-controls'):
   evidence=record['evidence'];assert all(evidence[key] for key in ['wrap','partialRestart','focusAfterHelp','menu'])
   for row in evidence['detour']:transition(row,mode)
   transition(evidence['afterHelp'],mode)
   if mode=='fifteen':assert evidence['nonadjacentUnchanged'] and NEW_TEXT in evidence['help']['content']
   else:
    assert evidence['hint'] and evidence['reload'] and len(evidence['keyboard'])==4;transition(evidence['keyboardMove'],mode);transition(evidence['returnMove'],mode)
   counts['controls']+=1
  elif name=='fifteen-partial-restart':
   e=record['evidence'];observed(e['initial'],mode,1);observed(e['reset'],mode,1);transition(e['partial'],mode);assert e['partial']['before']==e['initial']['values'] and e['reset']['values']!=e['partial']['after'] and e['partialRestart']
   def misplaced(values):return sum(value!=0 and value!=i+1 for i,value in enumerate(values))
   assert misplaced(e['initial']['values'])==misplaced(e['reset']['values'])==2 and misplaced(e['partial']['after'])>2
  elif name.endswith('art-green') or name=='art-english-fallback':
   e=record['evidence'];localized=name!='art-english-fallback';observed(e['initial'],mode,5,localized);transition(e['move'],mode);transition(e['repair'],mode);assert e['move']['before']==e['repair']['after']==e['initial']['values'] and e['move']['after']==e['repair']['before'] and e['restored']
   assert e['expectedSource']==('Coastal_Path-pt.svg' if localized else 'Coastal_Path.svg')
 assert counts['levels']==28 and counts['assisted_levels']==counts['unassisted_levels']==14 and counts['controls']==2 and inputs=={'click','key','drag'} and directions==set('LTRB')
 for mode in ['fifteen','sixteen']:assert receipts[mode+'-art-red']['case_sha256']==receipts[mode+'-art-green']['case_sha256']
 assert receipts['help-red']['case_sha256']==receipts['help-green']['case_sha256']
 assert 'movrt' in receipts['help-red']['case_result']['evidence']['content'] and NEW_TEXT in receipts['help-green']['case_result']['evidence']['content']
 return {'cases':len(NAMES),**counts,'source_files':673,'localized_art_consumers':2,'english_fallback':1,'snapshot_files':269,'wav_decoded':2,'scope':'Linux software; fourteen sixteen levels assisted by visible hints. Random states, Windows, listening, hardware and teacher acceptance not exhausted or approved.'}

if __name__=='__main__':
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--evidence',type=Path,default=ROOT/'.scratch/pt-pt/functional-sliding');args=parser.parse_args()
 try:print(json.dumps(audit(args.evidence),indent=2))
 except (AssertionError,OSError,ValueError,KeyError,zipfile.BadZipFile) as error:print('Sliding evidence rejected: '+str(error),file=sys.stderr);raise SystemExit(1)
