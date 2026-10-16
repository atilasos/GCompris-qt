#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Attack physical copies; accepted historical observations remain untouched."""
import argparse,copy,io,json,re,shutil,tempfile,zipfile
from pathlib import Path
from PIL import Image
import audit
from semantics import validate
from store import Reader,require,sha

def encoded(value):return (json.dumps(value,ensure_ascii=False,indent=2)+'\n').encode()
def replace(capture,objects,name,raw):
    digest=sha(raw);objects[digest]=raw;capture['files'][name]=digest
    capture['objects']=sorted(set(capture['objects'])|{digest})
def repack(base,capture,objects):
    for path in [base/'archive.json',*base.glob('objects.zip.part*')]:
        if path.exists():path.unlink()
    (base/'capture.json').write_bytes(encoded(capture))
    with zipfile.ZipFile(base/'objects.zip','w',zipfile.ZIP_DEFLATED) as archive:
        for digest,raw in sorted(objects.items()):archive.writestr('objects/'+digest,raw)
    return sha((base/'capture.json').read_bytes()),sha((base/'objects.zip').read_bytes())
def reject(operation,phrase):
    try:operation()
    except ValueError as error:
        require(phrase in str(error),'Wrong rejection boundary: '+str(error));return str(error)
    raise ValueError('Tampered proof unexpectedly accepted')
def coherent_attack(base,kind):
    original=Reader(base,audit.CAPTURE_SHA256,audit.ARCHIVE_SHA256)
    capture=copy.deepcopy(original.capture);objects=dict(original.objects);prefix='runs/complete-mosaic/'
    receipt=original.json(prefix+'result.json')
    if kind=='plan':receipt['case_result']['boards'][0]['plan']['placements'][0]['target_frame']['x']+=126
    elif kind=='pixels':
        name='level-1-question.png';image=Image.open(io.BytesIO(original.artifact(prefix+name)))
        stream=io.BytesIO();Image.new('RGB',image.size,'white').save(stream,format='PNG');raw=stream.getvalue()
        replace(capture,objects,prefix+name,raw)
        entry=next(row for row in receipt['screenshots'] if row['file']==name);entry['sha256']=sha(raw);entry['bytes']=len(raw)
    else:raise ValueError('Unknown attack')
    raw=encoded(receipt);replace(capture,objects,prefix+'result.json',raw);receipt_hash=sha(raw)
    log=original.artifact(prefix+'native.log').decode();log,count=re.subn(r'^qml: NATIVE_RESULT \{.*\}$','qml: NATIVE_RESULT '+json.dumps(receipt['case_result'],ensure_ascii=False,separators=(',',':')),log,flags=re.M)
    require(count==1,'Exactly one raw Qt marker');replace(capture,objects,prefix+'native.log',log.encode())
    launcher=original.json(prefix+'launcher-status.json');launcher['native_receipt_sha256']=receipt_hash;replace(capture,objects,prefix+'launcher-status.json',encoded(launcher))
    outer=original.json(prefix+'tool-status.json');outer['native_receipt_sha256']=receipt_hash;outer['launcher_status_sha256']=sha(encoded(launcher));replace(capture,objects,prefix+'tool-status.json',encoded(outer))
    return repack(base,capture,objects)
def exercise(base):
    accepted=audit.audit(base);report={'accepted':accepted}
    with tempfile.TemporaryDirectory(prefix='pattern proof attacks ') as directory:
        root=Path(directory)
        for kind,phrase in [('plan','Independent Python geometry'),('pixels','render discrepancy')]:
            forged=root/kind;shutil.copytree(base,forged);index,archive=coherent_attack(forged,kind)
            report[kind+'_external_anchor_rejection']=reject(lambda:audit.audit(forged),'external literal anchor')
            # Trust the forged identities ONLY inside this negative fixture. The
            # application keeps its original literal anchors and capsule bytes.
            reader=Reader(forged,index,archive);receipts=audit.verify_physical(reader)
            report[kind+'_coherent_physical_checks']='passed'
            report[kind+'_semantic_rejection']=reject(lambda:validate(reader,receipts),phrase)
        empty=root/'empty';shutil.copytree(base,empty);reader=Reader(empty,audit.CAPTURE_SHA256,audit.ARCHIVE_SHA256);capture=copy.deepcopy(reader.capture);capture['runs']={};index,archive=repack(empty,capture,reader.objects);reader=Reader(empty,index,archive)
        report['empty_rejection']=reject(lambda:validate(reader,audit.verify_physical(reader)),'Complete finite campaign')
        physical=root/'physical';shutil.copytree(base,physical)
        target=physical/'objects.zip' if (physical/'objects.zip').exists() else sorted(physical.glob('objects.zip.part*'))[0]
        raw=target.read_bytes();target.write_bytes(bytes([raw[0]^1])+raw[1:])
        report['physical_rejection']=reject(lambda:audit.audit(physical),'archive' if target.name=='objects.zip' else 'chunk bytes')
    return report
if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--evidence',type=Path,required=True);args=parser.parse_args();print(json.dumps(exercise(args.evidence)))
