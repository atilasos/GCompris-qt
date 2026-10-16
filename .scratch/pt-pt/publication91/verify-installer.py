from pathlib import Path
import hashlib,importlib.util,json,subprocess
ROOT=Path('/home/proteu/Projetos/GCompris-qt')
RUN='38894977302'
HEAD='3c98f5c6b4543e15dda66e2b0e275f5d9e6b49df'
BASE=ROOT/'build/pt-pt/download-publication-short'
EXE=ROOT/('build/pt-pt/windows-candidate-'+RUN)/'GCompris-PT-PT-Windows-x64-candidate.exe'
OUTPUT=BASE/'actual-installer'
TOOL=ROOT/'build/pt-pt/bin/pt_audio_rcc_inventory'
SEVENZIP='/tmp/gcompris-7zip-26/extracted/usr/lib/7zip/7z'
def require(ok,message):
 if not ok:raise ValueError(message)
def digest(path):
 with path.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()
def inventory(path,export=None):
 args=[str(TOOL),str(path)]
 if export:args.append(str(export))
 rows=json.loads(subprocess.check_output(args))
 return {row['path']:row['sha256'] for row in rows}
require(not OUTPUT.exists(),'Use a new extraction output')
proof=json.loads((ROOT/'.scratch/pt-pt/windows'/RUN/'download-verification.json').read_text())
require(proof['verified'] and proof['head_sha']==HEAD and digest(EXE)==proof['sha256'],'Actual installer identity mismatch')
OUTPUT.mkdir()
with (BASE/'actual-installer-extraction.log').open('w') as log:
 subprocess.run([SEVENZIP,'x','-y','-o'+str(OUTPUT),str(EXE),'source-commit.txt','assets-lock.json',
                 'share/GCompris/rcc/lang.rcc','share/GCompris/rcc/grammar_classes.rcc','share/GCompris/rcc/grammar_analysis.rcc','share/GCompris/rcc/data3/voices-ogg/*'],check=True,stdout=log,stderr=subprocess.STDOUT)
require((OUTPUT/'source-commit.txt').read_text(encoding='utf-8-sig').strip()==HEAD,'Packaged source revision mismatch')
lock=json.loads((OUTPUT/'assets-lock.json').read_text(encoding='utf-8'))
require(lock==json.loads((ROOT/'tools/windows/assets-lock.json').read_text(encoding='utf-8')),'Packaged policy differs from source')
voices=OUTPUT/'share/GCompris/rcc/data3/voices-ogg'
completion=json.loads((voices/'completion.json').read_text(encoding='utf-8'))
spec=importlib.util.spec_from_file_location('candidate_policy',ROOT/'tools/windows/verify-package.py')
policy=importlib.util.module_from_spec(spec);spec.loader.exec_module(policy)
selected=policy.approved_completion_files(completion,lock['pt_voice_completion'],lock['pt_voice_container_variants'])
require(selected is not None,'Unapproved container/index pair in actual installer')
for row in selected:
 path=voices/row['path']
 require(path.stat().st_size==row['bytes'] and digest(path)==row['sha256'],'Packaged resource failed fixed policy: '+row['path'])
manifest=json.loads((ROOT/'resources/pt-pt-voices/manifest.json').read_text(encoding='utf-8'))
source=voices/manifest['source_rcc']
require(digest(source)==manifest['source_rcc_sha256'],'Packaged upstream RCC changed')
old=inventory(source)
completed=voices/completion['files'][0]['path']
new=inventory(completed)
expected=dict(old)
for row in manifest['recordings']:expected[':/gcompris/data/voices-ogg/pt/'+row['file']]=row['sha256']
replacements=json.loads((ROOT/'resources/pt-pt-voices/replacements.json').read_text(encoding='utf-8'))
for row in replacements['recordings']:expected[':/gcompris/data/voices-ogg/pt/'+row['file']]=row['sha256']
require(len(old)==1578 and len(new)==1610 and new==expected,'Actual installer voice inventory differs from approved resources')
changed=sorted(key for key in old if old[key]!=new.get(key))
require(changed==[':/gcompris/data/voices-ogg/pt/words/fawn.ogg',':/gcompris/data/voices-ogg/pt/words/tick.ogg'],'Unexpected original voice replacements')
lang=OUTPUT/'share/GCompris/rcc/lang.rcc'
export=BASE/'actual-lang-export'
inventory(lang,export)
labels=json.loads((export/'gcompris/src/activities/lang/resource/content-pt.json').read_text(encoding='utf-8'))
require(labels==json.loads((ROOT/'src/activities/lang/resource/content-pt.json').read_text(encoding='utf-8')),'Packaged Portuguese vocabulary differs semantically from source')
require(labels['fawn.ogg']=='cervato' and labels['tick.ogg']=='carraça','Approved labels missing')
grammar={}
for activity in ['grammar_classes','grammar_analysis']:
 export_grammar=BASE/('actual-'+activity+'-export')
 inventory(OUTPUT/'share/GCompris/rcc'/(activity+'.rcc'),export_grammar)
 relative=Path('src/activities')/activity/'resource'/(activity+'-pt.json')
 data=json.loads((export_grammar/'gcompris'/relative).read_text(encoding='utf-8'))
 require(data==json.loads((ROOT/relative).read_text(encoding='utf-8')),'Packaged Portuguese grammar differs from source: '+activity)
 grammar[activity]={'levels':len(data['levels']),'matches_portuguese_source':True}
result={'run':RUN,'source':HEAD,'installer_sha256':proof['sha256'],'passed':True,'selected_container_files':completion['files'],
        'original_resources':len(old),'total_resources':len(new),'intact_originals':1576,'intact_additions':32,
        'grammar_resources':grammar,'changed_originals':changed,'labels':{key:labels[key] for key in ['fawn.ogg','tick.ogg']},
        'inventory_sha256':hashlib.sha256(json.dumps(new,sort_keys=True).encode()).hexdigest(),
        'scope':'Actual NSIS installer extracted and Qt resource bytes read on Linux; not installer execution or human hearing'}
(BASE/'actual-installer-verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(result,ensure_ascii=False,indent=2),flush=True)
