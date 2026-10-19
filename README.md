# .NET Application Examples (Windows)

Ready-to-test ASP.NET Core and ASP.NET (.NET Framework) sample apps, each in its own folder with a README that
says **exactly which .NET version it needs, which installer to download, and how to run it** as

- a **standalone `.exe`** (double-click),
- **`dotnet App.dll`** from cmd,
- a **Windows Service**, or
- a site in **IIS**.

> Platform: Windows x64 (tested layout on Windows 10 Pro). All apps listen on plain HTTP, no database needed
> (the BlogEngine example stores its data in XML files).

## The examples

| # | Folder | Technology / target framework | Prebuilt? | Standalone `.exe` | `dotnet` cmd | Windows Service | IIS | Needs (runtime installer) |
|---|---|---|---|---|---|---|---|---|
| 01 | [01-ServerInfo-NetCore22](01-ServerInfo-NetCore22) | ASP.NET Core **2.2** (`netcoreapp2.2`) | source - build with `build.cmd` | no (2.x has no apphost) | yes, :5000 | no | yes, :8085 | SDK 2.2 to build, Hosting Bundle **2.2.8** |
| 02 | [02-ServerInfo-NetCore31](02-ServerInfo-NetCore31) | ASP.NET Core **3.1** (`netcoreapp3.1`) | source - build with `build.cmd` | yes, :5031 | yes | no | yes, :8086 | SDK 3.1 to build, Hosting Bundle **3.1.32** |
| 03 | [03-ServerInfo-Net7](03-ServerInfo-Net7) | ASP.NET Core **7.0** (`net7.0`, locked to 7.0.x) | **yes** | yes, :5007 | yes | no | yes, :8084 | Hosting Bundle **7.0.20** (or ASP.NET Core Runtime 7) |
| 04 | [04-ServerInfo-Net8-runs-on-Net10](04-ServerInfo-Net8-runs-on-Net10) | `net8.0`, `rollForward=LatestMajor` -> runs on 8, 9 or **10** | **yes** | yes, :5000 | yes | no | no (no `web.config` in this package) | ASP.NET Core Runtime **8 or newer** |
| 05 | [05-Notes-Net8](05-Notes-Net8) | ASP.NET Core **8.0** Razor Pages (locked to 8.0.x) | **yes** | yes, :5008 | yes | no | yes, :8083 | Hosting Bundle **8.0.31** (or ASP.NET Core Runtime 8) |
| 06 | [06-TwoApps-IIS-Net8](06-TwoApps-IIS-Net8) | Two `net8.0` apps (ServerInfo + Notes), `LatestMajor` | **yes** + source | no (dll only) | yes | no | **yes**, one-click script | Hosting Bundle **8.0.31** |
| 07 | [07-WinKestrelApp-Service-Source](07-WinKestrelApp-Service-Source) | ASP.NET Core **8.0** on Kestrel, `UseWindowsService()` | source - build with `scripts\publish.ps1` | **yes** (self-contained, no .NET needed) | yes (`dotnet run`) | **YES - install script** | not needed | SDK 8+ to build; nothing to run the published exe |
| 08 | [08-WinKestrelApp-Prebuilt-dotnet-run](08-WinKestrelApp-Prebuilt-dotnet-run) | `net8.0`, `LatestMajor`, framework-dependent | **yes** | no | **yes** (`run.cmd`) | no | no | ASP.NET Core Runtime **8 or newer** |
| 09 | [09-MyApp-WebForms-Framework48](09-MyApp-WebForms-Framework48) | **.NET Framework 4.8** ASP.NET WebForms | yes (it is source) | no | no | no | **yes** / IIS Express | Windows feature "ASP.NET 4.8" (no download) |
| 10 | [10-BlogEngine-NET-Framework45](10-BlogEngine-NET-Framework45) | **BlogEngine.NET 3.3.8**, .NET Framework 4.5+ WebForms | yes | no | no | no | **yes** / IIS Express | Windows feature "ASP.NET 4.x" (no download) |

> **Windows Service** = only example **07** is written for it (it calls `UseWindowsService()`).
> How to make the others services: see [docs/INSTALL-MODES.md](docs/INSTALL-MODES.md#making-another-app-a-windows-service).

## Start here

1. **[docs/WHICH-INSTALLER.md](docs/WHICH-INSTALLER.md)** - for each installer you downloaded (`dotnet-sdk-…`,
   `dotnet-hosting-…`, `aspnetcore-runtime-…`): is it needed, and for which example.
2. **[docs/INSTALL-MODES.md](docs/INSTALL-MODES.md)** - step by step: standalone `.exe`, `dotnet` cmd,
   Windows Service, IIS, plus troubleshooting.
3. Run the checker to see what your PC already has:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\check-prereqs.ps1
```

## Repo layout

```
01-… to 10-…          one folder per example, each with its own README.md
docs/                 which installer is needed + install modes (exe / dotnet / service / IIS)
tools/                check-prereqs.ps1, install-iis-site.ps1, remove-iis-site.ps1
originals/            the untouched zip files these examples came from
```

## Ports used (so they do not clash)

| Port | App |
|---|---|
| 5000 | 01 (dotnet), 04, 07, 08 - **run only one of these at a time** |
| 5007 / 5008 / 5031 | 03 / 05 / 02 standalone |
| 5082 / 5083 | 06 via `dotnet` |
| 8082 / 8083 | 06 in IIS (05 can also use 8083 - pick another port if both are installed) |
| 8084 / 8085 / 8086 | 03 / 01 / 02 in IIS |
| 8090 / 8091 | 09 / 10 via IIS Express |

Change any port: `App.exe --urls http://*:9000`, or edit `"Urls"` in `appsettings.json`.

## Notes

- .NET Core 2.2, 3.1 and 7 are **out of support** - they are here for testing different runtimes side by side.
  Installing several runtimes side by side is safe; they do not replace each other.
- The `originals/` zips are kept exactly as received. Folders `01`-`10` are extracted copies with READMEs and
  launcher scripts added; no existing source/binary was modified.
- `06` contains the third (latest) of three zips: `DotNetCore-IIS-TwoApps` and `…2` are older revisions with other
  ports (8081/8082) and a less strict script; they remain in `originals/`.

