# SPDX-License-Identifier: GPL-3.0-or-later
import hashlib
import importlib.util
from pathlib import Path
import tempfile
import sys
import shutil
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('candidate_assets', ROOT / 'tools/windows/fetch-assets.py')
assets = importlib.util.module_from_spec(spec)
spec.loader.exec_module(assets)


class LockedAssetsTest(unittest.TestCase):
    def test_mismatched_download_cannot_become_packaged_resource(self):
        with tempfile.TemporaryDirectory() as temporary:
            target = Path(temporary) / 'data3'
            source = Path(temporary) / 'source.rcc'
            source.write_bytes(b'changed resource')
            entry = {'path': 'words/words.rcc', 'url': source.as_uri(),
                     'sha256': hashlib.sha256(b'approved resource').hexdigest(), 'bytes': 17}
            with self.assertRaises(ValueError):
                assets.fetch([entry], target)
            self.assertFalse((target / 'words/words.rcc').exists())

    def test_verified_asset_is_available_at_the_runtime_relative_path(self):
        with tempfile.TemporaryDirectory() as temporary:
            source = Path(temporary) / 'source.rcc'
            content = b'approved resource'
            source.write_bytes(content)
            entry = {'path': 'voices-ogg/voices-pt.rcc', 'url': source.as_uri(),
                     'sha256': hashlib.sha256(content).hexdigest(), 'bytes': len(content)}
            target = Path(temporary) / 'data3'
            assets.fetch([entry], target)
            self.assertEqual((target / entry['path']).read_bytes(), content)

class PackagedRuntimeTest(unittest.TestCase):
    def test_empty_stage_cannot_pass_offline_readiness(self):
        runtime_spec = importlib.util.spec_from_file_location('verify_package', ROOT / 'tools/windows/verify-package.py')
        runtime = importlib.util.module_from_spec(runtime_spec)
        runtime_spec.loader.exec_module(runtime)
        with tempfile.TemporaryDirectory() as temporary:
            result = runtime.check(Path(temporary), ['click_on_letter'], [])
            self.assertFalse(result['passed'])
            self.assertIn('bin/GCompris.exe', result['missing'])
            self.assertIn('share/GCompris/rcc/click_on_letter.rcc', result['missing'])


class WindowsTranslationTest(unittest.TestCase):
    @unittest.skipUnless(sys.platform == 'linux' and Path('/usr/lib/qt6/bin/lconvert').exists(),
                         'Native QTranslator probe runs against the Linux Qt installation')
    def test_windows_catalog_uses_european_zero_one_two_plural_rules(self):
        # Reuse the native QTranslator probe, then replace its QM via the Windows
        # build's own converter. This checks the produced artifact, not flag text.
        from test_translation_build import TranslationBuildTest
        fixture = TranslationBuildTest('test_european_portuguese_compiled_zero_one_two_plurals')
        self.addCleanup(fixture.doCleanups)
        fixture.setUp()
        module_spec = importlib.util.spec_from_file_location('compile_portuguese', ROOT / 'tools/windows/compile-portuguese.py')
        compiler = importlib.util.module_from_spec(module_spec)
        module_spec.loader.exec_module(compiler)
        compiler.compile_catalog(Path('/usr/lib/qt6'), fixture.catalog, fixture.ts, fixture.qm)
        output = fixture.run_command([str(fixture.build / 'probe'), str(fixture.qm)])
        self.assertEqual(output.splitlines(), ['0 maçãs', '1 maçã', '2 maçãs'])


class CompletedVoicePackageTest(unittest.TestCase):
    def test_generated_voice_manifest_preserves_original_and_checks_replacement(self):
        runtime_spec = importlib.util.spec_from_file_location('verify_package', ROOT / 'tools/windows/verify-package.py')
        runtime = importlib.util.module_from_spec(runtime_spec)
        runtime_spec.loader.exec_module(runtime)
        with tempfile.TemporaryDirectory() as temporary:
            stage = Path(temporary)
            voice_dir = stage / 'share/GCompris/rcc/data3/voices-ogg'
            voice_dir.mkdir(parents=True)
            original = b'original voices'
            completed = b'original voices plus approved additions'
            contents = b'pt updated contents'
            for name, data in [('original.rcc', original), ('completed.rcc', completed), ('Contents', contents)]:
                (voice_dir / name).write_bytes(data)
            entry = lambda name, data: {'path': name, 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}
            original_entries = [entry('voices-ogg/original.rcc', original), entry('voices-ogg/Contents', b'old contents')]
            completion = {'format': 1, 'source_rcc': 'original.rcc', 'source_rcc_sha256': hashlib.sha256(original).hexdigest(),
                          'original_files': 1578, 'added_files': 32, 'total_files': 1610, 'original_bytes_preserved': True,
                          'files': [entry('completed.rcc', completed), entry('Contents', contents)]}
            result = runtime.check(stage, [], original_entries, completion=completion)
            self.assertEqual(result['corrupt'], [])
            (voice_dir / 'completed.rcc').write_bytes(b'corrupted')
            result = runtime.check(stage, [], original_entries, completion=completion)
            self.assertIn('share/GCompris/rcc/data3/voices-ogg/completed.rcc', result['corrupt'])
            (voice_dir / 'completed.rcc').write_bytes(completed)
            (voice_dir / 'original.rcc').write_bytes(b'corrupted original')
            result = runtime.check(stage, [], original_entries, completion=completion)
            self.assertIn('share/GCompris/rcc/data3/voices-ogg/original.rcc', result['corrupt'])


