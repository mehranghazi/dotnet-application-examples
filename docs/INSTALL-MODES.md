# Install and run modes

Four ways to run the apps. Pick per example from the table in the [main README](../README.md).

1. [Standalone `.exe`](#1-standalone-exe-double-click)
2. [`dotnet App.dll` from cmd](#2-dotnet-appdll-from-cmd)
3. [Windows Service](#3-windows-service)
4. [IIS](#4-iis)
5. [Troubleshooting](#troubleshooting)

Install the required runtime first - see [WHICH-INSTALLER.md](WHICH-INSTALLER.md).

---

## 1. Standalone `.exe` (double-click)

Applies to **03, 04, 05** (prebuilt `.exe`), **02** (after `build.cmd`) and **07** (after `publish.ps1`).

| Example | File to double-click | URL |
|---|---|---|
| 02 | `publish\App1.ServerInfo.NetCore31\App1.ServerInfo.exe` | http://localhost:5031 |
| 03 | `App1.ServerInfo\App1.ServerInfo.exe` | http://localhost:5007 |
| 04 | `App1.ServerInfo\App1.ServerInfo.exe` | http://localhost:5000 |
| 05 | `App2.Notes\App2.Notes.exe` | http://localhost:5008 |
| 07 | `publish\WinKestrelApp.exe` | http://localhost:5000 |

- A console window opens and **is** the server: closing it (or Ctrl+C) stops the app.
- **03, 04, 05, 02** are *framework-dependent*: the PC needs the matching runtime. Keep all files of the folder
  together - the `.exe` is only a launcher for the `.dll` next to it.
- **07** is *self-contained*: copy `publish\` to any Windows x64 PC and double-click, no .NET needed.
- Another port / reachable from other PCs: `App.exe --urls http://*:8090`, or edit `"Urls"` in `appsettings.json`
  (`*` or `0.0.0.0` = all network cards; you may need a firewall rule:
  `New-NetFirewallRule -DisplayName "MyApp 8090" -Direction Inbound -Protocol TCP -LocalPort 8090 -Action Allow`).

## 2. `dotnet App.dll` from cmd

Same app, started by the `dotnet` host (process name is `dotnet.exe`). Every example has a `.cmd` for it, or run by hand:

```bat
cd 05-Notes-Net8\App2.Notes
dotnet App2.Notes.dll
dotnet App2.Notes.dll --urls http://localhost:9000
```

| Example | Launcher |
|---|---|
| 01, 02 | `run-with-dotnet.cmd` (after `build.cmd`) |
| 03, 04, 05 | `run-with-dotnet.cmd` |
| 06 | `run-app1-with-dotnet.cmd`, `run-app2-with-dotnet.cmd` |
| 08 | `run.cmd` (checks that a runtime exists, opens the browser) |
| 07 | `cd 07-…\WinKestrelApp` then `dotnet run` (SDK 8+ **and** ASP.NET Core Runtime 8.0 needed) |

Useful: `dotnet --list-runtimes` shows what the app can use. A `…runtimeconfig.json` next to the dll says which
version it asks for (`tfm`, `rollForward`).

## 3. Windows Service

Only **07** is written for this (`UseWindowsService()` in `Program.cs`, plus install scripts). In an **elevated**
PowerShell (Run as Administrator):

```powershell
cd 07-WinKestrelApp-Service-Source\WinKestrelApp
Set-ExecutionPolicy -Scope Process Bypass       # only if scripts are blocked

.\scripts\publish.ps1            # builds publish\WinKestrelApp.exe (self-contained, single file; needs SDK 8+ and internet for NuGet)
.\scripts\install-service.ps1    # creates service "WinKestrelApp", Automatic start, restart-on-failure, firewall port 5000, starts it
Get-Service WinKestrelApp        # Running
Start-Process http://localhost:5000

.\scripts\uninstall-service.ps1  # stop + delete service + firewall rule
```

Manage it: `Stop-Service WinKestrelApp`, `Start-Service WinKestrelApp`, or `services.msc`.
Logs: Event Viewer -> Windows Logs -> Application, source `WinKestrelApp`.
Change the port: edit `appsettings.json` **next to the installed exe**, then `Restart-Service WinKestrelApp`
(and the firewall rule). The service runs as `LocalSystem` by default; use `sc.exe config WinKestrelApp obj= "NT AUTHORITY\LocalService"`
for fewer rights.

The service path is the exe's current location, so publish to the final folder (e.g. `C:\Services\WinKestrelApp`)
*before* running `install-service.ps1`, or pass `-ExePath`.

### Making another app a Windows Service

An app only works as a service if it talks to the Service Control Manager. Without it, `sc start` fails with
**error 1053** ("did not respond in a timely fashion"). To convert 03/04/05/06/02 (needs a rebuild from source):

```xml
<!-- .csproj : pick the version matching the target framework -->
<PackageReference Include="Microsoft.Extensions.Hosting.WindowsServices" Version="8.0.1" />   <!-- net8.0 -->
<!-- net7.0 -> 7.0.1      netcoreapp3.1 -> 3.1.32 -->
```

```csharp
builder.Host.UseWindowsService();                  // .NET 6+ minimal hosting
// 3.1 generic host:  Host.CreateDefaultBuilder(args).UseWindowsService()...
// also set ContentRootPath = AppContext.BaseDirectory so appsettings.json is found (cwd of a service is System32)
```

Then `sc.exe create MyApp binPath= "\"C:\path\MyApp.exe\"" start= auto` (for a framework-dependent app the runtime
must be installed). .NET Core **2.2 has no `UseWindowsService`** - use IIS or a wrapper such as NSSM for that one.
.NET Framework apps (09, 10) are not services; they live in IIS.

## 4. IIS

Applies to everything except 04, 07 and 08. IIS = Windows feature *Internet Information Services*.

### ASP.NET Core apps (01-06) - needs a Hosting Bundle

1. Enable IIS (Control Panel -> Turn Windows features on or off -> *Internet Information Services*).
2. Install the matching **Hosting Bundle** ([WHICH-INSTALLER.md](WHICH-INSTALLER.md)), then `iisreset`.
3. One command (elevated PowerShell, from the repo root):

```powershell
.\tools\install-iis-site.ps1 -Name App1Net7 -SourcePath .\03-ServerInfo-Net7\App1.ServerInfo -Port 8084
```

It copies the files to `C:\inetpub\dotnetapps\App1Net7`, creates the app pool **`App1Net7-Pool` with .NET CLR = No Managed Code**,
creates the site, sets permissions, opens the firewall port and tests the URL. Remove with
`.\tools\remove-iis-site.ps1 -Name App1Net7 -DeleteFiles`.

For **06** use its own `deploy-iis.ps1` (creates both sites on 8082/8083).

Manual (IIS Manager): copy the folder -> *Application Pools -> Add* (name, **No Managed Code**) -> *Sites -> Add Website*
(path, that pool, port) -> browse. **Each ASP.NET Core in-process app needs its own app pool.**

Suggested names/ports: 01 `App1NetCore22` 8085 · 02 `App1NetCore31` 8086 (use the `publish\…` folder after `build.cmd`) ·
03 `App1Net7` 8084 · 04 has no `web.config` (exe/dotnet only; copy the one from 05 and change the dll name to use it in IIS) · 05 `App2Notes` 8083.

> All apps use `hostingModel="InProcess"`: the page shows `processName = w3wp`. Via `.exe`/`dotnet` it shows the
> exe name / `dotnet`. That is an easy way to see which mode you are in.

### .NET Framework apps (09, 10)

No download: needs Windows feature *IIS -> World Wide Web Services -> Application Development -> ASP.NET 4.8*.

```powershell
.\tools\install-iis-site.ps1 -Name MyApp -SourcePath .\09-MyApp-WebForms-Framework48\MyApp -Port 8090 -Framework
.\tools\install-iis-site.ps1 -Name Blog  -SourcePath .\10-BlogEngine-NET-Framework45\BlogEngine -Port 8091 -Framework
```

The script uses an app pool with **.NET CLR v4.0, Integrated** and gives the pool write access (BlogEngine writes
to `App_Data`). Quick test without full IIS: `run-iisexpress.cmd` (needs the free IIS Express).

---

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| *You must install or update .NET to run this application … version 'x'* | The exact runtime is missing (03 needs 7.0.x, 05 needs 8.0.x). Install it; check `dotnet --list-runtimes`. |
| `'dotnet' is not recognized` | No runtime/SDK installed, or open a **new** cmd window after installing. |
| IIS **HTTP 500.19** (0x8007000d) | Hosting Bundle missing. Install it, `iisreset`. |
| IIS **500.30 / 500.31** | Runtime for this app not installed (or wrong major). Event Viewer -> Application shows which. |
| IIS **500.35** | Two in-process ASP.NET Core apps in one app pool. Give each its own pool. |
| IIS **502.5 / 503** | Pool stopped/crashed. In `web.config` set `stdoutLogEnabled="true"`, recycle, read `logs\stdout_*.log`. |
| Hosting Bundle installed before IIS | Run the Hosting Bundle again -> **Repair**. |
| *Address already in use* | Another app has the port (several defaults are 5000). Use `--urls http://localhost:PORT`. |
| Site works on localhost but not from another PC | Bind to `*`/`0.0.0.0` (not `localhost`) and open the firewall port. |
| Service error **1053** | App has no `UseWindowsService()` - see [above](#making-another-app-a-windows-service). |
| Script blocked ("running scripts is disabled") | `Set-ExecutionPolicy -Scope Process Bypass` in that window. |
| BlogEngine error saving / logging in | The app pool identity needs Modify rights on `App_Data` (the install script grants it). Default login is **admin** - change the password immediately. |
| `build.cmd` can't restore packages (2.2 / 3.1) | Needs internet to nuget.org; the SDK must be installed (`dotnet --list-sdks`). |

