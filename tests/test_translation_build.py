# SPDX-License-Identifier: GPL-3.0-or-later
"""Compile through the real translation CMake function in an isolated project.

Requires CMake, a C++ compiler, gettext, Qt6 Core and Qt6 LinguistTools.
Run: python3 -m unittest discover -s tests -p test_translation_build.py
"""
from pathlib import Path
import subprocess
import tempfile
import unittest
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]

FIXTURE = '''msgid ""
msgstr ""
"Language: pt\\n"
"Content-Type: text/plain; charset=UTF-8\\n"
"Plural-Forms: nplurals=2; plural=n != 1;\\n"
"X-Qt-Contexts: true\\n"

#, qt-format
msgctxt "Fixture|"
msgid "%n apple"
msgid_plural "%n apples"
msgstr[0] "%n maçã"
msgstr[1] "%n maçãs"
'''


class TranslationBuildTest(unittest.TestCase):
    def run_command(self, args, **kwargs):
        result = subprocess.run(args, text=True, capture_output=True, **kwargs)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return result.stdout

    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix='gcompris-translation-')
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        (self.root / 'src/core').mkdir(parents=True)
        (self.root / 'src/core/LanguageList.qml').write_text(
            ' { "locale": "pt_PT.UTF-8" }\n { "locale": "pt_BR.UTF-8" }\n')
        self.catalog = self.root / 'poqm/pt/gcompris_qt.po'
        self.catalog.parent.mkdir(parents=True)
        self.catalog.write_text(FIXTURE)
        brazil = self.root / 'poqm/pt_BR/gcompris_qt.po'
        brazil.parent.mkdir(parents=True)
        brazil.write_text(FIXTURE.replace('Language: pt', 'Language: pt_BR'))
        (self.root / 'probe.cpp').write_text('''
#include <QCoreApplication>
#include <QTranslator>
#include <QTextStream>
int main(int argc, char **argv) {
    QCoreApplication app(argc, argv);
    QTranslator translator;
    if (!translator.load(QString::fromLocal8Bit(argv[1]))) return 2;
    app.installTranslator(&translator);
    QTextStream out(stdout);
    for (int n : {0, 1, 2})
        out << QCoreApplication::translate(argc > 2 ? argv[2] : "Fixture",
                                            argc > 3 ? argv[3] : "%n apple", nullptr, argc == 4 ? -1 : n) << "\\n";
}
''')
        (self.root / 'CMakeLists.txt').write_text(f'''
cmake_minimum_required(VERSION 3.20)
project(TranslationProbe LANGUAGES CXX)
find_package(Qt6 REQUIRED COMPONENTS Core LinguistTools)
set(QT_MAJOR Qt6)
set(GCOMPRIS_TRANSLATIONS_DIR "${{CMAKE_BINARY_DIR}}/translations")
include("{ROOT / 'cmake/translation.cmake'}")
gcompris_create_translation_files(FILENAME gcompris_qt)
add_executable(probe probe.cpp)
target_link_libraries(probe PRIVATE Qt6::Core)
''')
        self.build = self.root / 'build'
        self.run_command(['cmake', '-S', str(self.root), '-B', str(self.build)])
        self.run_command(['cmake', '--build', str(self.build), '-j2'])
        self.qm = self.build / 'translations/gcompris_qt_pt.qm'
        self.ts = self.build / 'tmp/gcompris_qt_pt.ts'

    def test_european_portuguese_compiled_zero_one_two_plurals(self):
        self.assertEqual(ET.parse(self.ts).getroot().get('language'), 'pt_PT')
        output = self.run_command([str(self.build / 'probe'), str(self.qm)])
        self.assertEqual(output.splitlines(), ['0 maçãs', '1 maçã', '2 maçãs'])

    def test_unchanged_catalog_does_not_recompile(self):
        initial = self.qm.stat().st_mtime_ns
        self.run_command(['cmake', '--build', str(self.build), '-j2'])
        self.assertEqual(self.qm.stat().st_mtime_ns, initial)

    def test_changed_catalog_rebuilds_compiled_translations(self):
        self.catalog.write_text(FIXTURE.replace('maçã', 'pera'))
        self.run_command(['cmake', '--build', str(self.build), '-j2'])
        output = self.run_command([str(self.build / 'probe'), str(self.qm)])
        self.assertEqual(output.splitlines(), ['0 peras', '1 pera', '2 peras'])

    def test_explicit_brazilian_portuguese_keeps_its_plural_rules(self):
        output = self.run_command([str(self.build / 'probe'),
                                   str(self.build / 'translations/gcompris_qt_pt_BR.qm')])
        self.assertEqual(output.splitlines(), ['0 maçã', '1 maçã', '2 maçãs'])

    def test_real_portuguese_catalog_compiles_and_returns_revised_text(self):
        self.catalog.write_bytes((ROOT / 'poqm/pt/gcompris_qt.po').read_bytes())
        self.run_command(['cmake', '--build', str(self.build), '-j2'])
        self.assertEqual(ET.parse(self.ts).getroot().get('language'), 'pt_PT')
        output = self.run_command([str(self.build / 'probe'), str(self.qm),
                                   'Adjacent_numbers', 'Find the %n previous number(s).', 'plural'])
        self.assertEqual(output.splitlines(), [
            'Encontra os 0 números anteriores.', 'Encontra 1 número anterior.',
            'Encontra os 2 números anteriores.'])
        output = self.run_command([str(self.build / 'probe'), str(self.qm),
                                   'ActivityInfo', 'Ctrl + V: paste copied or cut text'])
        self.assertEqual(output.splitlines(), ['Ctrl + V: colar o texto copiado ou cortado'] * 3)

        output = self.run_command([str(self.build / 'probe'), str(self.qm), 'ToolsPanel', 'Pattern'])
        self.assertEqual(output.splitlines(), ['Padrão'] * 3)
        output = self.run_command([str(self.build / 'probe'), str(self.qm),
                                   'Data', 'Which number comes immediately after 2?'])
        self.assertEqual(output.splitlines(), ['Que número vem imediatamente depois do 2?'] * 3)
        output = self.run_command([str(self.build / 'probe'), str(self.qm), 'Data', 'dog'])
        self.assertEqual(output.splitlines(), ['cão'] * 3)
