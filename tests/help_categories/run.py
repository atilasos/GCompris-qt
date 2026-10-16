#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Check all category tokens, the actual Qt catalogue and two native help sections."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import uuid
import xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[2]
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--binary',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--before-ref',help='Reproduce the old DialogHelp from this Git ref; native cases must fail')
    args=parser.parse_args()
    if args.output.exists() and any(args.output.iterdir()):parser.error('Use a new output directory')
    if not args.binary.is_file():parser.error('A built application is required')
    output=args.output.resolve();output.mkdir(parents=True,exist_ok=True)
    with (output/'data.log').open('w') as log:
        subprocess.run(['node','--test','tests/help_categories/categories.test.mjs'],cwd=ROOT,stdout=log,stderr=subprocess.STDOUT,check=True)
    workspace=ROOT/'build/help-categories'/uuid.uuid4().hex;workspace.mkdir(parents=True)
    probe=workspace/'qm-probe'
    flags=subprocess.check_output(['pkg-config','--cflags','--libs','Qt6Core','Qt6Qml'],text=True).split()
    subprocess.run(['c++','-std=c++17','-fPIC',str(ROOT/'tests/help_categories/qm_probe.cpp'),'-o',str(probe),*flags],check=True)
    ts=workspace/'pt.ts';qm=workspace/'pt.qm'
    subprocess.run(['/usr/lib/qt6/bin/lconvert','-target-language','pt_PT','-i',str(ROOT/'poqm/pt/gcompris_qt.po'),'-o',str(ts)],check=True)
    subprocess.run(['/usr/lib/qt6/bin/lrelease','-removeidentical','-nounfinished',str(ts),'-qm',str(qm)],check=True,capture_output=True)
    texts={}
    for locale,catalogue in [('pt_PT',str(qm)),('en','-')]:
        texts[locale]=json.loads(subprocess.check_output([str(probe),str(ROOT/'src/core/ActivityCategories.js'),catalogue],text=True))
        (output/(locale+'.json')).write_text(json.dumps(texts[locale],ensure_ascii=False,indent=2)+'\n')
    expected={'computer':'Computador','discovery':'Descoberta','sciences':'Ciências','fun':'Diversão','math':'Matemática','puzzle':'Quebra-cabeças','reading':'Leitura','strategy':'Estratégia','memory':'Memória','mouse':'Rato','keyboard':'Teclado','money':'Dinheiro','color':'Cores','colors':'Cores','maze':'Labirintos','addition':'Adição','braille':'Braille','subtraction':'Subtração','mobile':'Dispositivos móveis','multiplication':'Multiplicação','division':'Divisão','logic':'Lógica','arithmetic':'Aritmética','arts':'Arte','music':'Música','experiment':'Experiências','history':'História','geography':'Geografia','numeration':'Numeração','measures':'Medidas','letters':'Letras','words':'Palavras','vocabulary':'Vocabulário'}
    assert texts['pt_PT']['labels']==expected
    assert texts['en']['memory']=='Mathematics, Numeration'
    assert texts['pt_PT']['memory']=='Matemática, Numeração'
    inventory={}
    for line in (ROOT/'src/activities/activities.txt').read_text().splitlines():
        name=line.strip()
        if not name or name.startswith('#'):continue
        path=ROOT/'src/activities'/name/'ActivityInfo.qml'
        section=re.search(r'^\s*section:\s*"([^"]+)"',path.read_text(),re.M)[1]
        inventory[name]={'filter_ids':section,'labels':[expected[token] for token in section.split()],'source_sha256':sha(path)}
    assert len(inventory)==203
    (output/'inventory.json').write_text(json.dumps(inventory,ensure_ascii=False,indent=2)+'\n')
    (workspace/'bin').mkdir();binary=workspace/'bin/gcompris-qt';shutil.copy2(args.binary,binary)
    original=args.binary.resolve().parent.parent
    share=workspace/'share/gcompris-qt'
    for folder in ['rcc','translations']:
        (share/folder).mkdir(parents=True)
        for path in (original/'share/gcompris-qt'/folder).iterdir():
            if folder!='rcc' or path.name!='core.rcc':(share/folder/path.name).symlink_to(path)
    if (original/'lib/qml').exists():
        (workspace/'lib').mkdir();(workspace/'lib/qml').symlink_to(original/'lib/qml')
    previous=None
    if args.before_ref:
        previous=workspace/'DialogHelp-before.qml'
        previous.write_bytes(subprocess.check_output(['git','show',args.before_ref+':src/core/DialogHelp.qml'],cwd=ROOT))
    core=ROOT/'src/core';qrc=ET.Element('RCC');resource=ET.SubElement(qrc,'qresource',prefix='/gcompris/src/core')
    for path in sorted(core.rglob('*')):
        if path.is_file():ET.SubElement(resource,'file',alias=path.relative_to(core).as_posix()).text=str(previous if previous is not None and path.name=='DialogHelp.qml' else path)
    qrc_path=workspace/'core.qrc';ET.ElementTree(qrc).write(qrc_path,encoding='utf-8')
    rcc=share/'rcc/core.rcc';subprocess.run(['/usr/lib/qt6/libexec/rcc','--binary',str(qrc_path),'-o',str(rcc)],check=True)
    snapshot=workspace/'snapshot'
    with (output/'snapshot.log').open('w') as log:
        subprocess.run([sys.executable,str(ROOT/'tools/native_qml_resources.py'),'--binary',str(binary),'--output',str(snapshot)],stdout=log,stderr=subprocess.STDOUT,check=True)
    def native(task):
        activity,component=task
        process=subprocess.run([sys.executable,str(ROOT/'tools/run-native-qml-case.py'),'--source-root',str(ROOT),'--binary',str(binary),'--resource-snapshot',str(snapshot),'--activity',activity,'--qml-file',component,'--case','tests/help_categories/native.qml','--output',str(output/activity),'--timeout','40','--result-marker','NATIVE_CATEGORIES_RESULT','--offline'],cwd=ROOT,text=True,capture_output=True)
        return {'activity':activity,'exit_code':process.returncode,'launcher_output':process.stdout+process.stderr}
    with ThreadPoolExecutor(max_workers=2) as pool:
        results=list(pool.map(native,[('memory-wordnumber','src/activities/memory/MemoryCommon.qml'),('maze','src/activities/maze/Maze.qml')]))
    summary={'passed':all(row['exit_code']==0 for row in results),'activities':203,'category_tokens':33,'cases':results,'private_core_rcc_sha256':sha(rcc),'compiled_qm_sha256':sha(qm),'source_category_sha256':sha(ROOT/'src/core/ActivityCategories.js'),'core_source_ref':args.before_ref or 'working-tree','scope':'Category labels only; physical audio, Windows and teacher review pending.'}
    (output/'summary.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({'passed':summary['passed'],'cases':2,'activities':203,'tokens':33}))
    return 0 if summary['passed'] else 1
if __name__=='__main__':raise SystemExit(main())
