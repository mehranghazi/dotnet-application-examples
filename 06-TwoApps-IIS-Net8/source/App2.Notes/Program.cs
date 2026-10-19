using App2.Notes.Services;

var builder = WebApplication.CreateBuilder(args);

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
