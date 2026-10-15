#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Inventory generic Qt key handlers; candidates need native event reproduction."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re


def block(text, opening):
    depth = 1
    end = opening + 1
    while depth and end < len(text):
        if text[end] == '{': depth += 1
        elif text[end] == '}': depth -= 1
        end += 1
    return text[opening + 1:end - 1]


def inventory(root):
    result = []
    for path in sorted((root / 'src/activities').rglob('*.qml')):
        source = path.read_text()
        # Preserve line numbers while excluding commented-out handler examples.
        stripped = re.sub(r'/\*.*?\*/|//[^\n]*', lambda m: re.sub(r'[^\n]', ' ', m[0]), source, flags=re.S)
        for match in re.finditer(r'\bKeys\.onPressed\s*:\s*(?:\([^)]*\)\s*=>\s*)?\{', stripped):
            body = block(stripped, match.end() - 1)
            calls = re.findall(r'\bActivity\.(\w+)\(\s*event\s*\)', body)
            delegated = []
            for name in calls:
                for script in path.parent.glob('*.js'):
                    text = script.read_text()
                    function = re.search(r'function\s+' + re.escape(name) + r'\s*\([^)]*\)\s*\{', text)
                    if function:
                        delegated.append(block(text, function.end() - 1))
            handles_arrows = bool(re.search(r'Qt\.Key_(?:Left|Right|Up|Down)', body + ''.join(delegated)))
            consumes = bool(re.search(r'event\.accepted\s*=', body + ''.join(delegated)))
            result.append({'path': str(path.relative_to(root)), 'line': source.count('\n', 0, match.start()) + 1,
                           'has_arrow_branch': handles_arrows, 'has_explicit_acceptance': consumes,
                           'delegates': calls, 'candidate': handles_arrows and not consumes})
    return result


def compare(root, current, baseline_path, evidence_path):
    baseline = json.loads(baseline_path.read_text())['handlers']
    evidence = json.loads(evidence_path.read_text())
    if len({row['path'] for row in baseline}) != len(baseline):
        raise ValueError('Baseline contains multiple handlers in a file; disambiguate before comparison')
    initial = {row['path']: row for row in baseline}
    if set(initial) != {row['path'] for row in current}:
        raise ValueError('The handler inventory changed; review added/removed handlers')
    for row in current:
        row['initial_candidate'] = initial[row['path']]['candidate']
        details = evidence.get(row['path'], {'classification': 'not_flagged_static_only'})
        if row['initial_candidate'] and details['classification'] == 'not_flagged_static_only':
            raise ValueError('Initial candidate has no triage evidence: ' + row['path'])
        row.update(details)
        for label in ['before', 'after']:
            if label not in details:
                continue
            report = json.loads((root / details[label]).read_text())
            if report['passed'] != (label == 'after') or report['qml_errors']:
                raise ValueError('Unexpected native evidence status: ' + details[label])
            if label == 'after':
                # Dialog evidence belongs to its actual containing activity.
                source = root / 'src/activities' / report['qml_file']
                if hashlib.sha256(source.read_bytes()).hexdigest() != report['source_sha256']:
                    raise ValueError('Native evidence no longer matches its QML source: ' + str(source))
                case = root / details['case']
                if hashlib.sha256(case.read_bytes()).hexdigest() != report['case_sha256']:
                    raise ValueError('Native evidence no longer matches its test fragment: ' + str(case))
                for dependency, expected in details.get('dependencies', {}).items():
                    if hashlib.sha256((root / dependency).read_bytes()).hexdigest() != expected:
                        raise ValueError('Native dependency changed: ' + dependency)
    return {'scope': 'Static inventory plus the named single-event native probes; not all modes or inputs',
            'initial_handlers': len(baseline), 'initial_candidates': sum(row['candidate'] for row in baseline),
            'classification_counts': dict(Counter(row['classification'] for row in current)), 'handlers': current}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--baseline', type=Path)
    parser.add_argument('--evidence', type=Path)
    args = parser.parse_args()
    rows = inventory(args.root)
    if bool(args.baseline) != bool(args.evidence):
        parser.error('--baseline and --evidence must be supplied together')
    if args.baseline:
        result = compare(args.root, rows, args.baseline, args.evidence)
    else:
        result = {'scope': 'Static candidates, not proof of duplication or branch coverage', 'handlers': rows}
    print(json.dumps(result, indent=2))
