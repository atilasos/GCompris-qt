# SPDX-License-Identifier: GPL-3.0-or-later
"""Run with: python3 -m unittest discover -s tests -p 'test_audit_pt_pt.py'."""

import importlib.util
from pathlib import Path
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("audit_pt_pt", ROOT / "tools/audit-pt-pt.py")
AUDIT = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(AUDIT)


class CatalogAuditTest(unittest.TestCase):
    def test_multiline_plural_fuzzy_obsolete_and_qt_placeholders(self):
        source = '''msgid ""
msgstr ""
"Language: pt\\n"

#: activities/example/Example.qml:10
#, fuzzy, qt-format
msgctxt "Example|"
msgid "Hello "
"%1"
msgstr "Olá "
"%2"

#~| msgid "Previous source"
#~ msgid "Obsolete"
#~ msgstr ""

msgid "%n item"
msgid_plural "%n items"
msgstr[0] "%n elemento"
msgstr[1] ""

msgid "Untranslated"
msgstr ""
'''
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "sample.po").write_text(source, encoding="utf-8")
            report = AUDIT.inspect_catalog(root, "sample.po")
        self.assertEqual(report["entries"], 3)
        self.assertEqual(report["counts"], {"fuzzy": 1, "placeholder-mismatch": 1, "untranslated": 2})
        self.assertEqual(report["findings"][0]["source"], "Hello %1")
        self.assertEqual(report["findings"][0]["references"], ["activities/example/Example.qml:10"])

    def test_report_covers_real_activity_list_and_relative_qt_references(self):
        report = AUDIT.build_report(ROOT)
        expected = {line.strip() for line in (ROOT / "src/activities/activities.txt").read_text().splitlines()
                    if line.strip() and not line.startswith("#")}
        self.assertEqual({row["id"] for row in report["activities"]}, expected)
        findings = report["catalogs"][0]["findings"]
        for row in report["activities"]:
            expected_count = sum(any(f"activities/{row['id']}/" in ref for ref in finding["references"])
                                 for finding in findings)
            self.assertEqual(row["catalog_findings"], expected_count, row["id"])

    def test_invalid_active_syntax_is_not_silently_ignored(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "invalid.po"
            path.write_text('msgid "Example"\nmsgstr broken\n')
            with self.assertRaises(ValueError):
                AUDIT.read_po(path)

    def test_missing_portuguese_plural_form_is_untranslated(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "plural.po").write_text('msgid "item"\nmsgid_plural "items"\nmsgstr[0] "elemento"\n')
            report = AUDIT.inspect_catalog(root, "plural.po")
        self.assertEqual(report["counts"], {"untranslated": 1})


if __name__ == "__main__":
    unittest.main()
