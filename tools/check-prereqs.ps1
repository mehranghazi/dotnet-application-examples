# check-prereqs.ps1 - shows which .NET runtimes/SDKs/IIS parts are installed and which
# example can run on THIS machine.   Usage:  powershell -ExecutionPolicy Bypass -File .\tools\check-prereqs.ps1
# (Read-only. Changes nothing.)

function Get-Majors($kind) {
    $dir = Join-Path $env:ProgramFiles "dotnet\shared\$kind"
    if (-not (Test-Path $dir)) { return @() }
    Get-ChildItem $dir -Directory | ForEach-Object { $_.Name }
}

$aspnet = Get-Majors "Microsoft.AspNetCore.App"
$sdkDir = Join-Path $env:ProgramFiles "dotnet\sdk"
$sdks   = if (Test-Path $sdkDir) { Get-ChildItem $sdkDir -Directory | Where-Object { $_.Name -match '^\d' } | ForEach-Object { $_.Name } } else { @() }

function Has-Aspnet([string]$prefix)  { [bool]($aspnet | Where-Object { $_ -like "$prefix.*" }) }
function Has-Sdk([string]$prefix)     { [bool]($sdks   | Where-Object { $_ -like "$prefix.*" }) }
function Has-AspnetAtLeast([int]$m)   { [bool]($aspnet | Where-Object { [int]($_.Split('.')[0]) -ge $m }) }

$iisInstalled = [bool](Get-Service W3SVC -ErrorAction SilentlyContinue)
$ancm = $false
if ($iisInstalled) {
    $ancm = Test-Path (Join-Path $env:ProgramFiles "IIS\Asp.Net Core Module\V2\aspnetcorev2.dll")
}
$iisExpress = (Test-Path "$env:ProgramFiles\IIS Express\iisexpress.exe") -or (Test-Path "${env:ProgramFiles(x86)}\IIS Express\iisexpress.exe")
$netfx = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" -ErrorAction SilentlyContinue).Release

Write-Host "`n=== Installed on this PC ===" -ForegroundColor Cyan
Write-Host "ASP.NET Core runtimes : $($aspnet -join ', ')"
Write-Host "SDKs                  : $($sdks -join ', ')"
Write-Host "IIS (W3SVC)           : $iisInstalled"
Write-Host "ASP.NET Core Module V2: $ancm   (comes from a Hosting Bundle)"
Write-Host "IIS Express           : $iisExpress"
Write-Host ".NET Framework 4.x    : release $netfx  (528040+ = 4.8)"

$rows = @(
  @{ N='01-ServerInfo-NetCore22 (build)';   Ok=(Has-Sdk '2.2'); Need='SDK 2.2' },
  @{ N='01-ServerInfo-NetCore22 (run)';     Ok=(Has-Aspnet '2.2'); Need='ASP.NET Core Runtime 2.2 (or Hosting 2.2.8)' },
  @{ N='02-ServerInfo-NetCore31 (build)';   Ok=(Has-Sdk '3.1'); Need='SDK 3.1' },
  @{ N='02-ServerInfo-NetCore31 (run)';     Ok=(Has-Aspnet '3.1'); Need='ASP.NET Core Runtime 3.1 (or Hosting 3.1.32)' },
  @{ N='03-ServerInfo-Net7 (run)';          Ok=(Has-Aspnet '7.0'); Need='ASP.NET Core Runtime 7.0 (or Hosting 7.0.20)' },
  @{ N='04-ServerInfo-Net8-runs-on-Net10';  Ok=(Has-AspnetAtLeast 8); Need='ASP.NET Core Runtime 8 or newer' },
  @{ N='05-Notes-Net8 (run)';               Ok=(Has-Aspnet '8.0'); Need='ASP.NET Core Runtime 8.0 (or Hosting 8.0.31)' },
  @{ N='06-TwoApps-IIS-Net8 (run)';         Ok=(Has-AspnetAtLeast 8); Need='ASP.NET Core Runtime 8 or newer' },
  @{ N='07-WinKestrelApp (dotnet run)';     Ok=((Has-Sdk '8.0') -or (Has-Sdk '9.0') -or (Has-Sdk '10.0')) -and (Has-Aspnet '8.0'); Need='SDK 8+ and ASP.NET Core Runtime 8.0' },
  @{ N='08-WinKestrelApp-Prebuilt';         Ok=(Has-AspnetAtLeast 8); Need='ASP.NET Core Runtime 8 or newer' },
  @{ N='09/10 .NET Framework apps (IIS)';   Ok=($iisInstalled -and $netfx -ge 378389); Need='IIS + ASP.NET 4.x feature + .NET Framework 4.5+' },
  @{ N='09/10 .NET Framework (IIS Express)';Ok=$iisExpress; Need='IIS Express (free, from Microsoft)' },
  @{ N='IIS hosting of any ASP.NET Core app'; Ok=($iisInstalled -and $ancm); Need='IIS + a Hosting Bundle' }
)

Write-Host "`n=== Can it run here? ===" -ForegroundColor Cyan
foreach ($r in $rows) {
    $tag = if ($r.Ok) { 'OK     ' } else { 'MISSING' }
    $col = if ($r.Ok) { 'Green' } else { 'Yellow' }
    Write-Host ("{0} {1,-40} {2}" -f $tag, $r.N, $(if ($r.Ok) { '' } else { 'needs: ' + $r.Need })) -ForegroundColor $col
}
Write-Host ""
