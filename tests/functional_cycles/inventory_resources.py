#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Inspect actual canonical RCC bytes; keep exports outside immutable inputs."""
import argparse,hashlib,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--snapshot',type=Path,required=True);parser.add_argument('--output',type=Path,required=True);parser.add_argument('--tool',type=Path,required=True);args=parser.parse_args()
 if args.output.exists():parser.error('Output must be new')
 args.output.mkdir(parents=True);result={'inventory_tool_sha256':hashlib.sha256(args.tool.read_bytes()).hexdigest(),'rccs':{}}
 for name in ['canal_lock','watercycle','renewable_energy','core','chess']:
  rcc=args.snapshot/'share/gcompris-qt/rcc'/(name+'.rcc');export=ROOT/'build/functional-cycles/canonical'/name
  if export.exists():raise ValueError('Canonical export already exists')
  command=[str(args.tool.absolute()),str(rcc.absolute()),str(export.absolute())];run=subprocess.run(command,capture_output=True,text=True);run.check_returncode();files=json.loads(run.stdout)
  (args.output/(name+'.json')).write_text(run.stdout)
  result['rccs'][name]={'rcc_sha256':hashlib.sha256(rcc.read_bytes()).hexdigest(),'files':files,'command':command,'exit_code':run.returncode}
 (args.output/'index.json').write_text(json.dumps(result,indent=2)+'\n')
 print({name:len(row['files']) for name,row in result['rccs'].items()})
if __name__=='__main__':main()
