# SPDX-License-Identifier: GPL-3.0-or-later
"""Exercise the real CMake resource targets for the two offline datasets."""
import json
from pathlib import Path
import shlex
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class OfflineResourceBuild(unittest.TestCase):
    def test_default_datasets_are_in_the_compiled_resource_bundle(self):
        with tempfile.TemporaryDirectory(prefix='gcompris-offline-resources-') as directory:
            project = Path(directory)
            (project / 'CMakeLists.txt').write_text(f'''
cmake_minimum_required(VERSION 3.20)
project(OfflineResources LANGUAGES CXX)
find_package(Qt6 REQUIRED COMPONENTS Core)
set(QT_MAJOR Qt6)
set(WITH_RCC ON)
set(GCOMPRIS_RCC_DIR "${{CMAKE_BINARY_DIR}}/rcc")
file(MAKE_DIRECTORY "${{GCOMPRIS_RCC_DIR}}")
add_custom_target(createShareFolders)
include("{ROOT / 'cmake/rcc.cmake'}")
add_subdirectory("{ROOT / 'src/activities/multiple_choice_questions'}" mcq)
add_subdirectory("{ROOT / 'src/activities/ordering_chronology'}" chronology)
''')
            subprocess.run(['cmake', '-S', str(project), '-B', str(project / 'build')], check=True, capture_output=True)
            subprocess.run(['cmake', '--build', str(project / 'build')], check=True, capture_output=True)
            flags = shlex.split(subprocess.check_output(['pkg-config', '--cflags', '--libs', 'Qt6Core'], text=True))
            utility = project / 'probe'
            subprocess.run(['c++', '-std=c++17', '-fPIC', str(ROOT / 'tools/pt-pt-audio/rcc_inventory.cpp'),
                            *flags, '-o', str(utility)], check=True)
            for name, folders in [('multiple_choice_questions', ['1']), ('ordering_chronology', ['1', '2', '3'])]:
                rows = json.loads(subprocess.check_output([str(utility), str(project / 'build/rcc' / f'{name}.rcc')]))
                files = {row['path']: row for row in rows}
                for folder in folders:
                    path = f':/gcompris/src/activities/{name}/resource/{folder}/Data.qml'
                    self.assertIn(path, files)
                    self.assertGreater(files[path]['bytes'], 100)


if __name__ == '__main__':
    unittest.main()
