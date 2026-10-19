# Installs WinKestrelApp as a Windows Service (auto-start at boot) and opens the firewall port.
# Run in an ELEVATED PowerShell (Run as Administrator):  .\scripts\install-service.ps1
param(
    [string]$ServiceName = "WinKestrelApp",
    [string]$ExePath     = (Resolve-Path (Join-Path $PSScriptRoot "..\publish\WinKestrelApp.exe")).Path,
    [int]$Port           = 5000
)
$ErrorActionPreference = "Stop"

if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) {
    Write-Host "Service '$ServiceName' already exists. Run uninstall-service.ps1 first." -ForegroundColor Yellow
    exit 1
}

New-Service -Name $ServiceName `
    -BinaryPathName "`"$ExePath`"" `
    -DisplayName "WinKestrelApp (ASP.NET Core / Kestrel)" `
    -Description "Self-hosted ASP.NET Core web app on Kestrel, no IIS." `
    -StartupType Automatic | Out-Null

# Restart automatically if it crashes (after 5s, 3 times; counter resets daily)
sc.exe failure $ServiceName reset= 86400 actions= restart/5000/restart/5000/restart/5000 | Out-Null

# Allow inbound traffic so other machines on the network can reach it
New-NetFirewallRule -DisplayName "$ServiceName (TCP $Port)" -Direction Inbound `
    -Protocol TCP -LocalPort $Port -Action Allow -ErrorAction SilentlyContinue | Out-Null

Start-Service $ServiceName
Get-Service $ServiceName
Write-Host "`nInstalled and started. Browse to http://localhost:$Port" -ForegroundColor Green
