<%@ page contentType="text/html;charset=UTF-8" import="java.net.InetAddress, java.util.Date" %>
<!DOCTYPE html>
<html>
<head><title>PS Sample App</title>
<style>body{font-family:sans-serif;margin:2em}td{padding:4px 12px}td:first-child{font-weight:bold}</style>
</head>
<body>
<h1>PS Sample App is running</h1>
<p>A small WAR deployed on Apache Tomcat.</p>
<table>
  <tr><td>Served by host</td><td><%= InetAddress.getLocalHost().getHostName() %></td></tr>
  <tr><td>Server</td><td><%= application.getServerInfo() %></td></tr>
  <tr><td>Java version</td><td><%= System.getProperty("java.version") %> (<%= System.getProperty("java.vendor") %>)</td></tr>
  <tr><td>Context path</td><td><%= request.getContextPath() %></td></tr>
  <tr><td>Request came via</td><td><%= request.getHeader("X-Forwarded-For") != null ? "proxy, client " + request.getHeader("X-Forwarded-For") : "direct, client " + request.getRemoteAddr() %></td></tr>
  <tr><td>Host header</td><td><%= request.getHeader("Host") %></td></tr>
  <tr><td>Time</td><td><%= new Date() %></td></tr>
</table>
</body>
</html>
