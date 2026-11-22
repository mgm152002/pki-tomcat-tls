<%@ page contentType="text/html;charset=UTF-8" import="java.security.cert.X509Certificate" %>
<!DOCTYPE html>
<html>
<head><title>PKI Lab - Tomcat over HTTPS</title>
<style>
 body{font-family:Arial,Helvetica,sans-serif;margin:40px;color:#222}
 h1{color:#1f4e79} table{border-collapse:collapse} td{border:1px solid #ccc;padding:6px 10px}
 td:first-child{background:#f2f6fa;font-weight:bold}
</style></head>
<body>
<h1>Hello from Apache Tomcat over HTTPS</h1>
<p>This page is served with a TLS certificate issued by the <b>Simple Signing CA</b>,
which is in turn signed by the <b>Simple Root CA</b>.</p>
<table>
<tr><td>Server</td><td><%= application.getServerInfo() %></td></tr>
<tr><td>Scheme / secure</td><td><%= request.getScheme() %> / <%= request.isSecure() %></td></tr>
<tr><td>Local port</td><td><%= request.getLocalPort() %></td></tr>
<tr><td>TLS protocol</td><td><%= request.getAttribute("org.apache.tomcat.util.net.secure_protocol_version") %></td></tr>
<tr><td>Cipher suite</td><td><%= request.getAttribute("jakarta.servlet.request.cipher_suite") %></td></tr>
<tr><td>Server time</td><td><%= new java.util.Date() %></td></tr>
</table>
</body>
</html>
