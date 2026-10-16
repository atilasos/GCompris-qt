#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Record an independently observed final tool response, once, after wait."""
import argparse,hashlib,json
from pathlib import Path
if not __debug__:raise SystemExit('Grids observations require assertions; Python -O rejected')
def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True);parser.add_argument('--session',type=int,required=True);parser.add_argument('--chunk',required=True);parser.add_argument('--code',type=int,required=True);args=parser.parse_args();p=args.output;sha=lambda f:hashlib.sha256((p/f).read_bytes()).hexdigest();value={'format':1,'kind':'observed-exec-tool-return','session_id':args.session,'exit_code':args.code,'chunk_id':args.chunk,'stdout':'','native_receipt_sha256':sha('result.json'),'launcher_status_sha256':sha('launcher-status.json'),'case_sha256':sha('case.qml'),'provenance':'Actual tools.write_stdin final return after wait, independent of native receipt.'}
 with (p/'tool-exit.json').open('x') as stream:stream.write(json.dumps(value,indent=2)+'\n')
if __name__=='__main__':main()
