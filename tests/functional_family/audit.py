#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit the physical family capsule without Qt, Git or historical paths."""
import argparse,hashlib,io,json,re,sys,zipfile,xml.etree.ElementTree as ET
from pathlib import Path,PurePosixPath
from oracle import observe,relation,ICON_CATEGORY
if not __debug__:raise SystemExit('Family evidence requires assertions; Python -O rejected')
ROOT=Path(__file__).resolve().parent.parent.parent
CAPTURE_SHA='72462c4038ad64f4e1067bd3074ad730429d4ff5e6023a5f83e0e3f97a66c5be'
REVISIONS={'baseline':'1efc489b2e1f0b8ddf83d26bf1fda48d0d0bceae','translated':'90bd961d29d3be8815379aabf459af1675a6523e'}
NAMES=['family-inventory','family_find_relative-inventory','family-lexical-red','relative-lexical-red','family-lexical-green','relative-lexical-green','family-complete','relative-complete','family-controls','relative-controls']
ROLES={'Pai','Mãe','Avô','Avó','Neto','Neta','Irmão','Irmã','Primo','Tio','Tia','Sobrinho','Sobrinha','Sogro','Sogra','Cunhado','Cunhada','Genro'}
def sha(raw):return hashlib.sha256(raw).hexdigest()
def safe(name):
 path=PurePosixPath(name);assert not path.is_absolute() and '..' not in path.parts and str(path)==name,'Unsafe capsule path'
