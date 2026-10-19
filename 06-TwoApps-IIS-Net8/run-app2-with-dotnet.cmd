@echo off
title App2.Notes (dotnet, no IIS)
cd /d "%~dp0publish\App2.Notes"
echo http://localhost:5083   (Ctrl+C to stop)
start "" http://localhost:5083
dotnet App2.Notes.dll --urls http://localhost:5083
pause