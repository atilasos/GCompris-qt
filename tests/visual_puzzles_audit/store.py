# SPDX-License-Identifier: GPL-3.0-or-later
"""Content-addressed, relocation-safe physical evidence storage."""
import hashlib,io,json,re,tempfile,zipfile
from pathlib import Path,PurePosixPath

def require(ok,message):
 if not ok:raise ValueError(message)
def sha(raw):return hashlib.sha256(raw).hexdigest()
def safe(name):
 path=PurePosixPath(name)
 require(isinstance(name,str) and name and not path.is_absolute() and '..' not in path.parts and str(path)==name,'Unsafe logical artifact path')
 return name
class Writer:
 def __init__(self,output):
  self.output=Path(output)
  if self.output.exists() or self.output.is_symlink():raise FileExistsError('Use a fresh capsule output')
  self.objects={};self.files={}
 def put(self,raw):
  digest=sha(raw);require(digest not in self.objects or self.objects[digest]==raw,'Digest collision');self.objects[digest]=raw;return digest
 def file(self,name,path):
  safe(name);path=Path(path);require(not path.is_symlink() and path.is_file(),'Physical regular artifact required');digest=self.put(path.read_bytes());require(name not in self.files,'Duplicate logical artifact');self.files[name]=digest;return digest
 def finish(self,metadata):
  if self.output.exists() or self.output.is_symlink():raise FileExistsError('Capsule output appeared during collection')
  value=dict(metadata,format=1,files=self.files,objects=sorted(self.objects));raw=(json.dumps(value,ensure_ascii=False,indent=2)+'\n').encode();self.output.parent.mkdir(parents=True,exist_ok=True)
  with tempfile.TemporaryDirectory(prefix='.visual-capture-',dir=self.output.parent) as temporary:
   staged=Path(temporary)/'capsule';staged.mkdir();(staged/'capture.json').write_bytes(raw)
   with zipfile.ZipFile(staged/'objects.zip','x',zipfile.ZIP_DEFLATED) as bundle:
    for digest,data in sorted(self.objects.items()):
     entry=zipfile.ZipInfo('objects/'+digest,date_time=(2026,1,1,0,0,0));entry.compress_type=zipfile.ZIP_DEFLATED;bundle.writestr(entry,data)
   # Directory rename publishes only a complete candidate. Never replace one.
   if self.output.exists() or self.output.is_symlink():raise FileExistsError('Capsule output appeared before publication')
   staged.rename(self.output)
  return sha(raw)
class Reader:
 def __init__(self,base,expected_index,expected_archive=None):
  base=Path(base)
  for path in [base,base/'capture.json',base/'objects.zip']:require(not path.is_symlink(),'Symlink capsule')
  raw=(base/'capture.json').read_bytes();require(expected_index and sha(raw)==expected_index,'Capsule differs from external literal anchor');self.capture=json.loads(raw);require(self.capture['format']==1,'Unsupported capsule format')
  hashes=self.capture['objects'];require(hashes==sorted(set(hashes)) and all(re.fullmatch('[0-9a-f]{64}',h) for h in hashes),'Invalid object index')
  archive=archive_bytes(base,expected_archive)
  with zipfile.ZipFile(io.BytesIO(archive)) as bundle:
   names=bundle.namelist();require(len(names)==len(set(names)) and set(names)=={'objects/'+h for h in hashes},'Physical object set differs')
   require(sum(i.file_size for i in bundle.infolist())<2_000_000_000 and all(i.file_size<512_000_000 for i in bundle.infolist()),'Object limits exceeded');self.objects={h:bundle.read('objects/'+h) for h in hashes}
  require(all(sha(raw)==h for h,raw in self.objects.items()),'Physical object bytes changed')
  for name,h in self.capture['files'].items():safe(name);require(h in self.objects,'Missing logical artifact bytes')
 def blob(self,digest):return self.objects[digest]
 def artifact(self,name):return self.blob(self.capture['files'][safe(name)])
 def json(self,name):return json.loads(self.artifact(name))

def archive_bytes(base,expected=None):
 base=Path(base);single=base/'objects.zip';manifest=base/'archive.json'
 require(not manifest.is_symlink(),'Symlink archive manifest')
 if single.is_file():
  require(not manifest.exists(),'Mixed single and partitioned archive');raw=single.read_bytes()
 else:
  description=json.loads(manifest.read_bytes());chunks=description['chunks'];require(chunks,'Empty physical archive')
  require([c['file'] for c in chunks]==[f'objects.zip.part{i:03d}' for i in range(len(chunks))],'Sequential physical archive chunks')
  require(set(p.name for p in base.glob('objects.zip.part*'))=={c['file'] for c in chunks},'Unexpected archive chunks')
  data=[]
  for chunk in chunks:
   path=base/chunk['file'];require(not path.is_symlink(),'Symlink archive chunk');part=path.read_bytes();require(len(part)==chunk['bytes'] and sha(part)==chunk['sha256'],'Physical archive chunk bytes');data.append(part)
  raw=b''.join(data);require(len(raw)==description['bytes'] and sha(raw)==description['sha256'],'Concatenated original ZIP bytes')
 if expected:require(sha(raw)==expected,'Archive differs from external literal anchor')
 return raw
