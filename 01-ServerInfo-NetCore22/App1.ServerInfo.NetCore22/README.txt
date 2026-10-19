App1.ServerInfo - ASP.NET Core 2.2 (for IIS, in-process)
========================================================

This is SOURCE CODE. It must be built once on a Windows PC that can reach nuget.org
(.NET Core 2.x is built from NuGet packages).

1) INSTALL (from https://dotnet.microsoft.com/download/dotnet/2.2 )
   - For building : .NET Core SDK 2.2  (last one: 2.2.402, Windows x64 installer)
   - For IIS      : ASP.NET Core Runtime 2.2.8 -> "Hosting Bundle"
     Then run:  iisreset
   Both install side by side with .NET 7 / 8 / 10 and do not change your other apps.
   If the Hosting Bundle says a newer ASP.NET Core Module is already installed - that's fine, continue.
   Note: .NET Core 2.2 is out of support since 23 Dec 2019 - use for testing only.

2) BUILD
   Double-click build.cmd
   -> output: publish\App1.ServerInfo.NetCore22\   (contains App1.ServerInfo.dll + web.config)
   (global.json makes it use the 2.2 SDK even if newer SDKs are installed)
   If the build PC is not the IIS server, just copy that publish folder to the server.

3) IIS (IIS Manager)
   a. Copy publish\App1.ServerInfo.NetCore22 to  C:\inetpub\dotnetapps\App1.ServerInfo.NetCore22
   b. Application Pools -> Add Application Pool:
        Name: App1NetCore22-Pool    .NET CLR version: No Managed Code
   c. Sites -> Add Website:
        Site name: App1.ServerInfo.NetCore22
        Physical path: C:\inetpub\dotnetapps\App1.ServerInfo.NetCore22
        Application pool: App1NetCore22-Pool      Port: 8085
   d. Browse http://localhost:8085

   Check on the page:  framework = .NET Core 2.2.x   processName = w3wp  (in-process)
   JSON: /api/info   /api/health

Runtime rule: a 2.2 app only rolls forward within 2.x (2.2.x patches), never to 3.x or later.
