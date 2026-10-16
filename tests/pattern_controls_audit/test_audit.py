# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from copy import deepcopy
from pattern_controls_audit import validate_controls
from pattern_controls_audit.fixtures import result


class ControlsContract(unittest.TestCase):
    def test_failed_prefix_cannot_be_accepted_as_controls(self):
        with self.assertRaisesRegex(ValueError, 'failed'):
            validate_controls({'failures': 1, 'passes': 500, 'activity': 'redraw',
                               'wins': 0, 'evidence': {'keys': ['Right']}})

    def test_literal_complete_controls_configure_datasets_without_claiming_games(self):
        summary = validate_controls(result())
        self.assertEqual(summary['configured_datasets'], 3)
        self.assertEqual(summary['dataset_gameplay_completions_claimed'], 0)
        self.assertEqual(summary['natural_wins'], 0)

    def test_coherent_unchanged_partial_menu_state_is_rejected(self):
        observed = result()
        partial = observed['evidence']['partialBeforeMenu']
        partial['answerBefore'] = deepcopy(partial['answerAfter'])
        partial['edit']['before'] = deepcopy(partial['edit']['after'])
        partial['actions'] = [deepcopy(partial['edit'])]
        with self.assertRaisesRegex(ValueError, 'change'):
            validate_controls(observed)

    def test_three_coherent_copies_of_one_dataset_do_not_cover_all_datasets(self):
        observed = result()
        one = observed['evidence']['datasets'][0]
        observed['evidence']['datasets'] = [deepcopy(one), deepcopy(one), deepcopy(one)]
        with self.assertRaisesRegex(ValueError, 'data.set'):
            validate_controls(observed)

    def test_advertised_arrows_without_actual_cursor_movement_are_rejected(self):
        observed = result()
        move = observed['evidence']['keyboardAfterHelp']['arrows'][0]
        move['after'] = deepcopy(move['before'])
        with self.assertRaisesRegex(ValueError, 'cursor'):
            validate_controls(observed)

    def test_cursor_margin_is_one_pixel_and_does_not_relax_cell_geometry(self):
        observed = result()
        observed['evidence']['keyboardBeforeHelp']['arrows'][0]['after']['x'] += 1.01
        with self.assertRaisesRegex(ValueError, 'cursor'):
            validate_controls(observed)

    def test_all_seven_offered_digits_require_observed_paint_changes(self):
        observed = result()
        phase = observed['evidence']['keyboardAfterHelp']
        phase['offeredDigits'].pop()
        phase['digits'].pop()
        with self.assertRaisesRegex(ValueError, 'digit'):
            validate_controls(observed)

    def test_keyboard_event_names_cannot_replace_actual_painted_effects(self):
        observed = result()
        action = next(a for a in observed['evidence']['keyboardAfterHelp']['actions'] if a.get('key') == 'Space')
        action['after'] = deepcopy(action['before'])
        action['signature'] = action['before']['signature']
        with self.assertRaisesRegex(ValueError, 'keyboard'):
            validate_controls(observed)

    def test_coherent_drag_records_without_any_painted_change_are_rejected(self):
        observed = result()
        record = observed['evidence']['drag']
        record['drag']['after'] = deepcopy(record['drag']['before'])
        record['drag']['signature'] = record['drag']['before'][0]['signature']
        white = observed['evidence']['initial']['palette'][0]['frame']
        record['selection'] = {'frame': deepcopy(white), 'click': {'x': white['x'], 'y': white['y']}}
        record['after'] = deepcopy(record['before'])
        with self.assertRaisesRegex(ValueError, 'drag'):
            validate_controls(observed)

    def test_restart_requires_a_real_partial_edit_then_actual_blank_state(self):
        observed = result()
        observed['evidence']['restart']['before'] = deepcopy(observed['evidence']['restart']['after'])
        with self.assertRaisesRegex(ValueError, 'restart'):
            validate_controls(observed)

    def test_english_help_and_an_escape_without_dialog_close_are_rejected(self):
        for change in ['english', 'still-open']:
            observed = result()
            help_view = observed['evidence']['help']
            if change == 'english':
                help_view['manual'] = help_view['content'] = 'Keyboard controls: Space and Enter.'
            else:
                help_view['closedDepth'] = help_view['depth']
            with self.subTest(change=change):
                with self.assertRaisesRegex(ValueError, 'help|Escape'):
                    validate_controls(observed)

    def test_literal_mosaic_controls_accept_half_pixel_cursor_rounding(self):
        summary = validate_controls(result('mosaic'))
        self.assertEqual(summary['configured_datasets'], 4)
        self.assertEqual(summary['actual_cursor_moves'], 8)

    def test_mosaic_requires_real_selected_image_effects_and_tab_events(self):
        for change in ['source', 'loading', 'no-actions', 'no-tab']:
            observed = result('mosaic')
            phase = observed['evidence']['keyboardAfterHelp']
            if change == 'source':
                phase['actions'][0]['after']['source'] = 'qrc:/gcompris/another.svg'
            elif change == 'loading':
                phase['actions'][0]['after']['status'] = 0
            elif change == 'no-actions':
                phase['actions'] = []
            else:
                observed['evidence']['keys'] = [key for key in observed['evidence']['keys'] if not key.startswith('Tab')]
            with self.subTest(change=change):
                with self.assertRaises(ValueError):
                    validate_controls(observed)

    def test_mosaic_palette_ids_can_permute_slots_after_restart(self):
        observed = result('mosaic')
        palette = observed['evidence']['initial']['palette']
        for action, slot in zip(observed['evidence']['keyboardAfterHelp']['actions'], [4, 5, 6]):
            action['selected']['frame'] = deepcopy(palette[slot]['frame'])
        self.assertEqual(validate_controls(observed)['configured_datasets'], 4)

    def test_malformed_or_empty_input_is_a_value_error(self):
        for invalid in [None, {}, [], {'failures': 0, 'wins': 0, 'evidence': {}}]:
            with self.subTest(invalid=invalid):
                with self.assertRaises(ValueError):
                    validate_controls(invalid)

    def test_counters_must_match_real_observed_actions_and_assertions(self):
        for field, value in [('passes', 0), ('wins', False), ('pointerPaintActions', 999)]:
            observed = result()
            observed[field] = value
            with self.subTest(field=field):
                with self.assertRaises(ValueError):
                    validate_controls(observed)

    def test_literal_symmetric_controls_use_mirrored_question_geometry(self):
        summary = validate_controls(result('redraw_symmetrical'))
        self.assertEqual(summary['configured_datasets'], 3)
        self.assertEqual(summary['natural_wins'], 0)

    def test_coherent_digit_states_require_actual_intermediate_paint_actions(self):
        observed = result()
        state = observed['evidence']['keyboardBeforeHelp']['digits'][2]['before']
        state['signature'] = state['color'] = '#00ff00'
        with self.assertRaisesRegex(ValueError, 'continuity'):
            validate_controls(observed)

    def test_mosaic_cell_state_cannot_use_the_cursor_rounding_allowance(self):
        observed = result('mosaic')
        observed['evidence']['keyboardAfterHelp']['actions'][0]['after']['frame']['x'] += 0.5
        with self.assertRaisesRegex(ValueError, 'cell/click'):
            validate_controls(observed)


if __name__ == '__main__':
    unittest.main()
