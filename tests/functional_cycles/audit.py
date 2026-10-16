#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Pure physical audit of finite lock, water and energy observations."""
import argparse,hashlib,json,re,sys,tarfile
from pathlib import Path,PurePosixPath
from config import CASES,PHASES,FILES,PAIRS
from lock_plan import State,step,plan
ROOT=Path(__file__).resolve().parents[2]
EXPECTED_INDEX_SHA256='d9751aa922a996aac2143a79e67ad5db6ed629e4bac4f27ea1810d987f9b70d3'
def sha(data):return hashlib.sha256(data).hexdigest()
def require(condition,message):
 if not condition:raise ValueError(message)
def near(a,b,tolerance=1):return abs(a-b)<tolerance

def check_lock(result):
 require(len(result['journeys'])==2,'One complete two-leg round trip')
 evidence=result['evidence'];initial=evidence['startup']['after'];low=initial['water']['height'];high=None
 require(initial['boat']['x']<initial['water']['x']-initial['water']['width']/2,'Boat starts outside low-side gate')
 for row in evidence['rejected']['boat']:require(near(row['boat']['x'],initial['boat']['x']) and near(row['boat']['y'],initial['boat']['y']),'Closed gate actually blocks passage')
 for row in evidence['rejected']['gate']:require(near(row['gates'][1]['height'],initial['gates'][1]['height']),'Wrong height blocks gate')
 for row in evidence['rejected']['valve']:require(near(row['valves'][1]['height'],initial['valves'][1]['height']) and near(row['water']['height'],low),'Opposite valves interlock')
 state=State();moves=0
 for leg,journey in enumerate(result['journeys']):
  goal=2 if leg==0 else 0;require(journey['destination']==('right' if leg==0 else 'left'),'Actual journey destination')
  require([row['action'] for row in journey['steps']]==plan(state,goal),'Independent shortest physical plan')
  for row in journey['steps']:
   state=step(state,row['action']);before,after=row['before'],row['after'];require(len(row['samples'])>=7 and row['samples'][-1]==after,'Natural sampled geometry settles')
   for index,opened in enumerate([state.left_gate,state.right_gate]):
    height=after['gates'][index]['height'];closed=initial['gates'][index]['height'];require(height<closed if opened else near(height,closed),'Gate geometry agrees with physical rule');require(('green' if opened else 'red') in after['lights'][index],'Drawn signal agrees with gate')
   for index,opened in enumerate([state.left_valve,state.right_valve]):
    height=after['valves'][index]['height'];closed=initial['valves'][index]['height'];require(height<closed if opened else near(height,closed),'Valve geometry agrees with plan')
   if state.water==0:require(near(after['water']['height'],low),'Low water is repeated')
   else:
    require(after['water']['height']>low+10,'Higher water is visible')
    if high is None:high=after['water']['height']
    require(near(after['water']['height'],high),'High water is repeated')
   left=after['water']['x']-after['water']['width']/2;right=after['water']['x']+after['water']['width']/2;x=after['boat']['x']
   require(x<left if state.boat==0 else x>right if state.boat==2 else left<x<right,'Boat reaches independently predicted region')
   if left<before['boat']['x']<right and abs(after['water']['height']-before['water']['height'])>10:require(near(after['boat']['y']-before['boat']['y']+after['water']['height']-before['water']['height'],0,2),'Floating boat follows changing water')
   moves+=1
  require(state.boat==goal,'Destination reached')
 require(evidence['bonusCount']==1 and evidence['completeRoundTrip'],'Collecting logs produces one Bonus; return leg is distinct')
 require(result['journeys'][0]['final']['boat']['source'].endswith('boat2.svg') and result['journeys'][1]['final']['boat']['source'].endswith('boat1.svg'),'Logs loaded then unloaded')
 return moves

