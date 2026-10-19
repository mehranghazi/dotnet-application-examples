# remove-iis-site.ps1 - removes the site, app pool and firewall rule made by install-iis-site.ps1.
# Run as Administrator.   .\tools\remove-iis-site.ps1 -Name App1Net7 [-DeleteFiles]
param(
    [Parameter(Mandatory)] [string]$Name,
    [string]$Root = "C:\inetpub\dotnetapps",
    [switch]$DeleteFiles
)
Import-Module WebAdministration
$pool = "$Name-Pool"
if (Test-Path "IIS:\Sites\$Name")    { Stop-Website $Name -ErrorAction SilentlyContinue; Remove-Website $Name }
if (Test-Path "IIS:\AppPools\$pool") { Stop-WebAppPool $pool -ErrorAction SilentlyContinue; Remove-WebAppPool $pool }
Remove-NetFirewallRule -DisplayName "IIS $Name" -ErrorAction SilentlyContinue
if ($DeleteFiles) { Remove-Item (Join-Path $Root $Name) -Recurse -Force -ErrorAction SilentlyContinue }
Write-Host "Removed site/pool '$Name'." -ForegroundColor Green
