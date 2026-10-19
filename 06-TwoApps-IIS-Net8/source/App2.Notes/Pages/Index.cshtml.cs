using System.ComponentModel.DataAnnotations;
using App2.Notes.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace App2.Notes.Pages;

public class IndexModel : PageModel
{
    private readonly NoteStore _store;
    public IndexModel(NoteStore store) => _store = store;

    public IEnumerable<Note> Notes { get; private set; } = Enumerable.Empty<Note>();

    [BindProperty, Required, StringLength(200)]
    public string NewNote { get; set; } = "";

    public string Machine => Environment.MachineName;
    public string Framework => System.Runtime.InteropServices.RuntimeInformation.FrameworkDescription;

    public void OnGet() => Notes = _store.All();

    public IActionResult OnPostAdd()
    {
        if (!ModelState.IsValid) { Notes = _store.All(); return Page(); }
        _store.Add(NewNote);
        return RedirectToPage();
    }

    public IActionResult OnPostDelete(int id)
    {
        _store.Delete(id);
        return RedirectToPage();
    }
}
