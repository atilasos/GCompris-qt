# SPDX-License-Identifier: GPL-3.0-or-later
"""Semantic contracts for recorded native UI controls, without Qt."""
import math
from pattern_grid_solver import plan



def require(value, message):
    if not value:
        raise ValueError(message)


def frame(value):
    require(isinstance(value, dict), 'Actual visible frame required')
    for key in ['x', 'y', 'width', 'height']:
        number = value[key]
        require(type(number) in (int, float) and math.isfinite(number), 'Finite actual frame required')
    require(value['width'] > 0 and value['height'] > 0, 'Positive actual frame required')
    return value


def point(value, target, cursor=False):
    target = frame(target)
    tolerance = 1 if cursor else max(target['width'], target['height']) * 1e-6
    require(type(value['x']) in (int, float) and type(value['y']) in (int, float) and
            math.isfinite(value['x']) and math.isfinite(value['y']) and
            abs(value['x']-target['x']) <= tolerance and abs(value['y']-target['y']) <= tolerance,
            'Actual cursor position' if cursor else 'Actual cell/click position')


def states(rows, activity):
    require(isinstance(rows, list) and rows, 'Nonempty actual cell states required')
    for index, row in enumerate(rows):
        frame(row['frame'])
        require(isinstance(row['signature'], str) and row['signature'], 'Actual signature required')
        for earlier in rows[:index]:
            require(abs(earlier['frame']['x']-row['frame']['x']) > row['frame']['width']*1e-6 or
                    abs(earlier['frame']['y']-row['frame']['y']) > row['frame']['height']*1e-6,
                    'Duplicate actual cell states')
        if activity == 'mosaic':
            require(row['status'] == 1 and row['source'].startswith('qrc:/'), 'Actual image must be ready')
        else:
            require(row['color'] == row['signature'], 'Actual rendered color differs from signature')
    return rows


def find(rows, target):
    matching = [row for row in rows if
                abs(row['frame']['x']-target['x']) <= target['width']*1e-6 and
                abs(row['frame']['y']-target['y']) <= target['height']*1e-6]
    require(len(matching) == 1, 'One actual cell at the strict geometric target')
    return matching[0]


def same_states(before, after):
    require(len(before) == len(after), 'Actual cell state coverage changed')
    for row in before:
        actual = find(after, row['frame'])
        require(row['signature'] == actual['signature'], 'Actual cell states disagree')


def palette(samples):
    require(isinstance(samples, list) and len(samples) > 1, 'Nonempty actual palette required')
    for sample in samples:
        require(isinstance(sample['id'], str) and sample['id'].startswith('qrc:/') and
                isinstance(sample['signature'], str) and sample['signature'], 'Public palette image and signature required')
        frame(sample['frame'])
    require(len({sample['id'] for sample in samples}) == len(samples) and
            len({sample['signature'] for sample in samples}) == len(samples), 'Ambiguous actual palette')
    return samples


def board(question, answer, samples, activity):
    states(question, activity); states(answer, activity); palette(samples)
    return plan(question, answer, samples, mirror=activity == 'redraw_symmetrical')


def offered(sample, samples, permuted=False):
    matches = [p for p in samples if p['id'] == sample['id'] and p['signature'] == sample['signature']]
    require(len(matches) == 1, 'Paint must match an actual offered calibrated palette sample')
    frame(sample['frame'])
    if permuted:
        require(any(abs(sample['frame']['x']-p['frame']['x']) <= p['frame']['width']*1e-6 and
                    abs(sample['frame']['y']-p['frame']['y']) <= p['frame']['height']*1e-6 for p in samples),
                'Actual selected image occupies an observed palette slot')
    else:
        point(sample['frame'], matches[0]['frame'])
    return matches[0]


def clicked(event):
    point(event['click'], frame(event['frame']))


