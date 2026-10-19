# Two ASP.NET Core 8 apps for IIS

| App | Type | What it does | Default URL (script) |
|---|---|---|---|
| **App1.ServerInfo** | Minimal API | Page showing machine name, OS, .NET version, process (`w3wp` = in-process), uptime, request counter. JSON at `/api/info`, `/api/health` | http://localhost:8082 |
| **App2.Notes** | Razor Pages (Bootstrap) | Add / delete notes (in-memory, resets on app-pool recycle). JSON at `/api/notes` | http://localhost:8083 |

Both are **framework-dependent, .NET 8 (LTS)**, already published (`publish/` folder, `web.config` included, in-process hosting). Source code is in `source/`.

## Prerequisites on the Windows server
1. **IIS** (the script installs it if missing).
2. **ASP.NET Core 8 Hosting Bundle** — https://dotnet.microsoft.com/download/dotnet/8.0 → "ASP.NET Core Runtime 8.0.x" → **Windows: Hosting Bundle**. Install it **after** IIS, then run `iisreset`.

## Option A – automatic (PowerShell as Administrator)
```powershell
cd C:\path\to\extracted\folder
powershell -ExecutionPolicy Bypass -File .\deploy-iis.ps1
# custom ports / folder:
# .\deploy-iis.ps1 -Port1 80 -Port2 8080 -Root D:\sites
```
It copies the apps to `C:\inetpub\dotnetapps\`, creates one app pool per app (**No Managed Code**), creates two sites, opens the firewall ports, and tests both URLs.

## Option B – manual in IIS Manager
For each app:
1. Copy `publish\App1.ServerInfo` to e.g. `C:\inetpub\App1`.
2. **Application Pools → Add**: name `App1Pool`, .NET CLR version = **No Managed Code**.
3. **Sites → Add Website**: name `App1`, physical path `C:\inetpub\App1`, pool `App1Pool`, port `8082` (or a host name on port 80).
4. Browse.

Repeat for App2 with another port (8083) or another host name.

**Same port 80, different host names:** set Host name = `app1.local` / `app2.local` in the bindings and add them to `C:\Windows\System32\drivers\etc\hosts` (`127.0.0.1 app1.local`).

**As sub-applications of Default Web Site** (`http://server/app1`, `http://server/app2`): Default Web Site → Add Application → alias `app1`, pick the folder and pool. Each app **must** have its own app pool (in-process hosting allows only one app per pool).

## Troubleshooting
| Error | Fix |
|---|---|
| **HTTP 500.19** (config error 0x8007000d) | Hosting Bundle not installed → install, `iisreset`. |
| **HTTP 500.30 / 500.31** | Wrong runtime: install the **.NET 8** Hosting Bundle. Check Event Viewer → Windows Logs → Application. |
| **HTTP 500.35** | Two in-process apps in one app pool → give each its own pool. |
| **HTTP 502.5 / 503** | App pool stopped/crashed → in `web.config` set `stdoutLogEnabled="true"`, recycle, read `logs\stdout_*.log`. |
| Hosting Bundle installed before IIS | Run the Hosting Bundle installer again → **Repair**. |

## Rebuild from source (optional)
```bash
dotnet publish source/App1.ServerInfo -c Release -o publish/App1.ServerInfo
dotnet publish source/App2.Notes      -c Release -o publish/App2.Notes
```
