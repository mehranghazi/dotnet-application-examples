# Builds a self-contained Windows x64 build: the target machine does NOT need .NET installed.
# Run from the project folder:  .\scripts\publish.ps1
param(
    [string]$Runtime = "win-x64",
    [string]$Output  = ".\publish"
)
$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

dotnet publish -c Release -r $Runtime --self-contained true `
    -p:PublishSingleFile=true `
    -p:IncludeNativeLibrariesForSelfExtract=true `
    -o $Output

Write-Host "`nDone. Run it with:  $Output\WinKestrelApp.exe" -ForegroundColor Green
Write-Host "Then open:          http://localhost:5000"
