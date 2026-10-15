#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Check finished counting receipts, original cases, screenshots and native logs."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

MAIN = ['enumerate-auto-settled', 'enumerate-ok-first', 'dice-complete-first', 'domino-complete-first']
PHYSICAL = ['enumerate-auto-physical', 'enumerate-ok-physical', 'dice-physical', 'domino-physical']
CONTROLS = ['enumerate-controls-navigation', 'dice-controls-first', 'domino-controls-first']
SELECTORS = ['enumerate-selectors', 'dice-selectors', 'domino-selectors']

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def collect(base):
    report = {'cases': [], 'main_questions': 0, 'physical_tracer_questions': 0, 'controls': {}}
    for name in MAIN + PHYSICAL + CONTROLS + SELECTORS:
        folder = base / name
        d = json.loads((folder / 'result.json').read_text())
        assert d['passed'] and d['exit_code'] == 0 and not d['timeout'] and not d['qml_errors'], name
        assert d['private_file_ownership_verified'] and not d['deployment_retained']
        assert sha(folder / 'case.qml') == d['case_sha256']
        assert d['network'] == 'docker-none'
        for image in d['screenshots']:
            assert sha(folder / image['file']) == image['sha256']
        if name in MAIN + PHYSICAL:
            subprocess.run([sys.executable, str(Path(__file__).with_name('audit.py')), '--result', str(folder / 'result.json'),
                            '--case', str(folder / 'case.qml'), '--output', str(folder / 'oracle.json')]
                           + (['--partial'] if name in PHYSICAL else []), check=True, capture_output=True)
            total = json.loads((folder / 'oracle.json').read_text())['questions']
            report['main_questions' if name in MAIN else 'physical_tracer_questions'] += total
            if name in PHYSICAL:
                assert 'property bool visualPreference: false' in (folder / 'case.qml').read_text()
        if name in CONTROLS[1:]:
            # Earlier launch commands captured generic Qt totals in result.json;
            # the original log preserves the case-specific observation marker.
            matches = re.findall(r'NATIVE_COUNTING_RESULT (\{[^\n]+\})', (folder / 'native.log').read_text())
            assert len(matches) == 1
            c = json.loads(matches[0]); assert c['failures'] == 0
            rows = c['observations']; speeds = [r for r in rows if 'speed' in r]
            assert [r['speed'] for r in speeds] == list(range(1, 11))
            assert all(r['toY'] > r['fromY'] for r in speeds)
            assert any(r.get('missed') and r['elapsedMs'] > 5000 for r in rows)
            assert any(r.get('recovered') for r in rows)
            assert any(r.get('focusRestored') and r.get('physicalWithoutVisual') for r in rows)
            report['controls'][name] = rows
        report['cases'].append({'name': name, 'result_sha256': sha(folder / 'result.json'), 'case_sha256': d['case_sha256']})
    assert report['main_questions'] == 848 and report['physical_tracer_questions'] == 174
    source_identity = json.loads((base / 'source-identity.json').read_text())
    root = Path(__file__).resolve().parents[2]
    for resource in source_identity.values():
        for row in resource['files']:
            assert sha(root / row['path'].removeprefix(':/gcompris/')) == row['sha256']
    report['rcc_source_files'] = sum(len(value['files']) for value in source_identity.values())
    assert report['rcc_source_files'] == 335
    files = {str(p.relative_to(base)): sha(p) for p in sorted(base.rglob('*'))
             if p.is_file() and not any(part.startswith('.native-qml-') for part in p.parts)
             and p.name not in ['index.json', 'artifacts-sha256.json']}
    (base / 'artifacts-sha256.json').write_text(json.dumps(files, indent=2) + '\n')
    (base / 'index.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
    return report

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--evidence', type=Path, required=True)
    args = parser.parse_args()
    result = collect(args.evidence)
    print(json.dumps({key: result[key] for key in ['main_questions', 'physical_tracer_questions']}))
