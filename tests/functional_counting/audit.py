#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit native counting receipts from observed artwork and elementary arithmetic."""
from collections import Counter
from pathlib import Path
import re
from oracle import dice_pips


def validate_visual(visual, root):
    if 'source' in visual:
        prefix = 'qrc:/gcompris/src/activities/smallnumbers/resource/'
        assert visual['source'].startswith(prefix)
        filename = visual['source'].removeprefix(prefix)
        assert re.fullmatch(r'dice[0-9]\.svg', filename)
        value = dice_pips(root / 'src/activities/smallnumbers/resource' / filename)
    else:
        assert len(visual['parts']) == 2
        values = []
        for part in visual['parts']:
            if 'dots' in part:
                number = part['dots']
            elif 'images' in part:
                assert all(route.endswith('/memory-enumerate/resource/butterfly.svg') for route in part['images'])
                number = len(part['images'])
                assert part['count'] == number
            else:
                label = part['label']
                if re.fullmatch(r'[0-9]', label):
                    number = int(label)
                else:
                    assert re.fullmatch(r'(?:IX|IV|V?I{0,3})', label)
                    digits = {'I': 1, 'V': 5, 'X': 10}
                    number = sum(-digits[letter] if index + 1 < len(label) and digits[letter] < digits[label[index + 1]] else digits[letter]
                                 for index, letter in enumerate(label))
                assert part['count'] == number
            assert isinstance(number, int) and 0 <= number <= 9
            values.append(number)
        value = sum(values)
    assert visual['count'] == value
    return value


def validate_fruit(observation):
    counts = Counter(observation['pictures'])
    answers = {row['source']: row['count'] for row in observation['answers']}
    assert len(answers) == len(observation['answers'])
    assert counts == answers
    return sum(counts.values())


def main():
    import argparse
    import hashlib
    import json
    from inventory import inventory, ROOT

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--result', type=Path, required=True)
    parser.add_argument('--case', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--partial', action='store_true')
    args = parser.parse_args()
    result = json.loads(args.result.read_text())
    assert result['passed'] and result['exit_code'] == 0 and not result['timeout'] and not result['qml_errors']
    assert hashlib.sha256(args.case.read_bytes()).hexdigest() == result['case_sha256']
    assert result['private_file_ownership_verified'] and not result['deployment_retained']
    rows = result['case_result']['observations']
    activity = result['activity']
    data = inventory()['activities'][activity]
    for row in rows:
        if activity == 'enumerate':
            validate_fruit(row)
            for route in row['pictures']:
                assert route.startswith('qrc:/gcompris/src/activities/enumerate/resource/')
                assert (ROOT / route.removeprefix('qrc:/gcompris/')).is_file()
            assert len(row['answers']) == data['levels'][row['level'] - 1]['numberOfItemType']
            assert all(0 < answer['count'] <= data['levels'][row['level'] - 1]['numberOfItemMax'] for answer in row['answers'])
        else:
            assert validate_visual(row['visual'], ROOT) in data['levels'][row['level'] - 1]['allowed_digits']
    if not args.partial:
        if activity == 'enumerate':
            modes = {row['mode'] for row in rows}
            assert modes in [{1}, {2}]
        else:
            modes = ['dice'] if activity == 'smallnumbers' else ['dot', 'number', 'roman', 'image']
        expected = sorted((mode, level + 1, question + 1) for mode in modes
                          for level, item in enumerate(data['levels']) for question in range(item['subLevels']))
        assert sorted((row['mode'], row['level'], row['round']) for row in rows) == expected
    report = {'passed': True, 'activity': activity, 'questions': len(rows),
              'modes': sorted({row['mode'] for row in rows}),
              'result_sha256': hashlib.sha256(args.result.read_bytes()).hexdigest(),
              'case_sha256': result['case_sha256'], 'scope': 'Observed counts and recorded native actions only; no physical audio or Windows acceptance.'}
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report))


if __name__ == '__main__':
    main()
