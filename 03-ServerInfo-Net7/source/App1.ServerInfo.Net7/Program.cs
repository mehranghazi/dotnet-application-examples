using System.Diagnostics;
using System.Runtime.InteropServices;

// Content root = the app's own folder, so appsettings.json is found
// even when the .exe is started from another directory (or as a service).
var builder = WebApplication.CreateBuilder(new WebApplicationOptions
{
    Args = args,
    ContentRootPath = AppContext.BaseDirectory
});
var app = builder.Build();

var startedAt = DateTime.Now;
long hits = 0;

object GetInfo(HttpContext ctx) => new
{
    app = "App1.ServerInfo",
    machine = Environment.MachineName,
    os = RuntimeInformation.OSDescription,
    framework = RuntimeInformation.FrameworkDescription,
    environment = app.Environment.EnvironmentName,
    processId = Environment.ProcessId,
    processName = Process.GetCurrentProcess().ProcessName,   // w3wp = in-process, dotnet = out-of-process
    pathBase = ctx.Request.PathBase.Value,
    contentRoot = app.Environment.ContentRootPath,
    serverTime = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"),
    uptime = (DateTime.Now - startedAt).ToString(@"d\.hh\:mm\:ss"),
    requests = Interlocked.Increment(ref hits),
    clientIp = ctx.Connection.RemoteIpAddress?.ToString()
};

app.MapGet("/api/info", (HttpContext ctx) => Results.Json(GetInfo(ctx)));
app.MapGet("/api/health", () => Results.Ok(new { status = "Healthy", time = DateTime.UtcNow }));

app.MapGet("/", (HttpContext ctx) =>
{
    var json = System.Text.Json.JsonSerializer.Serialize(GetInfo(ctx));
    var dict = System.Text.Json.JsonSerializer.Deserialize<Dictionary<string, object>>(json)!;
    var rows = string.Join("", dict.Select(kv =>
        $"<tr><th>{System.Net.WebUtility.HtmlEncode(kv.Key)}</th><td>{System.Net.WebUtility.HtmlEncode(kv.Value?.ToString() ?? "")}</td></tr>"));
    var html = $$"""
<!doctype html>
<html><head><meta charset="utf-8"><title>App1 - Server Info</title>
<style>
 body{font-family:Segoe UI,Arial,sans-serif;background:#0f2a44;color:#eee;margin:0;padding:40px}
 .card{max-width:720px;margin:auto;background:#163a5f;border-radius:12px;padding:24px 32px;box-shadow:0 6px 20px #0006}
 h1{margin-top:0;color:#5fd3ff} table{width:100%;border-collapse:collapse}
 th,td{text-align:left;padding:8px;border-bottom:1px solid #2b5580} th{color:#9cc8ee;width:35%}
 a{color:#5fd3ff}
</style></head>
<body><div class="card">
<h1>&#9989; App1 &mdash; Server Info</h1>
<p>ASP.NET Core Minimal API is running under IIS.</p>
<table>{{rows}}</table>
<p>JSON: <a href="api/info">api/info</a> &middot; <a href="api/health">api/health</a></p>
</div></body></html>
""";
    // Make links work when hosted under a sub-path (e.g. /app1 under Default Web Site)
    html = html.Replace("href=\"api/", $"href=\"{ctx.Request.PathBase}/api/");
    return Results.Content(html, "text/html");
});

app.Run();