def check_water(result):
 e=result['evidence'];stages=e['stages'];names=['initial','evaporation','cloud','rain','river','pumping','treatment','ready','success','continued'];require([r['name'] for r in stages]==names,'Complete visible water cycle')
 require(all(b['timestamp']>=a['timestamp'] for a,b in zip(stages,stages[1:])),'Ordered real observations');v={r['name']:r['view'] for r in stages}
 require(len(e['intro'])==4 and e['dryPumpRejected'],'Four intro pages and actual dry pump rejection')
 require(v['initial']['fill']['opacity']<0.3 and not v['initial']['bath']['visible'],'No initial supplied water or bath')
 require(v['evaporation']['vapor']['opacity']>0.9,'Drawn evaporation');require(v['cloud']['cloud']['opacity']>0.9 and v['cloud']['cloud']['width']>0,'Drawn cloud');require(v['rain']['rain']['opacity']>0.9 and v['river']['river']['opacity']==1,'Rain fills visible river')
 require(v['pumping']['fill']['opacity']>0.9 and v['treatment']['waste']['opacity']>0.9,'Visible supply and wastewater pipes')
 require(v['ready']['tower']['scale']>=0.99 and v['ready']['shower']['visible'] and v['ready']['parked']['opacity']>0.9,'Stored water and home arrival precede shower')
 require(v['success']['bath']['visible'] and 'good' in e['bonus'] and e['cycleComplete'],'Actual bathing and natural Bonus')
 require('ciclo' in v['success']['instruction'].lower(),'Drawn completion instruction')
 return 1

def check_energy(result):
 rows=result['levels'];require([r['level'] for r in rows]==[1,2,3],'All three energy levels')
 require(len(result['evidence']['intro'])==4,'All energy intro pages')
 for index,row in enumerate(rows):
  wrong=row['wrong'];good=row['success']['view'];require(wrong['switches'][index]['source'].endswith('/off.svg'),'Insufficient supply refuses the actual consumer')
  require('good' in row['success']['bonus'] and good['level']==index and good['total']==3,'Natural level Bonus and public contract')
  generators=good['hydro']+good['wind']+good['solar'];require(len(generators)==index+1,'All unlocked generator meters observed')
  for meter in generators+[good['produced'],good['consumed']]:require(meter['text']==str(meter['watts'])+'W' and meter['watts']>=0,'Arithmetic uses only painted watts')
  total=sum(m['watts'] for m in generators);require(all(m['watts']>0 for m in generators) and good['produced']['watts']==total,'Independent sum of all generation');require(0<good['consumed']['watts']<=total,'No excess consumption')
  require(all(s['source'].endswith('/on.svg') for s in good['switches'][:index+1]),'Required consumers enabled after repair')
  require(all(light['visible'] for light in good['lights'][:index+1]),'Actual lights drawn')
 expiry=result['evidence']['windExpiry'];require(result['evidence']['lastLevelStays'] and expiry['level']==2,'Final level stays available');require(expiry['wind'][0]['watts']==0 and expiry['switches'][2]['source'].endswith('/off.svg'),'Natural wind expiry sheds the large consumer');require(expiry['consumed']['watts']<=expiry['produced']['watts'],'Load remains below remaining generation')
 return 3

