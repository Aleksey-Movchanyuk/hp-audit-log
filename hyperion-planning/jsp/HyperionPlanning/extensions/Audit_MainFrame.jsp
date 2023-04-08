<%@ page errorPage="ExceptionHandler.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="java.util.List,java.util.ArrayList,
            ua.com.borlas.HPExtensions.*,
    		ua.com.borlas.HPExtensions.Audit.*,
    		ua.com.borlas.HPExtensions.Audit.DAO.*"
    		%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

<%
   request.setCharacterEncoding("UTF-8");
   
   // Объявляем переменные
   String sApplication = request.getParameter("Application");
   String sCube = request.getParameter("Cube"); 
   String sForm = request.getParameter("Form");
   String sCell = request.getParameter("Cell");
%>

<link rel="stylesheet" type="text/css" href="/HyperionPlanning/extensions/css/Extension.css" />

<script>
function getElementsByPrefix(inPrefix, inRoot) { 
   var elem_array = new Array; 
   if(typeof inRoot.firstChild!= 'undefined') { 
      var elem = inRoot.firstChild; 
      while (elem!= null) { 
         if(typeof elem.firstChild!= 'undefined') { 
            elem_array = elem_array.concat(getElementsByPrefix(inPrefix,elem)); 
         } 
         if(typeof elem.id!= 'undefined') { 
            var reg = new RegExp ( '^'+inPrefix+'.*' ); 
            if(elem.id.match(reg)) { 
               elem_array.push(elem); 
            } 
         } 
         elem = elem.nextSibling; 
      } 
   } 
   return elem_array; 
}

