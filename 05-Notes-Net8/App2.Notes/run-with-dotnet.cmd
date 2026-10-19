@echo off
title App2.Notes (.NET 8) - dotnet App2.Notes.dll
cd /d "%~dp0"
echo Starting with "dotnet App2.Notes.dll" on http://localhost:5008  (Ctrl+C to stop)
start "" http://localhost:5008
dotnet App2.Notes.dll
pause