#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run the four native PT letter activities with real Qt input and offline assets.

Builds the test-only IME adapter. Requires the ordinary application already built,
Qt6 development tools and the cached Docker image used by run-native-qml-case.py.
No production build or application setting is modified.
"""
import argparse
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
CASES = [
    ('gletters', 'gletters/Gletters.qml', 'gletters.qml', 300),
    ('keyboard_training', 'keyboard_training/Keyboard_training.qml', 'keyboard_training.qml', 1100),
    ('click_on_letter', 'click_on_letter/ClickOnLetter.qml', 'click_on_letter.qml', 360),
    ('click_on_letter_up', 'click_on_letter/ClickOnLetter.qml', 'click_on_letter.qml', 360),
]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--binary', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--suite', choices=('all', 'gameplay', 'controls', 'navigation', 'audio', 'speed'), default='all')
    parser.add_argument('--workers', type=int, default=4)
    parser.add_argument('--qmltestrunner', default='/usr/lib/qt6/bin/qmltestrunner')
    args = parser.parse_args()
    if args.output.exists() and any(args.output.iterdir()):
        parser.error('Use a new empty output directory')
    if args.workers < 1:
        parser.error('--workers must be positive')
    args.output.mkdir(parents=True, exist_ok=True)
    output = args.output.resolve()
    adapter = ROOT / 'build/functional-input'
    subprocess.run(['cmake', '-S', str(ROOT / 'tests/functional_letters/native_input'),
                    '-B', str(adapter)], check=True)
    subprocess.run(['cmake', '--build', str(adapter), '-j2'], check=True)
    with (output / 'adapter.log').open('w') as log:
        subprocess.run([args.qmltestrunner, '-input', str(adapter / 'check')],
                       env=dict(os.environ, QT_QPA_PLATFORM='offscreen'),
                       stdout=log, stderr=subprocess.STDOUT, check=True)
    tasks = []
    if args.suite in ('all', 'gameplay'):
        tasks += [('gameplay', *row, None) for row in CASES]
    if args.suite in ('all', 'controls'):
        tasks += [('controls', activity, qml, 'controls.qml', 40, None)
                  for activity, qml, _, _ in CASES]
    if args.suite in ('all', 'navigation'):
        tasks += [('navigation', activity, 'click_on_letter/ClickOnLetter.qml',
                   'click_navigation.qml', 40, 3)
                  for activity in ('click_on_letter', 'click_on_letter_up')]

    if args.suite in ('all', 'audio'):
        tasks += [('audio', activity, qml, 'audio_route.qml', 30, None)
                  for activity, qml, _, _ in CASES]

    if args.suite in ('all', 'speed'):
        tasks += [('speed', 'gletters', 'gletters/Gletters.qml', 'speed.qml', 40, None)]

    def execute(task):
        suite, activity, qml, case, timeout, level = task
        target = output / suite / activity
        command = [sys.executable, str(ROOT / 'tools/run-native-qml-case.py'),
                   '--source-root', str(ROOT), '--binary', str(args.binary.resolve()),
                   '--activity', activity, '--qml-file', 'src/activities/' + qml,
                   '--case', 'tests/functional_letters/' + case, '--output', str(target),
                   '--timeout', str(timeout), '--result-marker', 'NATIVE_LETTERS_RESULT', '--offline']
        if level is not None:
            command += ['--start-level', str(level)]
        process = subprocess.run(command, cwd=ROOT, text=True, capture_output=True)
        path = target / 'result.json'
        return {'suite': suite, 'activity': activity, 'exit_code': process.returncode,
                'result': str(path.relative_to(output)),
                'result_sha256': sha(path) if path.exists() else None,
                'launcher_output': process.stdout + process.stderr}

    with ThreadPoolExecutor(max_workers=args.workers) as executor:
        results = list(executor.map(execute, tasks))
    libraries = list(adapter.glob('*functionalinput.so')) + list(adapter.glob('*functionalinput.dll'))
    summary = {'format': 1, 'suite': args.suite,
               'adapter_source_sha256': sha(ROOT / 'tests/functional_letters/native_input/input.cpp'),
               'adapter_libraries': {path.name: sha(path) for path in libraries},
               'cases': results, 'passed': all(row['exit_code'] == 0 for row in results),
               'scope': 'Only these native input/gameplay/control checks. No Windows, hardware keyboard layout or teacher pronunciation approval.'}
    (output / 'summary.json').write_text(json.dumps(summary, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps({'passed': summary['passed'], 'cases': len(results), 'summary': str(output / 'summary.json')}))
    return 0 if summary['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
