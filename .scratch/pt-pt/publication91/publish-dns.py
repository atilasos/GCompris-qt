import runpy,json
from pathlib import Path
mod=runpy.run_path('/tmp/gcompris-cloudflare-api.py');api=mod['api'];conf=mod['credentials']()
base=Path(__file__).resolve().parent
manifest=json.loads((base/'current-installer.json').read_text())
if manifest['run']!='38894977302':raise RuntimeError('Do not expose the old validation candidate')
state=json.loads((base/'cloudflare-state.json').read_text())
zone=conf['CLOUDFLARE_ZONE_ID'];hostname=state['hostname']
existing=api('GET','zones/'+zone+'/dns_records?name='+hostname)
if existing:raise RuntimeError('Hostname is now occupied; inspect before mutation')
record=api('POST','zones/'+zone+'/dns_records',{'type':'CNAME','name':hostname,'content':state['tunnel_id']+'.cfargotunnel.com','proxied':True,'ttl':1,'comment':'GCompris Windows x64 installer requested by school owner'})
state['dns_created']=True;state['dns_record_id']=record['id']
(base/'cloudflare-state.json').write_text(json.dumps(state,indent=2)+'\n')
readback=api('GET','zones/'+zone+'/dns_records/'+record['id'])
if readback['name']!=hostname or readback['content']!=record['content'] or not readback['proxied']:raise RuntimeError('DNS readback mismatch')
print('Published verified installer at https://'+hostname+'; DNS id '+record['id'])
