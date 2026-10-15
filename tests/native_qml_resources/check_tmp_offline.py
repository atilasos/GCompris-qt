#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Exercise normal offline Qt cases with runtime resources underneath /tmp."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[2]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--binary', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True, help='new evidence directory outside /tmp')
    args = parser.parse_args()
    output = args.output.resolve()
    if output.exists() or output.is_relative_to('/tmp'):
        parser.error('--output must be a new directory outside /tmp')
    output.mkdir(parents=True)
    temporary = Path(tempfile.mkdtemp(prefix='gcompris-qml-tmp-', dir='/tmp'))
    snapshot = temporary / 'external-snapshot'
    subprocess.run([sys.executable, str(ROOT / 'tools/native_qml_resources.py'),
                    '--binary', str(args.binary.resolve()), '--output', str(snapshot)],
                   check=True, capture_output=True, text=True)
    checks = []
    for name, case_output, resources in [
        ('automatic', temporary / 'automatic-case', ['--binary', str(args.binary.resolve())]),
        ('external', output / 'external-case', ['--resource-snapshot', str(snapshot)]),
    ]:
        command = [sys.executable, str(ROOT / 'tools/run-native-qml-case.py'), *resources,
                   '--activity', 'click_on_letter', '--qml-file',
                   str(ROOT / 'src/activities/click_on_letter/ClickOnLetter.qml'),
                   '--case', str(ROOT / 'tests/functional_letters/click_navigation.qml'),
                   '--output', str(case_output), '--start-level', '3',
                   '--result-marker', 'NATIVE_LETTERS_RESULT', '--offline', '--timeout', '45']
        execution = subprocess.run(command, capture_output=True, text=True)
        evidence = output / (name + '-evidence')
        evidence.mkdir()
        (evidence / 'launcher.stderr').write_text(execution.stderr)
        result_path = case_output / 'result.json'
        result = json.loads(result_path.read_text()) if result_path.is_file() else {}
        for filename in ['result.json', 'native.log']:
            if (case_output / filename).is_file():
                shutil.copy2(case_output / filename, evidence / filename)
        deployment_removed = bool(result) and not Path(result['deployment']).exists()
        owner_matches = (result.get('private_file_ownership_verified') is True
                         and result.get('runtime_uid') == os.getuid()
                         and result.get('runtime_gid') == os.getgid())
        passed = (execution.returncode == 0 and result.get('passed') is True
                  and deployment_removed and owner_matches)
        checks.append({'case': name, 'passed': passed, 'launcher_exit': execution.returncode,
                       'case_result': result.get('case_result'), 'deployment_removed': deployment_removed,
                       'ownership_verified': owner_matches, 'output': str(case_output),
                       'snapshot': result.get('resource_snapshot')})
    passed = all(check['passed'] for check in checks)
    if passed:
        shutil.rmtree(temporary)
    summary = {'passed': passed, 'checks': checks, 'temporary_root': str(temporary),
               'temporary_removed': not temporary.exists()}
    (output / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps(summary))
    return 0 if passed else 1


if __name__ == '__main__':
    raise SystemExit(main())
