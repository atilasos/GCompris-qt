#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Copy native QML runtime resources into an independently verified snapshot."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil


def sha(path):
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return digest.hexdigest()


def tree_files(path, ancestors=frozenset(), include_dirs=False):
    """Follow directory and file links, rejecting cycles and special files."""
    resolved = path.resolve(strict=True)
    if resolved in ancestors:
        raise ValueError(f'Resource symlink cycle: {path}')
    if path.is_dir():
        if include_dirs:
            yield path
        for child in sorted(path.iterdir()):
            yield from tree_files(child, ancestors | {resolved}, include_dirs)
    elif path.is_file():
        yield path
    else:
        raise ValueError(f'Resource is not a regular file or directory: {path}')


def source_files(binary):
    prefix = binary.parent.parent
    files = {'bin/gcompris-qt': binary}
    for name in ['share/gcompris-qt', 'lib/qml']:
        root = prefix / name
        if root.exists() or root.is_symlink():
            files.update((name + '/' + path.relative_to(root).as_posix(), path)
                         for path in tree_files(root))
    if not (prefix / 'share/gcompris-qt').is_dir():
        raise ValueError('Binary prefix must contain share/gcompris-qt')
    return files


def source_directories(binary):
    prefix = binary.parent.parent
    directories = {}
    for name in ['share/gcompris-qt', 'lib/qml']:
        root = prefix / name
        if root.exists() or root.is_symlink():
            directories.update((path.relative_to(prefix).as_posix(), path)
                               for path in tree_files(root, include_dirs=True) if path.is_dir())
    return directories


def inventory(files):
    return {name: sha(path) for name, path in sorted(files.items())}


def source_identity(files):
    identities = {}
    for name, path in files.items():
        stat = path.stat()
        identities[name] = (str(path.resolve(strict=True)), stat.st_dev, stat.st_ino,
                            stat.st_mode, stat.st_size, stat.st_mtime_ns, stat.st_ctime_ns)
    return identities


def create_snapshot(binary, destination):
    binary = Path(binary).absolute()
    destination = Path(destination).absolute()
    if destination.exists():
        raise ValueError('Snapshot output must be a new directory')
    before_files = source_files(binary)
    before_dirs = source_directories(binary)
    before_identity = source_identity(before_files | before_dirs)
    before = inventory(before_files)
    # A destination within a copied tree would recursively copy itself.
    for root in [binary.parent.parent / 'share/gcompris-qt', binary.parent.parent / 'lib/qml']:
        if destination.resolve().is_relative_to(root.resolve()):
            raise ValueError('Snapshot output must be outside the source resources')
    destination.mkdir(parents=True)
    try:
        for name in before_dirs:
            (destination / name).mkdir(parents=True, exist_ok=True)
        for name, path in before_files.items():
            target = destination / name
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, target, follow_symlinks=True)
        copied = inventory({name: destination / name for name in before})
        after_files = source_files(binary)
        if (copied != before or source_identity(after_files | source_directories(binary)) != before_identity
                or inventory(after_files) != before):
            raise RuntimeError('Resources changed while copying; retry after the source build is stable')
        manifest = {'version': 1, 'files': copied,
                    'directories': sorted(path.relative_to(destination).as_posix()
                                          for path in destination.rglob('*') if path.is_dir())}
        (destination / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
        return manifest
    except BaseException:
        shutil.rmtree(destination)
        raise


def verify_snapshot(destination):
    destination = Path(destination)
    manifest = json.loads((destination / 'manifest.json').read_text())
    if (manifest.get('version') != 1 or not isinstance(manifest.get('files'), dict)
            or not isinstance(manifest.get('directories'), list)):
        raise ValueError('Unsupported resource snapshot manifest')
    files = {}
    for path in destination.rglob('*'):
        if path.is_symlink():
            raise ValueError('Resource snapshot must not contain symlinks')
        if path.is_file() and path != destination / 'manifest.json':
            files[path.relative_to(destination).as_posix()] = path
        elif not path.is_file() and not path.is_dir():
            raise ValueError(f'Snapshot contains a non-regular resource: {path}')
    directories = sorted(path.relative_to(destination).as_posix()
                         for path in destination.rglob('*') if path.is_dir())
    if directories != manifest['directories']:
        raise RuntimeError('Resource snapshot directories differ from its manifest')
    if 'bin/gcompris-qt' not in manifest['files'] or inventory(files) != manifest['files']:
        raise RuntimeError('Resource snapshot differs from its manifest')
    return manifest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--binary', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    manifest = create_snapshot(args.binary, args.output)
    print(json.dumps({'snapshot': str(args.output.resolve()), 'files': len(manifest['files']),
                      'binary_sha256': manifest['files']['bin/gcompris-qt']}))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
