# SPDX-License-Identifier: GPL-3.0-or-later
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
. "$PSScriptRoot/install-candidate.ps1"
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('gcompris-nsis-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $fixture | Out-Null
try {
    $sentinel = Join-Path $fixture 'sentinel.txt'
    Set-Content -LiteralPath $sentinel -Value 'native-nsis-installation-boundary' -NoNewline
    $script = Join-Path $fixture 'fixture.nsi'
    @'
Unicode true
Name "GCompris installer boundary fixture"
OutFile "${OUTPUT}"
RequestExecutionLevel user
Section
    SetOutPath "$INSTDIR\bin"
    File /oname=GCompris.exe "${SENTINEL}"
SectionEnd
'@ | Set-Content -LiteralPath $script
    $installer = Join-Path $fixture 'fixture.exe'
    & "${env:ProgramFiles(x86)}/NSIS/makensis.exe" /INPUTCHARSET UTF8 "/DOUTPUT=$installer" "/DSENTINEL=$sentinel" $script
    $installed = Invoke-GComprisCandidateInstall -Installer $installer -Destination "$fixture/parent with spaces/./installed"
    if ((Get-Content -LiteralPath "$installed/bin/GCompris.exe" -Raw) -cne 'native-nsis-installation-boundary') {
        throw 'Native NSIS fixture installed incorrect sentinel bytes'
    }
    Write-Host "Native NSIS installation boundary passed: $installed"
} finally {
    Remove-Item -LiteralPath $fixture -Recurse -Force
}
