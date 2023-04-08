<%@ page errorPage="ExceptionHandler.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="ua.com.borlas.HPExtensions.*,
            java.net.URL
           "
    %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html> 

<link rel="stylesheet" type="text/css" href="/HyperionPlanning/extensions/css/Extension.css" />

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Audit Browser</title>
</head>

<%
   request.setCharacterEncoding("UTF-8"); 
   
   String sApplication = request.getParameter("Application"); 
   sApplication = (sApplication == null ? "" : sApplication); 
   
   String sCube = request.getParameter("Cube"); 
   sCube = (sCube == null ? "" : sCube); 
   
   String sForm = request.getParameter("Form"); 
   sForm = (sForm == null ? "" : sForm); 
   
   String sCell = request.getParameter("Cell"); 
   sCell = (sCell == null ? "" : sCell); 
   
   String leftFrameURL = "Audit_LeftFrame.jsp?Application=" + sApplication;
   String mainFrameURL = "Audit_MainFrame.jsp?Application=" + sApplication + "&Cube=" + sCube + "&Form=" + sForm + "&Cell=" + sCell;
%>

<frameset rows="80%,*" frameborder="NO" border="0" framespacing="0">

   <frameset cols="240,*"  frameborder="NO" border="0" framespacing="0">
	  <frame src="<% out.print(leftFrameURL); %>" name="leftFrame" scrolling="auto">
	  <frame src="<% out.print(mainFrameURL); %>" name="mainFrame" scrolling="auto">
   </frameset>
   <frame src="Extension_ButtomFrame.jsp" name="buttomFrame" scrolling="NO" noresize> 
</frameset>

<body></body>
</html>