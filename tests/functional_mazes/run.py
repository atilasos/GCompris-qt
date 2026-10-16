#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run every native maze level in both walking modes against drawn walls."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--snapshot', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--levels', type=int, choices=range(1, 26), default=25)
    args = parser.parse_args()
    snapshot = args.snapshot.resolve()
    if not (snapshot / 'manifest.json').is_file():
        parser.error('A sealed native resource snapshot is required')
    output = args.output.resolve()
    try:
        output.mkdir(parents=True, exist_ok=False)
    except FileExistsError:
        parser.error('Use a new output directory')
    sources = sorted((ROOT / 'src/activities/maze').rglob('*'))
    sources += sorted((ROOT / 'src/activities/mazeinvisible').rglob('*'))
    sources += sorted((ROOT / 'src/activities/mazerelative').rglob('*'))
    sources += [ROOT / 'poqm/pt/gcompris_qt.po', ROOT / 'tools/run-native-qml-case.py',
                Path(__file__).resolve(), Path(__file__).with_name('gameplay.qml.in')]
    identity = {str(p.relative_to(ROOT)): sha(p) for p in sources if p.is_file()}
    (output / 'source-identity.json').write_text(json.dumps(identity, indent=2) + '\n')
    template = Path(__file__).with_name('gameplay.qml.in').read_text()
    jobs = []
    for activity in ['maze', 'mazeinvisible', 'mazerelative']:
        for fast in [False, True]:
            name = activity + ('-fast' if fast else '-normal')
            case = output / (name + '.qml')
            case.write_text(template.replace('__QA_LEVELS__', str(args.levels))
                            .replace('__QA_FAST__', str(fast).lower())
                            .replace('__QA_POINTER__', 'false'))
            jobs.append((activity, name, case))

    def run(job):
        activity, name, case = job
        command = [sys.executable, str(ROOT / 'tools/run-native-qml-case.py'),
                   '--source-root', str(ROOT), '--resource-snapshot', str(snapshot),
                   '--activity', activity, '--qml-file', str(ROOT / 'src/activities/maze/Maze.qml'),
                   '--case', str(case), '--output', str(output / name), '--timeout', '2400',
                   '--result-marker', 'NATIVE_MAZE_RESULT', '--offline']
        with (output / (name + '.launcher.log')).open('w') as stream:
            code = subprocess.run(command, stdout=stream, stderr=subprocess.STDOUT).returncode
        result_path = output / name / 'result.json'
        receipt = json.loads(result_path.read_text()) if result_path.exists() else {}
        passed = code == 0 and receipt.get('passed') is True
        passed = passed and len(receipt.get('case_result', {}).get('completed', [])) == args.levels
        print(json.dumps({'case': name, 'passed': passed}), flush=True)
        return {'case': name, 'passed': passed, 'exit_code': code}

    with ThreadPoolExecutor(max_workers=6) as pool:
        results = list(pool.map(run, jobs))
    unchanged = all(sha(ROOT / path) == digest for path, digest in identity.items())
    passed = bool(results) and all(row['passed'] for row in results) and unchanged
    (output / 'summary.json').write_text(json.dumps({'passed': passed, 'sources_unchanged': unchanged,
                                                   'cases': results}, indent=2) + '\n')
    return 0 if passed else 1


if __name__ == '__main__':
    raise SystemExit(main())
