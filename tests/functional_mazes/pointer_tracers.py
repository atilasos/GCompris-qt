#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Replay actual mouse swipes in small, medium and large native mazes."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--snapshot', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    snapshot, output = args.snapshot.resolve(), args.output.resolve()
    if not (snapshot / 'manifest.json').is_file():
        parser.error('A sealed native snapshot is required')
    try:
        output.mkdir(parents=True, exist_ok=False)
    except FileExistsError:
        parser.error('Use a new output directory')
    template = Path(__file__).with_name('gameplay.qml.in').read_text()
    jobs = []
    for activity in ['maze', 'mazeinvisible', 'mazerelative']:
        for fast in [False, True]:
            for level in [1, 14, 25]:
                name = f'{activity}-{level}-' + ('fast' if fast else 'normal')
                case = output / (name + '.qml')
                source = template.replace('__QA_LEVELS__', '1').replace('__QA_FAST__', str(fast).lower()).replace('__QA_POINTER__', 'true')
                old = 'for(var level=0;level<levelCount;level++) {'
                assert source.count(old) == 1
                source = source.replace(old, f'for(var level={level-1};level<{level};level++) {{')
                case.write_text(source)
                jobs.append((activity, name, level, fast, case))

    def run(job):
        activity, name, level, fast, case = job
        command = [sys.executable, str(ROOT / 'tools/run-native-qml-case.py'), '--source-root', str(ROOT),
                   '--resource-snapshot', str(snapshot), '--activity', activity,
                   '--qml-file', str(ROOT / 'src/activities/maze/Maze.qml'), '--case', str(case),
                   '--output', str(output / name), '--start-level', str(level), '--timeout', '900',
                   '--result-marker', 'NATIVE_MAZE_RESULT', '--offline']
        with (output / (name + '.launcher.log')).open('w') as stream:
            code = subprocess.run(command, stdout=stream, stderr=subprocess.STDOUT).returncode
        path = output / name / 'result.json'
        receipt = json.loads(path.read_text()) if path.exists() else {}
        completed = receipt.get('case_result', {}).get('completed', [])
        passed = code == 0 and receipt.get('passed') is True
        passed = passed and len(completed) == 1 and completed[0]['level'] == level and completed[0]['fast'] == fast
        row = {'case': name, 'passed': passed, 'exit_code': code}
        print(json.dumps(row), flush=True)
        return row

    with ThreadPoolExecutor(max_workers=4) as pool:
        results = list(pool.map(run, jobs))
    passed = bool(results) and all(row['passed'] for row in results)
    (output / 'summary.json').write_text(json.dumps({'passed': passed, 'cases': results}, indent=2) + '\n')
    return 0 if passed else 1


if __name__ == '__main__':
    raise SystemExit(main())
