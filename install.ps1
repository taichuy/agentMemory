param(
    [string]$Repo = "taichuy/agentMemory",
    [string]$Ref = "main",
    [string]$Destination = ".",
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$destinationPath = (Resolve-Path -LiteralPath $Destination).Path
$targetMemoryPath = Join-Path $destinationPath ".memory"

if ((Test-Path -LiteralPath $targetMemoryPath) -and -not $Force) {
    throw ".memory already exists in '$destinationPath'. Re-run with -Force to replace it."
}

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("agentMemory-" + [System.Guid]::NewGuid().ToString("N"))
$archivePath = Join-Path $tempRoot "agentMemory.zip"
$extractPath = Join-Path $tempRoot "extract"

try {
    New-Item -ItemType Directory -Path $tempRoot | Out-Null

    $downloadUrl = "https://codeload.github.com/$Repo/zip/refs/heads/$Ref"
    Invoke-WebRequest -Uri $downloadUrl -OutFile $archivePath

    Expand-Archive -LiteralPath $archivePath -DestinationPath $extractPath

    $repoRoot = Get-ChildItem -LiteralPath $extractPath -Directory | Select-Object -First 1
    if ($null -eq $repoRoot) {
        throw "Unable to locate the extracted repository root."
    }

    $sourceMemoryPath = Join-Path $repoRoot.FullName ".memory"
    if (-not (Test-Path -LiteralPath $sourceMemoryPath)) {
        throw "The repository archive does not contain a .memory directory."
    }

    if (Test-Path -LiteralPath $targetMemoryPath) {
        Remove-Item -LiteralPath $targetMemoryPath -Recurse -Force
    }

    Copy-Item -LiteralPath $sourceMemoryPath -Destination $destinationPath -Recurse -Force
    Write-Host "Installed .memory into $destinationPath"
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}
