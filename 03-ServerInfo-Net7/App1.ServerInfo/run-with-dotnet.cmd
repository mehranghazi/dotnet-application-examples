@echo off
title App1.ServerInfo (.NET 7) - dotnet App1.ServerInfo.dll
cd /d "%~dp0"
echo Starting with "dotnet App1.ServerInfo.dll" on http://localhost:5007  (Ctrl+C to stop)
start "" http://localhost:5007
dotnet App1.ServerInfo.dll
pause