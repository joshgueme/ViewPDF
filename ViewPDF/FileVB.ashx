<%@ WebHandler Language="VB" Class="FileVB" %>

Imports System
Imports System.Web
Imports System.Data
Imports System.Data.SqlClient
Imports System.Configuration

Public Class FileVB : Implements IHttpHandler
    
    Public Sub ProcessRequest(context As HttpContext) Implements IHttpHandler.ProcessRequest
        Dim id As Integer = Integer.Parse(context.Request.QueryString("Id"))
        Dim bytes As Byte()
        Dim fileName As String, contentType As String
        Dim constr As String = ConfigurationManager.ConnectionStrings("constr").ConnectionString
        Using con As New SqlConnection(constr)
            Using cmd As New SqlCommand()
                cmd.CommandText = "SELECT Name, Data, ContentType FROM tblFiles WHERE Id=@Id"
                cmd.Parameters.AddWithValue("@Id", id)
                cmd.Connection = con
                con.Open()
                Using sdr As SqlDataReader = cmd.ExecuteReader()
                    sdr.Read()
                    bytes = DirectCast(sdr("Data"), Byte())
                    contentType = sdr("ContentType").ToString()
                    fileName = sdr("Name").ToString()
                End Using
                con.Close()
            End Using
        End Using

        context.Response.Buffer = True
        context.Response.Charset = ""
        If context.Request.QueryString("download") = "1" Then
            context.Response.AppendHeader("Content-Disposition", Convert.ToString("attachment; filename=") & fileName)
        End If
        context.Response.Cache.SetCacheability(HttpCacheability.NoCache)
        context.Response.ContentType = "application/pdf"
        context.Response.BinaryWrite(bytes)
        context.Response.Flush()
        context.Response.[End]()
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property
End Class