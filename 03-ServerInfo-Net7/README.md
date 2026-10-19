# 03 - ServerInfo on .NET 7

| | |
|---|---|
| **What it is** | ServerInfo page + `/api/info`, `/api/health` (Minimal API) |
| **Framework** | ASP.NET Core **7.0** (`net7.0`), `RollForward=LatestPatch` -> runs **only on 7.0.x** |
| **Hosting** | `.exe` (Kestrel) / `dotnet` / IIS in-process |
| **Contents** | **Prebuilt** in `App1.ServerInfo\` (with `web.config`) + `source\` |
| **Support** | .NET 7 ended May 2024 - testing only. Installs side by side with 8/10 |

## Install
`dotnet-hosting-7.0.20-win.exe` (IIS + runtime). Without IIS the ASP.NET Core Runtime 7.0.x is enough.

## Run
- **Standalone `.exe`**: `App1.ServerInfo\App1.ServerInfo.exe` -> http://localhost:5007
- **`dotnet`**: `App1.ServerInfo\run-with-dotnet.cmd` (or `dotnet App1.ServerInfo.dll`)
- **Windows Service**: not prepared (this build has no `UseWindowsService`; see `docs/INSTALL-MODES.md`)
- **IIS** (admin): `..\tools\install-iis-site.ps1 -Name App1Net7 -SourcePath .\03-ServerInfo-Net7\App1.ServerInfo -Port 8084`

Check: page / `/api/info` shows `framework: .NET 7.0.x`. On a PC without .NET 7 you get
*"You must install or update .NET…version '7.0.0'"* - that is the lock working.

Original author notes: [App1.ServerInfo/README.txt](App1.ServerInfo/README.txt)