def audit(base):
 def read(path):return json.loads((base/path).read_text())
 require(sha((base/'index.json').read_bytes())==EXPECTED_INDEX_SHA256,'Immutable historical index')
 index=read('index.json');require(index['cases']==CASES and index['phases']==PHASES and len(CASES)==18,'Exact nonempty historical case/phase set')
 for relative,digest in index['files'].items():
  path=PurePosixPath(relative);require(not path.is_absolute() and '..' not in path.parts,'Relative physical path');target=base/relative;require(not target.is_symlink() and target.resolve().is_relative_to(base.resolve()),'Physical evidence stays inside archive');require(sha(target.read_bytes())==digest,'Physical bytes: '+relative)
 sources={}
 for phase,revision in PHASES.items():
  manifest=read('sources/'+phase+'/source-manifest.json');require(manifest['revision']==revision,'Historical phase revision');raw={}
  with tarfile.open(base/'sources'/phase/'source.tar.xz','r:xz') as archive:
   for entry in archive.getmembers():
    path=PurePosixPath(entry.name);require(entry.isfile() and not path.is_absolute() and '..' not in path.parts and entry.name not in raw,'Regular unique source member');raw[entry.name]=archive.extractfile(entry).read()
  require({p:sha(b) for p,b in raw.items()}==manifest['files'],'Complete physical source capsule');sources[phase]=raw
 snapshot=read('snapshot-manifest.json');require(len(snapshot['files'])==269,'Sealed full runtime inventory');resources=read('qt-resources.json');images=read('resource-cases/images.json');controls=0;image_count=0;diagnostics=0
 for name,description in CASES.items():
  activity=description['activity'];phase=description['phase'];source=sources[phase];native=read(name+'/result.json');status=read(name+'/launcher-status.json');tool=read(name+'/tool-status.json');case=(base/name/'case.qml').read_bytes();expected=description.get('expected_exit',0);result=native['case_result']
  require(native['activity']==activity and native['locale']=='pt_PT' and native['network']=='docker-none','Correct offline activity/locale');require(native['runtime_uid']==1000 and native['runtime_gid']==1000,'Observed unprivileged native user')
  require(native['exit_code']==0 and not native['timeout'] and not native['qml_errors'],'Actual clean Qt process exit')
  require(status['kind']=='observed-subprocess-exit' and tool['kind']=='observed-supervisor-return-after-wait' and status['exit_code']==tool['exit_code']==expected,'Observed independent post-wait returns')
  require(status['native_receipt_sha256']==tool['native_receipt_sha256']==sha((base/name/'result.json').read_bytes()),'Raw receipt binds both observations');require(tool['launcher_status_sha256']==sha((base/name/'launcher-status.json').read_bytes()),'Observed supervisor bytes')
  require(status['case_sha256']==tool['case_sha256']==native['case_sha256']==sha(case),'Exact executed physical case');require(tool['capture_sha256']==sha((base/'execution-tools/capture.py').read_bytes()),'Observed capturing process source')
  require(status['launcher_sha256']==native['runner_sha256']==sha(source['tools/run-native-qml-case.py']),'Historical native launcher');require(native['source_sha256']==sha(source['src/activities/'+activity+'/'+FILES[activity]]) and native['portuguese_catalogue_sha256']==sha(source['poqm/pt/gcompris_qt.po']),'Historical QML and PO')
  require(native['private_qm_sha256']==sha((base/'catalogue'/(phase+'.qm')).read_bytes()),'Physical effective compiled catalogue')
  expected_files=dict(snapshot['files']);expected_files['share/gcompris-qt/rcc/'+activity+'.rcc']=native['private_rcc_sha256'];expected_files['share/gcompris-qt/translations/gcompris_qt_pt.qm']=native['private_qm_sha256'];require(native['resource_files_sha256']==expected_files and native['resource_manifest_sha256']==sha((base/'snapshot-manifest.json').read_bytes()) and native['binary_sha256']==snapshot['files']['bin/gcompris-qt'],'Complete effective runtime identity')
  effective=resources['effective'][name];require(sha((base/'effective'/name/'activity.rcc').read_bytes())==native['private_rcc_sha256']==effective['rcc_sha256'],'Physical actual private RCC')
  expected_paths={p for p in source if p.startswith('src/activities/'+activity+'/')};require({r['path'].removeprefix(':/gcompris/') for r in effective['files']}==expected_paths,'Complete effective activity contents')
  for row in effective['files']:
   path=row['path'].removeprefix(':/gcompris/');wanted=source[path];actual=(base/'effective'/name/'files'/path).read_bytes()
   if path=='src/activities/'+activity+'/'+FILES[activity]:
    text=wanted.decode();closing=re.search(r'\n    }\s*\n}\s*$',text);fragment=case.decode().replace('__QA_OUTPUT__',effective['runtime_output']).replace('__QA_SOURCE__',effective['runtime_source']);wanted=('import QtTest\n'+text[:closing.start()]+'\n'+fragment+text[closing.start():]).encode()
   require(actual==wanted and sha(actual)==row['sha256'] and len(actual)==row['bytes'],'Exact physical resource and historical instrumentation')
  markers=re.findall(r'^qml: NATIVE_RESULT (\{.*\})$',(base/name/'native.log').read_text(),re.M);require(len(markers)==1 and json.loads(markers[0])==result,'Actual Qt marker equals raw receipt')
  for screenshot in native['screenshots']:require(sha((base/name/screenshot['file']).read_bytes())==screenshot['sha256'],'Actual native screenshot')
  require(native['passed']==(expected==0) and result['failures']==(1 if expected else 0) and result['passes']>=1,'Clean QtTest verdict distinct from process return')
  if expected:
   if description['kind']=='fixture-diagnostic':diagnostics+=1
   continue
  if description['kind']=='gameplay':
   if activity=='canal_lock':check_lock(result)
   elif activity=='watercycle':check_water(result)
   else:check_energy(result)
  elif description['kind']=='controls':
   e=result['evidence'];require(e['escape'] and e['inputAfterHelp'] and e['menu'] and e['menuDuringMotion'],'Real help/escape/input/menu');word={'canal_lock':'eclusa','watercycle':'água','renewable_energy':'energia'}[activity];require(word in e['help']['content'],'Drawn Portuguese help')
   if activity=='canal_lock':require(e['menuDuringMotion']['moving']['x']>e['menuDuringMotion']['before']['x']+2,'Menu during actual boat movement')
   else:
    require(e['partialRestart'] and e['partial']['vapor']['opacity']>0.9 and e['restarted']['vapor']['opacity']==0,'Visible partial process reset')
    if activity=='watercycle':require(e['restarted']['cloud']['opacity']==0 and e['restarted']['tower']['source'].endswith('watertowerfill.svg'),'Recorded cloud reset and tower identity')
    else:require(e['navigation'] and not e['restarted']['transformer']['visible'],'Energy navigation and transformer reset')
   controls+=1
  elif description['kind']=='resources':
   observed=result['resources'];require([r['path'] for r in observed]==images[activity] and observed,'Exact nonempty canonical image set')
   for row in observed:require(row['url']=='qrc'+row['path'] and row['status']==1 and row['width']>0 and row['height']>0,'Real Qt image loading')
   image_count+=len(observed)
  elif description['kind']=='wording-green':
   e=result['evidence']
   if activity=='canal_lock':require('eclusa' in e['intro'][0] and 'válvulas' in e['intro'][1] and 'dentro da eclusa' in e['intro'][2] and 'eclusa' in e['help']['title'],'Actual corrected lock terminology')
   else:require('Quando o Tux estiver em casa' in e['intro'][3] and 'torre tiver água' in e['intro'][3] and 'antes do Tux' not in e['intro'][3],'Actual shower prerequisites replace false deadline')
 canonical={}
 for name,observation in resources['canonical'].items():
  require(observation['rcc_sha256']==snapshot['files']['share/gcompris-qt/rcc/'+name+'.rcc']==sha((base/'canonical'/name/'resource.rcc').read_bytes()),'Physical canonical RCC and sealed snapshot')
  for row in observation['files']:
   path=row['path'].removeprefix(':/gcompris/');raw=(base/'canonical'/name/'files'/path).read_bytes();require(sha(raw)==row['sha256'] and len(raw)==row['bytes'],'Physical actual canonical extraction');canonical[row['path']]=raw
   if path in sources['baseline']:require(raw==sources['baseline'][path],'Canonical asset/source equals frozen source')
 for paths in images.values():require(set(paths)<=set(canonical),'All loaded images belong to physically preserved canonical resources')
 audio=resources['audio_decode'];expected_audio={p for p in canonical if Path(p).suffix.lower() in ['.wav','.ogg']};require({':/gcompris/'+r['path'] for r in audio}==expected_audio and len(audio)==21,'All selected sound files decoded')
 for row in audio:require(row['exit_code']==0 and row['sha256']==sha(canonical[':/gcompris/'+row['path']]) and row['argv'][0]=='gst-launch-1.0' and row['argv'][-1]=='fakesink','Actual observed decoding without hearing claim')
 for red,green in PAIRS:require((base/red/'case.qml').read_bytes()==(base/green/'case.qml').read_bytes(),'Identical real red/green case')
 require(controls==3 and image_count==110 and diagnostics==5,'Exact control/resource/diagnostic scope')
 return {'passed':True,'canal_round_trips':1,'canal_legs':2,'water_cycles':1,'energy_levels':3,'blocked_actions_repaired':7,'controls':controls,'native_receipts':18,'wording_pairs':2,'fixture_diagnostics':diagnostics,'image_loads':image_count,'unique_images':len(set(p for rows in images.values() for p in rows)),'decoded_audio_files':len(audio),'scope':'Finite Linux offline simulations; no exhaustive free-play permutations, Windows, hearing, hardware, teacher or stability acceptance'}

def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--evidence',type=Path,default=ROOT/'.scratch/pt-pt/functional-cycles');args=parser.parse_args()
 try:print(json.dumps(audit(args.evidence),indent=2))
 except (ValueError,OSError,KeyError,TypeError,tarfile.TarError) as error:print('Cycle evidence rejected: '+str(error),file=sys.stderr);return 1
 return 0
if __name__=='__main__':raise SystemExit(main())
