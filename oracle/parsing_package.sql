--------------------------------------------------------
-- File created - ноябрь-19-2011 
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package HSP$DELTA_EXTRA_PKG
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "HSP$DELTA_EXTRA_PKG" IS

-- Author : Алексей Мовчанюк
-- Created : 23.09.2011 11:14:52
-- Purpose : Функции и процедуры обеспечивающие поддержку информационной системы Hyperion Planning 11.1.2.1

-- Public function and procedure declarations

-- Функция возвращает строку по заданным параметрам
  FUNCTION Get_Plan_Type_Id_F(in_Form_Name NVARCHAR2)
    RETURN NUMBER;
    
-- Функция возвращает имя файла по имени пользователя
  FUNCTION Get_Plan_Type_Name_F(in_Form_Name NVARCHAR2)
    RETURN NVARCHAR2;
    
-- Функция возвращает ID формы по имени
FUNCTION Get_Form_Id_F(in_Form_Name NVARCHAR2)
RETURN NUMBER;

-- Функция возвращает список измерений формы по ее имени
FUNCTION Get_Form_Dim_Layout_F(in_Form_Name NVARCHAR2)
RETURN EXT_AUDIT_PKG.DIM_LIST_TYPE;

-- Функция возвращает путь к форме по ее имени
FUNCTION Get_Form_Path_F(in_Form_Name NVARCHAR2)
RETURN NVARCHAR2;

-- Функция возвращает ID элемента по его имени
FUNCTION Get_Member_Id_F(in_Member_Name NVARCHAR2)
RETURN NUMBER;

-- Split string into a table
FUNCTION Split_String_F(in_String IN NVARCHAR2, in_Delimiter IN NVARCHAR2)
RETURN EXT_AUDIT_PKG.MBR_LIST_TYPE;

-- Процедура добавления записи аудита в таблицу EXT_AUDIT
PROCEDURE Parse_Audit_P(in_Form_Name NVARCHAR2,
in_Form_Audit NVARCHAR2,
in_User_Name NVARCHAR2,
in_Time_Posted DATE,
in_Old_Value NVARCHAR2,
in_New_Value NVARCHAR2);

-- Процедура выполнения добавления записи аудита по ROWID
PROCEDURE Exec_Parse_Audit_P(in_RowId ROWID);

END HSP$DELTA_EXTRA_PKG; 

/

--------------------------------------------------------
--  DDL for Package Body HSP$DELTA_EXTRA_PKG
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "HSP$DELTA_EXTRA_PKG" IS


  -- Private constant declarations
  c_Path_Separator constant NVARCHAR2(10) := '|';

