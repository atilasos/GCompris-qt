#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Read finished native proofs into a new provisional capsule; no Git or Qt."""
import argparse,json
from pathlib import Path
from store import Writer,require,sha,safe
CANONICAL={'core','babymatch','details','paintings','photo_hunter','guesscount','tic_tac_toe'}

def collect(root_evidence,snapshot_manifest,selection,effective_indexes,external_observations,output):
 writer=Writer(output) # Refuse an existing output before reading or creating anything.
 root=Path(root_evidence);snapshot_manifest=Path(snapshot_manifest);description=json.loads(Path(selection).read_text());runs=description['runs'];require(runs,'Empty run selection')
 exports={}
 for path in effective_indexes:
  value=json.loads(Path(path).read_text());writer.file('observations/exports/'+Path(path).parent.name+'.json',path)
  for name,row in value['runs'].items():
   require(name not in exports or exports[name]==row,'Conflicting effective resource observations');exports[name]=row
 writer.file('selection.json',selection);snapshot=writer.file('snapshot-manifest.json',snapshot_manifest)
 # Preserve the actual executable as well as the manifest; the remaining269runtime
 # hashes still describe a larger environment which the portable capsule omits.
 binary=snapshot_manifest.parent/'bin/gcompris-qt';binary_hash=writer.file('runtime/bin/gcompris-qt',binary);require(json.loads(snapshot_manifest.read_text())['files']['bin/gcompris-qt']==binary_hash,'Snapshot binary changed')
 sources={};records={}
 for name,contract in runs.items():
  safe(name);require('/' not in name and name in exports,'Selected run has no physical export');original=root/name;export=exports[name];require(export['exit_code']==0,'Failed resource extraction');source=Path(export['source_root']);manifest=json.loads((source/'source-manifest.json').read_text());revision=manifest['revision'];require(source.name==revision,'Frozen revision/root identity')
  if revision not in sources:
   hashes={}
   for logical,expected in manifest['files'].items():
    safe(logical);actual=writer.file('sources/'+revision+'/'+logical,source/logical);require(actual==expected,'Frozen source bytes changed');hashes[logical]=actual
   writer.file('sources/'+revision+'/source-manifest.json',source/'source-manifest.json');sources[revision]={'historical_root':str(source),'manifest':manifest,'files':hashes}
  receipt=json.loads((original/'result.json').read_text());require(receipt.get('case_result') is not None and (original/'tool-status.json').is_file(),'Run is not finished')
  for path in sorted(original.rglob('*')):
   require(not path.is_symlink(),'Symlink inside a native observation')
   if path.is_file():writer.file('runs/'+name+'/'+path.relative_to(original).as_posix(),path)
  parent_log=original.with_name(name+'.log')
  if parent_log.is_file():writer.file('runs/'+name+'/parent.log',parent_log)
  require(export['rcc_sha256']==receipt['private_rcc_sha256'] and export['qm_sha256']==receipt['private_qm_sha256'],'Export does not identify the loaded private resources')
  rcc=writer.file('effective/'+name+'/resource.rcc',export['rcc']);qm=writer.file('effective/'+name+'/gcompris_qt_pt.qm',export['qm']);require((rcc,qm)==(export['rcc_sha256'],export['qm_sha256']),'Private resource bytes changed')
  inspector=writer.file('effective/'+name+'/inspector',export['argv'][0]);require(inspector==export['inspector_sha256'],'Actual resource inspector bytes changed')
  for row in export['files']:
   require(row['path'].startswith(':/gcompris/'),'Unexpected extracted resource prefix');relative=row['path'][2:];safe(relative);actual=writer.file('effective/'+name+'/files/'+relative,Path(export['files_root'])/relative);require(actual==row['sha256'] and len(writer.objects[actual])==row['bytes'],'Physical extracted bytes changed')
  tool=json.loads((original/'tool-status.json').read_text());capture=source/'tests/functional_visual_puzzles/capture.py';require(sha(capture.read_bytes())==tool['capture_sha256'],'Frozen capture tool differs from observed hash')
  records[name]=dict(contract,source=revision,historical_output=str(original),effective=export)
 canonical=json.loads((root/'canonical/index.json').read_text());require(set(canonical)==CANONICAL,'All seven canonical imports required');writer.file('canonical/index.json',root/'canonical/index.json')
 for name,row in canonical.items():
  require(row['exit_code']==0,'Failed canonical extraction');require(writer.file('canonical/'+name+'/resource.rcc',root/'canonical'/name/'resource.rcc')==row['sha256'],'Canonical RCC changed')
  for entry in row['files']:
   relative=entry['path'][2:];safe(relative);actual=writer.file('canonical/'+name+'/files/'+relative,root/'canonical'/name/'files'/relative);require(actual==entry['sha256'] and len(writer.objects[actual])==entry['bytes'],'Canonical physical extraction changed')
 for path in external_observations:writer.file('observations/external/'+Path(path).name,path)
 for relative in description.get('auxiliary',[]):
  safe(relative);path=root/relative
  if path.is_dir():
   require(not path.is_symlink(),'Symlink supplemental directory')
   for child in sorted(path.rglob('*')):
    require(not child.is_symlink(),'Symlink supplemental artifact')
    if child.is_file():writer.file('auxiliary/'+relative+'/'+child.relative_to(path).as_posix(),child)
  else:writer.file('auxiliary/'+relative,path)

 algorithms={}
 for activity,paths in {'details':['tests/functional_visual_puzzles/pixels.py'],'paintings':['tests/painting_pixel_solver/solver.py','tests/painting_pixel_solver/observation.py','tests/painting_rectangular_solver/__init__.py','tests/painting_rectangular_solver/solver.py']}.items():
  chosen=[r for r in records.values() if r['kind']=='complete' and r['activity']==activity]
  if chosen:
   require(len(chosen)==1,'One final algorithm phase per activity');manifest=sources[chosen[0]['source']]['files']
   for path in paths:require(path in manifest,'Final algorithm source not frozen');algorithms[path]=manifest[path]
 return writer.finish({'algorithms':algorithms,'scope':'Provisional until externally anchored; Linux software observations; human/Windows acceptance pending','snapshot':snapshot,'binary':binary_hash,'sources':sources,'runs':records,'canonical':canonical})

def main():
 p=argparse.ArgumentParser();p.add_argument('--root-evidence',type=Path,required=True);p.add_argument('--snapshot-manifest',type=Path,required=True);p.add_argument('--selection',type=Path,required=True);p.add_argument('--effective-index',type=Path,action='append',required=True);p.add_argument('--external-observations',type=Path,action='append',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();print(json.dumps({'candidate_index_sha256':collect(a.root_evidence,a.snapshot_manifest,a.selection,a.effective_index,a.external_observations,a.output)}))
if __name__=='__main__':main()
