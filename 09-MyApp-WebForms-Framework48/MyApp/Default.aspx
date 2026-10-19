<%@ Page Language="C#" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    List<string> Items
    {
        get
        {
            var l = Session["items"] as List<string>;
            if (l == null) { l = new List<string>(); Session["items"] = l; }
            return l;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        BindList();
    }

    protected void Add_Click(object sender, EventArgs e)
    {
        var text = TxtItem.Text.Trim();
        if (text.Length > 0) Items.Add(text);
        TxtItem.Text = "";
        BindList();
    }

    protected void Clear_Click(object sender, EventArgs e)
    {
        Items.Clear();
        BindList();
    }

    void BindList()
    {
        Rpt.DataSource = Items;
        Rpt.DataBind();
    }
</script>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>MyApp on IIS</title>
    <style>
        body { font-family: Segoe UI, Arial, sans-serif; max-width: 640px; margin: 40px auto; padding: 0 16px; }
        .box { background: #f4f6f8; border-radius: 8px; padding: 12px 16px; margin-bottom: 20px; }
        li { margin: 4px 0; }
        input[type=text] { padding: 6px; width: 260px; }
        input[type=submit] { padding: 6px 12px; }
    </style>
</head>
<body>
    <h1>Hello from .NET Framework</h1>
    <div class="box">
        <div>Server time: <b><%: DateTime.Now.ToString("F") %></b></div>
        <div>CLR version: <b><%: Environment.Version %></b></div>
        <div>Machine: <b><%: Environment.MachineName %></b></div>
        <div>JSON endpoint: <a href="api.ashx">api.ashx</a></div>
    </div>

    <form id="form1" runat="server">
        <h3>Session to-do list</h3>
        <asp:TextBox ID="TxtItem" runat="server" />
        <asp:Button ID="BtnAdd" runat="server" Text="Add" OnClick="Add_Click" />
        <asp:Button ID="BtnClear" runat="server" Text="Clear" OnClick="Clear_Click" />
        <ul>
            <asp:Repeater ID="Rpt" runat="server">
                <ItemTemplate>
                    <li><%# Server.HtmlEncode((string)Container.DataItem) %></li>
                </ItemTemplate>
            </asp:Repeater>
        </ul>
    </form>
</body>
</html>
