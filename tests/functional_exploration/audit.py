#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Verify physical task-84 observations without Git, Qt or original paths."""
import argparse,hashlib,json,re,tarfile
from pathlib import Path
from curriculum import COUNTS,AUDIO,text_target
HISTORICAL_INDEX_SHA256 = 'b0e234b0267060428c1b1bbc62b3cac0045456e0b7f95fc5ceff7c9c96a0d720'
def digest(raw):return hashlib.sha256(raw).hexdigest()
def require(ok,message):
 if not ok:raise ValueError(message)
def data(path):return json.loads(path.read_text())
def unpack(path):
 with tarfile.open(path,'r:xz') as tar:
  members=tar.getmembers();require(members and all(m.isfile() and not m.name.startswith('/') and '..' not in Path(m.name).parts for m in members),'Unsafe/empty capsule');require(len({m.name for m in members})==len(members),'Duplicate capsule entries')
  return {m.name:tar.extractfile(m).read() for m in members}
def audit(base):
 index_path=base/'sealed.json';require(not index_path.is_symlink() and digest(index_path.read_bytes())==HISTORICAL_INDEX_SHA256,'Historical archive index differs from external anchor');seal=data(index_path)
 require(seal and all(not (base/p).is_symlink() and (base/p).is_file() and digest((base/p).read_bytes())==h for p,h in seal.items()),'Physical archive bytes')
 evidence=data(base/'evidence.json');snapshot=data(base/'snapshot-manifest.json');sources={}
 for phase,expected in evidence['sources'].items():
  source=unpack(base/'sources'/(phase+'.tar.xz'));require({p:digest(raw) for p,raw in source.items()}==expected,'All frozen source bytes');sources[phase]=source
 require(set(sources)=={'baseline','pt-final','reviewed'},'All historical phases')
 for phase in ['pt-final','reviewed']:
  require(set(sources[phase])==set(sources['baseline']) and all(raw==sources['baseline'][p] for p,raw in sources[phase].items() if p!='poqm/pt/gcompris_qt.po'),'Production changes restricted to the PT catalogue')
 lessons_reference=data(base/'lessons.json');require(len(lessons_reference)==98,'All independently inspected lesson/photo identities');reviews={r['image']:r for r in data(base/'language-review.json')};help_review=data(base/'help-review.json');pairs={};campaigns={};controls=set();page_count=question_count=wrong_count=0;played=set()
 require(len(evidence['runs'])==20,'Twenty selected native runs')
 for name,record in evidence['runs'].items():
  folder=base/'runs'/name;native=data(folder/'result.json');case=(folder/'case.qml').read_bytes();phase=record['phase'];source=sources[phase];expected_exit=record['expected_exit']
  require(native['exit_code']==0 and not native['timeout'] and not native['qml_errors'] and native['network']=='docker-none' and native['private_file_ownership_verified'],'Clean offline native Qt exit')
  require(native['case_sha256']==digest(case) and native['activity']==record['activity'],'Executed case/activity identity')
  require(native['source_sha256']==digest(source['src/activities/explore_farm_animals/ExploreLevels.qml']) and native['portuguese_catalogue_sha256']==digest(source['poqm/pt/gcompris_qt.po']),'Frozen QML and Portuguese catalogue')
  launcher=data(folder/'launcher-status.json');supervisor=data(folder/'supervisor-status.json');tool=data(folder/'tool-status.json')
  for status in [launcher,supervisor,tool]:require(status['exit_code']==expected_exit and status['native_receipt_sha256']==digest((folder/'result.json').read_bytes()),'Observed subprocess return linked to native receipt')
  require(tool['kind']=='observed-runner-exit-after-wait' and launcher['kind']==supervisor['kind']=='observed-subprocess-exit','Actual return provenance')
  require(launcher['case_sha256']==tool['case_sha256']==digest(case) and launcher['launcher_sha256']==native['runner_sha256']==digest(source['tools/run-native-qml-case.py']),'Historical launcher and case')
  require(supervisor['supervisor_sha256']==digest(source['tools/run-native-qml-supervised.py']) and tool['runner_sha256']==supervisor['runner_sha256']==digest((folder/'execution-run.py').read_bytes()) and tool['capture_sha256']==digest((folder/'execution-capture.py').read_bytes()),'Physical execution tools')
  require(native['resource_manifest_sha256']==digest((base/'snapshot-manifest.json').read_bytes()) and native['binary_sha256']==snapshot['files']['bin/gcompris-qt'],'Independent snapshot manifest/binary')
  runtime=dict(snapshot['files']);runtime['share/gcompris-qt/rcc/explore_farm_animals.rcc']=record['rcc'];runtime['share/gcompris-qt/translations/gcompris_qt_pt.qm']=record['qm'];require(native['resource_files_sha256']==runtime,'Complete effective resource set')
  for key,native_key in [('rcc','private_rcc_sha256'),('qm','private_qm_sha256')]:require(record[key]==native[native_key]==digest((base/'blobs'/record[key]).read_bytes()),'Physical loaded '+key)
  extracted=unpack(base/'effective'/(name+'.tar.xz'));require(record['export_exit']==0 and {r['path'][2:] for r in record['resources']}==set(extracted),'All actual Qt-extracted activity resources')
  expected_paths={p for p in source if p.startswith('src/activities/explore_farm_animals/')};require({p.removeprefix('gcompris/') for p in extracted}==expected_paths,'Complete actual activity source set')
  for row in record['resources']:
   path=row['path'][2:];raw=extracted[path];wanted=source[path.removeprefix('gcompris/')]
   if path.endswith('/ExploreLevels.qml'):
    text=wanted.decode();closing=re.search(r'\n    }\s*\n}\s*$',text);fragment=case.decode().replace('__QA_OUTPUT__',record['runtime_output']).replace('__QA_SOURCE__',record['runtime_source']);wanted=('import QtTest\n'+text[:closing.start()]+'\n'+fragment+text[closing.start():]).encode()
   require(raw==wanted and digest(raw)==row['sha256'] and len(raw)==row['bytes'],'Exact frozen source and historical instrumentation')
  for image in native['screenshots']:
   raw=(folder/image['file']).read_bytes();require(digest(raw)==image['sha256'] and len(raw)==image['bytes'] and raw.startswith(b'\x89PNG\r\n\x1a\n'),'Physical native screenshot')
  markers=re.findall(r'^qml: NATIVE_RESULT (\{.*\})$',(folder/'native.log').read_text(),re.M);require(len(markers)==1 and json.loads(markers[0])==native['case_result'],'Raw observed Qt result')
  result=native['case_result'];require(result['failures']==expected_exit and result['passes']>0 and native['passed']==(expected_exit==0),'Native QtTest assertion outcome')
  if 'pair' in record:pairs.setdefault(record['pair'],[]).append((expected_exit,case))
  if record['kind']=='language':
   pages=result['pages'];require(len(pages)==sum(COUNTS[record['activity']]),'Every language presentation, not an empty sample')
   relevant=[p for p in pages if p['image'] in reviews];require(relevant,'Nonempty reviewed pages')
   if not expected_exit:require(all(p['title']==reviews[p['image']]['title'] and p['description']==reviews[p['image']]['description'] for p in relevant),'Exact corrected visible PT strings')
   continue
  if record['kind']=='help-red':continue
  if record['kind']=='controls':
   e=result['evidence'];require(all(e.get(k) is True for k in ['focusAfterHelp','partialReload','phaseNavigation','wrap','unsupportedKeyIgnored','menu']) and e['configurationOffered'] is False,'Real offered controls, focus and menu')
   require(e['help']['title'] and e['help']['content'],'Actual Portuguese help')
   for row in help_review:
    if row['activity']==record['activity']:require(row['new'] in e['help']['content'] and row['old'] not in e['help']['content'],'Correct Portuguese help semantics')
   controls.add(record['activity']);continue
  pages=result['pages'];questions=result['questions'];counts=COUNTS[record['activity']];audio=record['activity'] in AUDIO
  require(len(pages)==sum(counts) and len(questions)==sum(counts)*(2 if audio else 1),'Full lesson/question inventory')
  require(result['evidence']['wins']==len(counts)*(3 if audio else 2) and result['evidence']['naturalWrap'] is True,'Every natural Bonus and final wrap')
  for map_number,count in enumerate(counts,1):
   lessons=[p for p in pages if p['map']==map_number];require(len(lessons)==count and len({p['image'] for p in lessons})==count and len({p['title'] for p in lessons})==count,'Every distinct visible lesson')
   for lesson in lessons:
    reference=[p for p in lessons_reference if p['activity']==record['activity'] and p['map']==map_number and p['image']==lesson['image']];require(len(reference)==1,'Known reviewed presentation/photo identity')
    if not expected_exit:require(lesson['title']==reference[0]['title'] and lesson['description']==reference[0]['description'] and abs(lesson['x']-reference[0]['x'])<.005 and abs(lesson['y']-reference[0]['y'])<.005,'Independently inspected lesson label, photograph and map position')
    if lesson['image'] in reviews and not expected_exit:require(lesson['title']==reviews[lesson['image']]['title'] and lesson['description']==reviews[lesson['image']]['description'],'Reviewed lesson meaning and spelling')
    require(lesson['title'] and lesson['description'] and lesson['mapImage'].startswith('qrc:/') and 0<lesson['x']<1 and 0<lesson['y']<1,'Painted learning location and PT facts')
   for stage in ([2,3] if audio else [2]):
    rows=[q for q in questions if q['map']==map_number and q['stage']==stage];require(len(rows)==count and [q['before'] for q in rows]==list(range(count)) and [q['after'] for q in rows]==list(range(1,count+1)),'Every public score increment')
    require({q['selected'] for q in rows}=={p['title'] for p in lessons},'Every taught answer exactly once')
    for q in rows:
     if q['kind']=='audio':
      targets=[p for p in lessons if p['audio']==q['audio']];require(len(targets)==1,'Question audio was actually taught');target=targets[0]
     else:target=text_target(q['prompt'],lessons)
     require(q['selected']==target['title'] and abs(q['x']-target['x'])<.005 and abs(q['y']-target['y'])<.005,'Independent taught meaning and real map location')
     if 'wrong' in q:require(q['wrong']['selected']!=target['title'] and q['wrong']['unchanged'] is True,'Wrong response refused before repair')
    require('wrong' in rows[0] and (rows[0].get('repeated') is True if audio and stage==2 else True),'Wrong/repair and offered repeat control')
    transition=[t for t in result['transitions'] if t['map']==map_number and t['stage']==stage];require(len(transition)==1 and transition[0]['natural'] is True,'Natural next stage/map')
  if record['kind']=='question-language':continue
  require(record['kind']=='gameplay' and record['activity'] not in campaigns,'One final full campaign per activity');campaigns[record['activity']]=result
  page_count+=len(pages);question_count+=len(questions);wrong_count+=sum('wrong' in q for q in questions);played.update(result.get('playbacks',[]));played.update(p['audio'] for p in pages if p['audio'])
 require(set(campaigns)==set(controls)==set(COUNTS) and page_count==98 and question_count==116 and wrong_count==16,'All four activities, all stages and required negatives')
 require(len(pairs)==7 and all(len(p)==2 and {x[0] for x in p}=={0,1} and p[0][1]==p[1][1] for p in pairs.values()),'Seven identical red/green pairs')
 for name,record in evidence['imports'].items():
  require(record['rcc']==snapshot['files']['share/gcompris-qt/rcc/'+name+'.rcc']==digest((base/'blobs'/record['rcc']).read_bytes()),'Physical imported RCC')
  files=unpack(base/'effective'/('import-'+name+'.tar.xz'));require(set(files)=={r['path'][2:] for r in record['resources']},'Complete imported extraction')
  for row in record['resources']:
   raw=files[row['path'][2:]];require(digest(raw)==row['sha256'] and len(raw)==row['bytes'],'Physical imported Qt bytes')
   source_path=row['path'][2:].removeprefix('gcompris/')
   if name in COUNTS:require(source_path in sources['baseline'] and raw==sources['baseline'][source_path],'Actual shared activity import matches frozen source')
 require(set(played)=={a['resource'] for a in evidence['audio']} and len(evidence['audio'])>=18,'Every actually observed played resource')
 approved=data(base/'teacher-approval-32.json')['recordings']
 for audio in evidence['audio']:
  raw=(base/'blobs'/audio['blob']).read_bytes();require(digest(raw)==audio['blob'] and raw.startswith(b'OggS') and audio['decode_exit']==0 and audio['human_listening'] is False,'Actual playable audio bytes; no inferred human approval')
  key=audio['resource'].split('/voices-ogg/pt/',1)[-1] if '/voices-ogg/pt/' in audio['resource'] else None;require(audio['approved32_match']==(key in approved and approved[key]['sha256']==audio['blob']),'Approval applies only to the exact manifest bytes')
 voice=evidence['voice_import'];voice_rows={r['path'][2:]:r for r in voice['resources']}
 for audio in evidence['audio']:
  relative=audio['resource'].removeprefix('qrc:/')
  if '/voices-ogg/pt/' in audio['resource']:require(relative in voice_rows and voice_rows[relative]['sha256']==audio['blob'],'Selected actual voice export')
 voice=evidence['voice_import'];require(voice['rcc']==snapshot['files'][voice['file']]==digest((base/'blobs'/voice['rcc']).read_bytes()) and voice['export_exit']==0,'Actually registered voice package')
 return {'activities':4,'maps':14,'presentations':page_count,'questions':question_count,'wrong_repaired':wrong_count,'natural_bonus':30,'red_green_pairs':7,'controls':4,'decoded_audio':len(evidence['audio']),'human_audio_approved':sum(a['approved32_match'] for a in evidence['audio']),'scope':'Linux/software/offline; Windows, hardware, human listening and teacher acceptance pending'}
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--evidence',type=Path,default=Path(__file__).resolve().parents[2]/'.scratch/pt-pt/functional-exploration/archive');a=p.parse_args();print(json.dumps(audit(a.evidence)))
