# Stops and removes the Windows Service and its firewall rule. Run as Administrator.
param(
    [string]$ServiceName = "WinKestrelApp",
    [int]$Port           = 5000
)
if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) {
    Stop-Service $ServiceName -Force -ErrorAction SilentlyContinue
    sc.exe delete $ServiceName | Out-Null
    Write-Host "Service '$ServiceName' removed."
}
Remove-NetFirewallRule -DisplayName "$ServiceName (TCP $Port)" -ErrorAction SilentlyContinue
