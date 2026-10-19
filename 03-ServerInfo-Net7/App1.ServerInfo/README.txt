App1.ServerInfo - .NET 7 build
==============================

Target framework: net7.0   rollForward: LatestPatch
=> runs ONLY on .NET 7.0.x. It will NOT start on .NET 8, 9 or 10
   (you get "You must install or update .NET to run this application ... version '7.0.0'").

Requirement on Windows x64:
  .NET 7 "Hosting Bundle" (for IIS, includes the ASP.NET Core 7 runtime)
  or "ASP.NET Core Runtime 7.0.x" (enough for the .exe).
  Download: https://dotnet.microsoft.com/download/dotnet/7.0  (last release: 7.0.20)
  Note: .NET 7 is out of support since May 2024 - use it only for testing.
  Installing it side by side does not affect your .NET 8 apps.

Check: the page / http://.../api/info shows  "framework": ".NET 7.0.x"

A) Standalone .exe
   Double-click App1.ServerInfo.exe  ->  http://localhost:5007
   Other port: edit "Urls" in appsettings.json, or  App1.ServerInfo.exe --urls http://*:8090

B) IIS (manual, IIS Manager)
   1. Copy this folder to e.g. C:\inetpub\dotnetapps\App1.ServerInfo.Net7
   2. Application Pools -> Add: name App1Net7-Pool, .NET CLR version = No Managed Code
   3. Sites -> Add Website: name App1.ServerInfo.Net7, that folder, pool App1Net7-Pool, port 8084
   4. Browse http://localhost:8084
   (web.config is included. Use its own app pool - do not share a pool with the .NET 8 sites.)
