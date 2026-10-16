import importlib.util
from pathlib import Path
import unittest

SPEC = importlib.util.spec_from_file_location('authored_path_data', Path(__file__).with_name('path_data.py'))
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class AuthoredPathContract(unittest.TestCase):
    def test_straight_path_has_two_moves(self):
        self.assertEqual(MODULE.validate([list('S*E')])['moves'], 2)

    def test_fork_is_rejected(self):
        with self.assertRaises(AssertionError): MODULE.validate([list('.*.'), list('S*E')])

    def test_disconnected_cycle_is_rejected(self):
        with self.assertRaises(AssertionError): MODULE.validate([list('S*E..'), list('...**'), list('...**')])


if __name__ == '__main__':
    unittest.main()
