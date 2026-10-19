using System.Collections.Concurrent;

namespace App2.Notes.Services;

public record Note(int Id, string Text, DateTime CreatedAt);

// Simple in-memory store (resets when the IIS app pool recycles)
public class NoteStore
{
    private readonly ConcurrentDictionary<int, Note> _notes = new();
    private int _nextId = 0;

    public NoteStore()
    {
        Add("Welcome! This is App2 running on IIS.");
        Add("Add or delete notes using the form above.");
    }

    public IEnumerable<Note> All() => _notes.Values.OrderByDescending(n => n.Id);
    public void Add(string text)
    {
        var id = Interlocked.Increment(ref _nextId);
        _notes[id] = new Note(id, text.Trim(), DateTime.Now);
    }
    public void Delete(int id) => _notes.TryRemove(id, out _);
}
