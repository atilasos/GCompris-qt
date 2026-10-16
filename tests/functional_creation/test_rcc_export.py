# SPDX-License-Identifier: GPL-3.0-or-later
import json,unittest
from pathlib import Path
from unittest.mock import patch
from rcc_export import compile_exporter,export_resources
class RccExportBoundary(unittest.TestCase):
 @patch('rcc_export.subprocess.run')
 @patch('rcc_export.subprocess.check_output')
 def test_compile_keeps_explicit_source_output_and_qt_flags(self,output,run):
  output.return_value='-I/qt/include -lQt6Core\n';compile_exporter(Path('frozen/source.cpp'),Path('private/exporter'))
  output.assert_called_once_with(['pkg-config','--cflags','--libs','Qt6Core'],text=True)
  run.assert_called_once_with(['g++','-std=c++17','-fPIC','frozen/source.cpp','-o','private/exporter','-I/qt/include','-lQt6Core'],check=True)
 @patch('rcc_export.subprocess.check_output')
 def test_export_uses_explicit_rcc_and_destination(self,output):
  rows=[{'path':':/gcompris/icon.svg','bytes':3,'sha256':'a'*64}];output.return_value=json.dumps(rows)
  self.assertEqual(export_resources(Path('private/exporter'),Path('sealed/source.rcc'),Path('private/extracted')),rows)
  output.assert_called_once_with(['private/exporter','sealed/source.rcc','private/extracted'])
 @patch('rcc_export.subprocess.check_output')
 def test_invalid_export_response_is_rejected(self,output):
  output.return_value='{}'
  with self.assertRaises(ValueError):export_resources(Path('exporter'),Path('source.rcc'),Path('extracted'))
if __name__=='__main__':unittest.main()
