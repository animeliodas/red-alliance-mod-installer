# Red Alliance Mod Installer
# Installs BepInEx + the chosen plugin set into the Red Alliance game folder.
#
# Options:
#   1. Red Alliance v1.4    -> Speedrun Tools v2 plugin
#   2. Red Alliance v1.3    -> Speedrun Tools v1 plugin (+ optional Optimization Fix, recommended)
#   3. Fix only (v1.3)      -> Optimization Fix plugin only
#   4. Crosshair editor     -> in-game crosshair editor (works with both game versions)
#
# Offline mode: if a 'payload' folder sits next to this script and contains the needed
# files (plugin DLLs / BepInEx zip), they are used instead of downloading from GitHub.

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ============================ CONFIG ============================
# One repo hosts both speedrun mod versions as separate releases:
#   v2.0.0 = game v1.4 plugin, v1.0.0 = game v1.3 plugin.
# Pinned tags, NOT releases/latest — latest would always resolve to v2.x.
$RepoSpeedrunMod     = 'animeliodas/red-alliance-speedrun-mod'
$TagSpeedrunV14      = 'v2.0.0'
$TagSpeedrunV13      = 'v1.0.0'
$RepoOptimizationFix = 'animeliodas/red-alliance-v1.3-optimization-fix'
$TagOptimizationFix  = 'v1.0.0'
$RepoCrosshairEditor = 'animeliodas/red-alliance-crosshair-editor'
$TagCrosshairEditor  = 'v1.0.0'

# Release asset file names (raw DLLs attached to the releases).
$AssetSpeedrun        = 'RedAllianceSpeedrun.dll'
$AssetOptimizationFix = 'RedAllianceOptimizationFix.dll'
$AssetCrosshairEditor = 'RedAllianceCrosshairEditor.dll'

# BepInEx 5 (stable). x86/x64 chosen automatically from the game exe.
$BepInExVersion = '5.4.23.5'
# ================================================================

$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$PayloadDir = Join-Path $ScriptDir 'payload'

function Write-Title($text) {
    Write-Host ''
    Write-Host "=== $text ===" -ForegroundColor Cyan
}

function Find-GameDir {
    $candidates = @(
        'C:\Program Files (x86)\Steam\steamapps\common\Red Alliance',
        'C:\Program Files\Steam\steamapps\common\Red Alliance',
        'D:\Steam\steamapps\common\Red Alliance',
        'D:\SteamLibrary\steamapps\common\Red Alliance'
    )
    foreach ($c in $candidates) {
        if (Test-Path (Join-Path $c 'Red Alliance.exe')) { return $c }
    }
    return $null
}

function Get-ExeArch($exePath) {
    # Reads the PE header machine field: 0x14C = x86, 0x8664 = x64.
    $fs = [IO.File]::OpenRead($exePath)
    try {
        $br = New-Object IO.BinaryReader($fs)
        $fs.Position = 0x3C
        $peOffset = $br.ReadInt32()
        $fs.Position = $peOffset + 4
        $machine = $br.ReadUInt16()
        if ($machine -eq 0x8664) { return 'x64' }
        return 'x86'
    } finally {
        $fs.Close()
    }
}

function Get-File($url, $destPath, $payloadName) {
    # Offline payload wins over download.
    if ($payloadName) {
        $local = Join-Path $PayloadDir $payloadName
        if (Test-Path $local) {
            Copy-Item $local $destPath -Force
            Write-Host "  [payload] $payloadName" -ForegroundColor DarkGray
            return
        }
    }
    Write-Host "  downloading: $url" -ForegroundColor DarkGray
    Invoke-WebRequest -Uri $url -OutFile $destPath -UseBasicParsing
}

