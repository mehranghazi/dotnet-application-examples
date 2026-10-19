@echo off
title BlogEngine.NET - IIS Express
set IISX="%ProgramFiles%\IIS Express\iisexpress.exe"
if not exist %IISX% set IISX="%ProgramFiles(x86)%\IIS Express\iisexpress.exe"
if not exist %IISX% (
  echo IIS Express is not installed. Install it ^(free^) from Microsoft, or use tools\install-iis-site.ps1 -Framework for full IIS.
  pause & exit /b 1
)
echo http://localhost:8091   (Ctrl+C to stop)
start "" http://localhost:8091
%IISX% /path:"%~dp0BlogEngine" /port:8091
