# 08 - WinKestrelApp, prebuilt (run with `dotnet`)

| | |
|---|---|
| **What it is** | Compiled build of the WinKestrelApp web page/API (see example 07 for the source) |
| **Framework** | `net8.0`, `rollForward=LatestMajor`, framework-dependent (8, 9 or 10) |
| **Contents** | `WinKestrelApp.dll`, `run.cmd`, `appsettings.json`, `wwwroot\index.html` - **no `.exe`** |
| **Hosting** | Kestrel on http://localhost:5000, started with `dotnet WinKestrelApp.dll` |

## Install
`aspnetcore-runtime-8.0.31-win-x64.exe` (or any newer ASP.NET Core Runtime / SDK). `run.cmd` checks for it and tells you if it is missing.

## Run
- Double-click `WinKestrelApp\run.cmd` (opens the browser, runs `dotnet WinKestrelApp.dll`). Close the window to stop.
- By hand: `cd WinKestrelApp` then `dotnet WinKestrelApp.dll --urls http://localhost:8080`.
- **Windows Service**: this prebuilt build does not reference the WindowsServices package. Use example 07 for the service.
- **IIS**: not packaged.