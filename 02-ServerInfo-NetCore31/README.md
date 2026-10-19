# 02 - ServerInfo on ASP.NET Core 3.1

| | |
|---|---|
| **What it is** | Same ServerInfo page + `/api/info`, `/api/health` |
| **Framework** | ASP.NET Core **3.1** (`netcoreapp3.1`), generic host + Startup |
| **Hosting** | `.exe` (Kestrel), `dotnet`, or IIS in-process |
| **Contents** | **Source only** (+ a fallback `launcher\App1.ServerInfo.exe`) - build with `build.cmd` |
| **Runtime rule** | `RollForward=LatestPatch` -> 3.1.x only. Out of support since Dec 2022: testing only |

## Install
| Purpose | Installer |
|---|---|
| Build | `dotnet-sdk-3.1.426-win-x64.exe` (`global.json` pins 3.1) |
| Run / IIS | `dotnet-hosting-3.1.32-win.exe`, then `iisreset` |

## Build
Double-click `App1.ServerInfo.NetCore31\build.cmd` -> `publish\App1.ServerInfo.NetCore31\` with `App1.ServerInfo.exe`,
`App1.ServerInfo.dll`, `web.config`, `appsettings.json`.

## Run
- **Standalone `.exe`**: `publish\App1.ServerInfo.NetCore31\App1.ServerInfo.exe` -> http://localhost:5031
- **`dotnet`**: `App1.ServerInfo.NetCore31\run-with-dotnet.cmd`
- **Windows Service**: not prepared (see `docs/INSTALL-MODES.md`, "Making another app a Windows Service"; package version 3.1.x)
- **IIS**: `..\tools\install-iis-site.ps1 -Name App1NetCore31 -SourcePath .\02-ServerInfo-NetCore31\App1.ServerInfo.NetCore31\publish\App1.ServerInfo.NetCore31 -Port 8086`

Check on the page: `framework = .NET Core 3.1.x`.

Original author notes: [App1.ServerInfo.NetCore31/README.txt](App1.ServerInfo.NetCore31/README.txt)