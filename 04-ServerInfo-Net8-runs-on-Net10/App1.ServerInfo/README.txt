App1.ServerInfo - standalone .exe (Kestrel, no IIS)
===================================================

Requirement: ASP.NET Core Runtime 8.0 (or newer) on Windows x64.
The Hosting Bundle you installed for IIS already includes it.

Run:
  Double-click App1.ServerInfo.exe
  Then open http://localhost:5000

Change the port:
  - edit "Urls" in appsettings.json, e.g. "http://*:8090"   (* = reachable from other machines)
  - or start it with:  App1.ServerInfo.exe --urls http://*:8090

Stop: press Ctrl+C in the console window (or close it).

Keep all files in this folder together - the .exe runs App1.ServerInfo.dll.
The process name is App1.ServerInfo.exe (the app's own page shows processName).
