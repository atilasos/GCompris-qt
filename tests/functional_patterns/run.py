#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run one case against an atomically frozen phase and private offline runtime."""
import argparse,subprocess,sys
from pathlib import Path
from phase import ROOT,freeze
FILES={'redraw':'redraw/Redraw.qml','redraw_symmetrical':'redraw/Redraw.qml','mosaic':'mosaic/Mosaic.qml','polygons':'polygons/Polygons.qml'}
def main():
 parser=argparse.ArgumentParser(description=__doc__)
 parser.add_argument('--revision',required=True);parser.add_argument('--activity',choices=FILES,required=True)
 parser.add_argument('--case',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
 parser.add_argument('--snapshot',type=Path,default=ROOT/'build/patterns-origin');parser.add_argument('--timeout',type=int,default=240)
 args=parser.parse_args();output=args.output.absolute();log=output.parent/(output.name+'.log')
 if output.exists() or output.is_symlink() or log.exists() or log.is_symlink():parser.error('Output and parent log must both be new')
 if not args.case.is_file():parser.error('Case must exist')
 source=freeze(args.revision);output.parent.mkdir(parents=True,exist_ok=True)
 command=[sys.executable,str(ROOT/'tests/functional_patterns/capture.py'),'--launcher',str(source/'tools/run-native-qml-case.py'),'--source-root',str(source),'--activity',args.activity,'--qml-file',str(source/'src/activities'/FILES[args.activity]),'--case',str(args.case.absolute()),'--output',str(output),'--resource-snapshot',str(args.snapshot.absolute()),'--offline','--offline-container-image','sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b','--keep-deployment','--timeout',str(args.timeout)]
 with log.open('x') as stream:process=subprocess.run(command,stdout=stream,stderr=subprocess.STDOUT)
 return process.returncode
if __name__=='__main__':raise SystemExit(main())
