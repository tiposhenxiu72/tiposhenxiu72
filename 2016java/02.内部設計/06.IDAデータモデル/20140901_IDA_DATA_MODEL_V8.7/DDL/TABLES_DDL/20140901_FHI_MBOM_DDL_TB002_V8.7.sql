--<ScriptOptions statementTerminator=";"/>

CREATE TABLE "TB002001" (
		"REPR_ECS_NO" CHAR(11) NOT NULL, 
		"ECS_REV_NO" CHAR(1) NOT NULL, 
		"DRAWING_NO" CHAR(15) NOT NULL, 
		"DRAWING_REV_NO" CHAR(2) NOT NULL, 
		"DRAWING_ORDER" SMALLINT NOT NULL, 
		"DRAWING_NAME" CHAR(20) NOT NULL, 
		"DRAWING_CLASS" CHAR(1) NOT NULL, 
		"REPAIR_PARTS" CHAR(1) NOT NULL, 
		"MFR_LOCAL_CLASS" CHAR(1) NOT NULL, 
		"DWG_JDG_CODE" CHAR(1) NOT NULL, 
		"PAGE_NUMBER" CHAR(2) NOT NULL, 
		"SPEC_DWG_REQ" CHAR(1) NOT NULL, 
		"APPLY_CHG_DESCRIPTION" CHAR(100) NOT NULL, 
		"SCRAPPING_DIE" CHAR(1) NOT NULL, 
		"DIE_MODIFICATION" CHAR(1) NOT NULL, 
		"COST_VARIATION" CHAR(1) NOT NULL, 
		"MASS_VARIATION" CHAR(1) NOT NULL, 
		"OVERFLOW_FLAG" CHAR(1) NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB002002" (
		"DRAWING_NO" CHAR(15) NOT NULL, 
		"DRAWING_REV_NO" CHAR(2) NOT NULL, 
		"START_DATE" DATE NOT NULL, 
		"END_DATE" DATE NOT NULL, 
		"DRAWING_SERIES" CHAR(4) NOT NULL, 
		"BLOCK_NO" CHAR(4) NOT NULL, 
		"DRAWER" CHAR(1) NOT NULL, 
		"DESIGNER" CHAR(11) NOT NULL, 
		"DRAWING_CODE" CHAR(1) NOT NULL, 
		"DWG_JDG_CODE" CHAR(1) NOT NULL, 
		"PAGE_NUMBER" CHAR(2) NOT NULL, 
		"APPLY" CHAR(160) NOT NULL, 
		"CONFIDENTIAL_CLASS" CHAR(1) NOT NULL, 
		"INTERCHANGEABILITY" CHAR(1) NOT NULL, 
		"IMPORTANCE_SAFTY" CHAR(1) NOT NULL, 
		"REPAIR_PARTS_CLASS" CHAR(1) NOT NULL, 
		"DRAWING_CLASS" CHAR(1) NOT NULL, 
		"ISSUE_REASON" CHAR(1) NOT NULL, 
		"TITLE_NAME" CHAR(17) NOT NULL, 
		"RECEIVED_DATE" DATE NOT NULL, 
		"SIA_TO_SEND_FLAG" CHAR(1) NOT NULL, 
		"SIA_SEND_DATE" DATE NOT NULL, 
		"SEND_CHECK_OFF" CHAR(1) NOT NULL, 
		"MAIN_ECS_NO" CHAR(11) NOT NULL, 
		"REPR_OF_MAIN_ECS_NO" CHAR(11) NOT NULL, 
		"REMARKS" VARCHAR(600) NOT NULL, 
		"TCMA_DIST_COMMENT" VARCHAR(600) NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB002003" (
		"DRAWING_NO" CHAR(15) NOT NULL, 
		"DRAWING_REV_NO" CHAR(2) NOT NULL, 
		"SUPPLIER_CODE" CHAR(4) NOT NULL, 
		"ORD_SEC_REV_NO" CHAR(3) NOT NULL, 
		"ORD_SEC_SND_APRV_DATE" DATE NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB002004" (
		"DRAWING_NO" CHAR(15) NOT NULL, 
		"DRAWING_REV_NO" CHAR(2) NOT NULL, 
		"SUPPLIED_SECTION" CHAR(4) NOT NULL, 
		"SUP_SEC_REV_NO" CHAR(3) NOT NULL, 
		"SUP_SEC_DST_APRV_DATE" DATE NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB002005" (
		"DRAWING_NO" CHAR(15) NOT NULL, 
		"DRAWING_REV_NO" CHAR(2) NOT NULL, 
		"REF_DISTRIBUTED" CHAR(4) NOT NULL, 
		"REF_DIST_REV_NO" CHAR(3) NOT NULL, 
		"REF_DIST_DST_APRV_DATE" DATE NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB002006" (
		"DRAWING_NO" CHAR(15) NOT NULL, 
		"DRAWING_REV_NO" CHAR(2) NOT NULL, 
		"SEND_REV_NO" CHAR(3) NOT NULL, 
		"SIA_SEND_DATE" DATE NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB002007" (
		"DRAWING_NO" CHAR(15) NOT NULL, 
		"DRAWING_REV_NO" CHAR(2) NOT NULL, 
		"NOTIFY_REV_NO" CHAR(3) NOT NULL, 
		"NOTIFY_DATE" DATE NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB002008" (
		"DRAWING_NO" CHAR(15) NOT NULL, 
		"DRAWING_REV_NO" CHAR(2) NOT NULL, 
		"TCMA_DELIVER_REV_NO" CHAR(3) NOT NULL, 
		"TCMA_DELIVER_DATE" DATE NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB002009" (
		"DRAWING_NO" CHAR(15) NOT NULL, 
		"DRAWING_REV_NO" CHAR(2) NOT NULL, 
		"TCMA_RECEIVE_REV_NO" CHAR(3) NOT NULL, 
		"TCMA_RECEIVE_DATE" DATE NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB002010" (
		"SYSMTEM_ID" CHAR(4) NOT NULL, 
		"LATEST_CHECK_DATE" DATE NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB002011" (
		"MC_DEV_MODEL_CODE" CHAR(4) NOT NULL, 
		"DWG_CHECK_FLAG" CHAR(1) NOT NULL, 
		"DRAWING_QUANTITY" SMALLINT NOT NULL, 
		"CHECK_DATE" DATE NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB002012" (
		"PARTS_NO" CHAR(15) NOT NULL, 
		"CHECK_DATE" DATE NOT NULL, 
		"NOTIFY_DATE" DATE NOT NULL, 
		"ISSUE_STATUS" CHAR(1) NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB002013" (
		"PARTS_NO" CHAR(15) NOT NULL, 
		"PARENT_PARTS_NO" CHAR(15) NOT NULL, 
		"CHECK_DATE" DATE NOT NULL, 
		"DWG_JDG_CODE" CHAR(1) NOT NULL, 
		"SUB_PARTS_ISSUE_STATUS" CHAR(1) NOT NULL, 
		"REPR_FINAL_PARTS_NO" CHAR(15) NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB002014" (
		"PARENT_PARTS_NO" CHAR(15) NOT NULL, 
		"MC_DEV_MODEL_CODE" CHAR(4) NOT NULL, 
		"CHECK_DATE" DATE NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB002015" (
		"LIST_CODE" CHAR(4) NOT NULL, 
		"NEED_TO_SEND_FLAG" CHAR(1) NOT NULL, 
		"CHECK_DATE" DATE NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB002016" (
		"DRAWING_NO" CHAR(15) NOT NULL, 
		"DRAWING_REV_NO" CHAR(2) NOT NULL, 
		"MC_DEV_MODEL_CODE" CHAR(4) NOT NULL, 
		"CHECK_DATE" DATE NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB002017" (
		"PARTS_NO" CHAR(15) NOT NULL, 
		"PROD_BASE_CODE" CHAR(1) NOT NULL, 
		"SOURCE_TYPE" CHAR(1) NOT NULL, 
		"SUPPLIER_CODE" CHAR(4) NOT NULL, 
		"SUPPLIER_ADOPT_DATE" DATE NOT NULL, 
		"REMARKS" VARCHAR(600) NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB002018" (
		"PROD_BASE_CODE" CHAR(1) NOT NULL, 
		"SUPPLIER_CODE" CHAR(4) NOT NULL, 
		"INTER_EXTER_CLASS" CHAR(1) NOT NULL, 
		"REMARKS" VARCHAR(600) NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB002019" (
		"DRAWING_NO" CHAR(15) NOT NULL, 
		"DRAWING_REV_NO" CHAR(2) NOT NULL, 
		"SUPPLIER_CODE" CHAR(4) NOT NULL, 
		"PURCHASE_REV_NO" CHAR(3) NOT NULL, 
		"ARRANGEMENT_DATE" CHAR(5) NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB002020" (
		"ECS_PROCESS_ID" CHAR(12) NOT NULL, 
		"ECS_NO" CHAR(11) NOT NULL, 
		"ECS_REV_NO" CHAR(1) NOT NULL, 
		"PRECEDE_PROCESS_ID" CHAR(12) NOT NULL, 
		"DATA_RECEIVE_STATUS" CHAR(1) NOT NULL, 
		"FACTORY_DATA_STATUS" CHAR(1) NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

ALTER TABLE "TB002001" ADD CONSTRAINT "TB002001_PK" PRIMARY KEY
	("REPR_ECS_NO", 
	 "ECS_REV_NO", 
	 "DRAWING_NO");

ALTER TABLE "TB002002" ADD CONSTRAINT "TB002002_PK" PRIMARY KEY
	("DRAWING_NO", 
	 "DRAWING_REV_NO");

ALTER TABLE "TB002003" ADD CONSTRAINT "TB002003_PK" PRIMARY KEY
	("DRAWING_NO", 
	 "DRAWING_REV_NO", 
	 "SUPPLIER_CODE", 
	 "ORD_SEC_REV_NO");

ALTER TABLE "TB002004" ADD CONSTRAINT "TB002004_PK" PRIMARY KEY
	("DRAWING_NO", 
	 "DRAWING_REV_NO", 
	 "SUPPLIED_SECTION", 
	 "SUP_SEC_REV_NO");

ALTER TABLE "TB002005" ADD CONSTRAINT "TB002005_PK" PRIMARY KEY
	("DRAWING_NO", 
	 "DRAWING_REV_NO", 
	 "REF_DISTRIBUTED", 
	 "REF_DIST_REV_NO");

ALTER TABLE "TB002006" ADD CONSTRAINT "TB002006_PK" PRIMARY KEY
	("DRAWING_NO", 
	 "DRAWING_REV_NO", 
	 "SEND_REV_NO");

ALTER TABLE "TB002007" ADD CONSTRAINT "TB002007_PK" PRIMARY KEY
	("DRAWING_NO", 
	 "DRAWING_REV_NO", 
	 "NOTIFY_REV_NO");

ALTER TABLE "TB002008" ADD CONSTRAINT "TB002008_PK" PRIMARY KEY
	("DRAWING_NO", 
	 "DRAWING_REV_NO", 
	 "TCMA_DELIVER_REV_NO");

ALTER TABLE "TB002009" ADD CONSTRAINT "TB002009_PK" PRIMARY KEY
	("DRAWING_NO", 
	 "DRAWING_REV_NO", 
	 "TCMA_RECEIVE_REV_NO");

ALTER TABLE "TB002010" ADD CONSTRAINT "TB002010_PK" PRIMARY KEY
	("SYSMTEM_ID");

ALTER TABLE "TB002011" ADD CONSTRAINT "TB002011_PK" PRIMARY KEY
	("MC_DEV_MODEL_CODE");

ALTER TABLE "TB002012" ADD CONSTRAINT "TB002012_PK" PRIMARY KEY
	("PARTS_NO", 
	 "CHECK_DATE");

ALTER TABLE "TB002013" ADD CONSTRAINT "TB002013_PK" PRIMARY KEY
	("PARTS_NO", 
	 "PARENT_PARTS_NO", 
	 "CHECK_DATE");

ALTER TABLE "TB002014" ADD CONSTRAINT "TB002014_PK" PRIMARY KEY
	("PARENT_PARTS_NO", 
	 "MC_DEV_MODEL_CODE", 
	 "CHECK_DATE");

ALTER TABLE "TB002015" ADD CONSTRAINT "TB002015_PK" PRIMARY KEY
	("LIST_CODE");

ALTER TABLE "TB002016" ADD CONSTRAINT "TB002016_PK" PRIMARY KEY
	("DRAWING_NO", 
	 "DRAWING_REV_NO", 
	 "MC_DEV_MODEL_CODE");

ALTER TABLE "TB002017" ADD CONSTRAINT "TB002017_PK" PRIMARY KEY
	("PARTS_NO", 
	 "PROD_BASE_CODE", 
	 "SOURCE_TYPE", 
	 "SUPPLIER_CODE");

ALTER TABLE "TB002018" ADD CONSTRAINT "TB002018_PK" PRIMARY KEY
	("PROD_BASE_CODE", 
	 "SUPPLIER_CODE");

ALTER TABLE "TB002019" ADD CONSTRAINT "TB002019_PK" PRIMARY KEY
	("DRAWING_NO", 
	 "DRAWING_REV_NO", 
	 "SUPPLIER_CODE", 
	 "PURCHASE_REV_NO");

ALTER TABLE "TB002020" ADD CONSTRAINT "TB002020_PK" PRIMARY KEY
	("ECS_PROCESS_ID");

