#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Preserve actual selected snapshot RCC files and their QtCore extractions."""
import hashlib,json,shutil,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
NAMES=['core','babymatch','details','paintings','photo_hunter','guesscount','tic_tac_toe']
def main():
 base=ROOT/'.scratch/pt-pt/functional-visual-puzzles/canonical'
 if base.exists():raise ValueError('Canonical evidence already exists')
 tool=Path('/home/proteu/Projetos/GCompris-qt/build/pt-pt/bin/pt_audio_rcc_inventory');snapshot=ROOT/'build/visual-origin';records={}
 for name in NAMES:
  rcc=snapshot/'share/gcompris-qt/rcc'/(name+'.rcc');destination=base/name;destination.mkdir(parents=True);shutil.copyfile(rcc,destination/'resource.rcc')
  command=[str(tool),str(rcc),str(destination/'files')];run=subprocess.run(command,capture_output=True,text=True);run.check_returncode();records[name]={'sha256':hashlib.sha256(rcc.read_bytes()).hexdigest(),'argv':command,'exit_code':run.returncode,'files':json.loads(run.stdout)}
 (base/'index.json').write_text(json.dumps(records,indent=2)+'\n');print({name:len(record['files']) for name,record in records.items()})
if __name__=='__main__':main()
