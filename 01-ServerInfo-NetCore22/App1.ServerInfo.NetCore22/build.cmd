@echo off
title Build App1.ServerInfo (.NET Core 2.2)
cd /d "%~dp0src"

echo Installed SDKs:
dotnet --list-sdks
echo.
echo Building with SDK:
dotnet --version
if errorlevel 1 (
  echo.
  echo ERROR: .NET Core SDK 2.2 not found. Install "SDK 2.2.402" ^(or any 2.2.x SDK^) from
  echo        https://dotnet.microsoft.com/download/dotnet/2.2
  goto end
)

echo.
dotnet publish App1.ServerInfo.csproj -c Release -o "%~dp0publish\App1.ServerInfo.NetCore22"
if errorlevel 1 (
  echo.
  echo BUILD FAILED - send the messages above.
  goto end
)

echo.
echo OK. Files for IIS are in:
echo   %~dp0publish\App1.ServerInfo.NetCore22

:end
echo.
pause
