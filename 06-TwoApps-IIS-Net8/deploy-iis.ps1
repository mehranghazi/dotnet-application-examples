# deploy-iis.ps1  -  Creates two IIS sites for App1 (port 8082) and App2 (port 8083)
# Run in PowerShell **as Administrator** from the folder that contains the "publish" folder.
#   powershell -ExecutionPolicy Bypass -File .\deploy-iis.ps1

param(
    [string]$Root  = "C:\inetpub\dotnetapps",
    [int]$Port1    = 8082,
    [int]$Port2    = 8083
)

$ErrorActionPreference = "Stop"

# 1) IIS must be installed
if (-not (Get-Service W3SVC -ErrorAction SilentlyContinue)) {
    Write-Host "IIS is not installed. Installing..." -ForegroundColor Yellow
    if (Get-Command Install-WindowsFeature -ErrorAction SilentlyContinue) {
        Install-WindowsFeature Web-Server -IncludeManagementTools | Out-Null          # Windows Server
    } else {
        Enable-WindowsOptionalFeature -Online -All -NoRestart -FeatureName IIS-WebServerRole,IIS-WebServer,IIS-ManagementConsole | Out-Null  # Windows 10/11
    }
}
Import-Module WebAdministration

# Make sure the IIS services are running (Start-Website fails with "RPC server is unavailable" if W3SVC is stopped)
foreach ($svc in "WAS","W3SVC") {
    Set-Service $svc -StartupType Automatic
    if ((Get-Service $svc).Status -ne "Running") {
        Write-Host "Starting service $svc..." -ForegroundColor Yellow
        Start-Service $svc
    }
}

# 2) ASP.NET Core Module (from the Hosting Bundle) must be registered in IIS
$ancm = Get-WebGlobalModule -Name AspNetCoreModuleV2 -ErrorAction SilentlyContinue
if (-not $ancm) {
    Write-Host "ERROR: AspNetCoreModuleV2 is not registered in IIS." -ForegroundColor Red
    Write-Host "Install (or Repair) the ASP.NET Core Hosting Bundle from https://dotnet.microsoft.com/download , then run 'iisreset'."
    exit 1
}
Write-Host "ASP.NET Core Module found: $($ancm.Image)" -ForegroundColor Green

# 3) An ASP.NET Core runtime 8.0 or newer must be installed (apps roll forward to 9/10 if 8 is missing)
$rtDir = Join-Path $env:ProgramFiles "dotnet\shared\Microsoft.AspNetCore.App"
$runtimes = @()
if (Test-Path $rtDir) { $runtimes = Get-ChildItem $rtDir -Directory | ForEach-Object { $_.Name } }
$ok = $runtimes | Where-Object { [int]($_.Split('.')[0]) -ge 8 }
if (-not $ok) {
    Write-Host "ERROR: No ASP.NET Core runtime 8.0+ found in $rtDir (found: $($runtimes -join ', '))." -ForegroundColor Red
    Write-Host "Install the Hosting Bundle for .NET 8 or newer, then run 'iisreset'."
    exit 1
}
Write-Host "ASP.NET Core runtimes: $($runtimes -join ', ')" -ForegroundColor Green

$apps = @(
    @{ Name = "App1.ServerInfo"; Port = $Port1 },
    @{ Name = "App2.Notes";      Port = $Port2 }
)

foreach ($a in $apps) {
    $name = $a.Name
    $src  = Join-Path $PSScriptRoot "publish\$name"
    $dst  = Join-Path $Root $name
    $pool = "$name-Pool"

    Write-Host "`n=== $name -> http://localhost:$($a.Port) ===" -ForegroundColor Cyan

    # Stop existing site/pool so files are not locked
    if (Test-Path "IIS:\Sites\$name")    { Stop-Website $name -ErrorAction SilentlyContinue }
    if (Test-Path "IIS:\AppPools\$pool") { Stop-WebAppPool $pool -ErrorAction SilentlyContinue; Start-Sleep 2 }

    # Copy files
    New-Item -ItemType Directory -Force -Path $dst | Out-Null
    Copy-Item "$src\*" $dst -Recurse -Force
    New-Item -ItemType Directory -Force -Path (Join-Path $dst "logs") | Out-Null

    # App pool: "No Managed Code" (ASP.NET Core does not use the CLR of IIS)
    if (-not (Test-Path "IIS:\AppPools\$pool")) { New-WebAppPool $pool | Out-Null }
    Set-ItemProperty "IIS:\AppPools\$pool" managedRuntimeVersion ""
    Set-ItemProperty "IIS:\AppPools\$pool" startMode "AlwaysRunning"

    # Permissions for the app pool identity
    icacls $dst /grant "IIS AppPool\$($pool):(OI)(CI)RX" /T /Q | Out-Null
    icacls (Join-Path $dst "logs") /grant "IIS AppPool\$($pool):(OI)(CI)M" /T /Q | Out-Null

    # Site
    if (-not (Test-Path "IIS:\Sites\$name")) {
        New-Website -Name $name -Port $a.Port -PhysicalPath $dst -ApplicationPool $pool | Out-Null
    } else {
        Set-ItemProperty "IIS:\Sites\$name" physicalPath $dst
        Set-ItemProperty "IIS:\Sites\$name" applicationPool $pool
    }

    # Firewall (so other machines can reach it)
    if (-not (Get-NetFirewallRule -DisplayName "IIS $name" -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule -DisplayName "IIS $name" -Direction Inbound -Protocol TCP -LocalPort $a.Port -Action Allow | Out-Null
    }

    Start-WebAppPool $pool
    Start-Website $name
}

Write-Host "`nTesting..." -ForegroundColor Cyan
foreach ($a in $apps) {
    try {
        $r = Invoke-WebRequest "http://localhost:$($a.Port)/" -UseBasicParsing -TimeoutSec 30
        Write-Host ("  {0,-16} http://localhost:{1}  -> HTTP {2}" -f $a.Name, $a.Port, $r.StatusCode) -ForegroundColor Green
    } catch {
        Write-Host ("  {0,-16} http://localhost:{1}  -> FAILED: {2}" -f $a.Name, $a.Port, $_.Exception.Message) -ForegroundColor Red
    }
}
