<%@ WebHandler Language="C#" Class="Api" %>

using System;
using System.Web;
using System.Web.Script.Serialization;

public class Api : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        var result = new
        {
            status = "ok",
            time = DateTime.Now,
            clr = Environment.Version.ToString(),
            machine = Environment.MachineName
        };
        context.Response.Write(new JavaScriptSerializer().Serialize(result));
    }

    public bool IsReusable { get { return true; } }
}
