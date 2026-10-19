@echo off
title WinKestrelApp - close this window to stop the server
cd /d "%~dp0"

dotnet --list-runtimes | findstr /C:"Microsoft.AspNetCore.App" >nul
if errorlevel 1 (
  echo.
  echo  ASP.NET Core Runtime is not installed on this PC.
  echo  Install "ASP.NET Core Runtime 8" (or newer) - Windows x64 - from:
  echo  https://dotnet.microsoft.com/download/dotnet/8.0
  echo.
  pause
  exit /b 1
)

echo Starting server on http://localhost:5000  (close this window or press Ctrl+C to stop)
start "" http://localhost:5000
dotnet WinKestrelApp.dll
pause
