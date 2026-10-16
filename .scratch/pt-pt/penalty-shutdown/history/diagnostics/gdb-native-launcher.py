#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Inject a QtTest fragment into a PRIVATE activity RCC and exercise the real app.

The fragment is inserted in the pageComponent's lexical scope. Tests can access
its real IDs and use QtTest mouse/key events, timers and image grabs. The shared
build and distributed sources are never modified. Requires native Linux QtTest
and rcc; --offline also requires an already installed Docker image with chroot.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import uuid
import xml.etree.ElementTree as ET

from native_qml_resources import create_snapshot, verify_snapshot

ROOT = Path(__file__).resolve().parents[1]
ERROR = re.compile(r'(?:Reference|Type|Syntax)Error:|Expected token|Type \w+ unavailable|QQmlApplicationEngine failed|module .* is not installed')


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    global ROOT
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source-root', type=Path, default=ROOT)
    parser.add_argument('--binary', type=Path, help='source executable, required when creating a snapshot')
    parser.add_argument('--activity', required=True)
    parser.add_argument('--qml-file', type=Path, required=True, help='source path under src/activities, often the inherited base component')
    parser.add_argument('--case', type=Path, required=True, help='whole TestCase {...} QML fragment, without imports')
    parser.add_argument('--output', type=Path, required=True, help='new directory for logs, screenshots and result.json')
    parser.add_argument('--timeout', type=float, default=180)
    parser.add_argument('--result-marker', default='NATIVE_RESULT')
    parser.add_argument('--locale', default='pt_PT')
    parser.add_argument('--offline', action='store_true')
    parser.add_argument('--offline-container-image', default='alpine:latest')
    parser.add_argument('--start-level', type=int)
    parser.add_argument('--resource-snapshot', type=Path, help='verified independent runtime snapshot to reuse')
    parser.add_argument('--keep-deployment', action='store_true', help='retain successful private deployment; failures are always retained')
    args = parser.parse_args()
    ROOT = args.source_root.resolve()
    output = args.output.resolve()
    qml_path = args.qml_file.resolve()
    try:
        relative = qml_path.relative_to(ROOT / 'src/activities')
    except ValueError:
        parser.error('--qml-file must be under this checkout src/activities')
    if len(relative.parts) < 2 or not re.fullmatch(r'[A-Za-z0-9_-]+', args.activity):
        parser.error('Invalid activity or QML source path')
    if output.exists() and any(output.iterdir()):
        parser.error('Use a new empty output directory for every run')
    if (not args.resource_snapshot and (not args.binary or not args.binary.is_file())) or not args.case.is_file() or args.timeout <= 0:
        parser.error('Binary, case and positive timeout are required')
    source = qml_path.read_text()
    closing = re.search(r'\n    }\s*\n}\s*$', source)
    if 'pageComponent:' not in source or not closing:
        parser.error('Expected a pageComponent as the final member of the root QML object')
    fragment = args.case.read_text().replace('__QA_OUTPUT__', output.as_posix()).replace('__QA_SOURCE__', ROOT.as_posix())
    if not re.search(r'\bTestCase\s*{', fragment):
        parser.error('Case must contain a TestCase QML fragment')
    patched = source[:closing.start()] + '\n' + fragment + source[closing.start():]
    patched = 'import QtTest\n' + patched
    output.mkdir(parents=True, exist_ok=True)
    deployment = output.parent / ('.native-qml-' + uuid.uuid4().hex)
    profile = deployment / 'profile'
    (deployment / 'bin').mkdir(parents=True)
    for name in ['config', 'data', 'cache']:
        (profile / name).mkdir(parents=True)
    snapshot = args.resource_snapshot.resolve() if args.resource_snapshot else deployment / 'resource-snapshot'
    resource_manifest = verify_snapshot(snapshot) if args.resource_snapshot else create_snapshot(args.binary, snapshot)
    binary = deployment / 'bin/gcompris-qt'
    shutil.copy2(snapshot / 'bin/gcompris-qt', binary)
    share = deployment / 'share/gcompris-qt'
    share.mkdir(parents=True)
    # Each case replaces its own RCC and Portuguese catalogue below. All other
    # references point exclusively into the independent snapshot.
    for path in (snapshot / 'share/gcompris-qt').iterdir():
        target = share / path.name
        if path.name in ['rcc', 'translations']:
            target.mkdir()
            for resource in path.iterdir():
                (target / resource.name).symlink_to(resource)
        else:
            target.symlink_to(path, target_is_directory=path.is_dir())
    if (snapshot / 'lib/qml').is_dir():
        (deployment / 'lib').mkdir()
        (deployment / 'lib/qml').symlink_to(snapshot / 'lib/qml', target_is_directory=True)
    source_folder = ROOT / 'src/activities' / relative.parts[0]
    instrumented = deployment / qml_path.name
    instrumented.write_text(patched)
    qrc = ET.Element('RCC')
    resources = ET.SubElement(qrc, 'qresource', prefix='/gcompris/src/activities/' + relative.parts[0])
    for path in sorted(source_folder.rglob('*')):
        if path.is_file():
            ET.SubElement(resources, 'file', alias=path.relative_to(source_folder).as_posix()).text = str(instrumented if path == qml_path else path)
    qrc_path = deployment / 'case.qrc'
    ET.ElementTree(qrc).write(qrc_path, encoding='utf-8')
    rcc = share / 'rcc' / (relative.parts[0] + '.rcc')
    if rcc.is_symlink():
        rcc.unlink()
    subprocess.run(['/usr/lib/qt6/libexec/rcc', '--binary', str(qrc_path), '-o', str(rcc)], check=True)
    # Recompile this checkout's PT catalogue so translation fixes are exercised too.
    ts = deployment / 'gcompris_qt_pt.ts'
    subprocess.run(['/usr/lib/qt6/bin/lconvert', '-target-language', 'pt_PT', '-i',
                    str(ROOT / 'poqm/pt/gcompris_qt.po'), '-o', str(ts)], check=True, capture_output=True)
    qm = share / 'translations/gcompris_qt_pt.qm'
    if qm.is_symlink():
        qm.unlink()
    subprocess.run(['/usr/lib/qt6/bin/lrelease', '-removeidentical', '-nounfinished', str(ts),
                    '-qm', str(qm)], check=True, capture_output=True)
    cmake = (ROOT / 'CMakeLists.txt').read_text()
    version = [int(re.search(r'set\(GCOMPRIS_' + kind + r'_VERSION (\d+)\)', cmake)[1]) for kind in ['MAJOR', 'MINOR', 'PATCH']]
    version_code = version[0] * 10000 + version[1] * 100 + version[2]
    config = profile / 'config/gcompris/gcompris-qt.conf'
    config.parent.mkdir()
    config.write_text(f'[Internal]\nexeCount=1\nlastGCVersionRan={version_code}\n[%General]\nenableAutomaticDownloads=false\n')
    env = dict(os.environ, QT_QPA_PLATFORM='offscreen')
    for key, name in [('XDG_CONFIG_HOME', 'config'), ('XDG_DATA_HOME', 'data'), ('XDG_CACHE_HOME', 'cache')]:
        env[key] = str(profile / name)
    command = [str(binary), '--window', '--locale', args.locale, '--renderer', 'software', '--mute', '--launch', args.activity]
    if args.start_level is not None:
        command += ['--start-level', str(args.start_level)]
    command = ['/usr/bin/gdb', '--batch', '--return-child-result', '-ex', 'set pagination off', '-ex', 'run', '-ex', 'thread apply all bt', '--args', *command]
    container = None
    image = None
    if args.offline:
        image = subprocess.check_output(['docker', 'image', 'inspect', '--format', '{{.Id}}', args.offline_container_image], text=True).strip()
        container = 'gcompris-qa-' + uuid.uuid4().hex
        gnu_chroot = None
        for candidate in [shutil.which('gnuchroot'), '/usr/sbin/gnuchroot', shutil.which('chroot')]:
            if candidate and Path(candidate).is_file():
                version = subprocess.check_output([candidate, '--version'], text=True)
                if 'GNU coreutils' in version:
                    gnu_chroot = candidate
                    break
        if gnu_chroot is None:
            parser.error('--offline requires GNU chroot with --userspec support')
        settings = [f'{key}={env[key]}' for key in ['QT_QPA_PLATFORM', 'XDG_CONFIG_HOME', 'XDG_DATA_HOME', 'XDG_CACHE_HOME']]
        command = ['docker', 'run', '--rm', '--pull=never', '--name', container, '--network', 'none', '--read-only',
                   '--mount', 'type=bind,src=/,dst=/host,readonly',
                   # Restore private resources beneath /tmp after its tmpfs overlay.
                   '--mount', f'type=bind,src={deployment},dst=/host{deployment},readonly',
                   '--mount', f'type=bind,src={snapshot},dst=/host{snapshot},readonly',
                   '--mount', f'type=bind,src={profile},dst=/host{profile}',
                   '--mount', f'type=bind,src={output},dst=/host{output}',
                   '--tmpfs', '/host/tmp:rw,mode=1777', image, 'chroot', '/host', gnu_chroot,
                   f'--userspec={os.getuid()}:{os.getgid()}', '/', '/usr/bin/env', *settings, *command]
    effective_resources = dict(resource_manifest['files'])
    effective_resources['share/gcompris-qt/rcc/' + relative.parts[0] + '.rcc'] = sha(rcc)
    effective_resources['share/gcompris-qt/translations/gcompris_qt_pt.qm'] = sha(qm)
    metadata = {'resource_snapshot': str(snapshot), 'resource_manifest_sha256': sha(snapshot / 'manifest.json'), 'resource_files_sha256': effective_resources,
                'runtime_uid': os.getuid(), 'runtime_gid': os.getgid(), 'offline_image_id': image, 'activity': args.activity, 'locale': args.locale, 'qml_file': str(relative),
                'source_sha256': sha(qml_path), 'portuguese_catalogue_sha256': sha(ROOT / 'poqm/pt/gcompris_qt.po'),
                'private_qm_sha256': sha(qm), 'case_sha256': sha(args.case), 'private_rcc_sha256': sha(rcc),
                'binary_sha256': sha(binary), 'runner_sha256': sha(Path(__file__)), 'deployment': str(deployment), 'version_code': version_code,
                'network': 'docker-none' if args.offline else 'not-enforced', 'timestamp_utc': datetime.now(timezone.utc).isoformat(),
                'scope': 'Only actions and assertions in the named case; native Qt starts muted but cases may change audio settings; no physical sound, pronunciation or Windows approval.'}
    log_path = output / 'native.log'
    timeout = False
    with log_path.open('w') as log:
        process = subprocess.Popen(command, env=env, stdout=log, stderr=subprocess.STDOUT)
        try:
            code = process.wait(timeout=args.timeout)
        except subprocess.TimeoutExpired:
            timeout = True
            if container:
                subprocess.run(['docker', 'stop', '--time', '1', container], capture_output=True, timeout=10)
            else:
                process.terminate()
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()
            code = process.returncode
    text = log_path.read_text(errors='replace')
    markers = re.findall(r'^qml: ' + re.escape(args.result_marker) + r' (\{.*\})$', text, re.M)
    result = json.loads(markers[0]) if len(markers) == 1 else None
    errors = [line for line in text.splitlines() if ERROR.search(line)]
    passed = not timeout and code == 0 and result is not None and result.get('failures') == 0 and result.get('passes', 0) >= 1 and not errors
    verify_snapshot(snapshot)
    wrong_owners = [str(path) for root in [profile, output] for path in root.rglob('*')
                    if path.lstat().st_uid != os.getuid() or path.lstat().st_gid != os.getgid()]
    if wrong_owners:
        raise RuntimeError('Private runtime files have unexpected owners: ' + ', '.join(wrong_owners))
    screenshots = [{'file': path.name, 'sha256': sha(path), 'bytes': path.stat().st_size} for path in sorted(output.glob('*.png'))]
    metadata.update({'screenshots': screenshots, 'passed': passed, 'timeout': timeout, 'exit_code': code, 'qml_errors': errors, 'case_result': result})
    metadata['deployment_retained'] = args.keep_deployment or not passed
    metadata['private_file_ownership_verified'] = True
    (output / 'result.json').write_text(json.dumps(metadata, ensure_ascii=False, indent=2) + '\n')
    if not metadata['deployment_retained']:
        shutil.rmtree(deployment)
    print(json.dumps(metadata, ensure_ascii=False))
    return 0 if passed else 1


if __name__ == '__main__':
    raise SystemExit(main())
