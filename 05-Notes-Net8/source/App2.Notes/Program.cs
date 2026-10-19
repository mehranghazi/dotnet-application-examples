using App2.Notes.Services;

// Content root = the app's own folder, so appsettings.json, Razor views and wwwroot
// are found even when the .exe is started from another directory.
var builder = WebApplication.CreateBuilder(new WebApplicationOptions
{
    Args = args,
    ContentRootPath = AppContext.BaseDirectory,
    WebRootPath = Path.Combine(AppContext.BaseDirectory, "wwwroot")
});

builder.Services.AddRazorPages();
builder.Services.AddSingleton<NoteStore>();

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
}

// No HTTPS redirect: works on a plain http:// IIS binding. Add a cert/https binding in IIS if needed.
app.UseStaticFiles();
app.UseRouting();
app.UseAuthorization();

app.MapRazorPages();
app.MapGet("/api/notes", (NoteStore store) => store.All());

app.Run();
