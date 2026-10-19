# 10 - BlogEngine.NET 3.3.8 (blog engine, .NET Framework)

| | |
|---|---|
| **What it is** | The open-source BlogEngine.NET blog (`BlogEngine.Core` **3.3.8**): posts, pages, comments, themes, widgets, admin UI (AngularJS) |
| **Framework** | ASP.NET WebForms + Razor pages on **.NET Framework 4.5+** (`targetFramework="4.5"`; runs on 4.8) |
| **Storage** | XML files in `App_Data` (default). SQL Server / SQLite / MySQL scripts in `setup\` |
| **Hosting** | IIS (or IIS Express) only - not `dotnet`, exe or service |
| **Contents** | `BlogEngine\` = full web root (~31 MB, ~1700 files, `bin\` included) |

## Install - no download
Windows feature *IIS + ASP.NET 4.x* (script enables it). .NET Framework 4.8 already ships with Windows 10 1903+.

## Run
- **IIS** (admin PowerShell, from repo root):
  `.\tools\install-iis-site.ps1 -Name Blog -SourcePath .\10-BlogEngine-NET-Framework45\BlogEngine -Port 8091 -Framework`
  -> http://localhost:8091
- **IIS Express**: double-click `run-iisexpress.cmd` (the account running it needs write access to `App_Data`, which
  your own user has).
- Admin: http://localhost:8091/Account/login.aspx - default user **admin**; **change the password right away**.
- Remove: `.\tools\remove-iis-site.ps1 -Name Blog -DeleteFiles`

The pool identity needs Modify rights on the site folder (`App_Data` writes posts/users/settings) - `install-iis-site.ps1` grants it.