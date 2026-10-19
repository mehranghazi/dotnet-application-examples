# install-iis-site.ps1 - creates an IIS app pool + website for ANY example in this repo.
# Run in PowerShell AS ADMINISTRATOR.
#
# ASP.NET Core app (needs the matching Hosting Bundle installed first):
#   .\tools\install-iis-site.ps1 -Name App1Net7 -SourcePath .\03-ServerInfo-Net7\App1.ServerInfo -Port 8084
#
# .NET Framework app (WebForms / BlogEngine) - uses classic .NET 4 app pool, no Hosting Bundle:
#   .\tools\install-iis-site.ps1 -Name MyApp -SourcePath .\09-MyApp-WebForms-Framework48\MyApp -Port 8090 -Framework
#
# Files are copied to C:\inetpub\dotnetapps\<Name> (change with -Root). Re-running updates the files.

param(
    [Parameter(Mandatory)] [string]$Name,
    [Parameter(Mandatory)] [string]$SourcePath,
    [Parameter(Mandatory)] [int]$Port,
    [string]$Root = "C:\inetpub\dotnetapps",
    [switch]$Framework          # classic .NET Framework app instead of ASP.NET Core
)
$ErrorActionPreference = "Stop"

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Run this script in an ELEVATED PowerShell (Run as Administrator)." -ForegroundColor Red; exit 1
}
if (-not (Test-Path $SourcePath)) { Write-Host "SourcePath not found: $SourcePath" -ForegroundColor Red; exit 1 }
$SourcePath = (Resolve-Path $SourcePath).Path

# --- IIS present? ---
if (-not (Get-Service W3SVC -ErrorAction SilentlyContinue)) {
    Write-Host "IIS is not installed. Installing..." -ForegroundColor Yellow
    if (Get-Command Install-WindowsFeature -ErrorAction SilentlyContinue) {
        Install-WindowsFeature Web-Server, Web-Asp-Net45, Web-Mgmt-Console | Out-Null              # Windows Server
    } else {
        Enable-WindowsOptionalFeature -Online -All -NoRestart -FeatureName IIS-WebServerRole, IIS-WebServer, IIS-ManagementConsole,
            IIS-ASPNET45, IIS-NetFxExtensibility45 | Out-Null                                       # Windows 10/11
    }
}
Import-Module WebAdministration
foreach ($svc in "WAS", "W3SVC") {
    Set-Service $svc -StartupType Automatic
    if ((Get-Service $svc).Status -ne "Running") { Start-Service $svc }
}

if (-not $Framework) {
    if (-not (Get-WebGlobalModule -Name AspNetCoreModuleV2 -ErrorAction SilentlyContinue)) {
        Write-Host "AspNetCoreModuleV2 is not registered in IIS. Install the matching Hosting Bundle, then 'iisreset'." -ForegroundColor Red
        exit 1
    }
}

$dst  = Join-Path $Root $Name
$pool = "$Name-Pool"

if (Test-Path "IIS:\Sites\$Name")    { Stop-Website $Name -ErrorAction SilentlyContinue }
if (Test-Path "IIS:\AppPools\$pool") { Stop-WebAppPool $pool -ErrorAction SilentlyContinue; Start-Sleep 2 }

New-Item -ItemType Directory -Force -Path $dst | Out-Null
Copy-Item "$SourcePath\*" $dst -Recurse -Force
New-Item -ItemType Directory -Force -Path (Join-Path $dst "logs") | Out-Null

if (-not (Test-Path "IIS:\AppPools\$pool")) { New-WebAppPool $pool | Out-Null }
if ($Framework) {
    Set-ItemProperty "IIS:\AppPools\$pool" managedRuntimeVersion "v4.0"       # .NET Framework 4.x (covers 4.5 - 4.8)
    Set-ItemProperty "IIS:\AppPools\$pool" managedPipelineMode "Integrated"
} else {
    Set-ItemProperty "IIS:\AppPools\$pool" managedRuntimeVersion ""           # "No Managed Code" for ASP.NET Core
    Set-ItemProperty "IIS:\AppPools\$pool" startMode "AlwaysRunning"
}

# Permissions for the pool identity (modify on the whole folder: BlogEngine writes to App_Data, ASP.NET Core to logs)
icacls $dst /grant "IIS AppPool\$($pool):(OI)(CI)M" /T /Q | Out-Null

if (-not (Test-Path "IIS:\Sites\$Name")) {
    New-Website -Name $Name -Port $Port -PhysicalPath $dst -ApplicationPool $pool | Out-Null
} else {
    Set-ItemProperty "IIS:\Sites\$Name" physicalPath $dst
    Set-ItemProperty "IIS:\Sites\$Name" applicationPool $pool
}

if (-not (Get-NetFirewallRule -DisplayName "IIS $Name" -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -DisplayName "IIS $Name" -Direction Inbound -Protocol TCP -LocalPort $Port -Action Allow | Out-Null
}

Start-WebAppPool $pool
Start-Website $Name

try {
    $r = Invoke-WebRequest "http://localhost:$Port/" -UseBasicParsing -TimeoutSec 60
    Write-Host "`n$Name -> http://localhost:$Port  HTTP $($r.StatusCode)  (files in $dst)" -ForegroundColor Green
} catch {
    Write-Host "`n$Name created on port $Port but the test request failed: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "See the Troubleshooting table in docs\INSTALL-MODES.md"
}
