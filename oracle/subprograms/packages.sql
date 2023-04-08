
--------------------------------------------------------
--  DDL for Package EXT_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "EXT_AUDIT_PKG" IS

  -- Author  : ������� ��������
  -- Created : 28.09.2011 13:39:00
  -- Purpose : ������� � ��������� �� ��������� ������
  
  -- Public type declarations 
  TYPE DIM_LIST_TYPE IS TABLE OF DIM_TYPE;
  TYPE MBR_LIST_TYPE IS TABLE OF MBR_TYPE;
  TYPE MBR_PATH_LIST_TYPE IS TABLE OF NVARCHAR2(1500);
  
  -- Public constant declarations
  --<ConstantName> constant <Datatype> := <Value>;


  -- Public function and procedure declarations
  --FUNCTION <FunctionName>(<Parameter> <Datatype>) RETURN <Datatype>;
  
  -- ������� ���������� ���������� �� ������
  PROCEDURE Add_Audit_Info_P(
                 in_Application    NVARCHAR2,
                 in_Form_Id        NUMBER,
                 in_Form_Name      NVARCHAR2,
                 in_Form_Path      NVARCHAR2,
                 in_Plan_Type_Id   NUMBER,
                 in_Plan_Type_Name NVARCHAR2,
                 in_User_Name      NVARCHAR2,
                 in_Time_Posted    DATE,
                 in_Old_Value      NVARCHAR2,
                 in_New_Value      NVARCHAR2,
                 in_Dims           EXT_AUDIT_PKG.DIM_LIST_TYPE,
                 in_Members        EXT_AUDIT_PKG.MBR_LIST_TYPE,
                 in_Member_Path    EXT_AUDIT_PKG.MBR_PATH_LIST_TYPE
     );
     
  -- ������� ����������� ������ �� ������� EXT_AUDIT_DETAIL �� 
  -- ���������� ������ ������ � ���� ������ � ������� 
  -- ���������_1:�������_1|���������_2:�������_2|���������_N:�������_N
  FUNCTION Get_Audit_Details_F(
                 in_Audit_Id       NUMBER
      ) RETURN VARCHAR2;

END EXT_AUDIT_PKG; 

/

--------------------------------------------------------
--  DDL for Package Body EXT_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "EXT_AUDIT_PKG" IS

  -- Private type declarations
  --type <TypeName> is <Datatype>;
  
  -- Private constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Private variable declarations
  --<VariableName> <Datatype>;

  -- ������� ���������� ���������� �� ������
  PROCEDURE Add_Audit_Info_P(
                 in_Application    NVARCHAR2,
                 in_Form_Id        NUMBER,
                 in_Form_Name      NVARCHAR2,
                 in_Form_Path      NVARCHAR2,
                 in_Plan_Type_Id   NUMBER,
                 in_Plan_Type_Name NVARCHAR2,
                 in_User_Name      NVARCHAR2,
                 in_Time_Posted    DATE,
                 in_Old_Value      NVARCHAR2,
                 in_New_Value      NVARCHAR2,
                 in_Dims        EXT_AUDIT_PKG.DIM_LIST_TYPE,
                 in_Members     EXT_AUDIT_PKG.MBR_LIST_TYPE,
                 in_Member_Path EXT_AUDIT_PKG.MBR_PATH_LIST_TYPE
     )
  IS
    v_Audit_Id   NUMBER;
    v_Audit_Detail_Id   NUMBER;
  BEGIN
  
    -- �������������� �������� ���������� ���������� Id ������
    SELECT EXT_AUDIT_SEQ.NEXTVAL 
    INTO v_Audit_Id
    FROM dual;
    
    -- ��������� ������ � ������� ������
    INSERT INTO ext_audit ( audit_id, 
                            audit_application, 
                            audit_form_id,
                            audit_form_name, 
                            audit_form_path, 
                            audit_plan_type_id,
                            audit_plan_type_name,
                            audit_user_name,
                            audit_time_posted,
                            audit_old_value,
                            audit_new_value 
                           )
                  VALUES ( v_Audit_Id,
                           in_Application,
                           in_Form_Id,
                           in_Form_Name,
                           in_Form_Path,
                           in_Plan_Type_Id,
                           in_Plan_Type_Name,
                           in_User_Name,
                           in_Time_Posted,
                           in_Old_Value,
                           in_New_Value
                          );
                          
     -- ��������� ������� � ������� ������� ������
     FOR i IN in_Dims.FIRST .. in_Dims.LAST
     LOOP
     
       -- �������������� �������� ���������� ���������� Id ������� ������
       SELECT ext_audit_detail_seq.NEXTVAL 
       INTO v_Audit_Detail_Id
       FROM dual;
    
       INSERT INTO ext_audit_detail ( auditd_id, 
                                      auditd_audit, 
                                      auditd_dimension_id,
                                      auditd_dimension_name,
                                      auditd_member_id,
                                      auditd_member_name,
                                      auditd_member_path 
                                    )
                             VALUES ( v_Audit_Detail_Id,
                                      v_Audit_Id,
                                      in_Dims(i).Dim_Id,
                                      in_Dims(i).Dim_Name,
                                      in_Members(i).Mbr_Id,
                                      in_Members(i).Mbr_Name,
                                      NULL
                          );
       
       
     END LOOP;
      
     -- 
     COMMIT;
     
     -- exception handlers begin
     EXCEPTION 
       WHEN OTHERS THEN -- handles all other errors
         DBMS_OUTPUT.put_line('Add_Audit_Info_P error: ' || SQLERRM);      
     
  END Add_Audit_Info_P;
  
  -- ������� ����������� ������ �� ������� EXT_AUDIT_DETAIL �� 
  -- ���������� ������ ������ � ���� ������ � ������� 
  -- ���������_1:�������_1|���������_2:�������_2|���������_N:�������_N
  FUNCTION Get_Audit_Details_F(
                 in_Audit_Id       NUMBER
      ) RETURN VARCHAR2
  IS
     v_Output   VARCHAR2(4000);
     
     CURSOR Audit_Details_C IS
        SELECT 
           audit_detail.auditd_dimension_name,
           audit_detail.auditd_member_name
        FROM ext_audit_detail audit_detail
        WHERE audit_detail.auditd_audit = in_Audit_Id;
  BEGIN

    FOR Audit_Detail IN Audit_Details_C
       LOOP
            
          v_Output := v_Output || Audit_Detail.Auditd_Dimension_Name;
          v_Output := v_Output || ':';
          v_Output := v_Output || Audit_Detail.Auditd_Member_Name;
          v_Output := v_Output || '|';
               
       END LOOP; 
    
    RETURN SUBSTR(v_Output,POS => 1, LEN =>  LENGTH(v_Output)-1);
        
  END Get_Audit_Details_F;

END EXT_AUDIT_PKG; 

/
