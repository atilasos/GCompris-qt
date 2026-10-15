# SPDX-License-Identifier: GPL-3.0-or-later
"""Regression checks at the Portuguese language-resource boundary.

The literal dates and directions come from the exercise prompts, not from the
translation implementation. These checks do not approve linguistic quality.
"""
import importlib.util
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('audit_pt_pt', ROOT / 'tools/audit-pt-pt.py')
AUDIT = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(AUDIT)


class PortugueseInterfaceTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.entries = AUDIT.read_po(ROOT / 'poqm/pt/gcompris_qt.po')
        cls.translations = {entry['msgid']: entry.get('msgstr', '') for entry in cls.entries}

    def test_calendar_prompt_keeps_before_direction(self):
        self.assertEqual(self.translations[
            'Find the day of the week 17 days before August 16th.'],
            'Descobre o dia da semana 17 dias antes de 16 de agosto.')

    def test_calendar_prompt_keeps_all_date_offsets(self):
        examples = {
            'Find the day of the week 5 months and 2 days after July 3rd.':
                'Descobre o dia da semana 5 meses e 2 dias depois de 3 de julho.',
            'Find the day of the week 1 month and 3 days before December 28th.':
                'Descobre o dia da semana 1 mês e 3 dias antes de 28 de dezembro.',
            'Find the date 2 months, 1 week and 5 days after January 12th.':
                'Descobre a data 2 meses, 1 semana e 5 dias depois de 12 de janeiro.',
            'Human Rights Day is celebrated five days after December 5.<br> Find the date of Human Rights Day in 2017.':
                'O Dia dos Direitos Humanos celebra-se cinco dias depois de 5 de dezembro.<br>Descobre a data do Dia dos Direitos Humanos em 2017.',
            "Mark's birthday is on November 4. In 2017 his party was exactly two weeks later.<br> Find the date of his party in 2017":
                'O aniversário do Marco é a 4 de novembro. Em 2017, a sua festa foi exatamente duas semanas depois.<br>Descobre a data da festa em 2017',
        }
        for source, expected in examples.items():
            with self.subTest(source=source):
                self.assertEqual(self.translations[source], expected)

    def test_neighbor_numbers_instructions_have_readable_plural_forms(self):
        entry = next(entry for entry in self.entries
                     if entry['msgid'] == 'Find the %n previous number(s).')
        self.assertEqual(entry['msgstr[0]'], 'Encontra %n número anterior.')
        self.assertEqual(entry['msgstr[1]'], 'Encontra os %n números anteriores.')


if __name__ == '__main__':
    unittest.main()
