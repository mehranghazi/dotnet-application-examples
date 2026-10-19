# WinKestrelApp

ASP.NET Core (.NET 8) web app that runs on Windows **without IIS**, using Kestrel,
the web server built into ASP.NET Core. The same `.exe` runs either as a console
app or as a Windows Service.

## What's inside

| File | Purpose |
|---|---|
| `Program.cs` | Minimal API + static files; `UseWindowsService()` for service mode |
| `appsettings.json` | Kestrel listens on `http://0.0.0.0:5000` (change the port here) |
| `wwwroot/index.html` | Small dashboard page that calls the API |
| `scripts/publish.ps1` | Builds a self-contained single `.exe` (no .NET needed on the server) |
| `scripts/install-service.ps1` | Registers it as an auto-start Windows Service + firewall rule |
| `scripts/uninstall-service.ps1` | Removes the service and firewall rule |

Endpoints: `/` (page), `/api/info`, `/api/hello/{name}`, `/health`.

## 1. Run it for development

Requires the [.NET 8 SDK](https://dotnet.microsoft.com/download).

```powershell
cd WinKestrelApp
dotnet run
```

Open http://localhost:5000.

## 2. Publish a standalone .exe

```powershell
.\scripts\publish.ps1
.\publish\WinKestrelApp.exe
```

Copy the `publish` folder to any Windows x64 machine and run the `.exe`; .NET does
not need to be installed there. Override the port without editing config:

```powershell
.\publish\WinKestrelApp.exe --urls "http://0.0.0.0:8080"
```

## 3. Run as a Windows Service (starts at boot)

In PowerShell **as Administrator**:

```powershell
.\scripts\install-service.ps1      # create, start, open firewall port
Get-Service WinKestrelApp           # check status
.\scripts\uninstall-service.ps1    # remove
```

The service restarts automatically if it crashes, and logs go to the Windows
Event Viewer (Windows Logs → Application, source `WinKestrelApp`).

## HTTPS

Add an HTTPS endpoint with a certificate in `appsettings.json`:

```json
"Kestrel": {
  "Endpoints": {
    "Http":  { "Url": "http://0.0.0.0:5000" },
    "Https": {
      "Url": "https://0.0.0.0:5001",
      "Certificate": { "Path": "cert.pfx", "Password": "your-password" }
    }
  }
}
```

If the script execution policy blocks the `.ps1` files, run
`Set-ExecutionPolicy -Scope Process Bypass` in that window first.
