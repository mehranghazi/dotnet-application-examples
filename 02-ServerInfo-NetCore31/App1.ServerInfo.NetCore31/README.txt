App1.ServerInfo - ASP.NET Core 3.1 (for IIS in-process, and as .exe)
====================================================================

This is SOURCE CODE. Build it once on a Windows PC that can reach nuget.org.

1) INSTALL (from https://dotnet.microsoft.com/download/dotnet/3.1 )
   - For building : .NET Core SDK 3.1  (last one: 3.1.426, Windows x64 installer)
   - For IIS      : ASP.NET Core Runtime 3.1.32 -> "Hosting Bundle"
     Then run:  iisreset
   Both install side by side with your other .NET versions and do not change your other apps.
   If the Hosting Bundle says a newer ASP.NET Core Module is already installed - that's fine, continue.
   Note: .NET Core 3.1 is out of support since 13 Dec 2022 - use for testing only.

2) BUILD
   Double-click build.cmd
   -> output: publish\App1.ServerInfo.NetCore31\
      App1.ServerInfo.exe + App1.ServerInfo.dll + web.config + appsettings.json
   (global.json makes it use the 3.1 SDK even if newer SDKs are installed)
   If the build PC is not the IIS server, copy that publish folder to the server.

3) IIS (IIS Manager)
   a. Copy publish\App1.ServerInfo.NetCore31 to  C:\inetpub\dotnetapps\App1.ServerInfo.NetCore31
   b. Application Pools -> Add Application Pool:
        Name: App1NetCore31-Pool    .NET CLR version: No Managed Code
   c. Sites -> Add Website:
        Site name: App1.ServerInfo.NetCore31
        Physical path: C:\inetpub\dotnetapps\App1.ServerInfo.NetCore31
        Application pool: App1NetCore31-Pool      Port: 8086
   d. Browse http://localhost:8086
   Check on the page:  framework = .NET Core 3.1.x   processName = w3wp  (in-process)

4) STANDALONE .EXE (no IIS)
   Double-click App1.ServerInfo.exe  ->  http://localhost:5031
   Other port: edit "Urls" in appsettings.json, or  App1.ServerInfo.exe --urls http://*:8090

Runtime rule: RollForward = LatestPatch -> runs ONLY on 3.1.x, never on .NET 5/6/7/8/10.
