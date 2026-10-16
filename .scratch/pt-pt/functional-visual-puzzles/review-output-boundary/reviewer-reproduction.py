import importlib.util,json,sys,tempfile
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch
repo=Path('/home/proteu/Projetos/GCompris-qt');sys.path.insert(0,str(repo/'tests/functional_visual_puzzles'))
spec=importlib.util.spec_from_file_location('review88_runner',repo/'tests/functional_visual_puzzles/run.py');module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
with tempfile.TemporaryDirectory(prefix='review88-dangling-') as tmp:
 root=Path(tmp);output=root/'existing-link';output.symlink_to(root/'absent-target',target_is_directory=True);case=root/'case.qml';case.write_text('TestCase {}')
 with patch.object(sys,'argv',['run.py','--revision','unused','--activity','details','--case',str(case),'--output',str(output)]),patch.object(module,'freeze',return_value=root/'unused-source') as freeze,patch.object(module.subprocess,'run',return_value=SimpleNamespace(returncode=0)) as launch:
  code=module.main()
 print(json.dumps({'existing_symlink':output.is_symlink(),'source_preparation_called':freeze.called,'native_launch_attempted':launch.called,'new_parent_log_written':output.with_name(output.name+'.log').exists(),'runner_exit':code}))
 assert launch.called and freeze.called and output.with_name(output.name+'.log').exists()
