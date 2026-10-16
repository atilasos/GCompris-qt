# SPDX-License-Identifier: GPL-3.0-or-later
"""Recompute public grid geometry and replay pointer painting observations."""
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from pattern_grid_solver import plan
from store import require

def key(frame):
    return frame['x'], frame['y']

def states(cells):
    result = {key(cell['frame']): cell['signature'] for cell in cells}
    require(len(result) == len(cells), 'Unique actual painted cell positions')
    return result

def at_center(click, frame):
    require(abs(click['x']-frame['x']) < 1e-6 and abs(click['y']-frame['y']) < 1e-6, 'Pointer action at the actual public widget center')

def validate_board(board, mirror):
    expected = plan(board['question'], board['answerInitial'], board['palette'], mirror=mirror)
    actual = board['plan']
    require(all(actual[field] == expected[field] for field in ('rows', 'columns', 'placements')), 'Independent Python geometry matches the native JavaScript plan')
    target = {key(p['target_frame']): p['signature'] for p in expected['placements']}
    current = states(board['answerInitial'])
    palette = {p['id']: p['signature'] for p in board['palette']}
    actions = board['actions']
    require(actions and actions[-1]['role'] == 'repair-holdout', 'Final pointer repair exists')
    require(board['repair'] == actions[-1], 'Repair metadata is the actual last pointer action')
    holdout = key(board['holdout']['target_frame'])
    require(holdout in target and board['holdout']['signature'] == target[holdout], 'Holdout derived from current visible geometry')
    for index, action in enumerate(actions):
        position = key(action['target'])
        require(position in current and key(action['before']['frame']) == position and key(action['after']['frame']) == position, 'Action references one observed target')
        require(action['before']['signature'] == current[position], 'Sequential actual before-state is preserved')
        signature = action['expected_signature']
        require(action['palette']['id'] in palette and palette[action['palette']['id']] == signature == action['palette']['signature'], 'Paint chosen from the observed calibrated palette')
        at_center(action['selection'], action['palette']['frame'])
        at_center(action['click'], action['target'])
        require(action['after']['signature'] == signature, 'Actual paint after pointer action')
        if index == len(actions)-1:
            wrong = board['wrong']
            require(states(wrong['answer']) == current, 'Wrong state is the exact state before the final repair')
            require(current[holdout] != target[holdout] and all(current[k] == v for k,v in target.items() if k != holdout), 'Only the deliberate holdout remains visibly wrong')
            require(key(wrong['target']) == holdout and wrong['observed_signature'] == current[holdout] and wrong['expected_signature'] == target[holdout], 'Wrong evidence identifies the actual mismatching paint')
            require(wrong['wins_before'] == wrong['wins_after'] == board['level']-1 and wrong['currentLevel'] == board['level']-1 and not wrong['bonusPlaying'] and wrong['observed_without_success_ms'] >= 500, 'Wrong board did not win or advance during the observed interval')
            require(position == holdout and signature == target[holdout], 'Repair targets the deliberate error')
        current[position] = signature
    require(current == target == states(board['repaired']['answer']), 'Every actual painted target correct after repair')
    require(board['completed'] and board['winsAfter'] == board['level'] and board['nextLevel'] == board['level'] % board['total'] and board['bonus'].endswith('_good.svg'), 'Natural good Bonus, Win and continuation observed')
    return len(target)