def painted(action, samples, activity):
    target = frame(action['target'])
    states([action['before']], activity); states([action['after']], activity)
    point(action['before']['frame'], target); point(action['after']['frame'], target)
    offered(action['palette'], samples)
    point(action['selection'], action['palette']['frame']); point(action['click'], target)
    require(action['after']['signature'] == action['expected_signature'] == action['palette']['signature'],
            'Actual pointer painting result differs from the selected signature')
    if activity == 'mosaic':
        require(action['after']['source'] == action['palette']['id'], 'Actual painted image source differs from selection')


def partial_menu(evidence, activity):
    partial = evidence['partialBeforeMenu']
    actual = board(partial['question'], partial['answerBefore'], partial['palette'], activity)
    require(partial['plan']['placements'] == actual['placements'], 'Recomputed partial grid plan differs')
    require(partial['actions'] == [partial['edit']], 'Actual menu edit action must be retained')
    painted(partial['edit'], partial['palette'], activity)
    require(partial['edit']['role'] == 'partial-before-menu', 'Actual partial menu edit role')
    states(partial['answerAfter'], activity)
    before = find(partial['answerBefore'], partial['edit']['target'])
    after = find(partial['answerAfter'], partial['edit']['target'])
    require(before['signature'] != after['signature'], 'Partial menu edit must visibly change the cell')
    same_states([partial['edit']['before']], [before]); same_states([partial['edit']['after']], [after])
    expected = next(p for p in actual['placements'] if p['target_frame'] == partial['edit']['target'])
    require(after['signature'] != expected['signature'], 'Partial menu target must remain visibly wrong')
    for row in partial['answerBefore']:
        if row is not before:
            same_states([row], [find(partial['answerAfter'], row['frame'])])
    clicked(evidence['home'])
    require(evidence['menuDuringActivity'] == {'depth': 1, 'busy': False, 'isMenu': True}, 'Actual partial menu exit required')


def layout(rows):
    neutral = [{'frame': row['frame'], 'signature': 'neutral geometry'} for row in rows]
    derived = plan(neutral, [{'frame': row['frame']} for row in rows],
                   [{'id': 'neutral geometry', 'signature': 'neutral geometry'}])
    return derived, [p['target_frame'] for p in derived['placements']]


def arrows(record, activity):
    cells = states(record['before'], activity)
    geometry, frames = layout(cells)
    columns = geometry['columns']
    require(columns > 1 and geometry['rows'] > 1, 'Actual two-dimensional keyboard layout')
    expected = [('Right', 0, 1), ('Left', 1, 0), ('Down', 0, columns), ('Up', columns, 0)]
    require(len(record['arrows']) == 4, 'All four actual cursor movements required')
    for actual, (key, before, after) in zip(record['arrows'], expected):
        require(actual['key'] == key, 'Actual arrow key sequence')
        frame(actual['before']); frame(actual['after'])
        point(actual['before'], frames[before], cursor=True)
        point(actual['after'], frames[after], cursor=True)
    return 4


