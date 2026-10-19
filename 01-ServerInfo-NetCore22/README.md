# 01 - ServerInfo on ASP.NET Core 2.2

| | |
|---|---|
| **What it is** | Tiny web app: HTML page + JSON (`/api/info`, `/api/health`) showing machine, OS, .NET version, process name, uptime, request counter |
| **Framework** | ASP.NET Core **2.2** (`netcoreapp2.2`), C# 7.3, `WebHost` + `Startup` style |
| **Hosting** | IIS in-process (`w3wp`) or Kestrel |
| **Contents** | **Source only** - build once with `build.cmd` |
| **Runtime rule** | 2.2.x only - never rolls forward to 3.x or later. Out of support since Dec 2019: testing only |

## Install
| Purpose | Installer |
|---|---|
| Build | `dotnet-sdk-2.2.207-win-x64.exe` (`global.json` accepts any 2.2.x SDK) |
| Run / IIS | `dotnet-hosting-2.2.8-win.exe`, then `iisreset` |

Needs internet (nuget.org) for the first build.

## Build
Double-click `App1.ServerInfo.NetCore22\build.cmd` -> `publish\App1.ServerInfo.NetCore22\` (dll + web.config).

## Run
- **`dotnet`**: `App1.ServerInfo.NetCore22\run-with-dotnet.cmd` -> http://localhost:5000 (2.x creates no `.exe`)
- **Standalone `.exe`**: not available for 2.2
- **Windows Service**: not supported by 2.2 (no `UseWindowsService`)
- **IIS**: `..\tools\install-iis-site.ps1 -Name App1NetCore22 -SourcePath .\01-ServerInfo-NetCore22\App1.ServerInfo.NetCore22\publish\App1.ServerInfo.NetCore22 -Port 8085` (from repo root, admin) - or follow the manual steps in `App1.ServerInfo.NetCore22\README.txt`

Check on the page: `framework = .NET Core 2.2.x`, `processName = w3wp` under IIS.

Original author notes: [App1.ServerInfo.NetCore22/README.txt](App1.ServerInfo.NetCore22/README.txt)