function go() {
   var dims = getElementsByPrefix('dim_',document.documentElement);
   var cellCoordinate = "";
   for(var i = 0; i < dims.length; i++) {
      var value  = dims[i].options[dims[i].selectedIndex].value;
      
      if(value != "All") {
         cellCoordinate += value;
         
         if(i+1 < dims.length) 
            cellCoordinate += ",";
      }
   }
   cellCoordinate = cellCoordinate.substring(0, cellCoordinate.length-1);
   
   var application = "<% out.print(HPUtils.encodeURL(sApplication)); %>";
   var cube = "<% out.print(HPUtils.encodeURL(sCube)); %>";
   var form = "<% out.print(HPUtils.decodeURL(sForm)); %>";
   
   if(application && cube) {
      window.open( "/HyperionPlanning/extensions/AuditBrowser.jsp?Application=" + application + "&Cube=" + cube + "&Cell=" + cellCoordinate, '_parent');
   }
   else if(application && form) {
      window.open( "/HyperionPlanning/extensions/AuditBrowser.jsp?Application=" + application + "&Form=" + form + "&Cell=" + cellCoordinate, '_parent');
   }
}
</script>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</head>
<body class="body">
   <%
     List<String> cell = new ArrayList<String>();
     int pos = 0;
	 while(sCell.indexOf(",", pos) > 0) {
		  cell.add(sCell.substring(pos, sCell.indexOf(",", pos)));
		  pos = sCell.indexOf(",", pos)+1;
	 }
	 cell.add(sCell.substring(pos, sCell.length()));
     
     List<HPAudit> auditByCube = new ArrayList<HPAudit>();
     List<HPAudit> auditByForm = new ArrayList<HPAudit>();
     
     List<HPDimension> dimByCube = new ArrayList<HPDimension>();
     List<HPDimension> dimByForm = new ArrayList<HPDimension>();
     List<HPMember> member = new ArrayList<HPMember>();
     
     if(! sCube.equals("")) {
        out.println("<div>Установлен фильтр по типу плана:" + sCube + "</div>");
     }
     else if (!sForm.equals("")) {
        out.println("<div>Установлен фильтр по форме:" + HPUtils.decodeURL(sForm) + "</div>");
     }
   %>
   <table>
      <tr>
		 <td class="groupbox">
			   <table>
					<tr>
						<td class="primary">Выберите срез данных:</td></tr>
						<tr><td> 
						<%
						if (!sApplication.equals("") && ! sCube.equals("")) {
							dimByCube = HPDimensionDAO.getDimensionList_ByCube(sApplication, sCube);
							for(int i = 0; i < dimByCube.size(); i++) {
							
							   out.print(dimByCube.get(i).getName());
						%>
						<select id="dim_<% out.print(dimByCube.get(i).getName()); %>">
						       <option value="All">Все</option>
						   <%
						      member = HPMemberDAO.getMemberList(sApplication, dimByCube.get(i).getName());
						      for(int j = 0; j < member.size(); j++) {
						      %>
						        <option value="<% out.print(member.get(j).getName()); %>" <% if(cell.contains(member.get(j).getName())) out.print(" selected ");  %> ><% out.print(member.get(j).getName()); %></option>
						      <%
						      }
						   %>
					    </select>
					    <%
					        }
					     }
						 else if (!sApplication.equals("") && ! sForm.equals("")) {
							dimByForm = HPDimensionDAO.getDimensionList_ByForm(sApplication, sForm);
							for(int i = 0; i < dimByForm.size(); i++) {
							   out.print(dimByForm.get(i).getName());
					    %>
                          <select id="dim_<% out.print(dimByForm.get(i).getName()); %>">
						       <option value="All">Все</option>
						   <%
						      member = HPMemberDAO.getMemberList(sApplication, dimByForm.get(i).getName());
						      for(int j = 0; j < member.size(); j++) {
						      %>
						        <option value="<% out.print(member.get(j).getName()); %>" <% if(cell.contains(member.get(j).getName())) out.print(" selected ");  %> ><% out.print(member.get(j).getName()); %></option>
						      <%
						      }
						   %>
					    </select>
					    <%
					        }
					     }
					    %><input type="submit" class="primaryActive" value="Перейти" height="15" onClick="go();" onMouseOver="this.className='primaryRollover'" onMouseOut="this.className='primaryActive'" onMouseDown="this.className='primaryClicked'" onMouseUp="this.className='primaryRollover'" name="B1" title="Перейти">
						<!-- <input name="Go" value="Перейти" type="button" onclick="go();" > -->
						</td> </tr>
						<tr>
					</tr>
					<tr>
						<td><table class="audit" width="100%">
								<thead>
									<tr>
										<th>Пользователь</th>
										<th>Время</th>
										<th>Старое<br>значение</th>
										<th>Новое<br>значение</th>
										<th>Срез данных<br>Измерение:Элемент</th>
									</tr>
								</thead>
								<% 
								    if(sApplication.equals("")) {
								       %> 
								       <tr><td>
								       <% 
								       out.println("Записи отсутствуют");
								       %>
								       </td></tr>
								       <%
								    }
								    else if (!sApplication.equals("") && ! sCube.equals("") && sCell.equals("")) {
								       auditByCube = HPAuditDAO.getAuditList_ByCube(sApplication, sCube);
								       for(int i = 0; auditByCube.size() > i; i++) {
								%>
								<tr class="fieldLabel">
									<td class="fieldLabel"><% out.println(auditByCube.get(i).getUserName()); %></td>
									<td class="fieldLabel"><% out.println(auditByCube.get(i).getTimePosted()); %></td>
									<td class="fieldLabel"><% out.println(auditByCube.get(i).getOldValue()); %></td>
									<td class="fieldLabel"><% out.println(auditByCube.get(i).getNewValue()); %></td>
									<td class="fieldLabel"><% out.println(auditByCube.get(i).getAuditDetail()); %></td>
								</tr>
								<%
								       }
								    }
								      else if (!sApplication.equals("") && !sForm.equals("") && sCell.equals("")) {
								         auditByForm = HPAuditDAO.getAuditList_ByForm(sApplication, sForm);
								         for(int i = 0; auditByForm.size() > i; i++) {
								 %>
								<tr class="fieldLabel">
									<td class="fieldLabel"><% out.println(auditByForm.get(i).getUserName()); %></td>
									<td class="fieldLabel"><% out.println(auditByForm.get(i).getTimePosted()); %></td>
									<td class="fieldLabel"><% out.println(auditByForm.get(i).getOldValue()); %></td>
									<td class="fieldLabel"><% out.println(auditByForm.get(i).getNewValue()); %></td>
									<td class="fieldLabel"><% out.println(auditByForm.get(i).getAuditDetail()); %></td>
								</tr>
								<%
								       }
								    }
								    else if (!sApplication.equals("") && !sCube.equals("") && !sCell.equals("")) {
								         auditByCube = HPAuditDAO.getAuditList_ByCube(sApplication, sCube, sCell);
								         for(int i = 0; auditByCube.size() > i; i++) {
								 %>
								<tr class="fieldLabel">
									<td class="fieldLabel"><% out.println(auditByCube.get(i).getUserName()); %></td>
									<td class="fieldLabel"><% out.println(auditByCube.get(i).getTimePosted()); %></td>
									<td class="fieldLabel"><% out.println(auditByCube.get(i).getOldValue()); %></td>
									<td class="fieldLabel"><% out.println(auditByCube.get(i).getNewValue()); %></td>
									<td class="fieldLabel"><% out.println(auditByCube.get(i).getAuditDetail()); %></td>
								</tr>
								<%
								       }
								    }
								    else if (!sApplication.equals("") && !sForm.equals("") && !sCell.equals("")) {
								         auditByForm = HPAuditDAO.getAuditList_ByForm(sApplication, sForm, sCell);
								         for(int i = 0; auditByForm.size() > i; i++) {
								 %>
								<tr class="fieldLabel">
									<td class="fieldLabel"><% out.println(auditByForm.get(i).getUserName()); %></td>
									<td class="fieldLabel"><% out.println(auditByForm.get(i).getTimePosted()); %></td>
									<td class="fieldLabel"><% out.println(auditByForm.get(i).getOldValue()); %></td>
									<td class="fieldLabel"><% out.println(auditByForm.get(i).getNewValue()); %></td>
									<td class="fieldLabel"><% out.println(auditByForm.get(i).getAuditDetail()); %></td>
								</tr>
								<%
								       }
								    }
								 %>
							</table>
					<tr>
						<td><a href="/HyperionPlanning/extensions/Audit_Download.jsp?Application=<% out.println(sApplication); %>&Cube=<% out.println(sCube); %>&Form=<% out.println(sForm); %>&Cell=<% out.println(sCell); %>">Загрузить
								в Excel</a></td>
					</tr>
				</table></td>
      </tr>
   </table>

</body>
</html>