def redraw_keyboard(record, samples, blank, keys, activity):
    palette(samples)
    require(len(samples) == 7 and len(record['offeredDigits']) == 7 and len(record['digits']) == 7,
            'All seven offered digit/paint effects required')
    offered_digits = record['offeredDigits']
    require({row['digit'] for row in offered_digits} == set('0123456'), 'Every offered digit from zero to six')
    require({row['palette']['id'] for row in offered_digits} == {row['id'] for row in samples}, 'Every calibrated digit palette image')
    for shortcut in offered_digits:
        offered(shortcut['palette'], samples); frame(shortcut['frame'])
        distances = sorted((math.hypot(p['frame']['x']-shortcut['frame']['x'], p['frame']['y']-shortcut['frame']['y']), p['id']) for p in samples)
        require(distances[0][0] < distances[1][0] and distances[0][1] == shortcut['palette']['id'], 'Visible digit label geometry')
        require(keys.count('Digit '+shortcut['digit']) >= 1 and
                keys.count('Space after digit '+shortcut['digit']) >= 1, 'Actual digit and Space key observations in both phases')
    require({row['shortcut']['digit'] for row in record['digits']} == set('0123456'), 'Distinct actual digit effects')
    geometry, frames = layout(record['before']); current = frames[0]
    for row in record['digits']:
        require(row['shortcut'] in offered_digits, 'Actual digit refers to its offered label')
        states([row['before']], activity); states([row['after']], activity)
        point(row['before']['frame'], current); point(row['after']['frame'], current)
        require(row['before']['signature'] != row['after']['signature'] and
                row['after']['signature'] == row['shortcut']['palette']['signature'], 'Actual numeric keyboard paint change')
    selected = record['selectedDigit']; require(selected in offered_digits, 'Selected actual numeric label')
    require(selected['palette']['signature'] != blank, 'Selected numeric keyboard paint differs from blank')
    source_actions = record['actions']
    seeds = [row for row in source_actions if 'role' in row]
    for seed in seeds:
        require(seed['role'] == 'numeric-shortcut-seed', 'Actual numeric keyboard seed role')
        painted(seed, samples, activity)
        require(seed['before']['signature'] != seed['after']['signature'], 'Actual numeric seed must change paint')
    pending_seeds = iter(seeds)
    current_signature = find(record['before'], current)['signature']
    for digit in record['digits']:
        if digit['before']['signature'] != current_signature:
            seed = next(pending_seeds, None)
            require(seed is not None and seed['before']['signature'] == current_signature and
                    seed['after']['signature'] == digit['before']['signature'], 'Actual numeric keyboard state continuity requires its seed action')
            point(seed['target'], current)
            current_signature = seed['after']['signature']
        require(digit['before']['signature'] == current_signature, 'Actual numeric keyboard state continuity')
        current_signature = digit['after']['signature']
    require(next(pending_seeds, None) is None, 'Unmatched numeric keyboard seed breaks continuity')
    require(all(('key' in row) != ('role' in row) for row in source_actions), 'Actual keyboard action kind')
    key_actions = [row for row in source_actions if 'key' in row]
    require([row['key'] for row in key_actions] == ['Space', 'Delete', 'Return', 'Backspace', 'Enter', 'Delete'], 'All offered keyboard painting/deletion effects')
    for index in range(0, 6, 2):
        paint_event, deletion = key_actions[index:index+2]
        states([paint_event['before']], activity); states([paint_event['after']], activity); states([deletion['after']], activity)
        point(paint_event['before']['frame'], current); point(paint_event['after']['frame'], current); point(deletion['after']['frame'], current)
        require(paint_event['before']['signature'] == blank and
                paint_event['after']['signature'] == paint_event['signature'] == selected['palette']['signature'] and
                paint_event['before']['signature'] != paint_event['after']['signature'], 'Actual keyboard painting change required')
        require(deletion['after']['signature'] == deletion['expected_blank'] == blank, 'Actual keyboard deletion returns rendered blank')
        require(keys.count(paint_event['key']) >= 1 and keys.count(deletion['key']) >= 1, 'Real painting/deletion key observations in both phases')
    states(record['after'], activity); same_states(record['before'], record['after'])
    return len(seeds)


