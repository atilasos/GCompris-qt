#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run native deployed activities; this checks startup, not level completion."""
import argparse
import json
from pathlib import Path
import re
import subprocess
import time

ACTIVITIES = ['grammar_classes', 'grammar_analysis', 'click_on_letter', 'gletters',
              'keyboard_training', 'multiple_choice_questions', 'ordering_chronology', 'fractions_create']
ERROR = re.compile(r"Expected token|Type \w+ unavailable|(?:Reference|Type|Syntax)Error:|QQmlApplicationEngine failed|module .* is not installed|Error: Your root item|QML.*(?:Cannot open|Error decoding)")


def read_activities(path):
    names = [line.split('#', 1)[0].strip() for line in path.read_text(encoding='utf-8-sig').splitlines()]
    names = [name for name in names if name]
    if not names or len(set(names)) != len(names) or any(not re.fullmatch(r'[A-Za-z0-9_][A-Za-z0-9_-]*', name) for name in names):
        raise ValueError('Activity manifest must contain unique safe activity identifiers')
    return names


def check_startup(binary, activity, expected_voice, seconds, output):
    stdout = output / f'{activity}.stdout.log'
    stderr = output / f'{activity}.stderr.log'
    with stdout.open('w', encoding='utf-8') as out, stderr.open('w', encoding='utf-8') as err:
        process = subprocess.Popen([str(binary), '--window', '--locale', 'pt_PT', '--renderer', 'software', '--launch', activity], stdout=out, stderr=err)
        try:
            deadline = time.monotonic() + seconds
            while process.poll() is None and time.monotonic() < deadline:
                time.sleep(0.05)
            early_exit = process.poll()
        finally:
            if process.poll() is None:
                process.terminate()
                try:
                    process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait()
    text = stdout.read_text(encoding='utf-8', errors='replace') + stderr.read_text(encoding='utf-8', errors='replace')
    errors = [line for line in text.splitlines() if ERROR.search(line)]
    launched = f'Start activity {activity}/' in text
    registered = bool(re.search(r'Successfully registered resource[^\r\n]*' + re.escape(expected_voice), text))
    return {'activity': activity, 'passed': early_exit is None and launched and registered and not errors,
            'early_exit': early_exit, 'launch_marker': launched, 'completed_voices_registered': registered,
            'qml_errors': errors, 'seconds': seconds}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--binary', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--activities-file', type=Path, help='Authoritative full activity manifest for installed startup checks')
    parser.add_argument('--seconds', type=float, default=6)
    parser.add_argument('--expected-voice', default='voices-pt-2026-10-15-00-00-00.rcc')
    args = parser.parse_args()
    try:
        activities = read_activities(args.activities_file) if args.activities_file else ACTIVITIES
    except (OSError, ValueError) as error:
        parser.error(str(error))
    if args.seconds <= 0:
        parser.error('Startup duration must be positive')
    args.output.mkdir(parents=True, exist_ok=True)
    listing = subprocess.run([str(args.binary), '--locale', 'pt_PT', '--renderer', 'software', '--list-activities'], capture_output=True, timeout=60)
    (args.output / 'activities.txt').write_bytes(listing.stdout)
    (args.output / 'listing.stderr.log').write_bytes(listing.stderr)
    listed = listing.stdout.decode('utf-8-sig', errors='replace').split()
    list_matches = args.activities_file is None or (len(listed) == len(activities) and set(listed) == set(activities))
    # Sequential launches share the initially fresh CI Windows profile.
    results = [check_startup(args.binary, name, args.expected_voice, args.seconds, args.output) for name in activities]
    result = {'passed': listing.returncode == 0 and list_matches and all(row['passed'] for row in results),
              'activity_list_matches_manifest': list_matches, 'expected_activities': len(activities),
              'list_exit_code': listing.returncode, 'activities': results,
              'scope': 'Native offline startup in the same CI Windows user; no level completion or audible playback acceptance'}
    (args.output / 'startup-check.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))
    raise SystemExit(0 if result['passed'] else 1)
