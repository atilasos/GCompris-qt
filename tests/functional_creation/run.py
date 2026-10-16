#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run real creation UI with frozen inputs and retain physical effective resources."""
import argparse,hashlib,json,os,shutil,subprocess,sys,uuid
from pathlib import Path
from rcc_export import compile_exporter,export_resources
from phase import ACTIVITIES,verify_source
if not __debug__:raise SystemExit('Creation validation requires assertions; Python -O rejected')
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--source-root',type=Path,required=True);parser.add_argument('--snapshot',type=Path,required=True);parser.add_argument('--activity',choices=ACTIVITIES,required=True);parser.add_argument('--output',type=Path,required=True);parser.add_argument('--renderer',choices=['software','opengl'],default='software');parser.add_argument('--xvfb',type=Path);parser.add_argument('--exact-case',type=Path,required=True);args=parser.parse_args()
 if args.output.is_symlink() or args.output.exists():parser.error('Use a new output directory')
 source=args.source_root.resolve();output=args.output.resolve()
 verify_source(source);text=args.exact_case.read_text();case=ROOT/'build/creation-cases'/(hashlib.sha256(text.encode()).hexdigest()+'.qml');case.parent.mkdir(parents=True,exist_ok=True)
 if case.exists():assert case.read_text()==text
 else:case.write_text(text)
 syntax=subprocess.run(['/usr/lib/qt6/bin/qmlformat','--ignore-settings',str(case)],capture_output=True,text=True)
 if syntax.returncode:parser.error('Invalid QML case: '+syntax.stderr)
 command=[sys.executable,str(source/'tools/run-native-qml-supervised.py'),'--source-root',str(source),'--resource-snapshot',str(args.snapshot.resolve()),'--activity',args.activity,'--qml-file',str(source/'src/activities'/args.activity/({'simplepaint':'Simplepaint.qml','sketch':'Sketch.qml','drawing_wheels':'DrawingWheels.qml'}[args.activity])),'--case',str(case),'--output',str(output),'--offline','--keep-deployment','--timeout','1800','--result-marker','NATIVE_CREATION_RESULT']
 if args.renderer=='opengl':command+=['--renderer','opengl','--xvfb',str(args.xvfb.resolve())]
 completed=subprocess.run(command,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1',PYTHONPYCACHEPREFIX=str(ROOT/'build/creation-python-cache'/uuid.uuid4().hex)))
 if output.exists():
  shutil.copyfile(case,output/'case.qml');receipt=output/'result.json';status=output/'launcher-status.json';observed={'kind':'observed-supervisor-subprocess-exit','exit_code':completed.returncode,'native_receipt_sha256':sha(receipt) if receipt.is_file() else None,'launcher_status_sha256':sha(status) if status.is_file() else None,'case_sha256':sha(case),'supervisor_sha256':sha(source/'tools/run-native-qml-supervised.py')};(output/'supervisor-exit.json').write_text(json.dumps(observed,indent=2)+'\n')
  if receipt.is_file():
   value=json.loads(receipt.read_text());deployment=Path(value['deployment']);resources=output/'resources';resources.mkdir();rcc=resources/(args.activity+'.rcc');qm=resources/'gcompris_qt_pt.qm';shutil.copyfile(deployment/'share/gcompris-qt/rcc'/(args.activity+'.rcc'),rcc);shutil.copyfile(deployment/'share/gcompris-qt/translations/gcompris_qt_pt.qm',qm);assert sha(rcc)==value['private_rcc_sha256'] and sha(qm)==value['private_qm_sha256'];cpp=source/'tools/pt-pt-audio/rcc_inventory.cpp';inspector=resources/'inspector';compile_exporter(cpp,inspector);rows=export_resources(inspector,rcc,resources/'extracted');inspector.unlink();subprocess.run(['/usr/lib/qt6/bin/lconvert','-i',str(qm),'-o',str(resources/'catalogue.ts')],check=True,capture_output=True);(resources/'physical.json').write_text(json.dumps({'rcc_sha256':sha(rcc),'qm_sha256':sha(qm),'inspector_source_sha256':sha(cpp),'files':rows,'catalogue_ts_sha256':sha(resources/'catalogue.ts')},indent=2)+'\n')
  if receipt.is_file() and value.get('case_result'):
   saved=value['case_result'].get('evidence',{}).get('savedFiles',[])
   if saved:
    destination=output/'creations';destination.mkdir();records=[]
    for name in saved:
     original=Path(name);assert original.resolve().is_relative_to((deployment/'profile').resolve()) and original.is_file()
     with (destination/original.name).open('xb') as stream:stream.write(original.read_bytes())
     records.append({'file':original.name,'sha256':sha(original),'historical_path':str(original)})
    (destination/'files.json').write_text(json.dumps(records,indent=2)+'\n')
 return completed.returncode
if __name__=='__main__':raise SystemExit(main())