def audit(capsule):
 raw=(capsule/'capture.json').read_bytes();assert sha(raw)==CAPTURE_SHA,'Immutable family capsule changed';capture=json.loads(raw);assert capture['format']==1 and set(capture['cases'])==set(NAMES) and set(capture['phases'])==set(REVISIONS)
 for p in [capsule,capsule/'capture.json',capsule/'objects.zip']:assert not p.is_symlink(),'Symlink capsule'
 with zipfile.ZipFile(capsule/'objects.zip') as bundle:
  names=bundle.namelist();assert len(names)==len(set(names))==len(capture['objects']) and set(names)=={'objects/'+digest for digest in capture['objects']};objects={name.removeprefix('objects/'):bundle.read(name) for name in names}
 for digest,raw in objects.items():assert sha(raw)==digest,'Physical object bytes altered'
 used=set()
 def blob(digest):used.add(digest);return objects[digest]
 def artifact(name):safe(name);return blob(capture['files'][name])
 def js(name):return json.loads(artifact(name))
 for name in capture['files']:artifact(name)
 assert sha(Path(__file__).with_name('oracle.py').read_bytes())==capture['files']['harness/oracle.py'],'External oracle differs from tested capsule'
 sources={};snapshots={};canonical_count=0;audio_count=0;extraction_count=0
 def verify_rcc(value,phase,activity,patched=None,case_name=None):
  nonlocal extraction_count
  raw=blob(value['rcc_sha256']);assert raw.startswith(b'qres'),'Not physical RCC'
  prefix='src/core/' if activity=='core' else 'src/activities/'+activity+'/'
  wanted={name for name in sources[phase] if name.startswith(prefix)};rows=value['files'];assert len(rows)==len(wanted) and {row['path'] for row in rows}=={':/gcompris/'+name for name in wanted}
  for row in rows:
   path=row['path'].removeprefix(':/gcompris/');safe(path);raw=blob(row['sha256']);assert len(raw)==row['bytes'];assert raw==(patched if patched is not None and path=='src/activities/family/Family.qml' else blob(sources[phase][path])),'Qt extraction differs from source/case'
   if case_name:assert raw==artifact('cases/'+case_name+'/resources/extracted/'+row['path'].removeprefix(':/'))
   extraction_count+=1
 for phase,value in capture['phases'].items():
  assert value['revision']==value['source']['revision']==REVISIONS[phase];sources[phase]=value['source']['files']
  for name,digest in sources[phase].items():safe(name);blob(digest)
  snapshot=json.loads(blob(value['snapshot_manifest']));assert len(snapshot['files'])==269;snapshots[sha(blob(value['snapshot_manifest']))]=snapshot
  assert set(value['canonical'])=={'family','family_find_relative','core'}
  for activity,rcc in value['canonical'].items():
   assert rcc['rcc_sha256']==snapshot['files']['share/gcompris-qt/rcc/'+activity+'.rcc'];verify_rcc(rcc,phase,activity);canonical_count+=1
  assert len(value['audio'])==3
  for audio in value['audio']:assert audio['decode_exit_code']==0 and audio['sha256']==sources[phase][audio['path']];audio_count+=1
 assert set(sources['baseline'])==set(sources['translated']);assert {name for name in sources['baseline'] if sources['baseline'][name]!=sources['translated'][name]}=={'poqm/pt/gcompris_qt.po'}
 for phase in REVISIONS:assert [int(n) for n in re.findall(rb'// level (\d+)',blob(sources[phase]['src/activities/family/FamilyDataset.qml']))]==list(range(1,19))
 origin=json.loads(blob(capture['origin_snapshot_manifest']));assert len(origin['files'])==269
 receipts={};counts={'levels':0,'natural_good':0,'wrong_repair':0,'controls':0,'relative_pairs':0};roles_by_mode={}
 def expected(s):
  me=[i for i,p in enumerate(s['people']) if p['border']=='#e1e1e1'];target=[i for i,p in enumerate(s['people']) if p['border']=='#e77936'];assert len(me)==len(target)==1 and s['me']['text']=='Eu' and s['target']['text']=='?';g=observe(s);return g,{'me':me[0],'target':target[0],'label':relation(g,me[0],target[0])}
 def choices(s,g):
  question=s['question'].split(': ')[-1];assert question in ROLES;return question,[(a,b) for a in range(len(g['people'])) for b in range(a+1,len(g['people'])) if question in [relation(g,a,b),relation(g,b,a)]]
 for name in NAMES:
  prefix='cases/'+name+'/';r=js(prefix+'result.json');status=js(prefix+'launcher-status.json');outer=js(prefix+'supervisor-exit.json');tool=js(prefix+'tool-exit.json');phase='baseline' if name.endswith('inventory') or name.endswith('red') else 'translated';bad=int(name.endswith('red'));contract=capture['cases'][name];assert contract['phase']==phase and contract['expected_outer']==bad
  assert r['exit_code']==0 and not r['timeout'] and r['passed']==(bad==0) and r['private_file_ownership_verified'] and r['deployment_retained'] and not r['qml_errors']
  assert status['kind']=='observed-subprocess-exit' and outer['kind']=='observed-supervisor-subprocess-exit' and tool['kind']=='observed-exec-tool-return';assert status['exit_code']==outer['exit_code']==tool['exit_code']==bad
  assert status['native_receipt_sha256']==outer['native_receipt_sha256']==tool['native_receipt_sha256']==sha(artifact(prefix+'result.json'))
  assert status['case_sha256']==outer['case_sha256']==tool['case_sha256']==r['case_sha256']==sha(artifact(prefix+'case.qml'))
  assert outer['launcher_status_sha256']==tool['launcher_status_sha256']==sha(artifact(prefix+'launcher-status.json')) and tool['session_id']>0 and len(tool['chunk_id'])>=5
  assert status['launcher_sha256']==r['runner_sha256']==sources[phase]['tools/run-native-qml-case.py'] and outer['supervisor_sha256']==sources[phase]['tools/run-native-qml-supervised.py']
  assert r['source_sha256']==sources[phase]['src/activities/family/Family.qml'] and r['portuguese_catalogue_sha256']==sources[phase]['poqm/pt/gcompris_qt.po']
  assert r['runtime_uid']==r['runtime_gid']==1000 and r['network']=='docker-none' and r['locale']=='pt_PT' and r['qml_file']=='family/Family.qml' and r['activity'] in ['family','family_find_relative']
  snapshot=snapshots[r['resource_manifest_sha256']];effective=dict(snapshot['files']);effective['share/gcompris-qt/rcc/family.rcc']=r['private_rcc_sha256'];effective['share/gcompris-qt/translations/gcompris_qt_pt.qm']=r['private_qm_sha256'];assert r['resource_files_sha256']==effective and r['binary_sha256']==origin['files']['bin/gcompris-qt']==effective['bin/gcompris-qt']
  physical=js(prefix+'resources/physical.json');assert physical['rcc_sha256']==r['private_rcc_sha256']==sha(artifact(prefix+'resources/family.rcc')) and physical['qm_sha256']==r['private_qm_sha256']==sha(artifact(prefix+'resources/gcompris_qt_pt.qm')) and physical['inspector_source_sha256']==sources[phase]['tools/pt-pt-audio/rcc_inventory.cpp']
  assert artifact(prefix+'resources/gcompris_qt_pt.qm').startswith(bytes.fromhex('3cb86418caef9c95cd211cbf60a1bddd'));assert sha(artifact(prefix+'resources/catalogue.ts'))==physical['catalogue_ts_sha256'] and ET.fromstring(artifact(prefix+'resources/catalogue.ts')).tag=='TS'
  text=blob(sources[phase]['src/activities/family/Family.qml']).decode();closing=re.search(r'\n    }\s*\n}\s*$',text);fragment=artifact(prefix+'case.qml').decode().replace('__QA_OUTPUT__',contract['historical_output']).replace('__QA_SOURCE__',capture['phases'][phase]['historical_source_root']);patched=('import QtTest\n'+text[:closing.start()]+'\n'+fragment+text[closing.start():]).encode();verify_rcc(physical,phase,'family',patched,name)
  for screen in r['screenshots']:assert sha(artifact(prefix+screen['file']))==screen['sha256']
  c=r['case_result'];assert c['failures']==bad;receipts[name]=r
  if name.endswith('inventory'):assert len(c['records'])==18 and [s['level'] for s in c['records']]==list(range(1,19))
  if name.endswith('complete'):
   assert len(c['records'])==18;roles=set()
   for number,record in enumerate(c['records'],1):
    s=record['screen'];assert s['level']==number and s['publicLevels']==18;g=observe(s);assert g==record['graph'] and observe(record['afterWrong'])==g and record['afterWrong']['level']==number;assert record['wrong']['bonus']['source'].endswith('/lion_bad.svg')
    completions=record['completions'];assert completions,'Empty natural completion route'
    if r['activity']=='family':
     _,answer=expected(s);assert answer==record['expected'];roles.add(answer['label']);assert len(completions)==1 and completions[0]['label']==answer['label'] and s['options'][completions[0]['index']]==answer['label'] and record['wrong']['label']!=answer['label']
    else:
     q,pairs=choices(s,g);assert record['question']==q and [tuple(p) for p in record['pairs']]==pairs;assert [tuple(row['pair']) for row in completions]==pairs and tuple(record['wrong']['pair']) not in pairs and record['samePersonDeselect'];roles.add(q);counts['relative_pairs']+=len(pairs)
    for row in completions:assert row['bonus']['source'].endswith('/lion_good.svg') and row['nextLevel']==number%18+1
    counts['levels']+=1;counts['natural_good']+=len(completions);counts['wrong_repair']+=1
   assert roles==ROLES;roles_by_mode[r['activity']]=roles
  elif name.endswith('controls'):
   e=c['evidence'];assert e['navigation'] and e['previousWrap']['level']==18 and e['nextWrap']['level']==1 and not e['reloadExposed'] and not e['configurationExposed'] and e['focusAfterHelp'] and e['menu'] and e['bonus'].endswith('/lion_good.svg')
   assert 'árvore genealógica' in e['help']['content'] and 'anel' in e['help']['content']
   if r['activity']=='family':g,answer=expected(e['afterHelp']);assert e['selection']['label']==answer['label']
   else:
    assert any(p['border']=='#e77936' for p in e['partial']['people']) and all(p['border']=='#373737' for p in e['partialReset']['people']);g=observe(e['afterHelp']);q,pairs=choices(e['afterHelp'],g);assert tuple(sorted(e['selection']['pair'])) in pairs and e['selection']['pair'][0]>e['selection']['pair'][1]
   counts['controls']+=1
  elif name.endswith('lexical-green'):
   assert len(c['records'])==18
   for record in c['records']:
    s=record['screen'];g=observe(s);assert g==record['graph']
    if r['activity']=='family':_,answer=expected(s);assert answer['label'] in s['options'] and not {'Afilhado','Afilhada'}&set(s['options'])
    else:choices(s,g)
 for family in ['family','relative']:assert receipts[family+'-lexical-red']['case_sha256']==receipts[family+'-lexical-green']['case_sha256']
 assert counts=={'levels':36,'natural_good':46,'wrong_repair':36,'controls':2,'relative_pairs':28};assert canonical_count==6 and len(ICON_CATEGORY)==12;assert used==set(objects),'Unaccounted physical object'
 return {**counts,'cases':len(NAMES),'snapshot_files':269,'physical_canonical_rcc':canonical_count,'physical_override_rcc_qm':len(NAMES),'qt_extractions':extraction_count,'scope':'Linux software; gender categories are documented icon conventions, not explicit captions or certainty about people. Windows, hardware, audio listening, teacher review and stability83 remain pending.'}
if __name__=='__main__':
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--capsule',type=Path,default=ROOT/'.scratch/pt-pt/functional-family/capsule');args=parser.parse_args()
 try:print(json.dumps(audit(args.capsule),indent=2))
 except (AssertionError,OSError,ValueError,KeyError,zipfile.BadZipFile,ET.ParseError) as error:print('Family evidence rejected: '+str(error),file=sys.stderr);raise SystemExit(1)