def drag(evidence, activity, derived):
    record = evidence['drag']; sample_list = evidence['initial']['palette']
    states(record['before'], activity); states(record['after'], activity)
    same_states(record['before'], evidence['keyboardBeforeHelp']['after'])
    geometry, frames = layout(record['before'])
    gesture = record['drag']
    point(gesture['from'], frames[0]); point(gesture['to'], frames[1])
    require(len(gesture['before']) == len(gesture['after']) == 2, 'Two actual drag targets required')
    for i in range(2):
        states([gesture['before'][i]], activity); states([gesture['after'][i]], activity)
        point(gesture['before'][i]['frame'], frames[i]); point(gesture['after'][i]['frame'], frames[i])
        same_states([gesture['before'][i]], [find(record['before'], frames[i])])
        require(gesture['before'][i]['signature'] != gesture['after'][i]['signature'] == gesture['signature'],
                'Actual drag must visibly change both cells')
        same_states([gesture['after'][i]], [find(record['after'], frames[i])])
    clicked(record['selection'])
    selected = [p for p in sample_list if p['signature'] == gesture['signature']]
    require(len(selected) == 1, 'Actual drag paint belongs to the offered palette')
    point(record['selection']['frame'], selected[0]['frame'])
    guard = record['guard']; painted(guard, sample_list, activity)
    require(guard['role'] == 'drag-guard' and record['actions'] == [guard], 'Actual drag guard pointer action')
    require(all(abs(guard['target']['x']-f['x']) > f['width']*1e-6 or
                abs(guard['target']['y']-f['y']) > f['height']*1e-6 for f in frames[:2]), 'Drag guard must be outside both endpoints')
    expected = next(p for p in derived['placements'] if
                    abs(p['target_frame']['x']-guard['target']['x']) <= guard['target']['width']*1e-6 and
                    abs(p['target_frame']['y']-guard['target']['y']) <= guard['target']['height']*1e-6)
    require(guard['after']['signature'] != expected['signature'], 'Actual drag guard must remain visibly wrong')
    same_states([guard['before']], [find(record['before'], guard['target'])])
    same_states([guard['after']], [find(record['after'], guard['target'])])
    for row in record['before']:
        if all(row is not find(record['before'], target) for target in [frames[0], frames[1], guard['target']]):
            same_states([row], [find(record['after'], row['frame'])])
    return 1


def key_phases(keys):
    require(isinstance(keys, list) and all(isinstance(key, str) for key in keys), 'Actual key-event observations')
    require(keys.count('Escape close help') == 1, 'One actual Escape help close required')
    split = keys.index('Escape close help')
    require(0 < split < len(keys)-1, 'Actual keyboard operations before and after Escape')
    return keys[:split], keys[split+1:]


def help_restart(evidence, activity, blank):
    initial = evidence['initial']; restart = evidence['restart']; help_view = evidence['help']
    states(restart['before'], activity); states(restart['after'], activity)
    require(any(row['signature'] != blank for row in restart['before']) and
            all(row['signature'] == blank for row in restart['after']), 'Actual partial restart must clear changed paint')
    require(restart['initial_blank'] == blank, 'Observed restart blank differs from initial state')
    same_states(evidence['keyboardBeforeHelp']['before'], initial['answer'])
    previous_edit = evidence['keyboardBeforeHelp']['after'] if activity == 'mosaic' else evidence['drag']['after']
    same_states(restart['before'], previous_edit)
    same_states(restart['after'], initial['answer'])
    same_states(restart['after'], evidence['keyboardAfterHelp']['before'])
    board(restart['questionAfter'], restart['after'], initial['palette'], activity)
    next_event = restart['next']; previous = restart['previous']
    for event in [next_event, previous]:
        require(type(event['before']) is int and type(event['after']) is int and event['total'] == initial['total'], 'Actual restart level observations')
        clicked(event['event'])
    require(next_event['before'] == initial['level']-1 and
            next_event['after'] == (next_event['before']+1) % initial['total'] and
            previous['before'] == next_event['after'] and previous['after'] == next_event['before'], 'Actual next/previous restart roundtrip')
    titles = {'redraw': 'Voltar a desenhar a imagem atual',
              'redraw_symmetrical': 'Espelho da imagem indicada', 'mosaic': 'Reconstruir o mosaico'}
    require(help_view['title'] == titles[activity] and isinstance(help_view['manual'], str) and
            help_view['manual'] and help_view['manual'] in help_view['content'] and
            'Controlos do teclado' in help_view['content'] and 'espa' in help_view['content'].lower(), 'Actual PT-PT help contents required')
    clicked(help_view['opened'])
    require(type(help_view['depth']) is int and type(help_view['closedDepth']) is int and
            help_view['closedDepth'] >= 2 and help_view['depth'] == help_view['closedDepth']+1,
            'Escape must actually close one help dialog')


def subsequence(observed, required):
    iterator = iter(observed)
    return all(any(actual == wanted for actual in iterator) for wanted in required)


