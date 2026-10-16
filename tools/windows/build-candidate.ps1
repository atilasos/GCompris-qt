# SPDX-License-Identifier: GPL-3.0-or-later
param(
    [Parameter(Mandatory)][string]$QtRoot,
    [Parameter(Mandatory)][string]$OpenSSLRoot
)
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
. "$PSScriptRoot/native-check.ps1"
. "$PSScriptRoot/install-candidate.ps1"
$python = (Get-Command python).Source
$source = (Resolve-Path "$PSScriptRoot/../..").Path
$build = "$source/build/windows-candidate"
$stage = "$build/stage"
$artifacts = "$build/artifacts"
New-Item -ItemType Directory -Force $build, $artifacts | Out-Null
Start-Transcript -Path "$build/build.log"
try {
    $env:PATH = "$QtRoot/bin;$env:PATH"
    # Build the pinned Box2D submodule separately: the inherited superbuild tries
    # to strip PE binaries with a Unix strip command, which is wrong for MSVC.
    cmake -S "$source/external/qml-box2d" -B "$build/box2d" -G Ninja "-DCMAKE_PREFIX_PATH=$QtRoot" -DCMAKE_BUILD_TYPE=Release -DBUILD_EXAMPLES=OFF
    cmake --build "$build/box2d" --parallel 2
    $box2d = "$build/box2d/bin/plugins/Box2D"
    if (!(Test-Path "$box2d/qmlbox2d.dll")) { throw 'Box2D plugin missing' }
    # Use current windeployqt instead of the older hard-coded plugin packaging.
    # OGG avoids in-source format conversions; deployed FFmpeg decodes the assets.
    cmake -S $source -B $build -G Ninja "-DCMAKE_PREFIX_PATH=$QtRoot" "-DOPENSSL_ROOT_DIR=$OpenSSLRoot" -DCMAKE_BUILD_TYPE=Release -DBUILD_SERVER=OFF -DBUILD_STANDALONE=OFF -DPACKAGE_GCOMPRIS=OFF -DSKIP_TRANSLATIONS=ON -DCOMPRESSED_AUDIO=ogg -DQML_BOX2D_MODULE=system "-DQML_BOX2D_LIBRARY=$box2d/qmlbox2d.dll"
    cmake --build $build --parallel 2
    $translation = "$build/share/GCompris/translations"
    New-Item -ItemType Directory -Force $translation | Out-Null
    python "$PSScriptRoot/compile-portuguese.py" $QtRoot "$source/poqm/pt/gcompris_qt.po" "$build/gcompris_qt_pt.ts" "$translation/gcompris_qt_pt.qm"
    python "$PSScriptRoot/fetch-assets.py" "$build/share/GCompris/rcc/data3"
    cmake --build $build --target pt_audio_rcc_inventory --parallel 2
    $rcc = "$QtRoot/bin/rcc.exe"
    if (!(Test-Path $rcc)) { $rcc = "$QtRoot/libexec/rcc.exe" }
    python "$source/tools/pt-pt-audio/complete_voices.py" --voices-dir "$build/share/GCompris/rcc/data3/voices-ogg" --inventory-tool "$build/bin/pt_audio_rcc_inventory.exe" --rcc-tool $rcc
    New-Item -ItemType Directory -Force "$stage/bin", "$stage/share", "$stage/lib/qml/Box2D.2.0" | Out-Null
    Copy-Item "$build/bin/GCompris.exe" "$stage/bin/"
    Copy-Item "$build/share/GCompris" "$stage/share/" -Recurse -Force
    Copy-Item "$box2d/qmldir", "$box2d/qmlbox2d.dll" "$stage/lib/qml/Box2D.2.0/"
    & "$QtRoot/bin/windeployqt.exe" --help | Set-Content "$build/windeployqt-help.log"
    & "$QtRoot/bin/windeployqt.exe" --release --compiler-runtime --add-plugin-types "platforms,imageformats,multimedia,tls" --openssl-root "$OpenSSLRoot" --qmldir "$source/src" "$stage/bin/GCompris.exe"
    # Deploy dependencies of our dynamic Box2D plugin too.
    & "$QtRoot/bin/windeployqt.exe" --release --compiler-runtime "$stage/lib/qml/Box2D.2.0/qmlbox2d.dll"
    Copy-Item "$OpenSSLRoot/bin/*.dll" "$stage/bin/"
    $crt = Get-ChildItem "$env:VCToolsRedistDir/x64/Microsoft.VC*.CRT" -Directory | Select-Object -First 1
    if (!$crt) { throw 'MSVC app-local redistributable missing' }
    Copy-Item "$($crt.FullName)/*.dll" "$stage/bin/"
    foreach ($licenses in @("$QtRoot/licenses", "$QtRoot/LICENSES")) {
        if (Test-Path $licenses) { Copy-Item $licenses "$stage/Qt-licenses" -Recurse -Force }
    }
    if (Test-Path "$OpenSSLRoot/share/openssl/copyright") { Copy-Item "$OpenSSLRoot/share/openssl/copyright" "$stage/OpenSSL-LICENSE.txt" }
    Copy-Item "$source/LICENSES" "$stage/" -Recurse -Force
    Copy-Item "$source/README" "$stage/" -Force
    Copy-Item "$PSScriptRoot/../../.scratch/pt-pt/windows-candidate.md" "$stage/LEIA-PRIMEIRO.md"
    # Store the source revision and lock so the candidate remains traceable.
    git -C $source rev-parse HEAD | Set-Content "$stage/source-commit.txt"
    Copy-Item "$PSScriptRoot/assets-lock.json" "$stage/assets-lock.json"
    python "$PSScriptRoot/verify-package.py" $stage --activities "$source/src/activities/activities.txt" --output "$artifacts/package-check.json"
    Invoke-GComprisNativeCheck -InstallRoot $stage -Output "$artifacts/staged" -Python $python -RequireFreshProfile
    python "$PSScriptRoot/verify-package.py" $stage --activities "$source/src/activities/activities.txt" --listed "$artifacts/staged/activities.txt" --output "$artifacts/package-check.json"
    $installer = "$artifacts/GCompris-PT-PT-Windows-x64-candidate.exe"
    & "${env:ProgramFiles(x86)}/NSIS/makensis.exe" /INPUTCHARSET UTF8 "/DSTAGE=$stage" "/DSOURCE=$source" "/DOUTPUT=$installer" "$PSScriptRoot/candidate.nsi"
    $installed = Invoke-GComprisCandidateInstall -Installer $installer -Destination "$build/installed"
    # Independent installed processes in the same initially fresh CI account.
    Invoke-GComprisNativeCheck -InstallRoot $installed -Output "$artifacts/installed" -Python $python -ActivitiesFile "$source/src/activities/activities.txt"
    python "$PSScriptRoot/verify-package.py" $installed --activities "$source/src/activities/activities.txt" --listed "$artifacts/installed/activities.txt" --output "$artifacts/installer-check.json"
    Compress-Archive -Path "$stage/*" -DestinationPath "$artifacts/GCompris-PT-PT-Windows-x64-portable.zip" -Force
    Get-ChildItem $artifacts -File | Where-Object Extension -in '.exe','.zip' | ForEach-Object {
        "$((Get-FileHash $_.FullName -Algorithm SHA256).Hash.ToLower())  $($_.Name)"
    } | Set-Content "$artifacts/SHA256SUMS.txt"
} finally {
    Stop-Transcript
}
