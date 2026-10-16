#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Attack physical copies, preserving accepted native observations unchanged."""
import argparse,copy,json,re,shutil,tempfile,zipfile
from pathlib import Path
from unittest.mock import patch
import audit
from store import Reader,require,sha

def repack(base,capture,objects):
 for path in [base/'archive.json',*base.glob('objects.zip.part*')]:
  if path.exists():path.unlink()
 (base/'capture.json').write_text(json.dumps(capture,ensure_ascii=False,indent=2)+'\n')
 with zipfile.ZipFile(base/'objects.zip','w',zipfile.ZIP_DEFLATED) as bundle:
  for digest,raw in sorted(objects.items()):bundle.writestr('objects/'+digest,raw)
 return sha((base/'capture.json').read_bytes())
def replace(capture,objects,name,raw):
 digest=sha(raw);objects[digest]=raw;capture['files'][name]=digest
 if digest not in capture['objects']:capture['objects'].append(digest);capture['objects'].sort()
def encode(value):return (json.dumps(value,ensure_ascii=False,indent=2)+'\n').encode()
def coherent_target_attack(base):
 reader=Reader(base,audit.CAPTURE_SHA256);capture=copy.deepcopy(reader.capture);objects=dict(reader.objects);name=next(n for n,c in capture['runs'].items() if c['activity']=='details' and c['kind']=='complete');prefix='runs/'+name+'/';r=reader.json(prefix+'result.json');r['case_result']['boards'][0]['placements'][0]['target']['x']+=5
 replace(capture,objects,prefix+'result.json',encode(r));receipt_hash=sha(encode(r))
 log=reader.artifact(prefix+'native.log').decode();log,count=re.subn(r'^qml: NATIVE_RESULT \{.*\}$','qml: NATIVE_RESULT '+json.dumps(r['case_result'],ensure_ascii=False,separators=(',',':')),log,flags=re.M);require(count==1,'Attack fixture expected one raw Qt marker');replace(capture,objects,prefix+'native.log',log.encode())
 launcher=reader.json(prefix+'launcher-status.json');launcher['native_receipt_sha256']=receipt_hash;replace(capture,objects,prefix+'launcher-status.json',encode(launcher));outer=reader.json(prefix+'tool-status.json');outer['native_receipt_sha256']=receipt_hash;outer['launcher_status_sha256']=sha(encode(launcher));replace(capture,objects,prefix+'tool-status.json',encode(outer))
 return repack(base,capture,objects)
def expect_rejection(operation,phrase):
 try:operation()
 except ValueError as error:require(phrase in str(error),'Attack failed at an unintended boundary: '+str(error));return str(error)
 raise ValueError('Adversarial proof copy was accepted')
def exercise(base):
 result=audit.audit(base);out={'accepted':result}
 with tempfile.TemporaryDirectory(prefix='visual proof attacks ') as temporary:
  root=Path(temporary);forged=root/'coherent target';shutil.copytree(base,forged);new_anchor=coherent_target_attack(forged)
  out['external_anchor_rejection']=expect_rejection(lambda:audit.audit(forged),'external literal anchor')
  # Deliberately trust the attack's new anchor in this fixture only, proving that
  # the independent pixel contract rejects data which passed every byte hash.
  reader=Reader(forged,new_anchor);receipts=audit.verify_physical(reader);out['coherent_tamper_physical_checks']='passed'
  from semantics import validate
  out['coherent_tamper_semantic_rejection']=expect_rejection(lambda:validate(reader,receipts),'Independent visible pixel location')
  empty=root/'empty campaign';shutil.copytree(base,empty);reader=Reader(empty,audit.CAPTURE_SHA256);capture=copy.deepcopy(reader.capture);capture['runs']={};anchor=repack(empty,capture,reader.objects)
  with patch.object(audit,'CAPTURE_SHA256',anchor),patch.object(audit,'ARCHIVE_SHA256',sha((empty/'objects.zip').read_bytes())):out['empty_rejection']=expect_rejection(lambda:audit.audit(empty),'No finite observations')
 return out
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--evidence',type=Path,required=True);a=p.parse_args();print(json.dumps(exercise(a.evidence)))
