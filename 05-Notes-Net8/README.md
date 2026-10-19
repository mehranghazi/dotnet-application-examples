# 05 - Notes (Razor Pages) on .NET 8

| | |
|---|---|
| **What it is** | Bootstrap Razor Pages app: add / delete notes (kept in memory - reset on restart/recycle). JSON at `/api/notes` |
| **Framework** | ASP.NET Core **8.0**, `RollForward=LatestPatch` -> **only 8.0.x** (will not use 9 or 10) |
| **Hosting** | `.exe` / `dotnet` / IIS in-process |
| **Contents** | **Prebuilt** `App2.Notes\` (with `web.config`, `wwwroot`). Source: `06-TwoApps-IIS-Net8\source\App2.Notes` |

## Install
`dotnet-hosting-8.0.31-win.exe` (IIS + runtime), or `aspnetcore-runtime-8.0.31-win-x64.exe` for exe/dotnet only.

## Run
- **Standalone `.exe`**: `App2.Notes\App2.Notes.exe` -> http://localhost:5008
- **`dotnet`**: `App2.Notes\run-with-dotnet.cmd`
- **Windows Service**: not prepared (see `docs/INSTALL-MODES.md`)
- **IIS** (admin): `..\tools\install-iis-site.ps1 -Name App2Notes -SourcePath .\05-Notes-Net8\App2.Notes -Port 8083`
  (if you also installed example 06, use another port - 06 takes 8083)

Original notes: [App2.Notes/README.txt](App2.Notes/README.txt)