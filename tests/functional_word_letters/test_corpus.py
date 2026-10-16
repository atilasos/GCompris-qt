# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from corpus import corpus


class PortugueseCorpusTest(unittest.TestCase):
    def test_every_translated_word_is_usable_in_complete_and_sample_lessons(self):
        data=corpus()
        self.assertEqual(data['translation_entries'],1090)
        self.assertEqual(len(data['datasets']['words.json']),23)
        self.assertEqual(len(data['datasets']['words_sample.json']),6)
        self.assertEqual(sum(len(lesson['words']) for lesson in data['datasets']['words.json']),1090)
        self.assertEqual(sum(len(lesson['words']) for lesson in data['datasets']['words_sample.json']),116)


if __name__=='__main__':unittest.main()
