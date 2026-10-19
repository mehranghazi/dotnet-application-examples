@echo off
title Build App1.ServerInfo (.NET Core 3.1)
cd /d "%~dp0src"

echo Installed SDKs:
dotnet --list-sdks
echo.
echo Building with SDK:
dotnet --version
if errorlevel 1 (
  echo.
  echo ERROR: .NET Core SDK 3.1 not found. Install "SDK 3.1.426" ^(or any 3.1.x SDK^) from
  echo        https://dotnet.microsoft.com/download/dotnet/3.1
  goto end
)

echo.
dotnet publish App1.ServerInfo.csproj -c Release -o "%~dp0publish\App1.ServerInfo.NetCore31"
if errorlevel 1 (
  echo.
  echo BUILD FAILED - send the messages above.
  goto end
)

rem The 3.1 SDK creates the official App1.ServerInfo.exe. Fallback only if it is missing:
if not exist "%~dp0publish\App1.ServerInfo.NetCore31\App1.ServerInfo.exe" copy /y "%~dp0launcher\App1.ServerInfo.exe" "%~dp0publish\App1.ServerInfo.NetCore31\" >nul

echo.
echo OK. Files are in:
echo   %~dp0publish\App1.ServerInfo.NetCore31
echo   - IIS        : use the folder (web.config is included)
echo   - Standalone : App1.ServerInfo.exe  -^> http://localhost:5031

:end
echo.
pause
