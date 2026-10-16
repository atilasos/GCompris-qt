from pathlib import Path
import json,subprocess,time,sys
run='38894977302'
repo='atilasos/GCompris-qt'
base=Path('/home/proteu/Projetos/GCompris-qt')
output=base/'build/pt-pt/download-publication-short'
last=None;started=time.monotonic()
while True:
 result=json.loads(subprocess.check_output(['gh','run','view',run,'--repo',repo,'--json','status,conclusion,jobs']))
 current=[step['name'] for job in result['jobs'] for step in job.get('steps',[]) if step['status']=='in_progress']
 summary=(result['status'],result['conclusion'],tuple(current))
 print(json.dumps({'run':run,'elapsed_seconds':int(time.monotonic()-started),'status':result['status'],'conclusion':result['conclusion'],'current_steps':current}),flush=True)
 if result['status']=='completed':break
 time.sleep(43)
meta=base/'.scratch/pt-pt/windows/ci-status';meta.mkdir(parents=True,exist_ok=True)
for suffix,endpoint in [('',f'repos/{repo}/actions/runs/{run}'),('-artifacts',f'repos/{repo}/actions/runs/{run}/artifacts')]:
 value=json.loads(subprocess.check_output(['gh','api',endpoint]))
 (meta/(run+suffix+'.json')).write_text(json.dumps(value,indent=2)+'\n')
if result['conclusion']!='success':
 print('CI did not pass; publication not attempted.',flush=True)
 raise SystemExit(1)
for name in ['gcompris-fetch-ci-proof.py','gcompris-download-current-candidate.py']:
 print('Starting '+name,flush=True)
 log=output/(name+'.log')
 with log.open('w') as stream:
  done=subprocess.run([sys.executable,'/tmp/'+name,run],cwd=base,stdout=stream,stderr=subprocess.STDOUT)
 print('Completed '+name+' exit='+str(done.returncode),flush=True)
 print('\n'.join(log.read_text().splitlines()[-8:]),flush=True)
 if done.returncode:raise SystemExit(done.returncode)
print('VERIFIED_CANDIDATE_READY '+run,flush=True)
