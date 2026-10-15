# SPDX-License-Identifier: GPL-3.0-or-later
function Invoke-GComprisCandidateInstall {
    param(
        [Parameter(Mandatory)][string]$Installer,
        [Parameter(Mandatory)][string]$Destination
    )
    # NSIS strips forward slashes from /D=. Get a native absolute path first.
    $installed = (New-Item -ItemType Directory -Force -Path $Destination).FullName
    # NSIS requires /D= last, without additional quotation marks around the path.
    $process = Start-Process -FilePath $Installer -ArgumentList '/S',"/D=$installed" -PassThru -Wait
    if ($process.ExitCode -ne 0) { throw "Installer exited $($process.ExitCode)" }
    if (!(Test-Path -LiteralPath "$installed/bin/GCompris.exe" -PathType Leaf)) {
        throw "Installer reported success but GCompris.exe is missing from $installed"
    }
    return $installed
}
