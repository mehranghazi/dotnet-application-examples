using System.Runtime.InteropServices;
using Microsoft.Extensions.Hosting.WindowsServices;

var startedAt = DateTimeOffset.Now;
var isService = WindowsServiceHelpers.IsWindowsService(); // always false off Windows

var builder = WebApplication.CreateBuilder(new WebApplicationOptions
{
    Args = args,
    // When started by the Windows Service Control Manager the working directory is
    // C:\Windows\System32, so point content root at the folder the .exe lives in.
    ContentRootPath = isService ? AppContext.BaseDirectory : default
});

// Runs normally from a console; switches to service mode when launched by the SCM.
// (No-op on Linux/macOS, so the app also runs there for development.)
builder.Host.UseWindowsService(options => options.ServiceName = "WinKestrelApp");

// Kestrel is the built-in web server — no IIS involved.
// Listening URLs come from appsettings.json ("Kestrel:Endpoints"), or can be
// overridden with --urls "http://0.0.0.0:8080" on the command line.

var app = builder.Build();

app.UseDefaultFiles();   // serves wwwroot/index.html at "/"
app.UseStaticFiles();

app.MapGet("/api/info", (IHostEnvironment env) => Results.Ok(new
{
    server = "Kestrel (self-hosted, no IIS)",
    os = RuntimeInformation.OSDescription,
    framework = RuntimeInformation.FrameworkDescription,
    machine = Environment.MachineName,
    runningAsService = isService,
    environment = env.EnvironmentName,
    startedAt,
    serverTime = DateTimeOffset.Now
}));

app.MapGet("/api/hello/{name}", (string name) => Results.Ok(new { message = $"Hello, {name}!" }));

app.MapGet("/health", () => Results.Ok("healthy"));

app.Run();
