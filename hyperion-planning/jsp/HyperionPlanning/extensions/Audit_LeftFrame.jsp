<%@ page errorPage="ExceptionHandler.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="java.util.List,java.util.ArrayList,
    		ua.com.borlas.HPExtensions.Audit.*,
    		ua.com.borlas.HPExtensions.Audit.DAO.*"
    %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

<!-- TreeView source file --> 
<link rel="stylesheet" type="text/css" href="/HyperionPlanning/extensions/css/treeview.css" />
<script type="text/javascript" src="/HyperionPlanning/extensions/script/yahoo-dom-event.js" ></script>
<script type="text/javascript" src="/HyperionPlanning/extensions/script/treeview-min.js" ></script>

<link rel="stylesheet" type="text/css" href="/HyperionPlanning/extensions/css/Extension.css" />

<script> 
function changeApp(obj) { 

   var newApplication = obj.options[obj.selectedIndex].value;
   window.location.href = "/HyperionPlanning/extensions/Audit_LeftFrame.jsp?Application=" + newApplication;
} 

function selectCube(cubeName) { 

   var appSelect = document.getElementById("appSelect"); 
   var application = appSelect.options[appSelect.selectedIndex].value; 
   window.open( "/HyperionPlanning/extensions/AuditBrowser.jsp?Application=" + application + "&Cube=" + cubeName, '_parent');
}

function selectForm(formName) { 

   var appSelect = document.getElementById("appSelect"); 
   var application = appSelect.options[appSelect.selectedIndex].value; 
   window.open( "/HyperionPlanning/extensions/AuditBrowser.jsp?Application=" + application + "&Form=" + formName, '_parent');
}
</script> 

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</head>
<!-- <body  class="yui-skin-sam"> -->
<body class="body">

<%
	// Объявляем переменные
	String sApplication = "";
	sApplication = request.getParameter("Application");
	sApplication = (sApplication == null ? "" : sApplication);
	
	List<HPApplication> appList = new ArrayList<HPApplication>();
	appList = HPApplicationDAO.getApplicationList();
	
	String formListHTML = "";
	formListHTML = HPFormDAO.getUIFormList(sApplication);
	
	List<HPCube> cubeList = new ArrayList<HPCube>();
	cubeList = HPCubeDAO.getCubeList(sApplication);
%>
   <table>
      <tr>
	     <td>
		    Выберите приложение:<br> 
			<select id="appSelect" onchange="changeApp(this)">
			   <%
			      for (int i = 0; i < appList.size(); i++)
				  {
			         if(sApplication.compareTo( appList.get(i).getName()) == 0 )
			         	out.println("<OPTION value = " + appList.get(i).getName() + " selected >" + appList.get(i).getName() + "</OPTION>"); 
			         else
			            out.println("<OPTION value = " + appList.get(i).getName() + ">" + appList.get(i).getName() + "</OPTION>");
			      }	
		       %>
			   
			</select>
	     </td>
		 <td>
			   
		 </td>
	  </tr>
	  <tr>
	     <td>Выберите форму или тип плана:<br>
				<div id="treeForm">
					<ul>
						<% out.println(formListHTML); %>
					</ul>
				</div> <script type="text/javascript">
                (function() {
                   var tree;
                   tree = new YAHOO.widget.TreeView(document.getElementById("treeForm"));
                   tree.render();
                   
                   tree.subscribe('clickEvent', function(oArgs) { 
                      if(! oArgs.node.hasChildren (false)) {
                         selectForm(oArgs.node.label);
                      }; 
                   });
                   
                 }());
                </script>
                <div id="treeCube">
					<ul>
						<li>По типам плана
							<ul>
						    <%
			                 for (int i = 0; i < cubeList.size(); i++)
				             {
			                %>      
			                    <li><% out.println(cubeList.get(i).getName()); %></li>
			                <%
			                 }
			                %>
							</ul></li>
					</ul>
				</div> <script type="text/javascript">
                (function() {
                   var tree;
                   tree = new YAHOO.widget.TreeView(document.getElementById("treeCube"));
                   tree.render();
                   
                   tree.subscribe('clickEvent', function(oArgs) { 
                      if(! oArgs.node.hasChildren (false)) {
                         selectCube(oArgs.node.label);
                      }; 
                   });

                 }());
                </script>
         </td>
     </tr>
  </table>       
</body>
</html>