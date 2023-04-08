--------------------------------------------------------
--  DDL for Type DIM_TYPE
--------------------------------------------------------

  CREATE OR REPLACE TYPE "DIM_TYPE" as object
(
  -- Author  : Aleksey Movchanyuk
  -- Created : 29.09.2011 10:51:24
  -- Purpose : 
  
  -- Attributes
  Dim_Id      NUMBER,
  Dim_Name    NVARCHAR2(80)
  
) 


/

--------------------------------------------------------
--  DDL for Type MBR_TYPE
--------------------------------------------------------

  CREATE OR REPLACE TYPE "MBR_TYPE" as object
(
  -- Author  : Aleksey Movchanyuk
  -- Created : 29.09.2011 10:51:24
  -- Purpose :

  -- Attributes
  Mbr_Id      NUMBER,
  Mbr_Name    NVARCHAR2(80)

) 


/

--------------------------------------------------------
--  DDL for Sequence EXT_AUDIT_DETAIL_SEQ
--------------------------------------------------------

CREATE SEQUENCE  "EXT_AUDIT_DETAIL_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1040 CACHE 20 NOORDER  NOCYCLE ;

--------------------------------------------------------
--  DDL for Sequence EXT_AUDIT_SEQ
--------------------------------------------------------

CREATE SEQUENCE  "EXT_AUDIT_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 120 CACHE 20 NOORDER  NOCYCLE ;

--------------------------------------------------------
--  DDL for Table EXT_AUDIT
--------------------------------------------------------

CREATE TABLE "EXT_AUDIT" 
(	
"AUDIT_ID" NUMBER, 
"AUDIT_APPLICATION" NVARCHAR2(255), 
"AUDIT_FORM_ID" NUMBER, 
"AUDIT_FORM_NAME" NVARCHAR2(80), 
"AUDIT_FORM_PATH" NVARCHAR2(1500), 
"AUDIT_PLAN_TYPE_ID" NUMBER, 
"AUDIT_PLAN_TYPE_NAME" NVARCHAR2(80), 
"AUDIT_USER_NAME" NVARCHAR2(100), 
"AUDIT_TIME_POSTED" DATE, 
"AUDIT_OLD_VALUE" NVARCHAR2(1500), 
"AUDIT_NEW_VALUE" NVARCHAR2(1500)
) ;


COMMENT ON COLUMN "EXT_AUDIT"."AUDIT_ID" IS 'Id';

COMMENT ON COLUMN "EXT_AUDIT"."AUDIT_APPLICATION" IS '��� ����������';

COMMENT ON COLUMN "EXT_AUDIT"."AUDIT_FORM_ID" IS '��� �����';

COMMENT ON COLUMN "EXT_AUDIT"."AUDIT_FORM_NAME" IS '��� �����';

COMMENT ON COLUMN "EXT_AUDIT"."AUDIT_FORM_PATH" IS '������ ���� � �����';

COMMENT ON COLUMN "EXT_AUDIT"."AUDIT_PLAN_TYPE_ID" IS '��� ���� �����';

COMMENT ON COLUMN "EXT_AUDIT"."AUDIT_PLAN_TYPE_NAME" IS '�������� ���� �����';

COMMENT ON COLUMN "EXT_AUDIT"."AUDIT_USER_NAME" IS '������������ ������� ���� ���������';

COMMENT ON COLUMN "EXT_AUDIT"."AUDIT_TIME_POSTED" IS '����� ���������';

COMMENT ON COLUMN "EXT_AUDIT"."AUDIT_OLD_VALUE" IS '������ �������� �� ���������';

COMMENT ON COLUMN "EXT_AUDIT"."AUDIT_NEW_VALUE" IS '����� �������� ����� ���������';

COMMENT ON TABLE "EXT_AUDIT"  IS '������� �������� ����� ���������� Hyperion';

--------------------------------------------------------
--  DDL for Table EXT_AUDIT_DETAIL
--------------------------------------------------------

CREATE TABLE "EXT_AUDIT_DETAIL" 
(	
    "AUDITD_ID" NUMBER, 
    "AUDITD_AUDIT" NUMBER, 
    "AUDITD_DIMENSION_ID" NUMBER, 
    "AUDITD_DIMENSION_NAME" NVARCHAR2(80), 
    "AUDITD_MEMBER_ID" NUMBER, 
    "AUDITD_MEMBER_NAME" NVARCHAR2(80), 
    "AUDITD_MEMBER_PATH" NVARCHAR2(1500)
) ;


COMMENT ON COLUMN "EXT_AUDIT_DETAIL"."AUDITD_ID" IS 'Id ������';

COMMENT ON COLUMN "EXT_AUDIT_DETAIL"."AUDITD_AUDIT" IS '������ �� ������ � ������� EXT_AUDIT';

COMMENT ON COLUMN "EXT_AUDIT_DETAIL"."AUDITD_DIMENSION_ID" IS '��� ���������';

COMMENT ON COLUMN "EXT_AUDIT_DETAIL"."AUDITD_DIMENSION_NAME" IS '��� ���������';

COMMENT ON COLUMN "EXT_AUDIT_DETAIL"."AUDITD_MEMBER_ID" IS '��� ��������';

COMMENT ON COLUMN "EXT_AUDIT_DETAIL"."AUDITD_MEMBER_NAME" IS '��� ��������';

COMMENT ON COLUMN "EXT_AUDIT_DETAIL"."AUDITD_MEMBER_PATH" IS '���� � ��������';

COMMENT ON TABLE "EXT_AUDIT_DETAIL"  IS '����������� ������ ������';

--------------------------------------------------------
--  Constraints for Table EXT_AUDIT
--------------------------------------------------------

ALTER TABLE "EXT_AUDIT" ADD CONSTRAINT "AUDIT_PK" PRIMARY KEY ("AUDIT_ID") ENABLE;

ALTER TABLE "EXT_AUDIT" MODIFY ("AUDIT_ID" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table EXT_AUDIT_DETAIL
--------------------------------------------------------

ALTER TABLE "EXT_AUDIT_DETAIL" ADD CONSTRAINT "AUDIT_DETAIL_PK" PRIMARY KEY ("AUDITD_ID") ENABLE;

ALTER TABLE "EXT_AUDIT_DETAIL" MODIFY ("AUDITD_ID" NOT NULL ENABLE);
--------------------------------------------------------
--  DDL for Index AUDIT_DETAIL_PK
--------------------------------------------------------

CREATE UNIQUE INDEX "AUDIT_DETAIL_PK" ON "EXT_AUDIT_DETAIL" ("AUDITD_ID") 
;
--------------------------------------------------------
--  DDL for Index AUDIT_PK
--------------------------------------------------------

CREATE UNIQUE INDEX "AUDIT_PK" ON "EXT_AUDIT" ("AUDIT_ID") 
;

--------------------------------------------------------
--  Ref Constraints for Table EXT_AUDIT_DETAIL
--------------------------------------------------------

ALTER TABLE "EXT_AUDIT_DETAIL" ADD CONSTRAINT "AUDIT_DETAIL_REF_AUDIT_FK" FOREIGN KEY ("AUDITD_AUDIT")
    REFERENCES "EXT_AUDIT" ("AUDIT_ID") ENABLE;
