@echo off
title App1.ServerInfo (.NET Core 2.2) - dotnet
cd /d "%~dp0"
if not exist "publish\App1.ServerInfo.NetCore22\App1.ServerInfo.dll" (
  echo Not built yet - run build.cmd first ^(needs .NET Core SDK 2.2^).
  pause & exit /b 1
)
cd publish\App1.ServerInfo.NetCore22
echo http://localhost:5000   (Ctrl+C to stop)
start "" http://localhost:5000
dotnet App1.ServerInfo.dll
pause