class NativeActivityProbeTest(unittest.TestCase):
    def test_authoritative_manifest_selects_all_unique_activity_ids(self):
        probe_spec = importlib.util.spec_from_file_location('native_probe_manifest', ROOT / 'tools/windows/native-probe.py')
        probe = importlib.util.module_from_spec(probe_spec)
        probe_spec.loader.exec_module(probe)
        names = probe.read_activities(ROOT / 'src/activities/activities.txt')
        self.assertEqual(len(names), 203)
        self.assertEqual(len(set(names)), 203)
        self.assertIn('programmingMaze', names)
        self.assertIn('alphabet-sequence', names)
        with tempfile.TemporaryDirectory() as directory:
            manifest = Path(directory) / 'activities.txt'
            for text in ['', 'gletters\ngletters\n', '../outside', 'path/name', 'two words', 'game;cmd']:
                manifest.write_text(text)
                with self.subTest(text=text), self.assertRaises(ValueError):
                    probe.read_activities(manifest)

    @unittest.skipIf(sys.platform == 'win32', 'Executable fixture uses a POSIX shebang')
    def test_cli_runs_manifest_in_order_and_rejects_native_list_mismatch(self):
        import json
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            binary = folder / 'game'
            binary.write_text("#!/usr/bin/env python3\nimport sys,time\nif '--list-activities' in sys.argv:print('programmingMaze\\nalphabet-sequence');sys.exit(0)\na=sys.argv[-1]\nprint('Start activity '+a+'/Game.qml',flush=True)\nprint('Successfully registered resource voices-completed.rcc',flush=True)\ntime.sleep(3)\n")
            binary.chmod(0o755)
            manifest = folder / 'manifest.txt'
            manifest.write_text('# full manifest fixture\nprogrammingMaze\nalphabet-sequence\n')
            command = [sys.executable, str(ROOT / 'tools/windows/native-probe.py'), '--binary', str(binary),
                       '--activities-file', str(manifest), '--output', str(folder / 'result'),
                       '--seconds', '0.1', '--expected-voice', 'voices-completed.rcc']
            result = subprocess.run(command, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            report = json.loads((folder / 'result/startup-check.json').read_text())
            self.assertEqual([row['activity'] for row in report['activities']], ['programmingMaze', 'alphabet-sequence'])
            self.assertTrue(report['activity_list_matches_manifest'])
            manifest.write_text('programmingMaze\n')
            result = subprocess.run(command, capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            report = json.loads((folder / 'result/startup-check.json').read_text())
            self.assertFalse(report['passed'])
            self.assertFalse(report['activity_list_matches_manifest'])

    @unittest.skipUnless(sys.platform != 'win32', 'Executable fixture uses a POSIX shebang; Windows runs the native app')
    def test_launched_game_must_stay_alive_register_voices_and_have_no_qml_errors(self):
        probe_spec = importlib.util.spec_from_file_location('native_probe', ROOT / 'tools/windows/native-probe.py')
        probe = importlib.util.module_from_spec(probe_spec)
        probe_spec.loader.exec_module(probe)
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            executable = folder / 'game'
            executable.write_text("#!/usr/bin/env python3\nimport sys,time\na=sys.argv[-1]\nprint('Start activity '+a+'/Game.qml',flush=True)\nprint('Successfully registered resource voices-completed.rcc',flush=True)\nif a=='broken':print('TypeError: missing data',flush=True)\nif a=='early':sys.exit(0)\ntime.sleep(3)\n")
            executable.chmod(0o755)
            self.assertTrue(probe.check_startup(executable, 'good', 'voices-completed.rcc', 0.15, folder)['passed'])
            self.assertFalse(probe.check_startup(executable, 'broken', 'voices-completed.rcc', 0.15, folder)['passed'])
            self.assertFalse(probe.check_startup(executable, 'early', 'voices-completed.rcc', 0.15, folder)['passed'])
            self.assertFalse(probe.check_startup(executable, 'good', 'voices-absent.rcc', 0.15, folder)['passed'])


class CandidateInstallationBoundaryTest(unittest.TestCase):
    @unittest.skipUnless(shutil.which('pwsh'), 'Requires PowerShell7')
    def test_nsis_receives_canonical_destination_and_installation_is_checked(self):
        with tempfile.TemporaryDirectory() as directory:
            script = Path(directory) / 'installation.ps1'
            helper = str(ROOT / 'tools/windows/install-candidate.ps1').replace("'", "''")
            script.write_text("""
$ErrorActionPreference = 'Stop'
. '""" + helper + """'
$script:mode = 'success'
function Start-Process { param($FilePath,$ArgumentList,[switch]$PassThru,[switch]$Wait)
    if ($ArgumentList.Count -ne 2 -or $ArgumentList[0] -ne '/S') { throw 'Unexpected installer arguments' }
    $destination = $ArgumentList[-1].Substring(3)
    if ($ArgumentList[-1] -cne ('/D=' + (Get-Item -LiteralPath $destination).FullName)) { throw 'NSIS destination is not canonical' }
    if ($script:mode -eq 'success') {
        New-Item -ItemType Directory -Path "$destination/bin" | Out-Null
        New-Item -ItemType File -Path "$destination/bin/GCompris.exe" | Out-Null
    }
    return [pscustomobject]@{ExitCode = $(if ($script:mode -eq 'failure') { 9 } else { 0 })}
}
$destination = "$PSScriptRoot/parent with spaces/./installed"
$result = Invoke-GComprisCandidateInstall -Installer 'candidate.exe' -Destination $destination
if ($result -cne (Get-Item -LiteralPath $destination).FullName) { throw 'Returned installation root is not canonical' }
foreach ($mode in @('failure', 'missing-binary')) {
    $script:mode = $mode
    $caught = $false
    try { Invoke-GComprisCandidateInstall -Installer 'candidate.exe' -Destination "$PSScriptRoot/$mode" }
    catch { $caught = $true }
    if (!$caught) { throw "Unexpected installation acceptance: $mode" }
}
""")
            result = subprocess.run([shutil.which('pwsh'), '-NoProfile', '-File', str(script)], capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


class NativeEnvironmentLifecycleTest(unittest.TestCase):
    @unittest.skipUnless(shutil.which('pwsh'), 'Requires PowerShell7 (available on the native Windows runner)')
    def test_failure_restores_qt_environment_path_and_removes_firewall_rule(self):
        with tempfile.TemporaryDirectory() as directory:
            script = Path(directory) / 'lifecycle.ps1'
            helper = str(ROOT / 'tools/windows/native-check.ps1').replace("'", "''")
            script.write_text("""
$ErrorActionPreference = 'Stop'
. '""" + helper + """'
function New-NetFirewallRule { param($Name,$DisplayName,$Direction,$Program,$Action)
    $script:created = $Name
    $script:program = $Program
    $script:logging = $env:QT_FORCE_STDERR_LOGGING
    $env:QT_NEW_LEAK = 'must disappear'
}
function Remove-NetFirewallRule { param($Name,$ErrorAction) $script:removed = $Name }
$env:QT_PLUGIN_PATH = 'retained plugin path'
$env:QML_IMPORT_PATH = 'retained qml path'
$env:QSG_RHI_BACKEND = 'retained backend'
$env:QTDIR = 'retained sdk'
$env:QT_MEDIA_BACKEND = $null
$env:QT_FORCE_STDERR_LOGGING = $null
$oldPath = $env:PATH
$bin = New-Item -ItemType Directory -Path "$PSScriptRoot/install/bin"
$binary = New-Item -ItemType File -Path "$($bin.FullName)/GCompris.exe"
$expectedProgram = $binary.FullName
$caught = $false
try { Invoke-GComprisNativeCheck -InstallRoot "$PSScriptRoot/install/." -Output 'not-created' -Python '/intentionally-not-present/python' }
catch { $caught = $true }
if (!$caught) { throw 'Expected native invocation failure' }
if (!$script:created -or $script:created -ne $script:removed) { throw 'Firewall was not restored' }
if ($script:logging -ne '1') { throw 'Qt GUI logging must be captured on stderr' }
if ($script:program -cne $expectedProgram) { throw "Firewall Program is not the canonical executable path: $script:program" }
if ($env:PATH -ne $oldPath -or $env:QT_PLUGIN_PATH -ne 'retained plugin path' -or
    $env:QML_IMPORT_PATH -ne 'retained qml path' -or $env:QSG_RHI_BACKEND -ne 'retained backend' -or
    $env:QTDIR -ne 'retained sdk' -or $env:QT_MEDIA_BACKEND -or $env:QT_FORCE_STDERR_LOGGING -or $env:QT_NEW_LEAK) { throw 'Environment leaked' }
""")
            result = subprocess.run([shutil.which('pwsh'), '-NoProfile', '-File', str(script)], capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == '__main__':
    unittest.main()
