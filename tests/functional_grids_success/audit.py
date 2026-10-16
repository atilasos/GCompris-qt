#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Portable supplemental physical proof of real menu after natural success."""
import argparse,hashlib,json,re,zipfile,xml.etree.ElementTree as ET
from pathlib import Path,PurePosixPath
from oracle import from_screen,valid
if not __debug__:raise SystemExit('Success validation requires assertions; Python -O rejected')
CAPTURE_SHA='cf4a74a7c18017e3522a5e5c28172442e342ddb79c2618b541dc976333d5c4be'
ORIGINAL_SHA='d5332fa4e421521e55a67e1e3da85790e64716fefd5055a5005a67865603a8e7'
def sha(raw):return hashlib.sha256(raw).hexdigest()
def audit(root):
 raw=(root/'capture.json').read_bytes();assert sha(raw)==CAPTURE_SHA,'Immutable success capsule changed';c=json.loads(raw);assert c['original_capture_sha256']==ORIGINAL_SHA and c['menu_after_success'] and set(c['cases'])=={'sudoku','calcudoku'}
 with zipfile.ZipFile(root/'objects.zip') as z:
  assert len(z.namelist())==len(set(z.namelist()))==len(c['objects']) and set(z.namelist())=={'objects/'+s for s in c['objects']};objects={s:z.read('objects/'+s) for s in c['objects']}
 for s,raw in objects.items():assert sha(raw)==s,'Physical bytes altered'
 used=set()
 def blob(s):used.add(s);return objects[s]
 def file(n):
  p=PurePosixPath(n);assert not p.is_absolute() and '..' not in p.parts;return blob(c['files'][n])
 def js(n):return json.loads(file(n))
 for n in c['files']:file(n)
 assert sha(Path(__file__).with_name('oracle.py').read_bytes())==c['files']['harness/oracle.py']
 phase=c['phase'];sources=phase['source']['files'];assert phase['revision']==phase['source']['revision']=='d740510aa8a87611d28e4776e64c8345fc4b2a64'
 for s in sources.values():blob(s)
 snapshot_raw=blob(phase['snapshot_manifest']);snapshot=json.loads(snapshot_raw);assert len(snapshot['files'])==269
 def rcc(report,patched=None,activity=None,prefix=None):
  assert blob(report['rcc_sha256']).startswith(b'qres');wanted={n for n in sources if n.startswith('src/core/' if activity=='core' else 'src/activities/'+activity+'/')};assert {r['path'] for r in report['files']}=={':/gcompris/'+n for n in wanted}
  qml='src/activities/'+str(activity)+'/'+('Sudoku.qml' if activity=='sudoku' else 'Calcudoku.qml')
  for row in report['files']:
   raw=blob(row['sha256']);name=row['path'].removeprefix(':/gcompris/');assert len(raw)==row['bytes'] and raw==(patched if patched is not None and name==qml else blob(sources[name]))
   if prefix:assert raw==file(prefix+'resources/extracted/'+row['path'].removeprefix(':/'))
 for a,report in phase['canonical'].items():assert report['rcc_sha256']==snapshot['files']['share/gcompris-qt/rcc/'+a+'.rcc'];rcc(report,activity=a)
 boards=0
 for activity,contract in c['cases'].items():
  pre='cases/'+activity+'/';r=js(pre+'result.json');s=js(pre+'launcher-status.json');outer=js(pre+'supervisor-exit.json');tool=js(pre+'tool-exit.json');physical=js(pre+'resources/physical.json');arithmetic=activity=='calcudoku';qml='src/activities/'+activity+'/'+('Calcudoku.qml' if arithmetic else 'Sudoku.qml')
  assert r['exit_code']==s['exit_code']==outer['exit_code']==tool['exit_code']==0 and r['passed'] and not r['timeout'] and not r['qml_errors'] and r['private_file_ownership_verified'] and r['deployment_retained'] and r['runtime_uid']==r['runtime_gid']==1000 and r['network']=='docker-none' and r['locale']=='pt_PT'
  assert s['kind']=='observed-subprocess-exit' and outer['kind']=='observed-supervisor-subprocess-exit' and tool['kind']=='observed-exec-tool-return' and tool['session_id']>0 and tool['chunk_id']
  assert s['native_receipt_sha256']==outer['native_receipt_sha256']==tool['native_receipt_sha256']==sha(file(pre+'result.json')) and outer['launcher_status_sha256']==tool['launcher_status_sha256']==sha(file(pre+'launcher-status.json'))
  assert r['case_sha256']==s['case_sha256']==outer['case_sha256']==tool['case_sha256']==sha(file(pre+'case.qml'))==c['files']['harness/'+activity+'.qml']
  assert r['source_sha256']==sources[qml] and r['runner_sha256']==s['launcher_sha256']==sources['tools/run-native-qml-case.py'] and outer['supervisor_sha256']==sources['tools/run-native-qml-supervised.py'] and r['portuguese_catalogue_sha256']==sources['poqm/pt/gcompris_qt.po']
  assert r['resource_manifest_sha256']==sha(snapshot_raw);effective=dict(snapshot['files']);effective['share/gcompris-qt/rcc/'+activity+'.rcc']=r['private_rcc_sha256'];effective['share/gcompris-qt/translations/gcompris_qt_pt.qm']=r['private_qm_sha256'];assert effective==r['resource_files_sha256'] and r['binary_sha256']==snapshot['files']['bin/gcompris-qt']
  assert physical['rcc_sha256']==r['private_rcc_sha256']==sha(file(pre+'resources/'+activity+'.rcc')) and physical['qm_sha256']==r['private_qm_sha256']==sha(file(pre+'resources/gcompris_qt_pt.qm')) and physical['inspector_source_sha256']==sources['tools/pt-pt-audio/rcc_inventory.cpp']
  assert file(pre+'resources/gcompris_qt_pt.qm').startswith(bytes.fromhex('3cb86418caef9c95cd211cbf60a1bddd')) and physical['catalogue_ts_sha256']==sha(file(pre+'resources/catalogue.ts')) and ET.fromstring(file(pre+'resources/catalogue.ts')).tag=='TS'
  text=blob(sources[qml]).decode();closing=re.search(r'\n    }\s*\n}\s*$',text);fragment=file(pre+'case.qml').decode().replace('__QA_OUTPUT__',contract['historical_output']).replace('__QA_SOURCE__',phase['historical_source_root']);patched=('import QtTest\n'+text[:closing.start()]+'\n'+fragment+text[closing.start():]).encode();rcc(physical,patched,activity,pre)
  for image in r['screenshots']:assert sha(file(pre+image['file']))==image['sha256']
  e=r['case_result']['evidence'];assert r['case_result']['failures']==0 and len(e['levels'])==1 and e['dataset']==1
  level=e['levels'][0];total=20 if arithmetic else 5;ordinal=1 if arithmetic else 2;assert level['level']==ordinal and level['total']==len(level['boards'])==total
  def values(screen,initial):
   n=initial['size'];palette=[p['source'] for p in initial['palette']];v=[0]*(n*n)
   for cell in screen['cells']:
    if cell['source']:v[round(cell['y']/cell['height'])*n+round(cell['x']/cell['width'])]=int(cell['source'].rsplit('/',1)[-1].removesuffix('.svg')) if arithmetic else palette.index(cell['source'])+1
   return v
  def move(m,current,p):
   assert m['before']==current and m['input'] in ['click','key'] and not p['givens'][m['cell']];expected=current.copy();expected[m['cell']]=m['value'];assert m['after']==expected;return expected
  for i,b in enumerate(level['boards']):
   p=from_screen(b['initial'],arithmetic);assert p==b['puzzle'] and p['n']==3 and valid(p,b['solution']) and b['initial']['level']==ordinal and b['initial']['score']==[str(i)+'/'+str(total)];current=p['givens'].copy()
   if i==0:
    err=b['error']
    if err['preparation']:current=move(err['preparation'],current,p)
    w=err['attempt'];assert w['before']==w['after']==current and '#eb7878' in w['colors'] and any(current[j]==w['value'] and (j//3==w['cell']//3 or j%3==w['cell']%3) for j in range(9) if j!=w['cell']);assert err['clearing'] is None;current=move(err['repair'],current,p)
   assert values(b['afterError'],b['initial'])==current
   for m in b['moves']:current=move(m,current,p)
   assert current==values(b['completed'],b['initial'])==b['solution'] and valid(p,current) and b['scoreAfter']==[i+1,total];boards+=1
  assert level['bonus']['opacity']>0.5 and level['bonus']['source'].endswith('/flower_good.svg') and level['continuation']['score'][0].startswith('0/') and level['continuation']['level']==ordinal%(1 if arithmetic else 3)+1
  assert e['afterSuccess']['level']==level['continuation']['level'] and e['afterSuccess']['score'][0].startswith('0/') and e['menu']=={'isMenu':True,'depth':1};assert file(pre+'menu-after-success.png').startswith(b'\x89PNG')
 assert boards==25 and used==set(objects)
 return {'cases':2,'boards_repeated':boards,'natural_bonus':2,'stable_menu_after_success':2,'unique_coverage_added':0,'physical_rcc_qm_pairs':2}
if __name__=='__main__':
 parser=argparse.ArgumentParser();parser.add_argument('--capsule',type=Path,default=Path(__file__).resolve().parents[2]/'.scratch/pt-pt/functional-grids-success/capsule');args=parser.parse_args()
 try:print(json.dumps(audit(args.capsule),indent=2))
 except (AssertionError,KeyError,ValueError,OSError,zipfile.BadZipFile) as e:raise SystemExit('Success evidence rejected: '+str(e))
