#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Check observed questions against dataset constraints without the game JS."""
from decimal import Decimal
import json
from pathlib import Path
import re

from inventory import inventory


def compatible(activity, question, specification):
    numbers = [Decimal(s.replace(',', '.')) for s in re.findall(r'[0-9]+(?:,[0-9]+)?', question)]
    operation = activity in ('learn_decimals_additions', 'learn_decimals_subtractions')
    if len(numbers) != (2 if operation else 1):
        return False
    if specification['inputType'] == 'fixed':
        expected = [Decimal(str(specification[k])) for k in (['firstNumber','secondNumber'] if operation else ['fixedValue'])]
        return numbers == expected
    lower, upper = (Decimal(str(specification[k])) for k in ('minValue','maxValue'))
    if not all(lower <= number <= upper for number in numbers):
        return False
    if activity == 'learn_decimals_additions':
        return sum(numbers) <= upper
    if activity == 'learn_decimals_subtractions':
        return numbers[0] >= numbers[1]
    return True


def match_all(activity, questions, specifications):
    if not questions:
        return not specifications
    for index, specification in enumerate(specifications):
        if compatible(activity, questions[0], specification) and match_all(activity,questions[1:],specifications[:index]+specifications[index+1:]):
            return True
    return False


def audit(output):
    datasets = inventory()
    results = []
    for path in sorted(Path(output).glob('*/result.json')):
        report = json.loads(path.read_text())
        activity = report['activity']
        completed = (report.get('case_result') or {}).get('completed', [])
        levels = [level for dataset in datasets[activity] for level in dataset['levels']]
        failures = []
        for level_index, level in enumerate(levels):
            rows = [row for row in completed if row['level']==level_index]
            if sorted(row['sublevel'] for row in rows) != list(range(len(level['subLevels']))):
                failures.append(f'level{level_index}: missing or duplicate sublevel')
            elif not match_all(activity,[row['question'] for row in rows],level['subLevels']):
                failures.append(f'level{level_index}: questions cannot match the configured shuffled constraints')
            for row in rows:
                numbers = [Decimal(s.replace(',','.')) for s in re.findall(r'[0-9]+(?:,[0-9]+)?',row['question'])]
                value = sum(numbers) if activity=='learn_decimals_additions' else numbers[0]-numbers[1] if activity=='learn_decimals_subtractions' else numbers[0]
                expected = int(value*(1 if activity=='learn_quantities' else 10))
                if row['expectedUnits']!=expected:
                    failures.append(f'level{level_index}: incorrect arithmetic oracle')
                if row.get('typed') is not None and Decimal(row['typed'].replace(',','.'))!=value:
                    failures.append(f'level{level_index}: incorrect typed answer')
        results.append({'campaign':path.parent.name,'completed':len(completed),'failures':failures,'passed':report['passed'] and not failures})
    return results


if __name__=='__main__':
    import sys
    results = audit(Path(sys.argv[1]))
    print(json.dumps(results,indent=2))
    raise SystemExit(0 if len(results)==16 and all(row['passed'] for row in results) else 1)
