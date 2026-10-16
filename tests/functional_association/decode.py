#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Decode complete original WAV/OGG resources with libsndfile; no playback claim."""
import ctypes as C
import json
from pathlib import Path


class Info(C.Structure):
    _fields_=[('frames',C.c_int64),('samplerate',C.c_int),('channels',C.c_int),('format',C.c_int),('sections',C.c_int),('seekable',C.c_int)]


def decode(path):
    lib=C.CDLL('libsndfile.so.1')
    lib.sf_version_string.restype=C.c_char_p
    lib.sf_open.argtypes=[C.c_char_p,C.c_int,C.POINTER(Info)];lib.sf_open.restype=C.c_void_p
    lib.sf_readf_short.argtypes=[C.c_void_p,C.POINTER(C.c_short),C.c_int64];lib.sf_readf_short.restype=C.c_int64
    lib.sf_error.argtypes=[C.c_void_p];lib.sf_close.argtypes=[C.c_void_p]
    info=Info();handle=lib.sf_open(str(path).encode(),0x10,C.byref(info));assert handle
    try:
        buffer=(C.c_short*(4096*info.channels))();frames=0;peak=0
        while True:
            count=lib.sf_readf_short(handle,buffer,4096)
            if count==0:break
            assert count>0;frames+=count;peak=max(peak,max(abs(value) for value in buffer[:count*info.channels]))
        assert lib.sf_error(handle)==0 and frames==info.frames and frames>0
        return {'decoder':lib.sf_version_string().decode(),'frames':frames,'peak_pcm16':peak,'sample_rate':info.samplerate,'channels':info.channels,'duration':frames/info.samplerate}
    finally:lib.sf_close(handle)


if __name__=='__main__':
    import argparse
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--evidence',type=Path,required=True);args=parser.parse_args()
    report=args.evidence/'resources.json';records=json.loads(report.read_text())
    for record in records:
        if Path(record['file']).suffix in ('.ogg','.wav'):record['decoded']=decode(args.evidence/'resources'/record['file'])
    report.write_text(json.dumps(records,indent=2)+'\n')
