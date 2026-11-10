# SPDX-License-Identifier: GPL-3.0-or-later
"""Every CRJM strategy game must document where its rules come from.

The eight activities are original code for this fork, checked against the
CRJM platform. Each folder carries a provenance note naming that reference
and the licence, and REUSE.toml must cover the note.
"""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
ACTIVITIES = ROOT / "src" / "activities"
GAMES = ("dominorio", "quelhas", "faisca", "gatos_caes", "atari_go", "produto", "y", "nex")
NOTES = ("PROVENANCE.md", "ORIGIN.md")
REFERENCE = "atilasos/crjm"


class CrjmProvenanceTest(unittest.TestCase):
    def note(self, game):
        found = [ACTIVITIES / game / name for name in NOTES if (ACTIVITIES / game / name).is_file()]
        self.assertEqual(len(found), 1, f"{game}: expected exactly one of {NOTES}")
        return found[0]

    def test_games_are_registered_activities(self):
        registered = (ACTIVITIES / "activities.txt").read_text(encoding="utf-8").split()
        for game in GAMES:
            with self.subTest(game=game):
                self.assertIn(game, registered)

    def test_each_game_names_the_reference_and_licence(self):
        for game in GAMES:
            with self.subTest(game=game):
                text = self.note(game).read_text(encoding="utf-8")
                self.assertIn(REFERENCE, text)
                self.assertIn("GPL-3.0-or-later", text)

    def test_reuse_covers_each_note(self):
        reuse = (ROOT / "REUSE.toml").read_text(encoding="utf-8")
        for game in GAMES:
            with self.subTest(game=game):
                relative = self.note(game).relative_to(ROOT).as_posix()
                self.assertIn(f'"{relative}"', reuse)


if __name__ == "__main__":
    unittest.main()
