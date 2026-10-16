from pathlib import Path
import hashlib,json,subprocess,time,urllib.request
base=Path(__file__).resolve().parent
root=Path('/home/proteu/Projetos/GCompris-qt')
run='38894977302';head='3c98f5c6b4543e15dda66e2b0e275f5d9e6b49df'
proof=json.loads((root/'.scratch/pt-pt/windows'/run/'download-verification.json').read_text())
audit=json.loads((base/'actual-installer-verification.json').read_text())
ci=json.loads((root/'.scratch/pt-pt/windows/ci-status'/(run+'.json')).read_text())
if not (ci['conclusion']=='success' and ci['head_sha']==head and proof['verified'] and proof['head_sha']==head and audit['passed'] and audit['installer_sha256']==proof['sha256']):
 raise ValueError('Candidate has not passed every publication gate')
installer=Path(proof['installer_path'])
with installer.open('rb') as stream:actual=hashlib.file_digest(stream,'sha256').hexdigest()
if actual!=proof['sha256'] or installer.stat().st_size!=proof['bytes']:raise ValueError('Installer changed after verification')
meta={'installer':str(installer),'run':run,'source':head,'sha256':actual,'bytes':proof['bytes']}
temporary=base/'current-installer.json.partial'
temporary.write_text(json.dumps(meta,indent=2)+'\n')
temporary.replace(base/'current-installer.json')
subprocess.run(['systemctl','--user','stop','gcompris-download-local-validation.service'],check=True)
subprocess.run(['systemctl','--user','enable','--now','gcompris-download-origin.service'],check=True)
for attempt in range(20):
 try:
  with urllib.request.urlopen('http://127.0.0.1:8878/version.json',timeout=2) as response:version=json.load(response)
  if version!={k:meta[k] for k in ('run','source','sha256','bytes')}:raise ValueError('Wrong origin version')
  print('New verified origin ready: '+json.dumps(version),flush=True)
  break
 except OSError:
  if attempt==19:raise
  time.sleep(.5)
