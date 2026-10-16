#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Partition the anchored ZIP byte-for-byte, without changing its index."""
import argparse,json,tempfile
from pathlib import Path
from anchor import CAPTURE_SHA256,ARCHIVE_SHA256
from store import Reader,archive_bytes,sha

def partition(evidence,output):
 output=Path(output)
 if output.exists() or output.is_symlink():raise FileExistsError('Use a fresh partition output')
 Reader(evidence,CAPTURE_SHA256,ARCHIVE_SHA256)
 raw=archive_bytes(evidence,ARCHIVE_SHA256);output.parent.mkdir(parents=True,exist_ok=True)
 with tempfile.TemporaryDirectory(prefix='.visual-partition-',dir=output.parent) as temporary:
  staged=Path(temporary)/'capsule';staged.mkdir();chunks=[]
  for i,start in enumerate(range(0,len(raw),40*1024*1024)):
   data=raw[start:start+40*1024*1024];name=f'objects.zip.part{i:03d}';(staged/name).write_bytes(data);chunks.append({'file':name,'bytes':len(data),'sha256':sha(data)})
  (staged/'archive.json').write_text(json.dumps({'format':1,'bytes':len(raw),'sha256':sha(raw),'chunks':chunks},indent=2)+'\n')
  (staged/'capture.json').write_bytes((Path(evidence)/'capture.json').read_bytes())
  if output.exists() or output.is_symlink():raise FileExistsError('Partition output appeared')
  staged.rename(output)
 return chunks
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--evidence',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();print(json.dumps(partition(a.evidence,a.output)))
