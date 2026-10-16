import hashlib,json,urllib.request,urllib.error,sys,time
from pathlib import Path
base=Path(__file__).resolve().parent
meta=json.loads((base/'current-installer.json').read_text())
url='https://gcompris.infantinho.xyz'
checks=[]
def request(path='/',method='GET',headers=None):
 return urllib.request.urlopen(urllib.request.Request(url+path,method=method,headers=dict({'User-Agent': json.loads((base/'browser-verification.json').read_text())['userAgent']}, **(headers or {}))),timeout=60)
with request(method='HEAD') as response:
 if response.status!=200 or int(response.headers['Content-Length'])!=meta['bytes']:raise RuntimeError('Public length mismatch')
 if 'attachment' not in response.headers.get('Content-Disposition',''):raise RuntimeError('No download header')
 checks.append({'kind':'https-head','status':response.status,'bytes':meta['bytes']})
with Path(meta['installer']).open('rb') as local:
 for start,end in [(0,1048575),(meta['bytes']-1048576,meta['bytes']-1)]:
  with request(headers={'Range':f'bytes={start}-{end}'}) as response:
   data=response.read()
   if response.status!=206 or response.headers['Content-Range']!=f'bytes {start}-{end}/{meta["bytes"]}':raise RuntimeError('Bad public Range')
  local.seek(start)
  if data!=local.read(end-start+1):raise RuntimeError('Public bytes mismatch')
  checks.append({'kind':'https-range-equals-verified-installer','start':start,'end':end,'sha256':hashlib.sha256(data).hexdigest()})
with request('/SHA256SUMS.txt') as response:
 if response.read().decode().split()[0]!=meta['sha256']:raise RuntimeError('Public checksum mismatch')
 checks.append({'kind':'public-checksum','matches':True})
with request('/version.json') as response:
 value=json.load(response)
 if value!={k:meta[k] for k in ('run','source','sha256','bytes')}:raise RuntimeError('Public version mismatch')
 checks.append({'kind':'public-source-identity','matches':True})
try:request('/README.md')
except urllib.error.HTTPError as error:
 if error.code!=404:raise
 checks.append({'kind':'unlisted-path','status':404})
else:raise RuntimeError('Unlisted path served')
print('HEAD, Range, checksum, source identity, allowlist passed',flush=True)
sha=hashlib.sha256();total=0;started=time.monotonic()
with request() as response:
 while True:
  data=response.read(1024*1024)
  if not data:break
  sha.update(data);total+=len(data)
  if time.monotonic()-started>600:raise RuntimeError('Public full download exceeded bounded validation time')
if total!=meta['bytes'] or sha.hexdigest()!=meta['sha256']:raise RuntimeError('Public full download mismatch')
checks.append({'kind':'complete-public-https-download','bytes':total,'sha256':sha.hexdigest(),'seconds':round(time.monotonic()-started,2)})
result={'url':url,'run':meta['run'],'source':meta['source'],'sha256':meta['sha256'],'bytes':meta['bytes'],'checks':checks,'scope':'Verified installer served over HTTPS; no school Windows 10 or hardware acceptance'}
(base/'public-verification.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2),flush=True)
