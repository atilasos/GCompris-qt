#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Reconstitute historical overrides only when their complete SHA is identical."""
import argparse,datetime,hashlib,json,os,re,subprocess,tempfile,xml.etree.ElementTree as ET,zipfile
from pathlib import Path
from seal import CASES
from phase import verify_source
if not __debug__:raise SystemExit('Alignment resource validation requires assertions; Python -O rejected')
ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'.scratch/pt-pt/functional-alignment'
ORIGINAL_OUTPUT_NAMES={name:('align-ai-complete' if name in ['align-ai-old-draw-diagnostic','align-ai-preview-diagnostic','align-ai-wait-diagnostic'] else 'align-friend-complete' if name=='align-friend-draw-diagnostic' else 'align-friend-controls' if name in ['align-friend-key-diagnostic','align-friend-key-diagnostic2'] else name.replace('-parse-diagnostic','').replace('-turn-diagnostic','-red') if 'parse-diagnostic' in name or 'turn-diagnostic' in name else 'align-help-red' if name=='align-help-first-red' else 'keyboard-ai-red' if name=='keyboard-ai-initial-control' else name) for name in CASES}
ORIGINAL_OUTPUT_NAMES['keyboard-help-observation']='keyboard-help-probe'

def sha(raw):return hashlib.sha256(raw).hexdigest()
def read(path):return json.loads(path.read_text())
def reconstruct(output):
 if output.exists():raise ValueError('Use a new supplementary output directory')
 output.mkdir(parents=True);objects={};records={};canonical={};catalogues={};phases=read(BASE/'source-phases.json')
 def store(raw):
  digest=sha(raw);assert digest not in objects or objects[digest]==raw;objects[digest]=raw;return digest
 with tempfile.TemporaryDirectory(prefix='alignment exact resources ',dir=ROOT/'build') as temporary:
  work=Path(temporary);inspector=work/'rcc-inventory';cpp=ROOT/'build/alignment-sources'/phases['baseline']['revision']/'tools/pt-pt-audio/rcc_inventory.cpp'
  assert sha(cpp.read_bytes())==phases['baseline']['files']['tools/pt-pt-audio/rcc_inventory.cpp'];flags=subprocess.check_output(['pkg-config','--cflags','--libs','Qt6Core'],text=True).split();subprocess.run(['g++','-std=c++17','-fPIC',str(cpp),'-o',str(inspector),*flags],check=True)
  def inspect(path):
   destination=work/('extracted-'+sha(path.read_bytes()));destination.mkdir(exist_ok=True)
   rows=json.loads(subprocess.check_output([str(inspector),str(path),str(destination)]))
   for row in rows:
    raw=(destination/row['path'].removeprefix(':/')).read_bytes();assert sha(raw)==row['sha256'] and len(raw)==row['bytes'];store(raw)
   return {'rcc_sha256':store(path.read_bytes()),'files':rows}
  for phase,snapshot_name in [('baseline','alignment-verified'),('rules','alignment-final'),('final','alignment-keyboard')]:
   snapshot=ROOT/'build'/snapshot_name;expected=read(BASE/('identities-'+phase)/'resources.json');assert sha((snapshot/'manifest.json').read_bytes())==sha((BASE/('identities-'+phase)/'snapshot-manifest.json').read_bytes());canonical[phase]={}
   for activity,old in expected['canonical'].items():
    report=inspect(snapshot/'share/gcompris-qt/rcc'/(activity+'.rcc'));assert report==old;canonical[phase][activity]=report
  for name,contract in CASES.items():
   receipt=read(BASE/name/'result.json');phase=contract['phase'];source=ROOT/'build/alignment-sources'/phases[phase]['revision'];assert verify_source(source)==phases[phase];qml=source/'src/activities'/receipt['qml_file'];text=qml.read_text();closing=re.search(r'\n    }\s*\n}\s*$',text);assert closing
   fragment=(BASE/name/'case.qml').read_text().replace('__QA_OUTPUT__',(BASE/ORIGINAL_OUTPUT_NAMES[name]).as_posix()).replace('__QA_SOURCE__',source.as_posix());patched='import QtTest\n'+text[:closing.start()]+'\n'+fragment+text[closing.start():];instrumented=work/qml.name;instrumented.write_text(patched)
   tree=ET.Element('RCC');res=ET.SubElement(tree,'qresource',prefix='/gcompris/src/activities/'+qml.parent.name)
   for path in sorted(qml.parent.rglob('*')):
    if path.is_file():ET.SubElement(res,'file',alias=path.relative_to(qml.parent).as_posix()).text=str(instrumented if path==qml else path)
   qrc=work/'case.qrc';ET.ElementTree(tree).write(qrc,encoding='utf-8');end=int(datetime.datetime.fromisoformat(receipt['timestamp_utc']).timestamp()*1000);os.utime(instrumented,ns=(end*1000000,end*1000000));rcc=work/'case.rcc';subprocess.run(['/usr/lib/qt6/libexec/rcc','--binary',str(qrc),'-o',str(rcc)],check=True);raw=rcc.read_bytes();needle=end.to_bytes(8,'big');offset=raw.find(needle);assert offset>=0 and raw.count(needle)==1,'Expected one instrumented QML timestamp'
   matched=None
   for candidate in range(end,end-120000,-1):
    attempt=raw[:offset]+candidate.to_bytes(8,'big')+raw[offset+8:]
    if sha(attempt)==receipt['private_rcc_sha256']:matched=candidate;rcc.write_bytes(attempt);break
   assert matched is not None,'Historical complete RCC SHA not recovered: '+name
   report=inspect(rcc);instrumented_row=next(row for row in report['files'] if row['path']==':/gcompris/src/activities/'+receipt['qml_file']);assert instrumented_row['sha256']==sha(patched.encode())
   catalogue=receipt['portuguese_catalogue_sha256']
   if catalogue not in catalogues:
    ts=work/'catalogue.ts';qm=work/'catalogue.qm';subprocess.run(['/usr/lib/qt6/bin/lconvert','-target-language','pt_PT','-i',str(source/'poqm/pt/gcompris_qt.po'),'-o',str(ts)],check=True,capture_output=True);subprocess.run(['/usr/lib/qt6/bin/lrelease','-removeidentical','-nounfinished',str(ts),'-qm',str(qm)],check=True,capture_output=True);assert sha(qm.read_bytes())==receipt['private_qm_sha256'],'Historical complete QM SHA differs';decoded=work/'decoded.ts';subprocess.run(['/usr/lib/qt6/bin/lconvert','-i',str(qm),'-o',str(decoded)],check=True,capture_output=True);catalogues[catalogue]={'qm_sha256':store(qm.read_bytes()),'decoded_ts_sha256':store(decoded.read_bytes())}
   assert catalogues[catalogue]['qm_sha256']==receipt['private_qm_sha256']
   records[name]={'receipt_sha256':sha((BASE/name/'result.json').read_bytes()),'case_sha256':sha((BASE/name/'case.qml').read_bytes()),'phase':phase,'historical_output_name':ORIGINAL_OUTPUT_NAMES[name],'historical_source_root':source.as_posix(),'rcc':report,'qm_sha256':receipt['private_qm_sha256'],'catalogue_sha256':catalogue,'instrumented_qml_sha256':instrumented_row['sha256'],'recovered_qml_mtime_ms':matched,'metadata_timestamp_ms':end,'timestamp_search_window_ms':120000};print(name,'exact RCC/QM',flush=True)
  store(cpp.read_bytes())
 report={'format':1,'original_capture_sha256':sha((BASE/'capture.json').read_bytes()),'source_archive_sha256':sha((BASE/'source-tree.zip').read_bytes()),'inspector_source_sha256':sha(cpp.read_bytes()),'canonical':canonical,'catalogues':catalogues,'cases':records,'method':'Historical sources and exact cases, full RCC/QM SHA equality required. Only RCC instrumented QML mtime searched within 120 seconds before historical metadata time. Qt QResource extraction preserved without running activities.','scope':'Core and four activity canonical RCCs, every historical private instrumented RCC and Portuguese QM. Other snapshot resources remain identified by historical manifest; no new gameplay or audio approval.'}
 (output/'resources.json').write_text(json.dumps(report,indent=2)+'\n')
 with zipfile.ZipFile(output/'resources.zip','x',zipfile.ZIP_DEFLATED) as bundle:
  for digest,raw in sorted(objects.items()):
   entry=zipfile.ZipInfo('objects/'+digest,date_time=(2026,1,1,0,0,0));entry.compress_type=zipfile.ZIP_DEFLATED;bundle.writestr(entry,raw)
 print(json.dumps({'receipts':len(records),'objects':len(objects),'zip_bytes':(output/'resources.zip').stat().st_size}))
if __name__=='__main__':
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args();reconstruct(args.output.resolve())
