/*
 * Native Windows launcher (apphost) for App1.ServerInfo.dll
 *
 * Works like the official .NET apphost: it finds the installed .NET runtime,
 * loads hostfxr.dll and runs App1.ServerInfo.dll *inside this process*,
 * so the running process is App1.ServerInfo.exe (not dotnet.exe).
 *
 * Runtime lookup order (same as the official apphost):
 *   1. DOTNET_ROOT_X64 / DOTNET_ROOT environment variable
 *   2. HKLM\SOFTWARE\dotnet\Setup\InstalledVersions\x64  InstallLocation (32-bit registry view)
 *   3. %ProgramFiles%\dotnet
 *
 * Build:  x86_64-w64-mingw32-gcc -O2 -municode -o App1.ServerInfo.exe launcher.c version.o -lshlwapi
 */
#ifndef UNICODE
#define UNICODE
#endif
#ifndef _UNICODE
#define _UNICODE
#endif
#include <windows.h>
#include <shellapi.h>
#include <shlwapi.h>
#include <stdio.h>
#include <wchar.h>

#define APP_DLL L"App1.ServerInfo.dll"

typedef int (__cdecl *hostfxr_main_startupinfo_fn)(
    const int argc, const wchar_t **argv,
    const wchar_t *host_path, const wchar_t *dotnet_root, const wchar_t *app_path);

static void pause_if_own_console(void)
{
    DWORD pids[2];
    /* If this process is the only one attached to the console, it was started by
       double-click: keep the window open so the message can be read. */
    if (GetConsoleProcessList(pids, 2) == 1) {
        fwprintf(stderr, L"\nPress Enter to close...");
        getwchar();
    }
}

static int fail(const wchar_t *msg)
{
    fwprintf(stderr, L"ERROR: %ls\n", msg);
    pause_if_own_console();
    return 1;
}

static BOOL dir_has_fxr(const wchar_t *root)
{
    wchar_t p[MAX_PATH];
    if (!root || !*root) return FALSE;
    if (swprintf(p, MAX_PATH, L"%ls\\host\\fxr", root) < 0) return FALSE;
    return PathIsDirectoryW(p);
}

static BOOL find_dotnet_root(wchar_t *out, DWORD cch)
{
    DWORD n;

    n = GetEnvironmentVariableW(L"DOTNET_ROOT_X64", out, cch);
    if (n > 0 && n < cch && dir_has_fxr(out)) return TRUE;

    n = GetEnvironmentVariableW(L"DOTNET_ROOT", out, cch);
    if (n > 0 && n < cch && dir_has_fxr(out)) return TRUE;

    {
        HKEY key;
        if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\dotnet\\Setup\\InstalledVersions\\x64",
                          0, KEY_READ | KEY_WOW64_32KEY, &key) == ERROR_SUCCESS) {
            DWORD type = 0, size = cch * sizeof(wchar_t);
            LONG r = RegQueryValueExW(key, L"InstallLocation", NULL, &type, (BYTE *)out, &size);
            RegCloseKey(key);
            if (r == ERROR_SUCCESS && type == REG_SZ) {
                out[cch - 1] = 0;
                size_t len = wcslen(out);
                while (len > 0 && (out[len - 1] == L'\\' || out[len - 1] == L'/')) out[--len] = 0;
                if (dir_has_fxr(out)) return TRUE;
            }
        }
    }

    n = ExpandEnvironmentStringsW(L"%ProgramFiles%\\dotnet", out, cch);
    if (n > 0 && n <= cch && dir_has_fxr(out)) return TRUE;

    return FALSE;
}

/* Compare "8.0.31" style versions. Release beats prerelease ("9.0.0-rc.1") of the same number. */
static int cmp_version(const wchar_t *a, const wchar_t *b)
{
    int a1 = 0, a2 = 0, a3 = 0, b1 = 0, b2 = 0, b3 = 0;
    swscanf(a, L"%d.%d.%d", &a1, &a2, &a3);
    swscanf(b, L"%d.%d.%d", &b1, &b2, &b3);
    if (a1 != b1) return a1 - b1;
    if (a2 != b2) return a2 - b2;
    if (a3 != b3) return a3 - b3;
    {
        int ap = wcschr(a, L'-') != NULL, bp = wcschr(b, L'-') != NULL;
        return bp - ap;
    }
}

