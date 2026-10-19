App2.Notes - .NET 8 build
=========================

Target framework: net8.0   rollForward: LatestPatch
=> runs ONLY on .NET 8.0.x. It will NOT roll forward to .NET 9 or 10,
   even when they are installed (the previous build used LatestMajor and
   therefore ran on .NET 10.0.12 on your server).

Requirement: .NET 8 Hosting Bundle (already installed: 8.0.31).

Check: the page header shows ".NET 8.0.x"

A) Standalone .exe
   Double-click App2.Notes.exe  ->  http://localhost:5008
   Other port: edit "Urls" in appsettings.json, or  App2.Notes.exe --urls http://*:8090

B) IIS (manual, IIS Manager) - replace the existing App2 site files
   1. Sites -> App2.Notes -> Stop.  Application Pools -> App2.Notes-Pool -> Stop.
   2. Copy all files of this folder into C:\inetpub\dotnetapps\App2.Notes (overwrite).
      If you added AppDynamics settings to web.config there, keep YOUR web.config (do not overwrite it).
   3. Start the app pool, then the site.  Browse http://localhost:8083
