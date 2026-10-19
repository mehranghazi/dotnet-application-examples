# 06 - Two ASP.NET Core 8 apps for IIS (App1.ServerInfo + App2.Notes)

The package's own [README.md](README.md) is unchanged (IIS details + troubleshooting). Summary:

| | App1.ServerInfo | App2.Notes |
|---|---|---|
| Type | Minimal API + info page | Razor Pages notes app |
| Framework | `net8.0`, `rollForward=LatestMajor` (8, 9 or 10) | same |
| IIS port (script) | 8082 | 8083 |
| `dotnet` port | 5082 | 5083 |
| Prebuilt | `publish\App1.ServerInfo` | `publish\App2.Notes` |
| Source | `source\App1.ServerInfo` | `source\App2.Notes` |

No `.exe` (framework-dependent dlls, `UseAppHost=false`) - run with `dotnet` or IIS.

## Install
- IIS: `dotnet-hosting-8.0.31-win.exe` (install after IIS; `deploy-iis.ps1` installs IIS itself if missing, but then repair the bundle)
- No IIS: `aspnetcore-runtime-8.0.31-win-x64.exe` (any newer ASP.NET Core Runtime also works)
- Rebuild: `dotnet-sdk-10.0.401` (or SDK 8)

## Run
- **IIS, one command** (admin PowerShell in this folder):
  `powershell -ExecutionPolicy Bypass -File .\deploy-iis.ps1` (custom ports: `-Port1 80 -Port2 8080 -Root D:\sites`).
  It checks IIS, the ASP.NET Core Module and the runtime, copies to `C:\inetpub\dotnetapps\`, creates one pool per app
  (No Managed Code), opens the firewall, tests both URLs.
- **`dotnet`**: `run-app1-with-dotnet.cmd`, `run-app2-with-dotnet.cmd`
- **Standalone `.exe`**: no. Example 04/05 are prebuilt `.exe` builds of the same apps.
- **Windows Service**: not prepared.

Older revisions of this package (`DotNetCore-IIS-TwoApps.zip`, `…2.zip`) are in `../originals` (ports 8081/8082).