-- Функция возвращает ID типа плана по имени формы
  FUNCTION Get_Plan_Type_Id_F(in_Form_Name NVARCHAR2)
    RETURN NUMBER IS
    v_Plan_Type NUMBER;
  BEGIN
  
    SELECT
      --f.form_id, 
      --o.object_name, 
      c.plan_type
    INTO v_Plan_Type
    FROM hsp_object o, hsp_form f, hsp_cubes c
    WHERE
      -- Соединяем таблицы по ID объекта 
      f.form_id = o.object_id
      -- Соединяем формы с кубами 
      AND f.cube_id = c.cube_id
      -- Условие на имя формы
      AND o.object_name = in_Form_Name;
  
    RETURN v_Plan_Type;
  
  -- exception handlers begin
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN -- catches all 'no data found' errors
      RETURN NULL;
    WHEN OTHERS THEN -- handles all other errors
      RETURN NULL;
    
  END Get_Plan_Type_Id_F;
  
  -- Функция возвращает имя типа плана по имени формы
  FUNCTION Get_Plan_Type_Name_F(in_Form_Name NVARCHAR2)
    RETURN NVARCHAR2
  IS
    v_Plan_Type_Name NVARCHAR2(80);
  BEGIN
  
    SELECT
      --f.form_id, 
      --o.object_name, 
      p.type_name
    INTO v_Plan_Type_Name
    FROM hsp_object o, hsp_form f, hsp_cubes c, hsp_plan_type p
    WHERE
      -- Соединяемся с базой данных
      f.form_id = o.object_id
    -- Соединяем формы с кубами
    AND f.cube_id = c.cube_id
    -- Соединяем кубы с типами планов
    AND c.plan_type = p.plan_type
    -- Условие на имя формы
    AND o.object_name = in_Form_Name;
  
    RETURN v_Plan_Type_Name;
  
  -- exception handlers begin
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN -- catches all 'no data found' errors
      RETURN NULL;
    WHEN OTHERS THEN -- handles all other errors
      RETURN NULL;
    
  END Get_Plan_Type_Name_F;
  
  -- Функция возвращает один параметр по имени
  FUNCTION Get_Form_Id_F(in_Form_Name NVARCHAR2)
    RETURN NUMBER
  IS
    v_Form_Id                 NUMBER;
  BEGIN
  
    -- Получаем идентификатор формы
    SELECT obj.object_id
    INTO v_Form_Id
    FROM hsp_object obj
    WHERE obj.object_type = 7 and obj.object_name = in_Form_Name;
    
    RETURN v_Form_Id;
    
    -- exception handlers begin
    EXCEPTION 
      WHEN OTHERS THEN -- handles all other errors
        DBMS_OUTPUT.put_line(SQLERRM); 
        RETURN NULL;  
  
  END Get_Form_Id_F;
  
  -- Функция возвращает структуру измерений по имени формы
  FUNCTION Get_Form_Dim_Layout_F(in_Form_Name NVARCHAR2)
    RETURN EXT_AUDIT_PKG.DIM_LIST_TYPE 
  IS
    v_Form_Layout EXT_AUDIT_PKG.DIM_LIST_TYPE ;
    v_Form_Id NUMBER;
  BEGIN
  
    -- Получаем идентификатор формы
    SELECT obj.object_id 
    INTO v_Form_Id
    FROM hsp_object obj
    WHERE obj.object_type = 7 and obj.object_name = in_Form_Name;
    
    -- Получаем структуру измерений
    SELECT DIM_TYPE(object_id, object_name)
    BULK COLLECT INTO v_Form_Layout
    FROM (
      SELECT object_id, object_name
      FROM (
       SELECT 1 layout_type, form_layout.ordinal, obj.object_id, obj.object_name
       FROM hsp_form_layout form_layout, hsp_object obj
       WHERE form_layout.dim_id = obj.object_id
         AND form_layout.form_id = v_Form_Id
         AND form_layout.layout_type = 2
       UNION ALL 
       SELECT 2 layout_type, form_layout.ordinal, obj.object_id, obj.object_name
       FROM hsp_form_layout form_layout, hsp_object obj
       WHERE form_layout.dim_id = obj.object_id
         AND form_layout.form_id = v_Form_Id
         AND form_layout.layout_type = 3
       UNION ALL 
       SELECT 3 layout_type, form_layout.ordinal, obj.object_id, obj.object_name
       FROM hsp_form_layout form_layout, hsp_object obj
       WHERE form_layout.dim_id = obj.object_id
         AND form_layout.form_id = v_Form_Id
         AND form_layout.layout_type = 0
       UNION ALL
       SELECT 4 layout_type, form_layout.ordinal, obj.object_id, obj.object_name
       FROM hsp_form_layout form_layout, hsp_object obj
       WHERE form_layout.dim_id = obj.object_id
         AND form_layout.form_id = v_Form_Id
         AND form_layout.layout_type = 1
      ) ORDER BY layout_type, ordinal
    ); 
    
  RETURN v_Form_Layout;
  
  -- exception handlers begin
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN -- catches all 'no data found' errors
      RETURN NULL;
    WHEN OTHERS THEN -- handles all other errors
      DBMS_OUTPUT.put_line(SQLERRM); 
      RETURN NULL;  
  
  END Get_Form_Dim_Layout_F;
  
  -- Функция возвращает один параметр по имени
  FUNCTION Get_Form_Path_F(in_Form_Name NVARCHAR2)
    RETURN NVARCHAR2
  IS
    v_Form_Id                 NUMBER;
    v_Form_Parent_Id          NUMBER;
    v_Rows_Count              NUMBER;
    v_Form_Name               NVARCHAR2(80);
    v_Form_Path               NVARCHAR2(1500);
  BEGIN
  
    v_Form_Path := in_Form_Name;
  
    -- Получаем идентификатор формы
    SELECT obj.object_id, obj.parent_id, obj.object_name
    INTO v_Form_Id, v_Form_Parent_Id, v_Form_Name
    FROM hsp_object obj
    WHERE obj.object_type = 7 and obj.object_name = in_Form_Name;
    
    WHILE (v_Form_Parent_Id > 0) LOOP
    
      -- Получаем все связанные строки
      SELECT COUNT(*)
      INTO v_Rows_Count
      FROM hsp_object obj
      WHERE obj.object_id = v_Form_Parent_Id
        AND UPPER(obj.object_name) <> 'FORMS';
        
      IF v_Rows_Count > 0 THEN
      
        SELECT obj.object_id, obj.parent_id, obj.object_name
        INTO v_Form_Id, v_Form_Parent_Id, v_Form_Name
        FROM hsp_object obj
        WHERE obj.object_id = v_Form_Parent_Id
        AND UPPER(obj.object_name) <> 'FORMS';
        
        v_Form_Path := v_Form_Name || c_Path_Separator || v_Form_Path;
        
      ELSE
      
        v_Form_Parent_Id := 0;
        
      END IF;
      
    END LOOP;
    
    RETURN v_Form_Path;
    
    -- exception handlers begin
    EXCEPTION 
      WHEN OTHERS THEN -- handles all other errors
        DBMS_OUTPUT.put_line(SQLERRM); 
        RETURN NULL;  
  
  END Get_Form_Path_F;
  
  -- Функция возвращает идентификатор элемента по его имени
  FUNCTION Get_Member_Id_F(in_Member_Name NVARCHAR2)
    RETURN NUMBER
  IS
    v_Member_Id     NUMBER;
  BEGIN
  
    SELECT obj.object_id 
    INTO v_Member_Id
    FROM hsp_object obj
    WHERE obj.object_name = in_Member_Name
       AND obj.object_type IN (31,32,33,34,35,37,38,50);  
       
    RETURN v_Member_Id;
    
  -- exception handlers begin
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN -- catches all 'no data found' errors
      RETURN NULL;
    WHEN OTHERS THEN -- handles all other errors
      DBMS_OUTPUT.put_line(in_Member_Name);
      DBMS_OUTPUT.put_line(SQLERRM); 
      RETURN NULL;  
  
  END Get_Member_Id_F;  

  -- Split string into a table
  FUNCTION Split_String_F(in_String IN NVARCHAR2, in_Delimiter IN NVARCHAR2) 
    RETURN EXT_AUDIT_PKG.MBR_LIST_TYPE
  IS
      v_Rows    EXT_AUDIT_PKG.MBR_LIST_TYPE := EXT_AUDIT_PKG.MBR_LIST_TYPE();
    v_String  NVARCHAR2(1500);
      v_Start     NUMBER := 1;
      v_Pos     NUMBER := 0;
  BEGIN
  
    v_String := REPLACE(in_String, '"', '');  
  
      -- determine first chuck of string 
      v_Pos := INSTR(v_String, in_Delimiter, v_Start);
    
      -- while there are chunks left, loop 
      WHILE (v_Pos != 0) LOOP
           -- create array
       v_Rows.extend;
           v_Rows( v_Rows.COUNT ) := MBR_TYPE(
                                    HSP$DELTA_EXTRA_PKG.Get_Member_Id_F(in_Member_Name => TRIM(SUBSTR(v_String, v_Start, v_Pos - v_Start))),
                                    TRIM(SUBSTR(v_String, v_Start, v_Pos - v_Start))
                                    );
           v_Start := v_Pos + 1; 
           v_Pos := INSTR(v_String, in_Delimiter, v_Start);    
      END LOOP;
    
    -- add in last item
    v_Rows.extend;
      v_Rows( v_Rows.COUNT ) := MBR_TYPE(
                                HSP$DELTA_EXTRA_PKG.Get_Member_Id_F(in_Member_Name => TRIM(SUBSTR(v_String, v_Start))),
                                TRIM(SUBSTR(v_String, v_Start))
                                );

      RETURN v_Rows;
  
  END Split_String_F;
  
  
  -- Процедура парсинга строки таблицы
  PROCEDURE Parse_Audit_P(in_Form_Name NVARCHAR2, 
                          in_Form_Audit NVARCHAR2,
                          in_User_Name NVARCHAR2,
                          in_Time_Posted DATE,
                          in_Old_Value NVARCHAR2,
                          in_New_Value NVARCHAR2
                          )
  IS
    v_Form_Id                      NUMBER;
    v_Form_Path                    NVARCHAR2(1500);
    v_Plan_Type_Id                 NUMBER;
    v_Plan_Type_Name               NVARCHAR2(255);
    v_Audit_Dims                   EXT_AUDIT_PKG.DIM_LIST_TYPE;
    v_Audit_Members                EXT_AUDIT_PKG.MBR_LIST_TYPE;
    v_Audit_Members_Path           EXT_AUDIT_PKG.MBR_PATH_LIST_TYPE;
  BEGIN
     
    /**********************************************************
    Получаем атрибуты формы Id, имя, тип плана
    *********************************************************/
    / Получаем Id формы */
    SELECT Get_Form_Id_F(in_Form_Name)
    INTO v_Form_Id
    FROM dual;
    /* Получаем имя типа плана */
    SELECT 
      hsp$delta_extra_pkg.get_form_path_f(in_form_name => in_Form_Name)
    INTO v_Form_Path
    FROM dual;  
     
 
    /**********************************************************
    Получаем атрибуты типа плана Id, имя
    *********************************************************/
    / Получаем имя типа плана */
    SELECT Get_Plan_Type_Name_F(in_Form_Name => in_Form_Name) 
    INTO v_Plan_Type_Name
    FROM dual;
    /* Получаем идентификатор типа плана */
    SELECT Get_Plan_Type_Id_F(in_Form_Name => in_Form_Name)
    INTO v_Plan_Type_Id
    FROM dual;

    -- Получаем структуру измерений
    v_Audit_Dims := HSP$DELTA_EXTRA_PKG.Get_Form_Dim_Layout_F(in_Form_Name);

    -- Парсим строку
    v_Audit_Members := HSP$DELTA_EXTRA_PKG.Split_String_F(in_Form_Audit, ',');

    -- Создаем объект вида список путей до членов
    v_Audit_Members_Path := EXT_AUDIT_PKG.MBR_PATH_LIST_TYPE();
    
    /************************************************************
      Debug Info
    ************************************************************/
    DBMS_OUTPUT.put_line('in_Application: ' || 'DEMO_PLAN');
    DBMS_OUTPUT.put_line('in_Form_Id: ' || v_Form_Id);
    DBMS_OUTPUT.put_line('in_Form_Name: ' || in_Form_Name);
    DBMS_OUTPUT.put_line('in_Form_Path: ' || v_Form_Path);  
    DBMS_OUTPUT.put_line('in_Plan_Type_Id: ' || v_Plan_Type_Id);
    DBMS_OUTPUT.put_line('in_Plan_Type_Name: ' || v_Plan_Type_Name);
    DBMS_OUTPUT.put_line('in_User_Name: ' || in_User_Name);
    DBMS_OUTPUT.put_line('in_Time_Posted: ' || in_Time_Posted);
    DBMS_OUTPUT.put_line('in_Old_Value: ' || in_Old_Value);
    DBMS_OUTPUT.put_line('in_New_Value: ' || in_New_Value);
    
    DBMS_OUTPUT.put_line('Audit Dims Count:' || TO_CHAR(v_Audit_Dims.COUNT));
    DBMS_OUTPUT.put_line('Audit Mbrs Count:' || TO_CHAR(v_Audit_Members.COUNT));
    DBMS_OUTPUT.put_line('Audit Mbrs:' || in_Form_Audit);
    
    FOR i IN v_Audit_Dims.FIRST .. v_Audit_Dims.LAST
    LOOP
       DBMS_OUTPUT.put_line('Dim_Id(' || TO_CHAR(i) || ')' || TO_CHAR(v_Audit_Dims(i).Dim_Id));
       DBMS_OUTPUT.put_line('Dim_Name(' || TO_CHAR(i) || ')' || TO_CHAR(v_Audit_Dims(i).Dim_Name));
    END LOOP;
    
    FOR i IN v_Audit_Members.FIRST .. v_Audit_Members.LAST
    LOOP
       DBMS_OUTPUT.put_line('Mbr_Id(' || TO_CHAR(i) || ')' || TO_CHAR(v_Audit_Members(i).Mbr_Id));
       DBMS_OUTPUT.put_line('Mbr_Name(' || TO_CHAR(i) || ')' || TO_CHAR(v_Audit_Members(i).Mbr_Name));
    END LOOP;
    /***********************************************************
      Debug Info end
    ***********************************************************/
    
    -- Call the procedure
    EXT_AUDIT_PKG.Add_Audit_Info_P(
       in_Application    => 'DemoPlan',
       in_Form_Id        => v_Form_Id,
       in_Form_Name      => in_Form_Name,
       in_Form_Path      => v_Form_Path,
       in_Plan_Type_Id   => v_Plan_Type_Id,
       in_Plan_Type_Name => v_Plan_Type_Name,
       in_User_Name      => in_User_Name,
       in_Time_Posted    => in_Time_Posted,
       in_Old_Value      => in_Old_Value,
       in_New_Value      => in_New_Value,
       in_Dims           => v_Audit_Dims,
       in_Members        => v_Audit_Members,
       in_Member_Path    => v_Audit_Members_Path
    );
    
    
   -- exception handlers begin
   EXCEPTION 
     WHEN OTHERS THEN -- handles all other errors
       DBMS_OUTPUT.put_line('Parse_Audit_P error: ' || SQLERRM); 
  
  END Parse_Audit_P;
  
  -- Процедура записи аудита изменения строки таблицы
  PROCEDURE Exec_Parse_Audit_P(in_RowId ROWID)
  IS
    v_Job_Id         NUMBER;
    
    v_Form_Name      NVARCHAR2(500);
    v_Form_Audit     NVARCHAR2(500);
    v_User_Name      NVARCHAR2(100);
    v_Time_Posted    DATE;
    v_Old_Value      NVARCHAR2(1500);
    v_New_Value      NVARCHAR2(1500);
  BEGIN

    SELECT
      HSP_AUDIT_RECORDS.ID_1,
      HSP_AUDIT_RECORDS.ID_2,
      HSP_AUDIT_RECORDS.USER_NAME,
      HSP_AUDIT_RECORDS.TIME_POSTED,
      HSP_AUDIT_RECORDS.OLD_VAL,
      HSP_AUDIT_RECORDS.NEW_VAL
    INTO
      v_Form_Name,
      v_Form_Audit,
      v_User_Name,
      v_Time_Posted,
      v_Old_Value,
      v_New_Value
    FROM hsp_audit_records 
    WHERE hsp_audit_records.rowid = in_RowId;
    
    Parse_Audit_P(v_Form_Name, v_Form_Audit, v_User_Name, v_Time_Posted, v_Old_Value, v_New_Value);
    /*
    SELECT hsp$job_seq.nextval
    INTO v_Job_Id
    FROM dual;
    
    DBMS_SCHEDULER.CREATE_JOB(job_name            => 'Parse_Audit_' || TO_CHAR(v_Job_Id),
                              job_type            => 'STORED_PROCEDURE',
                              job_action          => 'HSP$DELTA_EXTRA_PKG.Parse_Audit_P',
                              number_of_arguments => 1,
                              comments            => 'Ïðîöåäóðà ïàðñèíãà àóäèòà'
                              );
    
    DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE('Parse_Audit_' || TO_CHAR(v_Job_Id),
                                          1,
                                          TO_CHAR(in_RowId));
                                          
    DBMS_SCHEDULER.ENABLE('Parse_Audit_' || TO_CHAR(v_Job_Id));
    */
      
  END Exec_Parse_Audit_P;

END HSP$DELTA_EXTRA_PKG; 

/

