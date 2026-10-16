# SPDX-License-Identifier: GPL-3.0-or-later
# Executed by gdb's Python interpreter. Filled paths are explicit diagnostic inputs.
import datetime,hashlib,json,os,pathlib
import gdb
OUTPUT=pathlib.Path('/home/proteu/Projetos/GCompris-qt-worktrees/pt-penalty-shutdown/.scratch/pt-pt/penalty-shutdown/probes/baseline-retained')
record={'kind':'gdb-inferior-observation','gdb_pid':os.getpid(),'qt_pid':None,'identity_observed':False,'native_exit_code':None,'signals':[]}
def save():
 (OUTPUT/'inferior-status.json').write_text(json.dumps(record,indent=2)+'\n')
def observe():
 pid=gdb.selected_inferior().pid
 if not pid:return
 proc=pathlib.Path('/proc')/str(pid);argv=(proc/'cmdline').read_bytes().split(b'\0');binary=gdb.current_progspace().filename
 record.update(qt_pid=pid,binary=binary,argv=[v.decode(errors='replace') for v in argv if v],cmdline_matches_binary=bool(argv and argv[0].decode()==binary),binary_sha256=hashlib.sha256(pathlib.Path(binary).read_bytes()).hexdigest(),gdb_pid_namespace=os.readlink('/proc/self/ns/pid'),qt_pid_namespace=os.readlink(str(proc/'ns/pid')),identity_observed=True,observed_utc=datetime.datetime.now(datetime.timezone.utc).isoformat())
 record['proc_status']=[line for line in (proc/'status').read_text().splitlines() if line.split(':')[0] in ['Name','Pid','PPid','NSpid','Uid','VmRSS','VmSize']];save()
class AtMain(gdb.Breakpoint):
 def stop(self):
  observe();return False
AtMain('main',temporary=True,internal=True)
def stopped(event):
 if isinstance(event,gdb.SignalEvent):
  record['signals'].append(event.stop_signal);save()
  if event.stop_signal=='SIGSEGV':
   for name,command in [('stack.txt','thread apply all bt full'),('registers.txt','info registers'),('mappings.txt','info proc mappings')]:
    try:(OUTPUT/name).write_text(gdb.execute(command,to_string=True))
    except gdb.error as error:(OUTPUT/name).write_text(str(error))
def exited(event):
 record['native_exit_code']=getattr(event,'exit_code',None);save()
gdb.events.stop.connect(stopped);gdb.events.exited.connect(exited);save()
