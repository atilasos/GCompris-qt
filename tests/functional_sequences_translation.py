# SPDX-License-Identifier: GPL-3.0-or-later
"""The real compiled PT chronology instruction must describe images, not letters."""
from pathlib import Path
import shlex
import subprocess
import tempfile
import unittest
ROOT = Path(__file__).resolve().parents[1]

class ChronologyTranslation(unittest.TestCase):
    def test_actual_qtranslator_instruction_mentions_images(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            subprocess.run(['/usr/lib/qt6/bin/lconvert', '-target-language', 'pt_PT', '-i',
                            str(ROOT / 'poqm/pt/gcompris_qt.po'), '-o', str(folder / 'pt.ts')], check=True, capture_output=True)
            subprocess.run(['/usr/lib/qt6/bin/lrelease', str(folder / 'pt.ts'), '-qm', str(folder / 'pt.qm')], check=True, capture_output=True)
            source = folder / 'probe.cpp'
            source.write_text('''#include <QCoreApplication>
#include <QTranslator>
#include <QTextStream>
int main(int argc,char**argv){QCoreApplication app(argc,argv);QTranslator t;
if(!t.load(argv[1]))return 2;app.installTranslator(&t);
QTextStream(stdout)<<QCoreApplication::translate("ordering","Drag and drop the items in chronological order.");}
''')
            flags = shlex.split(subprocess.check_output(['pkg-config', '--cflags', '--libs', 'Qt6Core'], text=True))
            subprocess.run(['c++', '-std=c++17', '-fPIC', str(source), *flags, '-o', str(folder / 'probe')], check=True)
            actual = subprocess.check_output([str(folder / 'probe'), str(folder / 'pt.qm')], text=True)
            self.assertEqual(actual, 'Arrasta e larga as imagens por ordem cronológica.')

if __name__ == '__main__':
    unittest.main()
