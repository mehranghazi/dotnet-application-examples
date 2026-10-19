@echo off
title App1.ServerInfo (.NET Core 3.1) - dotnet
cd /d "%~dp0"
if not exist "publish\App1.ServerInfo.NetCore31\App1.ServerInfo.dll" (
  echo Not built yet - run build.cmd first ^(needs .NET Core SDK 3.1^).
  pause & exit /b 1
)
cd publish\App1.ServerInfo.NetCore31
echo http://localhost:5031   (Ctrl+C to stop)
start "" http://localhost:5031
dotnet App1.ServerInfo.dll
pause