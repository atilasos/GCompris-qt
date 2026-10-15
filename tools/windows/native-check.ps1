# SPDX-License-Identifier: GPL-3.0-or-later
function Invoke-GComprisNativeCheck {
    param(
        [Parameter(Mandatory)][string]$InstallRoot,
        [Parameter(Mandatory)][string]$Output,
        [Parameter(Mandatory)][string]$Python,
        [string]$ActivitiesFile,
        [switch]$RequireFreshProfile
    )
    if ($RequireFreshProfile) {
        # Qt queries Known Folders, not APPDATA/LOCALAPPDATA environment overrides.
        # Refuse an existing profile; never delete the user's application data.
        $local = [Environment]::GetFolderPath('LocalApplicationData')
        $roaming = [Environment]::GetFolderPath('ApplicationData')
        $common = [Environment]::GetFolderPath('CommonApplicationData')
        $paths = @("$local/GCompris", "$local/KDE/GCompris", "$roaming/KDE/GCompris", "$common/KDE/GCompris")
        foreach ($path in $paths) {
            if (Test-Path -LiteralPath $path) { throw "Native check requires a fresh dedicated Windows account; existing data: $path" }
        }
    }
    $previousPath = $env:PATH
    $previousQt = @{}
    foreach ($entry in Get-ChildItem Env: | Where-Object Name -Match '^(QT|QML|QSG_)') {
        $previousQt[$entry.Name] = $entry.Value
        [Environment]::SetEnvironmentVariable($entry.Name, $null, 'Process')
    }
    $rule = 'GCompris-Candidate-' + [guid]::NewGuid().ToString('N')
    $firewallAdded = $false
    try {
        $binary = (Get-Item -LiteralPath "$InstallRoot/bin/GCompris.exe" -ErrorAction Stop).FullName
        $env:PATH = "$(Split-Path -Parent $binary);$env:SystemRoot/System32;$env:SystemRoot"
        $env:QT_QPA_PLATFORM = 'offscreen'
        $env:QT_MEDIA_BACKEND = 'ffmpeg'
        # GUI Qt on Windows otherwise routes debug/ QML diagnostics to the debugger.
        $env:QT_FORCE_STDERR_LOGGING = '1'
        New-NetFirewallRule -Name $rule -DisplayName 'GCompris candidate offline test' -Direction Outbound -Program $binary -Action Block | Out-Null
        $firewallAdded = $true
        $probeArguments = @("$PSScriptRoot/native-probe.py", '--binary', $binary, '--output', $Output)
        if ($ActivitiesFile) { $probeArguments += @('--activities-file', $ActivitiesFile) }
        & $Python @probeArguments
        if ($LASTEXITCODE -ne 0) { throw "Native startup checks failed with code $LASTEXITCODE" }
    } finally {
        try {
            if ($firewallAdded) { Remove-NetFirewallRule -Name $rule -ErrorAction Stop }
        } finally {
            foreach ($entry in Get-ChildItem Env: | Where-Object Name -Match '^(QT|QML|QSG_)') {
                [Environment]::SetEnvironmentVariable($entry.Name, $null, 'Process')
            }
            foreach ($name in $previousQt.Keys) { [Environment]::SetEnvironmentVariable($name, $previousQt[$name], 'Process') }
            $env:PATH = $previousPath
        }
    }
}
