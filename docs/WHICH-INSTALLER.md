# Which installer do I need?

Terms:

| Package | What it contains | Use it for |
|---|---|---|
| **SDK** (`dotnet-sdk-…`) | compiler + `dotnet build/publish` **and** the .NET + ASP.NET Core runtime of the same version | **building** from source; also runs apps of that version |
| **ASP.NET Core Runtime** (`aspnetcore-runtime-…`) | .NET runtime + ASP.NET Core runtime | **running** apps (`.exe` / `dotnet App.dll` / Windows Service). **Not** IIS |
| **Hosting Bundle** (`dotnet-hosting-…`) | everything in the ASP.NET Core Runtime **+ the IIS module (ANCM)** | running apps **in IIS** (also works for `.exe` / `dotnet`) |

Rule of thumb: *only run, no IIS* -> Runtime. *IIS* -> Hosting Bundle. *Build from source* -> SDK.
Install **IIS first**, then the Hosting Bundle(s) (oldest -> newest), then `iisreset`. If you install IIS afterwards,
run the Hosting Bundle again -> **Repair**.

## Your downloaded files

| File | Needed? | For which example |
|---|---|---|
| `dotnet-sdk-2.2.207-win-x64.exe` | only to **build** 01 | 01 (`build.cmd`; `global.json` accepts any 2.2.x SDK) |
| `dotnet-hosting-2.2.8-win.exe` | to **run** 01 | 01 in IIS or with `dotnet` |
| `dotnet-sdk-3.1.426-win-x64.exe` | only to **build** 02 | 02 (`build.cmd`) |
| `dotnet-hosting-3.1.32-win.exe` | to **run** 02 | 02 as `.exe`, `dotnet`, or IIS |
| `dotnet-hosting-7.0.20-win.exe` | **yes** | 03 (exe + IIS). It is locked to 7.0.x |
| `dotnet-hosting-8.0.31-win.exe` | **yes** (best single choice for 04, 05, 06, 08) | 05 (needs exactly 8.0.x), 04/06/08 (8 or newer), IIS for all .NET 8 apps |
| `aspnetcore-runtime-8.0.31-win-x64.exe` | alternative to the Hosting Bundle when **no IIS** | 04, 05, 06 via `dotnet`, 08. Also needed to `dotnet run` example 07 |
| `dotnet-sdk-10.0.401-win-x64.exe` | optional | build anything incl. 07; also gives you runtime 10 so 04/06/08 run on .NET 10 |
| `dotnet-sdk-10.0.112-win-x64.exe` | **not needed** | older SDK 10 feature band; 10.0.401 covers it (they can coexist) |
| `Adobe…`, `Claude Setup`, `WinSCP`, `tabby`, `td-setup`, `v2ray…`, `wireguard…` | **not .NET** | unrelated to these examples |

## Per example (minimum)

| Example | Just run it (exe / dotnet) | Run in IIS | Build from source |
|---|---|---|---|
| 01 NetCore 2.2 | `dotnet-hosting-2.2.8` | `dotnet-hosting-2.2.8` | `dotnet-sdk-2.2.207` |
| 02 NetCore 3.1 | `dotnet-hosting-3.1.32` (or its SDK) | `dotnet-hosting-3.1.32` | `dotnet-sdk-3.1.426` |
| 03 .NET 7 | `dotnet-hosting-7.0.20` | `dotnet-hosting-7.0.20` | (source included) `dotnet-sdk-10.0.401` can build `net7.0` if NuGet is reachable |
| 04 net8 / runs on 10 | `aspnetcore-runtime-8.0.31` **or any newer** | not packaged for IIS (no web.config) | - |
| 05 Notes .NET 8 | `aspnetcore-runtime-8.0.31` (**8.0.x only**, 9/10 will not do) | `dotnet-hosting-8.0.31` | - |
| 06 TwoApps | `aspnetcore-runtime-8.0.31` (8 or newer) | `dotnet-hosting-8.0.31` (script installs IIS if missing) | `dotnet-sdk-10.0.401` |
| 07 WinKestrel (service) | published exe: **nothing** (self-contained) | not used | `dotnet-sdk-10.0.401` (+ internet for NuGet) |
| 08 WinKestrel prebuilt | `aspnetcore-runtime-8.0.31` or newer | not used | - |
| 09 / 10 .NET Framework | **no download**: Windows feature *ASP.NET 4.8* (Windows 10 1903+ already has .NET Framework 4.8) | enable IIS + ASP.NET 4.x (`tools\install-iis-site.ps1 -Framework` does it) | - |

## Recommended install set for testing everything

```
IIS (Windows features)          ->  then, oldest to newest:
dotnet-hosting-2.2.8-win.exe
dotnet-hosting-3.1.32-win.exe
dotnet-hosting-7.0.20-win.exe
dotnet-hosting-8.0.31-win.exe
dotnet-sdk-10.0.401-win-x64.exe        (adds runtime 10 + builds 07)
dotnet-sdk-2.2.207-win-x64.exe         (only if you want to build 01)
dotnet-sdk-3.1.426-win-x64.exe         (only if you want to build 02)
iisreset
```

Silent install (elevated cmd), for any of these installers:

```bat
dotnet-hosting-8.0.31-win.exe /install /quiet /norestart
```

## Check what is installed

```bat
dotnet --list-runtimes
dotnet --list-sdks
```

or run `tools\check-prereqs.ps1`, which also tells you which example is runnable.

## Version locks (why the right version matters)

| Example | `rollForward` | Behaviour |
|---|---|---|
| 01 (2.2) | default | 2.2.x only (2.x never rolls to 3.x) |
| 02 (3.1) | `LatestPatch` | 3.1.x only |
| 03 (7.0) | `LatestPatch` | 7.0.x only. On a PC with only .NET 8/10 it fails with *"You must install or update .NET…"* |
| 04, 06, 08 | `LatestMajor` | 8.0 or **any newer** (so it runs on 10 if 8 is absent) |
| 05 (8.0) | `LatestPatch` | 8.0.x only |