def mosaic_keyboard(record, samples, question, keys, permuted=False):
    derived = board(question, record['before'], samples, 'mosaic')
    geometry, frames = layout(record['before']); target = frames[0]
    expected = next(p['signature'] for p in derived['placements'] if p['target_frame'] == target)
    actions = record['actions']
    require([action['key'] for action in actions] == ['Space', 'Return', 'Enter'], 'Actual Mosaic keyboard selections/paintings required')
    required_keys = []
    current = find(record['before'], target)
    for action in actions:
        offered(action['selected'], samples, permuted=permuted)
        states([action['before']], 'mosaic'); states([action['after']], 'mosaic')
        point(action['before']['frame'], target); point(action['after']['frame'], target)
        require(action['before']['signature'] == current['signature'], 'Actual Mosaic keyboard state continuity')
        require(action['after']['signature'] == action['selected']['signature'] and
                action['after']['source'] == action['selected']['id'], 'Actual selected Mosaic image source/signature')
        require(action['before']['signature'] != action['after']['signature'] and
                action['after']['signature'] != expected == action['expected_question_signature'],
                'Actual Mosaic keyboard paint changes and remains wrong')
        required_keys.extend(['Tab to selector', action['key']+' select image',
                              'Tab to answer', action['key']+' paint target'])
        current = action['after']
    require(subsequence(keys, required_keys), 'Actual Mosaic Tab/select/paint key sequence')
    states(record['after'], 'mosaic'); same_states([current], [find(record['after'], target)])
    require(len(record['after']) == len(record['before']), 'Complete actual Mosaic keyboard state')
    for row in record['before']:
        if row is not find(record['before'], target):
            same_states([row], [find(record['after'], row['frame'])])


TOTALS = {'redraw': 38, 'redraw_symmetrical': 21, 'mosaic': 22}


def initial_state(evidence, activity):
    initial = evidence['initial']
    require(type(initial['total']) is int and initial['total'] == TOTALS[activity] and
            type(initial['level']) is int and 1 <= initial['level'] <= initial['total'], 'Actual initial public level range')
    derived = board(initial['question'], initial['answer'], initial['palette'], activity)
    require(derived['rows'] > 1 and derived['columns'] > 1, 'Actual two-dimensional controls grid')
    blank = initial['answer'][0]['signature']
    require(all(row['signature'] == blank for row in initial['answer']), 'Actual initial edit grid must be blank')
    search = evidence['levelSearch']
    require([row['level'] for row in search] == list(range(1, initial['level']+1)) and
            search[-1]['rows'] == derived['rows'] and search[-1]['columns'] == derived['columns'], 'Finite actual level search')
    require({(p['id'], p['signature']) for p in search[-1]['palette']} ==
            {(p['id'], p['signature']) for p in initial['palette']}, 'Observed selected level palette differs')
    return derived, blank


def datasets(evidence, activity, blank):
    records = evidence['datasets']; count = 4 if activity == 'mosaic' else 3
    require(len(records) == count, 'All offered data sets must be configured')
    labels = None; selected = []
    for record in records:
        rows = record['labels']
        require(len(rows) == count and all(isinstance(row['text'], str) and row['text'].strip() and
                type(row['checked']) is bool for row in rows), 'Actual labelled data-set checkboxes required')
        names = {row['text'] for row in rows}
        require(len(names) == count and (labels is None or labels == names), 'Consistent unique data-set labels required')
        labels = names
        for row in rows:frame(row['frame'])
        active = [row['text'] for row in rows if row['checked']]
        require(len(active) == 1, 'One actual data-set checkbox selected')
        selected.extend(active)
        clicked(record['save'])
        require(type(record['levels']) is int and record['levels'] > 0 and
                type(record['currentLevel']) is int and record['currentLevel'] == 0, 'Actual configured data-set level range')
        board(record['question'], record['answer'], record['palette'], activity)
        if activity != 'mosaic':
            for sample in record['palette']:
                require(any(p['id'] == sample['id'] and p['signature'] == sample['signature'] for p in evidence['initial']['palette']),
                        'Configured data-set paint differs from the calibrated full palette')
    require(len(set(selected)) == count, 'Distinct actual data sets, not copies of one configuration')
    require(sum(row['levels'] for row in records) == evidence['initial']['total'], 'Configured data-set ranges must compose the public total')
    same_states(records[-1]['question'], evidence['partialBeforeMenu']['question'])
    same_states(records[-1]['answer'], evidence['partialBeforeMenu']['answerBefore'])
    for gesture in evidence['configScroll']:
        require(math.isfinite(gesture['before']) and math.isfinite(gesture['after']), 'Actual scroll offsets')
        require(gesture['from']['y'] != gesture['to']['y'], 'Actual vertical configuration scroll gesture')
    return count


