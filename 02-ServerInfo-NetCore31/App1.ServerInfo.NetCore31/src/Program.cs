// App1.ServerInfo - ASP.NET Core 3.1 version (Generic Host + Startup)
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace App1.ServerInfo
{
    public class Program
    {
        public static void Main(string[] args)
        {
            Host.CreateDefaultBuilder(args)
                // App folder as content root (also when the .exe is started from another directory)
                .UseContentRoot(AppContext.BaseDirectory)
                .ConfigureWebHostDefaults(web => web.UseStartup<Startup>())
                .Build()
                .Run();
        }
    }

    public class Startup
    {
        private static readonly DateTime StartedAt = DateTime.Now;
        private static long _hits;
        private readonly IWebHostEnvironment _env;

        public Startup(IWebHostEnvironment env)
        {
            _env = env;
        }

        public void ConfigureServices(IServiceCollection services)
        {
        }

        public void Configure(IApplicationBuilder app)
        {
            // One router (not app.Map), so Request.PathBase stays the real site/app path
            app.Run(ctx =>
            {
                var path = (ctx.Request.Path.Value ?? "").TrimEnd('/').ToLowerInvariant();

                if (path == "/api/info")
                    return WriteJson(ctx, GetInfo(ctx));

                if (path == "/api/health")
                    return WriteJson(ctx, new List<KeyValuePair<string, string>>
                    {
                        Kv("status", "Healthy"),
                        Kv("time", DateTime.UtcNow.ToString("o"))
                    });

                if (path == "")
                    return WriteHtml(ctx, GetInfo(ctx));

                ctx.Response.StatusCode = 404;
                return ctx.Response.WriteAsync("Not found");
            });
        }

        // Version folder of a shared framework, e.g. ...\shared\Microsoft.NETCore.App\3.1.32\ -> "3.1.32"
        private static string FrameworkFolderVersion(Type t)
        {
            try
            {
                var dir = Path.GetDirectoryName(t.Assembly.Location);
                return string.IsNullOrEmpty(dir) ? "unknown" : Path.GetFileName(dir);
            }
            catch
            {
                return "unknown";
            }
        }

        private List<KeyValuePair<string, string>> GetInfo(HttpContext ctx)
        {
            var proc = Process.GetCurrentProcess();
            var uptime = DateTime.Now - StartedAt;
            return new List<KeyValuePair<string, string>>
            {
                Kv("app", "App1.ServerInfo (ASP.NET Core 3.1)"),
                Kv("machine", Environment.MachineName),
                Kv("os", RuntimeInformation.OSDescription),
                Kv("framework", ".NET Core " + FrameworkFolderVersion(typeof(object))),
                Kv("aspnetcore", FrameworkFolderVersion(typeof(WebHost))),
                Kv("frameworkDescription", RuntimeInformation.FrameworkDescription),
                Kv("processArchitecture", RuntimeInformation.ProcessArchitecture.ToString()),
                Kv("environment", _env.EnvironmentName),
                Kv("processId", proc.Id.ToString()),
                Kv("processName", proc.ProcessName),   // w3wp = in-process (IIS), dotnet = out-of-process
                Kv("pathBase", ctx.Request.PathBase.Value),
                Kv("contentRoot", _env.ContentRootPath),
                Kv("serverTime", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss")),
                Kv("uptime", string.Format("{0}.{1:00}:{2:00}:{3:00}", uptime.Days, uptime.Hours, uptime.Minutes, uptime.Seconds)),
                Kv("requests", Interlocked.Increment(ref _hits).ToString()),
                Kv("clientIp", ctx.Connection.RemoteIpAddress == null ? "" : ctx.Connection.RemoteIpAddress.ToString())
            };
        }

        private static KeyValuePair<string, string> Kv(string k, string v)
        {
            return new KeyValuePair<string, string>(k, v ?? "");
        }

        private static string JsonEscape(string s)
        {
            var sb = new StringBuilder();
            foreach (var c in s)
            {
                switch (c)
                {
                    case '"': sb.Append("\\\""); break;
                    case '\\': sb.Append("\\\\"); break;
                    case '\n': sb.Append("\\n"); break;
                    case '\r': sb.Append("\\r"); break;
                    case '\t': sb.Append("\\t"); break;
                    default:
                        if (c < 0x20) sb.Append("\\u").Append(((int)c).ToString("x4"));
                        else sb.Append(c);
                        break;
                }
            }
            return sb.ToString();
        }

        private static Task WriteJson(HttpContext ctx, List<KeyValuePair<string, string>> items)
        {
            var sb = new StringBuilder("{");
            for (int i = 0; i < items.Count; i++)
            {
                if (i > 0) sb.Append(',');
                sb.Append('"').Append(JsonEscape(items[i].Key)).Append("\":\"").Append(JsonEscape(items[i].Value)).Append('"');
            }
            sb.Append('}');
            ctx.Response.ContentType = "application/json; charset=utf-8";
            return ctx.Response.WriteAsync(sb.ToString());
        }

        private static Task WriteHtml(HttpContext ctx, List<KeyValuePair<string, string>> items)
        {
            var rows = new StringBuilder();
            foreach (var kv in items)
            {
                rows.Append("<tr><th>").Append(WebUtility.HtmlEncode(kv.Key))
                    .Append("</th><td>").Append(WebUtility.HtmlEncode(kv.Value)).Append("</td></tr>");
            }
            var pb = ctx.Request.PathBase.Value ?? "";

            var html =
                "<!doctype html>\n<html><head><meta charset=\"utf-8\"><title>App1 - Server Info (.NET Core 3.1)</title>\n" +
                "<style>\n" +
                " body{font-family:Segoe UI,Arial,sans-serif;background:#14352f;color:#eee;margin:0;padding:40px}\n" +
                " .card{max-width:720px;margin:auto;background:#1d4a42;border-radius:12px;padding:24px 32px;box-shadow:0 6px 20px #0006}\n" +
                " h1{margin-top:0;color:#7ee0c3} table{width:100%;border-collapse:collapse}\n" +
                " th,td{text-align:left;padding:8px;border-bottom:1px solid #2f6b5f} th{color:#b4ecdc;width:35%}\n" +
                " a{color:#7ee0c3}\n" +
                "</style></head>\n<body><div class=\"card\">\n" +
                "<h1>&#9989; App1 &mdash; Server Info</h1>\n" +
                "<p>ASP.NET Core <b>3.1</b> is running.</p>\n" +
                "<table>" + rows + "</table>\n" +
                "<p>JSON: <a href=\"" + pb + "/api/info\">api/info</a> &middot; <a href=\"" + pb + "/api/health\">api/health</a></p>\n" +
                "</div></body></html>";

            ctx.Response.ContentType = "text/html; charset=utf-8";
            return ctx.Response.WriteAsync(html);
        }
    }
}
