#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Portable physical creation evidence audit. No Qt, Git or historical tree needed."""
import io,argparse,hashlib,json,math,re,zipfile
from pathlib import Path,PurePosixPath
from pixels import png,pixel,changed,bounds
from curves import svg_paths,curve_error
if not __debug__:raise SystemExit('Creation audit rejects Python -O')
CAPTURE_SHA='9b8e6aab0aac15a3c9f8bcd73dcaac8b62a0eb7040181f6c874dd51e27ebeb61'
POSITIVE=['simplepaint-levels-v5','simplepaint-palettes-green','sketch-tracer-v6','sketch-tools-v3','wheels-levels-v4','fixed-resources','sketch-labels-green','wheels-labels-green','sketch-background-v2','wheels-controls-v2']
def sha(raw):return hashlib.sha256(raw).hexdigest()
def safe(name):
 p=PurePosixPath(name);assert not p.is_absolute() and '..' not in p.parts and str(p)==name,'Unsafe artifact path'
def audit(capsule):
 for p in [capsule,capsule/'capture.json',capsule/'objects.zip']:assert not p.is_symlink()
 raw=(capsule/'capture.json').read_bytes();assert sha(raw)==CAPTURE_SHA,'Immutable creation anchor changed';capture=json.loads(raw);assert capture['format']==1 and set(POSITIVE)<=set(capture['cases'])
 parts=sorted(capsule.glob('objects.zip.[0-9][0-9][0-9]'))
 if parts:
  assert [p.name for p in parts]==[f'objects.zip.{i:03d}' for i in range(len(parts))] and not any(p.is_symlink() for p in parts);archive_raw=b''.join(p.read_bytes() for p in parts)
 else:archive_raw=(capsule/'objects.zip').read_bytes()
 assert sha(archive_raw)=='2fe09088b42e0cf41917e430ebf4ac97e19a48f3c5ddf50e04648ef6d6ef9395','Physical archive bytes altered'
 with zipfile.ZipFile(io.BytesIO(archive_raw)) as archive:
  names=archive.namelist();assert len(names)==len(set(names)) and set(names)=={'objects/'+d for d in capture['objects']};objects={name[8:]:archive.read(name) for name in names}
 for digest,raw in objects.items():assert sha(raw)==digest,'Physical bytes altered'
 used=set()
 def blob(digest):used.add(digest);return objects[digest]
 def artifact(path):safe(path);return blob(capture['files'][path])
 def js(path):return json.loads(artifact(path))
 for path in capture['files']:artifact(path)
 for name in ['pixels.py','curves.py']:assert sha(Path(__file__).with_name(name).read_bytes())==capture['files']['harness/'+name],'Pure oracle changed'
 sources={}
 for revision,phase in capture['phases'].items():
  assert phase['source']['revision']==revision;sources[revision]=phase['source']['files']
  for path,digest in sources[revision].items():safe(path);blob(digest)
 snapshots={key:json.loads(blob(digest)) for key,digest in capture['snapshots'].items()}
 for key,s in snapshots.items():assert sha(blob(capture['snapshots'][key]))==key and len(s['files'])==269
 def physical(report,prefix=None,source=None,patched=None):
  assert blob(report['rcc_sha256']).startswith(b'qres'),'Physical RCC missing'
  for row in report['files']:
   path=row['path'].removeprefix(':/gcompris/');safe(path);raw=blob(row['sha256']);assert len(raw)==row['bytes']
   if source is not None:assert raw==(patched[path] if patched and path in patched else blob(source[path])),'RCC extraction does not match historical input'
   if prefix:assert raw==artifact(prefix+'/'+row['path'].removeprefix(':/'))
 for name,providers in capture['canonical'].items():
  assert set(providers)=={'simplepaint','sketch','drawing_wheels','core'}
  for activity,report in providers.items():
   revision={'creation-canonical':'4a4e636b615b228c559d2ad3349c55b4b878f675','creation-focused':'9c1fa4b621f377593a6251338677c0f1f525a413','creation-final':'416ddcc9dd331e8072c7f4a7e69bf3339ac86655'}.get(name);physical(report,source=sources[revision] if revision else None)
 dependency=js('dependencies/physical.json');assert len(dependency['providers'])==43 and len(dependency['inventory']['assets'])==159
 git=js('dependencies/git.json');assert len(git['files'])==1481 and len(git['mismatches'])==2
 for provider,report in dependency['providers'].items():
  physical(report,'dependencies/extracted/'+provider)
  assert artifact('dependencies/rcc/'+provider+'.rcc')==blob(report['rcc_sha256'])
  for row in report['files']:
   path=row['path'].removeprefix(':/gcompris/');entry=git['files'][path];raw=blob(row['sha256']);assert sha(raw)==entry['resource_sha256']
   gitsha=hashlib.sha1(b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest();assert gitsha==entry.get('historical_git_blob',entry['git_blob'])
 for path,digest in dependency['git_assets'].items():assert digest==git['files'][path]['resource_sha256']
 receipts={};observed={}
 for name,entry in capture['cases'].items():
  prefix='cases/'+name+'/';r=js(prefix+'result.json');receipts[name]=r;digest=sha(artifact(prefix+'result.json'));case=artifact(prefix+'case.qml');assert sha(case)==r['case_sha256'];assert r['exit_code']==entry['native'] and r['passed']==entry['passed'] and not r['timeout']
  status=js(prefix+'launcher-status.json');supervisor=js(prefix+'supervisor-exit.json');tool=js(prefix+'tool-exit.json');observed[name]={'qt':r['exit_code'],'launcher':status['exit_code'],'supervisor':supervisor['exit_code'],'capturer':tool['exit_code']}
  for s in [status,supervisor,tool]:assert s['native_receipt_sha256']==digest and s['case_sha256']==r['case_sha256']
  assert status['exit_code']==supervisor['exit_code'] and supervisor['launcher_status_sha256']==tool['launcher_status_sha256']==sha(artifact(prefix+'launcher-status.json'));assert tool['kind']=='observed-exec-tool-return' and tool['session_id']>0 and re.fullmatch('[0-9a-f]+',tool['chunk_id'])
  assert r['runtime_uid']==r['runtime_gid']==1000 and r['private_file_ownership_verified'] and r['deployment_retained'] and r['network']=='docker-none'
  snapshot=snapshots[r['resource_manifest_sha256']];effective=dict(snapshot['files']);effective['share/gcompris-qt/rcc/'+r['activity']+'.rcc']=r['private_rcc_sha256'];effective['share/gcompris-qt/translations/gcompris_qt_pt.qm']=r['private_qm_sha256'];assert r['resource_files_sha256']==effective and r['binary_sha256']==snapshot['files']['bin/gcompris-qt']
  compatible=entry['compatible_phases'];assert compatible
  for revision in compatible:
   source=sources[revision];assert source['src/activities/'+r['qml_file']]==r['source_sha256'] and source['poqm/pt/gcompris_qt.po']==r['portuguese_catalogue_sha256'] and source['tools/run-native-qml-case.py']==r['runner_sha256'];assert supervisor['supervisor_sha256']==source['tools/run-native-qml-supervised.py']
  assert r['renderer_requested']=='software' or r['xvfb_sha256']==sha(artifact('environment/Xvfb'));chosen=next(revision for revision in compatible if r['renderer_requested']=='software' or sources[revision]['tools/native_qml_headless.py']==r['headless_helper_sha256']);source=sources[chosen];assert artifact('capturers/'+entry['capturer'])
  report=js(prefix+'resources/physical.json');assert report['rcc_sha256']==r['private_rcc_sha256'] and report['qm_sha256']==r['private_qm_sha256'];assert artifact(prefix+'resources/'+r['activity']+'.rcc')==blob(report['rcc_sha256']);assert artifact(prefix+'resources/gcompris_qt_pt.qm')==blob(report['qm_sha256']) and blob(report['qm_sha256']).startswith(bytes.fromhex('3cb86418caef9c95cd211cbf60a1bddd'));assert sha(artifact(prefix+'resources/catalogue.ts'))==report['catalogue_ts_sha256']
  original=blob(source['src/activities/'+r['qml_file']]).decode();closing=re.search(r'\n    }\s*\n}\s*$',original);assert closing;fragment=case.decode().replace('__QA_OUTPUT__',entry['historical_output']).replace('__QA_SOURCE__',capture['phases'][chosen]['historical_source']);patched=('import QtTest\n'+original[:closing.start()]+'\n'+fragment+original[closing.start():]).encode();assert {row['path'].removeprefix(':/gcompris/') for row in report['files']}=={path for path in source if path.startswith('src/activities/'+r['activity']+'/')};physical(report,prefix+'resources/extracted',source,{'src/activities/'+r['qml_file']:patched})
  for image in r['screenshots']:assert sha(artifact(prefix+image['file']))==image['sha256'] and len(artifact(prefix+image['file']))==image['bytes']
  for saved in entry['saved_after_wait']:
   if saved['exists_after_wait']:blob(saved['sha256'])
  if name in POSITIVE:assert r['passed'] and r['exit_code']==0 and not r['qml_errors'] and r['case_result']['failures']==0 and status['exit_code']==0
 def e(name):return receipts[name]['case_result']['evidence']
 def image(name,path):return png(artifact('cases/'+name+'/'+path+'.png'))
 def rect(value):return tuple(value[k] for k in ['x','y','width','height'])
 def rgb(hexcode):return tuple(bytes.fromhex(hexcode.lstrip('#')[-6:]))
 def sample(im,x,y):return pixel(im,math.floor(x+.5),math.floor(y+.5))
 def equal_canvas(a,b,box):assert changed(a,b,rect(box))==0,'Painted content differs'
 n='simplepaint-levels-v5';levels=e(n)['levels'];assert len(levels)==31 and [v['level'] for v in levels]==list(range(1,32)) and e(n)['publicLevels']==31 and e(n)['wrap'] and e(n)['menu']
 for v in levels:
  label='level-'+str(v['level']);x,y=v['cell']['x'],v['cell']['y'];offset=v['cell']['width']*.08
  for state,color in [('initial','blank'),('painted','mousePaint'),('erased','erased'),('reload','reload')]:assert sample(image(n,label+'-'+state),x+offset,y+offset)==rgb(v[color]),(label,state,color)
  assert v['blank']==v['erased']==v['reload'] and v['mousePaint']==v['keyPaint']=='#550000';point=v['keyboard'];assert sample(image(n,label+'-keyboard'),v['grid']['x']+point['x'],v['grid']['y']+point['y'])==rgb(v['keyPaint'])
 n='simplepaint-palettes-green';palettes=e(n)['palettes'];assert [v['count'] for v in palettes]==[12,49]
 for palette in palettes:
  assert len(palette['colors'])==palette['count']
  for v in palette['colors']:
   tag='palette-'+str(palette['level'])+'-'+str(v['index']);s=v['swatch'];assert 0<=s['x']<1024 and 0<=s['y']<768;assert sample(image(n,tag+'-choice'),s['x']+s['width']/2,s['y']+s['height']/2)==rgb(v['swatchPixel']);assert sample(image(n,tag+'-paint'),v['grid']['x']+v['point']['x'],v['grid']['y']+v['point']['y'])==rgb(v['painted'])
   if v['index']:assert v['color']==v['painted']==v['swatchPixel']
 n='sketch-tracer-v6';canvas=e(n)['canvas'];assert changed(image(n,'initial'),image(n,'stroke'),rect(canvas))>100
 for a,b in [('initial','undo'),('stroke','redo'),('saved','opened'),('new','initial')]:equal_canvas(image(n,a),image(n,b),canvas)
 assert e(n)['fileNameTyped']=='CRIAÇÃO' and e(n)['menu']
 n='sketch-tools-v3';routes=e(n)['routes'];assert len(routes)==23 and [v['index'] for v in routes]==list(range(23));canvas=e(n)['canvas'];cx,cy,_,_=rect(canvas);tool_bounds=[]
 for v in routes:
  tag='route-'+str(v['index']);a=image(n,tag+'-before-widget');b=image(n,tag+'-after-widget');assert a[:2]==b[:2]==(936,622);count,box=bounds(a,b,(0,0,936,622));assert count>100,'No actual tool marks';tool_bounds.append(box)
  # Widget pixels must be the visible canvas, including both before/after states.
  for state,widget in [('before',a),('after',b)]:
   scene=image(n,tag+'-'+state)
   for y in range(0,622,7):
    for x in range(0,936,7):assert pixel(widget,x,y)==pixel(scene,x+round(cx),y+round(cy)),'Widget capture disagrees with full scene'
 assert routes[16]['text']=='OLÁ CRIAÇÃO'
 for index in [6,8]:
  l,t,r,b=tool_bounds[index];assert abs((r-l)-360)<=2 and abs((b-t)-240)<=2,'Rectangle/ellipse dimensions from real gesture'
 for v in routes[17:]:
  tag='route-'+str(v['index']);before=image(n,tag+'-before-widget');after=image(n,tag+'-after-widget');lightening=sum(sum(pixel(after,x,y))-sum(pixel(before,x,y)) for y in range(100,460,4) for x in range(150,550,4));assert lightening>100,'Eraser must remove existing darker marks'

 for index in [7,9]:
  l,t,r,b=tool_bounds[index];assert abs((r-l)-(b-t))<=2,'Square/circle geometry'
 l,t,r,b=tool_bounds[11];assert r-l>100 and b-t<=6,'Horizontal constrained line'
 for index in range(17,23):assert routes[index]['group']=='eraserTools'
 n='wheels-levels-v4';routes=e(n)['levels'];assert len(routes)==2 and [r['level'] for r in routes]==[1,2];errors=[]
 for route in routes:
  if route['level']==1:
   assert route['wheel']==96 and route['gear']==30 and len(route['fixed'])==7 and sum(len(row['gears']) for row in route['fixed'])==30
   route=dict(route,wheel=96,gear=30) # Numbers of the actual chosen labelled buttons.
  else:assert route['wheel']==route['wheelSlider']['value'] and route['gear']==route['gearSlider']['value']
  saved=next(row for row in capture['cases'][n]['saved_after_wait'] if row['name']=='RODAS'+str(route['level'])+'.svg');paths=svg_paths(blob(saved['sha256']));points=[point for path in paths for point in path['points']];err=curve_error(route,points);assert err<=3,'Drawn vector disagrees with rolling-circle equation';errors.append(err)
  assert route['reopened'] and route['stopped']==route['still'] and route['moving']!=route['initial']
 inventory=dependency['inventory'];assert [row['background'] for row in e('simplepaint-levels-v5')['levels']]==inventory['simple_backgrounds']
 for palette,declared in zip(e('simplepaint-palettes-green')['palettes'],[inventory['simple_palette'],inventory['advanced_palette']]):
  normalized=[color.lower() if not color.lower().startswith('#ff') else '#'+color[3:].lower() for color in declared];assert [row['color'] for row in palette['colors']]==normalized
 assert [e('sketch-controls-v5')['backgrounds'][str(i)]['source'] for i in range(42)]==inventory['sketch_backgrounds']
 n='fixed-resources';assert len(e(n)['images'])==159 and [row['source'] for row in e(n)['images']]==inventory['assets']
 for row in e(n)['images']:assert row['status']==1 and row['width']>0 and row['height']>0
 assert e('sketch-background-v2')['menu'] and e('wheels-controls-v2')['menu']
 assert e('sketch-controls-v5')['undoConfig']['persisted']==e('sketch-controls-v5')['undoConfig']['selected'] and e('wheels-controls-v2')['undoPersisted']==e('wheels-controls-v2')['undoSelected']
 assert len(e('sketch-controls-v5')['palettes'])==12 and len(e('sketch-controls-v5')['patterns'])==14 and len(e('sketch-controls-v5')['backgrounds'])==42
 for n in ['sketch-labels-green','wheels-labels-green']:
  assert receipts[n]['case_result']['failures']==0 and set(e(n)['expected'])<=set(e(n)['labels']);red=n.replace('green','red');assert receipts[red]['case_sha256']==receipts[n]['case_sha256'] and not receipts[red]['passed']
 assert receipts['simplepaint-palettes']['case_sha256']==receipts['simplepaint-palettes-green']['case_sha256'] and not receipts['simplepaint-palettes']['passed']
 for palette in e('sketch-controls-v5')['palettes']:
  assert len(palette['colors'])==9;scene=image('sketch-controls-v5','palette-'+str(palette['index']))
  for color in palette['colors']:
   x,y,w,h=rect(color['geometry']);assert sample(scene,x+w/2,y+h/2)==rgb(color['pixel'])==rgb(color['color'])
 assert e('sketch-background-v2')['backgroundColor']=='#e87836';orange=image('sketch-background-v2','orange-background');assert pixel(orange,50,50)==rgb('#e87836')

 assert used==set(objects),'Unreferenced archive object'
 return {'simplepaint_levels':31,'palette_choices':61,'sketch_tools':23,'wheel_levels':2,'fixed_images':159,'curve_max_errors':errors,'observed_statuses':observed,'scope':'Composite native routes; free combinations, Windows, hardware, hearing, teacher and task83 stability pending'}
if __name__=='__main__':
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--capsule',type=Path,default=Path(__file__).resolve().parents[2]/'.scratch/pt-pt/functional-creation/portable-capsule');args=parser.parse_args();print(json.dumps(audit(args.capsule),indent=2))
