#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit exact physical RCC/QM overrides and Qt extractions beside old evidence."""
import argparse,hashlib,io,json,re,sys,zipfile,xml.etree.ElementTree as ET
from pathlib import Path,PurePosixPath
import audit as historical
if not __debug__:raise SystemExit('Alignment resources require assertions; Python -O rejected')
ROOT=Path(__file__).resolve().parent.parent.parent
RESOURCE_CAPTURE_SHA='9799d3bb76d7a6f92382a18fbf7cb5f9d57ec3880d3e8c75062e651ae089c343'

def sha(raw):return hashlib.sha256(raw).hexdigest()
def safe(name):
 path=PurePosixPath(name);assert not path.is_absolute() and '..' not in path.parts and str(path)==name,'Unsafe resource path'
def verify(original,supplement):
 summary=historical.audit(original);raw=(supplement/'capture.json').read_bytes();assert sha(raw)==RESOURCE_CAPTURE_SHA,'Immutable supplemental capture changed';capture=json.loads(raw)
 for name,digest in capture['files'].items():
  safe(name);path=supplement/name;assert not any(p.is_symlink() for p in [path,*path.parents]);assert sha(path.read_bytes())==digest,'Physical supplementary artifact changed '+name
 tool=json.loads((supplement/'tool-reconstruction.json').read_text());assert tool['kind']=='observed-exec-tool-return' and tool['exit_code']==0 and tool['session_id']==68122 and tool['chunk_id']=='d5bbec' and tool['log_sha256']==sha((supplement/'reconstruction-green.log').read_bytes()) and tool['resources_json_sha256']==sha((supplement/'resources.json').read_bytes())
 report=json.loads((supplement/'resources.json').read_text());assert report['format']==1 and report['original_capture_sha256']==historical.CAPTURE_SHA and report['source_archive_sha256']==historical.SOURCE_SHA
 phases=json.loads((original/'source-phases.json').read_text());cases=json.loads((original/'capture.json').read_text())['cases'];assert set(report['cases'])==set(cases)
 with zipfile.ZipFile(io.BytesIO((supplement/'resources.zip').read_bytes())) as bundle:
  names=bundle.namelist();assert len(names)==len(set(names)) and all(name.startswith('objects/') for name in names);objects={name.removeprefix('objects/'):bundle.read(name) for name in names}
 for digest,raw in objects.items():assert len(digest)==64 and sha(raw)==digest,'Physical object bytes changed'
 used=set()
 def object_bytes(digest):used.add(digest);return objects[digest]
 with zipfile.ZipFile(original/'source-tree.zip') as bundle:sources={name:bundle.read(name) for name in bundle.namelist()}
 def source(name,phase):return sources[phase+'/'+name]
 assert object_bytes(report['inspector_source_sha256'])==source('tools/pt-pt-audio/rcc_inventory.cpp','baseline')
 extractions=0;canonical_count=0
 def rcc(value,phase,activity,instrumented=None):
  nonlocal extractions
  raw=object_bytes(value['rcc_sha256']);assert raw.startswith(b'qres'),'Not physical RCC bytes'
  prefix='src/core/' if activity=='core' else 'src/activities/'+activity+'/'
  wanted={name for name in phases[phase]['files'] if name.startswith(prefix)};assert len(value['files'])==len(wanted) and {row['path'] for row in value['files']}=={':/gcompris/'+name for name in wanted}
  for row in value['files']:
   path=row['path'].removeprefix(':/gcompris/');safe(path);raw=object_bytes(row['sha256']);assert len(raw)==row['bytes']
   assert raw==(instrumented[1] if instrumented and path==instrumented[0] else source(path,phase)),'Qt extraction differs from exact source/case '+path
   extractions+=1
 for phase,activities in report['canonical'].items():
  assert phase in ['baseline','rules','final'];expected=json.loads((original/('identities-'+phase)/'resources.json').read_text())['canonical'];assert activities==expected
  for activity,value in activities.items():rcc(value,phase,activity);canonical_count+=1
 assert set(report['canonical'])=={'baseline','rules','final'} and canonical_count==15
 for catalogue,value in report['catalogues'].items():
  qm=object_bytes(value['qm_sha256']);assert qm.startswith(bytes.fromhex('3cb86418caef9c95cd211cbf60a1bddd')),'Not physical QM bytes';decoded=ET.fromstring(object_bytes(value['decoded_ts_sha256']));assert decoded.tag=='TS' and decoded.findall('.//translation')
  assert any(catalogue==phases[phase]['files']['poqm/pt/gcompris_qt.po'] for phase in ['baseline','help','rules','final'])
 for name,record in report['cases'].items():
  directory=original/name;receipt_raw=(directory/'result.json').read_bytes();receipt=json.loads(receipt_raw);phase=cases[name]['phase'];assert record['phase']==phase and record['receipt_sha256']==sha(receipt_raw) and record['case_sha256']==receipt['case_sha256']==sha((directory/'case.qml').read_bytes())
  text=source('src/activities/'+receipt['qml_file'],phase).decode();closing=re.search(r'\n    }\s*\n}\s*$',text);assert closing
  output_name=record['historical_output_name'];assert '/' not in output_name and output_name not in ['.','..'];historical_root=record['historical_source_root'];assert historical_root.endswith('/build/alignment-sources/'+phases[phase]['revision'])
  # Historical paths are inert strings in the archived QML; never opened.
  output=Path(historical_root).parents[2]/'.scratch/pt-pt/functional-alignment'/output_name
  fragment=(directory/'case.qml').read_text().replace('__QA_OUTPUT__',output.as_posix()).replace('__QA_SOURCE__',historical_root);patched=('import QtTest\n'+text[:closing.start()]+'\n'+fragment+text[closing.start():]).encode();assert sha(patched)==record['instrumented_qml_sha256']
  assert record['rcc']['rcc_sha256']==receipt['private_rcc_sha256'];rcc(record['rcc'],phase,receipt['qml_file'].split('/')[0],('src/activities/'+receipt['qml_file'],patched))
  assert record['qm_sha256']==receipt['private_qm_sha256']==report['catalogues'][record['catalogue_sha256']]['qm_sha256'] and record['catalogue_sha256']==receipt['portuguese_catalogue_sha256']
  assert 0<=record['metadata_timestamp_ms']-record['recovered_qml_mtime_ms']<record['timestamp_search_window_ms']==120000
 assert used==set(objects),'Unaccounted physical objects'
 return {'receipts_with_exact_overrides':len(cases),'primary_games_preserved':summary['games'],'canonical_rcc':canonical_count,'qt_extracted_files':extractions,'physical_objects':len(objects),'scope':'Exact historical core/four activity RCCs and all private RCC/QM overrides reconstructed with original SHA equality; no new gameplay. Other snapshot inventory remains historical metadata. Windows, physical input/audio and teacher acceptance pending.'}
if __name__=='__main__':
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--original',type=Path,default=ROOT/'.scratch/pt-pt/functional-alignment');parser.add_argument('--supplement',type=Path,default=ROOT/'.scratch/pt-pt/functional-alignment-resources');args=parser.parse_args()
 try:print(json.dumps(verify(args.original,args.supplement),indent=2))
 except (AssertionError,OSError,ValueError,KeyError,zipfile.BadZipFile,ET.ParseError) as error:print('Alignment physical resources rejected: '+str(error),file=sys.stderr);raise SystemExit(1)
