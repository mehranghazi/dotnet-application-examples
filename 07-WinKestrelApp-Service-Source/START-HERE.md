# 07 - WinKestrelApp: standalone `.exe` + Windows Service (no IIS)

The project's own [README.md](WinKestrelApp/README.md) is unchanged. Summary:

| | |
|---|---|
| **What it is** | Minimal API + static page (`wwwroot/index.html`) on Kestrel. Endpoints `/`, `/api/info`, `/api/hello/{name}`, `/health` |
| **Framework** | ASP.NET Core **8.0** (`net8.0`) + `Microsoft.Extensions.Hosting.WindowsServices` 8.0.1 |
| **Contents** | **Source** + 3 PowerShell scripts. You build the exe once |
| **Modes** | console `.exe`, **Windows Service** (`UseWindowsService()`), `dotnet run` |
| **Default URL** | http://localhost:5000 (`Kestrel:Endpoints` in `appsettings.json`) |

## Install
| Purpose | Installer |
|---|---|
| Build the exe | `dotnet-sdk-10.0.401-win-x64.exe` (any SDK 8 or newer; needs internet for NuGet runtime packs) |
| Run the published exe | **nothing** - `publish.ps1` makes it self-contained (includes .NET) |
| `dotnet run` | SDK **and** `aspnetcore-runtime-8.0.31` (an SDK 10-only PC lacks runtime 8) |

## Standalone exe
```powershell
cd WinKestrelApp
.\scripts\publish.ps1                       # -> publish\WinKestrelApp.exe (single file, tens of MB because it includes .NET)
.\publish\WinKestrelApp.exe                 # double-click works too -> http://localhost:5000
.\publish\WinKestrelApp.exe --urls "http://0.0.0.0:8080"
```
Copy the whole `publish` folder to any Windows x64 PC; no .NET required there.

## Windows Service (admin PowerShell)
```powershell
.\scripts\install-service.ps1      # service "WinKestrelApp", auto-start, restart on crash, firewall 5000, starts it
Get-Service WinKestrelApp
.\scripts\uninstall-service.ps1    # remove service + firewall rule
```
Publish to the folder you want to keep first (the service points at that exe). Logs: Event Viewer -> Application.
More detail: [docs/INSTALL-MODES.md](../docs/INSTALL-MODES.md#3-windows-service).

## dotnet
`cd WinKestrelApp` -> `dotnet run`. A prebuilt framework-dependent copy is example 08.