function Install-BepInEx($gameDir) {
    $coreDll = Join-Path $gameDir 'BepInEx\core\BepInEx.dll'
    if (Test-Path $coreDll) {
        Write-Host 'BepInEx is already installed - skipping.' -ForegroundColor Green
        return
    }
    $arch = Get-ExeArch (Join-Path $gameDir 'Red Alliance.exe')
    $zipName = "BepInEx_win_${arch}_$BepInExVersion.zip"
    $url = "https://github.com/BepInEx/BepInEx/releases/download/v$BepInExVersion/$zipName"
    $tmp = Join-Path $env:TEMP $zipName

    Write-Title "Installing BepInEx $BepInExVersion ($arch)"
    Get-File $url $tmp $zipName
    Expand-Archive -Path $tmp -DestinationPath $gameDir -Force
    Remove-Item $tmp -Force
    Write-Host 'BepInEx installed.' -ForegroundColor Green
}

function Install-Plugin($gameDir, $repo, $tag, $asset, $displayName) {
    $pluginsDir = Join-Path $gameDir 'BepInEx\plugins'
    if (-not (Test-Path $pluginsDir)) {
        New-Item -ItemType Directory -Force $pluginsDir | Out-Null
    }
    Write-Title "Installing $displayName"
    $url = "https://github.com/$repo/releases/download/$tag/$asset"
    Get-File $url (Join-Path $pluginsDir $asset) $asset
    Write-Host "$displayName installed." -ForegroundColor Green
}

# ----------------------------------------------------------------

Write-Host ''
Write-Host '  Red Alliance Mod Installer' -ForegroundColor Yellow
Write-Host '  --------------------------'

$gameDir = Find-GameDir
if ($gameDir) {
    Write-Host "Game found: $gameDir"
    $answer = Read-Host 'Use this folder? [Y/n]'
    if ($answer -match '^[nN]') { $gameDir = $null }
}
while (-not $gameDir) {
    $entered = Read-Host 'Enter the Red Alliance game folder path'
    if (Test-Path (Join-Path $entered 'Red Alliance.exe')) {
        $gameDir = $entered
    } else {
        Write-Host 'Red Alliance.exe not found there. Try again.' -ForegroundColor Red
    }
}

Write-Host ''
Write-Host 'What do you want to install?'
Write-Host '  1. Red Alliance v1.4  - Speedrun Mod (new game version)'
Write-Host '  2. Red Alliance v1.3  - Speedrun Mod (old game version)'
Write-Host '  3. Fix only           - Optimization Fix for v1.3 (no speedrun tools)'
Write-Host '  4. Crosshair editor   - in-game crosshair editor (any game version)'
$choice = Read-Host 'Choice [1/2/3/4]'

switch ($choice) {
    '1' {
        Install-BepInEx $gameDir
        Install-Plugin $gameDir $RepoSpeedrunMod $TagSpeedrunV14 $AssetSpeedrun 'Speedrun Mod (game v1.4)'
    }
    '2' {
        Install-BepInEx $gameDir
        Install-Plugin $gameDir $RepoSpeedrunMod $TagSpeedrunV13 $AssetSpeedrun 'Speedrun Mod (game v1.3)'
        Write-Host ''
        Write-Host 'The Optimization Fix removes the progressive freezes of v1.3' -ForegroundColor Yellow
        Write-Host '(the game stutters after 20-30 level loads without it).' -ForegroundColor Yellow
        $fix = Read-Host 'Install Optimization Fix too? (recommended) [Y/n]'
        if ($fix -notmatch '^[nN]') {
            Install-Plugin $gameDir $RepoOptimizationFix $TagOptimizationFix $AssetOptimizationFix 'Optimization Fix (v1.3)'
        }
    }
    '3' {
        Install-BepInEx $gameDir
        Install-Plugin $gameDir $RepoOptimizationFix $TagOptimizationFix $AssetOptimizationFix 'Optimization Fix (v1.3)'
    }
    '4' {
        Install-BepInEx $gameDir
        Install-Plugin $gameDir $RepoCrosshairEditor $TagCrosshairEditor $AssetCrosshairEditor 'Crosshair Editor'
    }
    default {
        Write-Host 'Unknown choice, nothing installed.' -ForegroundColor Red
        exit 1
    }
}

Write-Title 'Done'
Write-Host 'Launch the game through Steam as usual. Config files appear in BepInEx\config after the first run.'
Write-Host ''
Read-Host 'Press Enter to exit'
