<%@ page isErrorPage="true" import="java.io.*" %>
<html>
<link rel="stylesheet" type="text/css" href="/HyperionPlanning/extensions/css/Extension.css" />
<head>
	<title>Exceptional Even Occurred!</title>
	<style>
	body, p { font-family:Tahoma; font-size:10pt; padding-left:30; }
	pre { font-size:8pt; }
	</style>
</head>
<body class="body">

<%-- Exception Handler --%>
<font color="red">
<%= exception.toString() %><br>
</font>

<%
out.println("<!--");
StringWriter sw = new StringWriter();
PrintWriter pw = new PrintWriter(sw);
exception.printStackTrace(pw);
out.print(sw);
sw.close();
pw.close();
out.println("-->");
%>

</body>
</html>