# 04 - ServerInfo, built for .NET 8, runs on .NET 10

| | |
|---|---|
| **What it is** | ServerInfo page + `/api/info`, `/api/health` |
| **Framework** | `net8.0` with `rollForward=LatestMajor` -> uses .NET 8 if installed, otherwise 9 or **10** |
| **Hosting** | Standalone `.exe` (Kestrel, **no IIS** - no web.config in this package) or `dotnet` |
| **Contents** | **Prebuilt** `App1.ServerInfo\` + `launcher-source\` (C source of the small native `.exe` launcher) |

The `.exe` is a native launcher (like the official apphost): it finds the installed runtime and runs
`App1.ServerInfo.dll` inside its own process, so the process name is `App1.ServerInfo.exe`, not `dotnet.exe`.

## Install
`aspnetcore-runtime-8.0.31-win-x64.exe` - or any newer ASP.NET Core Runtime / SDK 10 (`dotnet-sdk-10.0.401`).

## Run
- **Standalone `.exe`**: `App1.ServerInfo\App1.ServerInfo.exe` -> http://localhost:5000
- **`dotnet`**: `App1.ServerInfo\run-with-dotnet.cmd`
- **Windows Service**: not prepared (see `docs/INSTALL-MODES.md`)
- **IIS**: not packaged. The sibling example `06-TwoApps-IIS-Net8` contains the same app with a `web.config`.

Port: edit `"Urls"` in `appsettings.json` or `App1.ServerInfo.exe --urls http://*:8090`.
The folder name says "Net10": the app *runs on* .NET 10 when that is the newest runtime installed (the page shows the framework in use).

Original notes: [App1.ServerInfo/README.txt](App1.ServerInfo/README.txt)