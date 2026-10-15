#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Inventory generic Qt key handlers; candidates need native event reproduction."""
import argparse
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


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    print(json.dumps({'scope': 'Static candidates, not proof of duplication or branch coverage',
                      'handlers': inventory(args.root)}, indent=2))