def _validate(case_result):
    require(isinstance(case_result, dict), 'Recorded controls object required')
    require(type(case_result['failures']) is int and case_result['failures'] == 0, 'A failed controls prefix is not complete evidence')
    require(type(case_result['passes']) is int and case_result['passes'] > 0, 'Real QtTest assertions required')
    require(type(case_result['wins']) is int and case_result['wins'] == 0, 'Controls cannot claim natural wins')
    evidence = case_result['evidence']; activity = case_result['activity']
    require(activity in TOTALS, 'Unsupported public controls activity')
    require(isinstance(evidence, dict) and not evidence.get('failure'), 'A failed assertion observation cannot become a successful prefix')
    derived, blank = initial_state(evidence, activity)
    partial_menu(evidence, activity)
    require(evidence['keyboardBeforeHelp']['label'] == 'before-help' and
            evidence['keyboardAfterHelp']['label'] == 'after-help', 'Two separate keyboard phases around help')
    cursor_moves = arrows(evidence['keyboardBeforeHelp'], activity) + arrows(evidence['keyboardAfterHelp'], activity)
    phases = key_phases(evidence['keys'])
    if activity != 'mosaic':
        for name, observed_keys in zip(['keyboardBeforeHelp', 'keyboardAfterHelp'], phases):
            redraw_keyboard(evidence[name], evidence['initial']['palette'], blank, observed_keys, activity)
        drag(evidence, activity, derived)
    else:
        for name, question, observed_keys in zip(['keyboardBeforeHelp', 'keyboardAfterHelp'],
                [evidence['initial']['question'], evidence['restart']['questionAfter']], phases):
            mosaic_keyboard(evidence[name], evidence['initial']['palette'], question, observed_keys, permuted=name=='keyboardAfterHelp')
    help_restart(evidence, activity, blank)
    configured = datasets(evidence, activity, blank)
    pointer_count = sum(sum('role' in action for action in evidence[name]['actions']) for name in ['keyboardBeforeHelp', 'keyboardAfterHelp'])
    pointer_count += len(evidence['partialBeforeMenu']['actions'])
    if activity != 'mosaic':
        pointer_count += len(evidence['drag']['actions'])
    require(type(case_result['pointerPaintActions']) is int and case_result['pointerPaintActions'] == pointer_count, 'Pointer counter must equal actual retained actions')
    return {'activity': case_result['activity'], 'validated_controls': True,
            'keyboard_phases': 2, 'observed_digit_effects': 0 if activity == 'mosaic' else 14,
            'observed_enter_space_paints': 6, 'observed_keyboard_deletions': 0 if activity == 'mosaic' else 6,
            'drag_targets': 0 if activity == 'mosaic' else 2, 'actual_menu_edits': 1,
            'scope': 'Semantic recorded observations only; source, PNG, resource and return provenance require the outer physical audit',
            'configured_datasets': configured,
            'dataset_gameplay_completions_claimed': 0, 'natural_wins': 0, 'actual_cursor_moves': cursor_moves}



def validate_controls(case_result):
    """Validate complete recorded controls or raise ValueError; no Qt or I/O."""
    try:
        return _validate(case_result)
    except ValueError:
        raise
    except (KeyError, IndexError, TypeError, AttributeError, StopIteration, OverflowError) as error:
        raise ValueError('Malformed or incomplete recorded controls: '+str(error)) from error
