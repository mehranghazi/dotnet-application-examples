@echo off
title App1.ServerInfo (dotnet, no IIS)
cd /d "%~dp0publish\App1.ServerInfo"
echo http://localhost:5082   (Ctrl+C to stop)
start "" http://localhost:5082
dotnet App1.ServerInfo.dll --urls http://localhost:5082
pause