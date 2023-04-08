<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="java.io.*,java.util.*,
            java.util.List,java.util.ArrayList,
    		ua.com.borlas.HPExtensions.Audit.*,
    		ua.com.borlas.HPExtensions.Audit.DAO.*"
%>
<%
   String sApplication = request.getParameter("Application");
   String sCube = request.getParameter("Cube"); 
   String sForm = request.getParameter("Form"); 
   String sCell = request.getParameter("Cell");
   
   List<HPAudit> auditByCube = new ArrayList<HPAudit>();
   List<HPAudit> auditByForm = new ArrayList<HPAudit>();
     
   String content = new String("");
   
   if(!sApplication.equals("") && !sCube.equals("") && sCell.equals("")) { 
      auditByCube = HPAuditDAO.getAuditList_ByCube(sApplication, sCube);
      for(int i = 0; i < auditByCube.size(); i++) {
         content += auditByCube.get(i).getUserName() + ";";
         content += auditByCube.get(i).getTimePosted() + ";";
         content += auditByCube.get(i).getOldValue() + ";";
         content += auditByCube.get(i).getNewValue() + ";";
         content += auditByCube.get(i).getAuditDetail() + ";\n";
      }
   }
   else if(!sApplication.equals("") && !sForm.equals("") && sCell.equals("")) {
      auditByForm = HPAuditDAO.getAuditList_ByForm(sApplication, sForm);
      for(int i = 0; i < auditByCube.size(); i++) {
         content += auditByForm.get(i).getUserName() + ";";
         content += auditByForm.get(i).getTimePosted() + ";";
         content += auditByForm.get(i).getOldValue() + ";";
         content += auditByForm.get(i).getNewValue() + ";";
         content += auditByForm.get(i).getAuditDetail() + ";\n";
      }
   }
   else if(!sApplication.equals("") && !sCube.equals("") && !sCell.equals("")) {
      auditByCube = HPAuditDAO.getAuditList_ByCube(sApplication, sCube, sCell);
      for(int i = 0; i < auditByCube.size(); i++) {
         content += auditByCube.get(i).getUserName() + ";";
         content += auditByCube.get(i).getTimePosted() + ";";
         content += auditByCube.get(i).getOldValue() + ";";
         content += auditByCube.get(i).getNewValue() + ";";
         content += auditByCube.get(i).getAuditDetail() + ";\n";
      }
   }
   else if(!sApplication.equals("") && !sForm.equals("") && !sCell.equals("")) {
      auditByForm = HPAuditDAO.getAuditList_ByForm(sApplication, sForm, sCell);
      for(int i = 0; i < auditByForm.size(); i++) {
         content += auditByForm.get(i).getUserName() + ";";
         content += auditByForm.get(i).getTimePosted() + ";";
         content += auditByForm.get(i).getOldValue() + ";";
         content += auditByForm.get(i).getNewValue() + ";";
         content += auditByForm.get(i).getAuditDetail() + ";\n";
      }
   }
   
   byte requestBytes[] = content.getBytes();
   ByteArrayInputStream bis = new ByteArrayInputStream(requestBytes);
                
   response.reset();
   response.setContentType("application/text");
   response.setHeader("Content-disposition","attachment; filename=Audit.csv");

   byte[] buf = new byte[1024];
   int len;
   while ((len = bis.read(buf)) > 0) {
      response.getOutputStream().write(buf, 0, len);
   }
   bis.close();
   response.getOutputStream().flush(); 
   
%>