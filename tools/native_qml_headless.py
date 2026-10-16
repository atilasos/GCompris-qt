#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run one OpenGL case on private Xvfb inside the offline container's tmpfs."""
import argparse,os,socket,subprocess,time
from pathlib import Path

def environment(original):
    env=dict(original)
    for key in ['XAUTHORITY','QT_QUICK_BACKEND']:env.pop(key,None)
    env.update(DISPLAY=':99',LIBGL_ALWAYS_SOFTWARE='1',QT_QPA_PLATFORM='xcb')
    return env

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--xvfb',type=Path,required=True)
    parser.add_argument('command',nargs=argparse.REMAINDER)
    args=parser.parse_args();command=args.command
    if command[:1]==['--']:command=command[1:]
    if not args.xvfb.is_file() or not command:parser.error('Existing Xvfb and command required')
    env=environment(os.environ)
    Path('/tmp/.X11-unix').mkdir(mode=0o1777,exist_ok=True)
    server=subprocess.Popen([str(args.xvfb),':99','-screen','0','1024x768x24','-nolisten','tcp','-ac','-noreset'],env=env)
    try:
        ready=False
        for attempt in range(100):
            if server.poll() is not None:raise RuntimeError('Private Xvfb exited before startup')
            with socket.socket(socket.AF_UNIX) as connection:
                try:connection.connect('/tmp/.X11-unix/X99');ready=True;break
                except OSError:time.sleep(.05)
        if not ready:raise RuntimeError('Private Xvfb did not become ready')
        print('NATIVE_PRIVATE_XVFB_READY display=:99 Mesa-software=true',flush=True)
        return subprocess.run(command,env=env).returncode
    finally:
        if server.poll() is None:server.terminate()
        server.wait(timeout=10)
if __name__=='__main__':raise SystemExit(main())