static BOOL find_hostfxr(const wchar_t *root, wchar_t *out, DWORD cch)
{
    wchar_t pattern[MAX_PATH], best[MAX_PATH] = L"";
    WIN32_FIND_DATAW fd;
    HANDLE h;

    swprintf(pattern, MAX_PATH, L"%ls\\host\\fxr\\*", root);
    h = FindFirstFileW(pattern, &fd);
    if (h == INVALID_HANDLE_VALUE) return FALSE;
    do {
        if (!(fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)) continue;
        if (fd.cFileName[0] < L'0' || fd.cFileName[0] > L'9') continue;
        {
            wchar_t candidate[MAX_PATH];
            swprintf(candidate, MAX_PATH, L"%ls\\host\\fxr\\%ls\\hostfxr.dll", root, fd.cFileName);
            if (!PathFileExistsW(candidate)) continue;
        }
        if (!best[0] || cmp_version(fd.cFileName, best) > 0) wcsncpy(best, fd.cFileName, MAX_PATH - 1);
    } while (FindNextFileW(h, &fd));
    FindClose(h);

    if (!best[0]) return FALSE;
    swprintf(out, cch, L"%ls\\host\\fxr\\%ls\\hostfxr.dll", root, best);
    return TRUE;
}

int wmain(void)
{
    wchar_t exe_path[MAX_PATH], app_dir[MAX_PATH], app_path[MAX_PATH];
    wchar_t dotnet_root[MAX_PATH], fxr_path[MAX_PATH], msg[1024];
    int argc = 0, rc;
    LPWSTR *argv;
    HMODULE fxr;
    hostfxr_main_startupinfo_fn run;

    if (!GetModuleFileNameW(NULL, exe_path, MAX_PATH)) return fail(L"Cannot get the path of this executable.");
    wcscpy(app_dir, exe_path);
    PathRemoveFileSpecW(app_dir);
    swprintf(app_path, MAX_PATH, L"%ls\\%ls", app_dir, APP_DLL);

    if (!PathFileExistsW(app_path)) {
        swprintf(msg, 1024, L"%ls was not found next to this .exe (%ls).", APP_DLL, app_dir);
        return fail(msg);
    }

    if (!find_dotnet_root(dotnet_root, MAX_PATH))
        return fail(L".NET runtime not found. Install the ASP.NET Core Runtime 8.0 (or the Hosting Bundle) "
                    L"from https://dotnet.microsoft.com/download/dotnet/8.0");

    if (!find_hostfxr(dotnet_root, fxr_path, MAX_PATH)) {
        swprintf(msg, 1024, L"hostfxr.dll not found under %ls\\host\\fxr", dotnet_root);
        return fail(msg);
    }

    fxr = LoadLibraryExW(fxr_path, NULL, LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR | LOAD_LIBRARY_SEARCH_DEFAULT_DIRS);
    if (!fxr) {
        swprintf(msg, 1024, L"Failed to load %ls (error %lu).", fxr_path, GetLastError());
        return fail(msg);
    }

    run = (hostfxr_main_startupinfo_fn)(void *)GetProcAddress(fxr, "hostfxr_main_startupinfo");
    if (!run) return fail(L"hostfxr_main_startupinfo export not found in hostfxr.dll.");

    argv = CommandLineToArgvW(GetCommandLineW(), &argc);
    if (!argv || argc < 1) return fail(L"Cannot parse the command line.");
    argv[0] = exe_path;

    rc = run(argc, (const wchar_t **)argv, exe_path, dotnet_root, app_path);
    if (rc != 0) pause_if_own_console();
    return rc;
}
