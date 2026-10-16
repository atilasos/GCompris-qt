# SPDX-License-Identifier: GPL-3.0-or-later
import copy,hashlib,json,shutil,subprocess,sys,tempfile,unittest
from pathlib import Path
from audit import audit,check_lock,check_water,check_energy
ROOT=Path(__file__).resolve().parents[2];BASE=ROOT/'.scratch/pt-pt/functional-cycles'
def case(name):return json.loads((BASE/name/'result.json').read_text())['case_result']
def physical_copy(destination):
 index=json.loads((BASE/'index.json').read_text())
 for relative in ['index.json',*index['files']]:
  target=destination/relative;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(BASE/relative,target)
 return index
class IndependentEvidence(unittest.TestCase):
 def test_complete_original(self):self.assertEqual(audit(BASE)['energy_levels'],3)
 def test_physical_lock_geometry(self):
  data=case('canal-complete2');check_lock(data);broken=copy.deepcopy(data);broken['journeys'][0]['steps'][0]['after']['boat']['x']=100000
  with self.assertRaises(ValueError):check_lock(broken)
 def test_water_storage_prerequisite(self):
  data=case('water-pilot');check_water(data);broken=copy.deepcopy(data);next(s for s in broken['evidence']['stages'] if s['name']=='ready')['view']['tower']['scale']=0
  with self.assertRaises(ValueError):check_water(broken)
 def test_energy_is_independent_arithmetic(self):
  data=case('energy-pilot');check_energy(data);broken=copy.deepcopy(data);broken['levels'][2]['success']['view']['produced']['watts']=1
  with self.assertRaises(ValueError):check_energy(broken)
 def test_empty_energy_coverage_refused(self):
  data=case('energy-pilot');data['levels']=[]
  with self.assertRaises(ValueError):check_energy(data)
 def test_physical_copy_and_missing_resource(self):
  with tempfile.TemporaryDirectory() as tmp:
   target=Path(tmp);physical_copy(target);self.assertTrue(audit(target)['passed'])
   next((target/'effective').glob('*/activity.rcc')).unlink()
   with self.assertRaises((ValueError,OSError)):audit(target)
 def test_corrupt_compiled_catalogue(self):
  with tempfile.TemporaryDirectory() as tmp:
   target=Path(tmp);physical_copy(target);catalogue=next((target/'catalogue').glob('*.qm'));catalogue.write_bytes(catalogue.read_bytes()+b'corruption')
   with self.assertRaises(ValueError):audit(target)
 def test_coherently_resealed_receipt_refused(self):
  with tempfile.TemporaryDirectory() as tmp:
   target=Path(tmp);index=physical_copy(target);receipt=target/'water-pilot/result.json';data=json.loads(receipt.read_text());data['case_result']['evidence']['stages']=[];receipt.write_text(json.dumps(data));digest=hashlib.sha256(receipt.read_bytes()).hexdigest()
   for name in ['launcher-status.json','tool-status.json']:
    path=target/'water-pilot'/name;status=json.loads(path.read_text());status['native_receipt_sha256']=digest
    if name=='tool-status.json':status['launcher_status_sha256']=hashlib.sha256((target/'water-pilot/launcher-status.json').read_bytes()).hexdigest()
    path.write_text(json.dumps(status))
   for relative in index['files']:index['files'][relative]=hashlib.sha256((target/relative).read_bytes()).hexdigest()
   (target/'index.json').write_text(json.dumps(index))
   with self.assertRaisesRegex(ValueError,'Immutable historical index'):audit(target)
 def test_existing_output_preserves_all_bytes(self):
  with tempfile.TemporaryDirectory() as tmp:
   root=Path(tmp);out=root/'existing';out.mkdir();(out/'tool-status.json').write_text('historical status');(out/'result.json').write_text('historical receipt');log=root/'existing.log';log.write_text('historical log');fragment=root/'case.qml';fragment.write_text('TestCase{}');before={p.name:p.read_bytes() for p in out.iterdir()};before['log']=log.read_bytes()
   for tool in ['run.py','capture.py']:
    command=[sys.executable,str(ROOT/'tests/functional_cycles'/tool),'--case',str(fragment),'--output',str(out)]
    if tool=='run.py':command+=['--activity','watercycle','--revision','irrelevant']
    run=subprocess.run(command,capture_output=True,text=True);self.assertNotEqual(run.returncode,0);self.assertEqual({p.name:p.read_bytes() for p in out.iterdir()}, {k:v for k,v in before.items() if k!='log'});self.assertEqual(log.read_bytes(),before['log'])
if __name__=='__main__':unittest.main()
