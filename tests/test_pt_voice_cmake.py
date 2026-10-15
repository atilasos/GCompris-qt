# SPDX-License-Identifier: GPL-3.0-or-later
"""Exercise the asset target in native and cross-compiling CMake fixtures."""
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class VoiceAssetHook(unittest.TestCase):
    def test_cross_compiling_keeps_get_assets_without_executing_target_binary(self):
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory)
            (source / 'CMakeLists.txt').write_text(f'''
cmake_minimum_required(VERSION 3.16)
project(CrossAssets NONE)
if(NOT CMAKE_CROSSCOMPILING)
  message(FATAL_ERROR "Fixture must actually cross-compile")
endif()
set(COMPRESSED_AUDIO ogg)
add_custom_target(getAssets COMMAND ${{CMAKE_COMMAND}} -E touch "${{CMAKE_BINARY_DIR}}/assets-downloaded")
include("{ROOT / 'cmake/CompletePtVoices.cmake'}")
gcompris_complete_pt_voices(getAssets)
if(TARGET pt_audio_rcc_inventory)
  message(FATAL_ERROR "Cross assets must not build a target utility for host execution")
endif()
''')
            build = source / 'build'
            result = subprocess.run(['cmake', '-S', str(source), '-B', str(build), '-DCMAKE_SYSTEM_NAME=Generic'], capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            subprocess.run(['cmake', '--build', str(build), '--target', 'getAssets'], check=True, capture_output=True)
            self.assertTrue((build / 'assets-downloaded').is_file())

    def test_native_get_assets_builds_host_tool_and_runs_completion_hook(self):
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory)
            scripts = source / 'tools/pt-pt-audio'
            scripts.mkdir(parents=True)
            for name in ['rcc_inventory.cpp', 'complete_voices.py']:
                shutil.copy2(ROOT / 'tools/pt-pt-audio' / name, scripts / name)
            manifest = source / 'resources/pt-pt-voices'
            manifest.mkdir(parents=True)
            (manifest / 'manifest.json').write_text(json.dumps({'source_rcc': 'not-downloaded.rcc'}))
            (source / 'CMakeLists.txt').write_text(f'''
cmake_minimum_required(VERSION 3.16)
project(NativeAssets LANGUAGES CXX)
find_package(Qt6 REQUIRED COMPONENTS Core)
set(QT_MAJOR Qt6)
set(COMPRESSED_AUDIO ogg)
set(GCOMPRIS_ASSETS_DIR "${{CMAKE_BINARY_DIR}}/rcc")
add_custom_target(getAssets COMMAND ${{CMAKE_COMMAND}} -E touch "${{CMAKE_BINARY_DIR}}/assets-downloaded")
include("{ROOT / 'cmake/CompletePtVoices.cmake'}")
gcompris_complete_pt_voices(getAssets)
''')
            build = source / 'build'
            subprocess.run(['cmake', '-S', str(source), '-B', str(build)], check=True, capture_output=True)
            result = subprocess.run(['cmake', '--build', str(build), '--target', 'getAssets', '-j2'], capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn('PT voice completion skipped: upstream assets have not been downloaded.', result.stdout)
            self.assertTrue((build / 'assets-downloaded').is_file())
