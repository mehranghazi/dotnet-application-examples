# 09 - MyApp: classic ASP.NET WebForms on .NET Framework 4.8

| | |
|---|---|
| **What it is** | `Default.aspx` (session-based to-do list, shows server time/CLR/machine) + `api.ashx` JSON endpoint |
| **Framework** | **.NET Framework 4.8** (`targetFramework="4.8"`), inline-compiled WebForms, no build step |
| **Hosting** | IIS (or IIS Express) only - **not** `dotnet`, not a standalone exe, not a service |
| **Contents** | `MyApp\` = web root (`Default.aspx`, `api.ashx`, `web.config`, `App_Data`) |

## Install - no download
.NET Framework 4.8 is part of Windows 10 (1903+) / Windows 11 / Server 2022. You only need the Windows features:
*Internet Information Services -> World Wide Web Services -> Application Development Features -> ASP.NET 4.8*
(the install script enables them).
The .NET SDK / Hosting Bundle installers are **not** used for this app.

## Run
- **IIS** (admin PowerShell, from repo root):
  `.\tools\install-iis-site.ps1 -Name MyApp -SourcePath .\09-MyApp-WebForms-Framework48\MyApp -Port 8090 -Framework`
  -> http://localhost:8090 and http://localhost:8090/api.ashx
- **IIS Express** (free, if installed): double-click `run-iisexpress.cmd` -> http://localhost:8090
- Remove: `.\tools\remove-iis-site.ps1 -Name MyApp -DeleteFiles`

`customErrors` is Off and `debug="true"` for learning - change both before real use.