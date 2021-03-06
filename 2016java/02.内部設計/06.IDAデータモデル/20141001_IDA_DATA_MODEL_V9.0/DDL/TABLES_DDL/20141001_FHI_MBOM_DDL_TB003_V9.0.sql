--<ScriptOptions statementTerminator=";"/>

CREATE GLOBAL TEMPORARY TABLE "GT003001" (
		"ECS_NO" CHAR(11) NOT NULL, 
		"ECS_REV_NO" CHAR(1) NOT NULL, 
		"REPR_SIMUL_CLASS" CHAR(1) NOT NULL
	)
	ON COMMIT PRESERVE ROWS
	NOT LOGGED ON ROLLBACK DELETE ROWS;

CREATE TABLE "TB003001" (
		"ECS_NO" CHAR(11) NOT NULL, 
		"ECS_REV_NO" CHAR(1) NOT NULL, 
		"ECS_SERIES" CHAR(4) NOT NULL, 
		"SECTION_CODE" CHAR(1) NOT NULL, 
		"SERIAL_NO" CHAR(4) NOT NULL, 
		"REPR_SIMUL_CLASS" CHAR(1) NOT NULL, 
		"ECS_TITLE_JP" VARCHAR(250) NOT NULL, 
		"ECS_TITLE_EN" VARCHAR(300) NOT NULL, 
		"ECS_STATUS" CHAR(2) NOT NULL, 
		"ECS_PUBLIC_STATUS" CHAR(2) NOT NULL, 
		"PRECEDE_FLAG" CHAR(1) NOT NULL, 
		"DESIGN_DEPARTMENT" VARCHAR(90) NOT NULL, 
		"DESIGN_SECTION" VARCHAR(90) NOT NULL, 
		"ARRANGE_CLASS" CHAR(1) NOT NULL, 
		"ATTENTION" CHAR(1) NOT NULL, 
		"URGENCY" CHAR(1) NOT NULL, 
		"DISTRIBUTE_CLASS" CHAR(30) NOT NULL, 
		"APPLIED_MODEL" CHAR(30) NOT NULL, 
		"VEHICLE_CHECK" CHAR(1) NOT NULL, 
		"EG_TM_CHECK" CHAR(1) NOT NULL, 
		"REASON" CHAR(1) NOT NULL, 
		"IMPORTANCE" CHAR(1) NOT NULL, 
		"SYNCHRONOUS_CHANGE" CHAR(1) NOT NULL, 
		"RECEIVED_DATE" DATE NOT NULL, 
		"OVERFLOW_REPR_ECS_NO" CHAR(11) NOT NULL, 
		"ECS_ISSUE_DATE" DATE NOT NULL, 
		"GJ_ECS_RECEIVE_DATE" DATE NOT NULL, 
		"ECS_ISSUE_MEMBER" VARCHAR(30) NOT NULL, 
		"DESIGN_PHONE_NO" CHAR(4) NOT NULL, 
		"REGULATION" CHAR(7) NOT NULL, 
		"EC_DEMAND_DEPT" VARCHAR(30) NOT NULL, 
		"EC_APPLY" CHAR(1) NOT NULL, 
		"ARRANGE_REMARKS" VARCHAR(3000) NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB003002" (
		"REPR_ECS_NO" CHAR(11) NOT NULL, 
		"REPR_ECS_REV_NO" CHAR(1) NOT NULL, 
		"SIMULTANEOUS_ECS_NO" CHAR(11) NOT NULL, 
		"SIMULTANEOUS_ECS_ORDER" SMALLINT NOT NULL, 
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

CREATE TABLE "TB003003" (
		"REPR_ECS_NO" CHAR(11) NOT NULL, 
		"REPR_ECS_REV_NO" CHAR(1) NOT NULL, 
		"RELATED_ECS_NO" CHAR(11) NOT NULL, 
		"RELATED_ECS_ORDER" SMALLINT NOT NULL, 
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

CREATE TABLE "TB003004" (
		"ECS_NO" CHAR(11) NOT NULL, 
		"ECS_REV_NO" CHAR(1) NOT NULL, 
		"LIST_CODE" CHAR(4) NOT NULL, 
		"BLOCK_NO" CHAR(4) NOT NULL, 
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

CREATE TABLE "TB003005" (
		"ECS_SERIES" CHAR(4) NOT NULL, 
		"ECS_MEETING_DATE" DATE NOT NULL, 
		"ECS_MTG_LOCATION" CHAR(4) NOT NULL, 
		"ECS_MEETING_NAME" VARCHAR(200) NOT NULL, 
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

CREATE TABLE "TB003006" (
		"ECS_MTG_LOCATION" CHAR(4) NOT NULL, 
		"ECS_MTG_LOC_NAME" VARCHAR(200) NOT NULL, 
		"LOCATION_CODE" CHAR(1) NOT NULL, 
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

CREATE TABLE "TB003007" (
		"ECS_SERIES" CHAR(4) NOT NULL, 
		"ECS_MEETING_DATE" DATE NOT NULL, 
		"ECS_MTG_LOCATION" CHAR(4) NOT NULL, 
		"ECS_NO" CHAR(11) NOT NULL, 
		"ECS_REV_NO" CHAR(1) NOT NULL, 
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

CREATE TABLE "TB003008" (
		"ECS_NO" CHAR(11) NOT NULL, 
		"ECS_REV_NO" CHAR(1) NOT NULL, 
		"APPLIED_MODEL_CODE" CHAR(5) NOT NULL, 
		"DESTINATION" CHAR(1) NOT NULL, 
		"IMPL_DATE_INPUT_COL" CHAR(1) NOT NULL, 
		"APPLIED_MODEL" CHAR(3) NOT NULL, 
		"ECS_IMPL_REV_NO" CHAR(3) NOT NULL, 
		"DISPLAY_ORDER" SMALLINT NOT NULL, 
		"DGN_REQD_START_DATE" CHAR(2) NOT NULL, 
		"ARR_REQD_START_DATE" CHAR(2) NOT NULL, 
		"DECIDED_IMPL_DATE" DATE NOT NULL, 
		"PARTIAL_PENDING_FLAG" CHAR(1) NOT NULL, 
		"PENDING_DECIDED_DATE" DATE NOT NULL, 
		"IMPLEMENT_EVENT_ID" CHAR(6) NOT NULL, 
		"ECS_ISSUE_DATE" DATE NOT NULL, 
		"IMPL_DATE_DECIDED_DATE" DATE NOT NULL, 
		"ECS_MEETING_DATE" DATE NOT NULL, 
		"ECS_MTG_DATE_STATUS" CHAR(1) NOT NULL, 
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

CREATE TABLE "TB003009" (
		"ECS_NO" CHAR(11) NOT NULL, 
		"ECS_REV_NO" CHAR(1) NOT NULL, 
		"ECS_ISSUE_REV_NO" CHAR(3) NOT NULL, 
		"ECS_ISSUE_DATE" DATE NOT NULL, 
		"ECS_IMPL_REV_NO" CHAR(3) NOT NULL, 
		"ECS_MEETING_DATE" DATE NOT NULL, 
		"ECS_MTG_DATE_STATUS" CHAR(1) NOT NULL, 
		"DUMMY_ISSUE_FLAG" CHAR(1) NOT NULL, 
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

CREATE TABLE "TB003011" (
		"EVENT_ID" CHAR(6) NOT NULL, 
		"PARENT_EVENT_ID" CHAR(6) NOT NULL, 
		"EVENT_NAME" VARCHAR(100) NOT NULL, 
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

CREATE TABLE "TB003012" (
		"MC_DEV_MODEL_CODE" CHAR(4) NOT NULL, 
		"EVENT_ID" CHAR(6) NOT NULL, 
		"PROD_BASE_CODE" CHAR(1) NOT NULL, 
		"BODY_UNIT_DIV" CHAR(1) NOT NULL, 
		"EVENT_DATE" DATE NOT NULL, 
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

CREATE TABLE "TB003013" (
		"ECS_NO" CHAR(11) NOT NULL, 
		"ECS_REV_NO" CHAR(1) NOT NULL, 
		"FILE_NAME" VARCHAR(256) NOT NULL, 
		"FILE_DATA" BLOB NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

ALTER TABLE "TB003001" ADD CONSTRAINT "TB003001_PK" PRIMARY KEY
	("ECS_REV_NO", 
	 "ECS_NO");

ALTER TABLE "TB003002" ADD CONSTRAINT "TB003002_PK" PRIMARY KEY
	("REPR_ECS_NO", 
	 "REPR_ECS_REV_NO", 
	 "SIMULTANEOUS_ECS_NO");

ALTER TABLE "TB003003" ADD CONSTRAINT "TB003003_PK" PRIMARY KEY
	("REPR_ECS_NO", 
	 "REPR_ECS_REV_NO", 
	 "RELATED_ECS_NO");

ALTER TABLE "TB003004" ADD CONSTRAINT "TB003004_PK" PRIMARY KEY
	("ECS_NO", 
	 "ECS_REV_NO", 
	 "LIST_CODE", 
	 "BLOCK_NO");

ALTER TABLE "TB003005" ADD CONSTRAINT "TB003005_PK" PRIMARY KEY
	("ECS_SERIES", 
	 "ECS_MEETING_DATE", 
	 "ECS_MTG_LOCATION");

ALTER TABLE "TB003006" ADD CONSTRAINT "TB003006_PK" PRIMARY KEY
	("ECS_MTG_LOCATION");

ALTER TABLE "TB003007" ADD CONSTRAINT "TB003007_PK" PRIMARY KEY
	("ECS_SERIES", 
	 "ECS_MEETING_DATE", 
	 "ECS_MTG_LOCATION", 
	 "ECS_NO", 
	 "ECS_REV_NO");

ALTER TABLE "TB003008" ADD CONSTRAINT "TB003008_PK" PRIMARY KEY
	("ECS_NO", 
	 "ECS_REV_NO", 
	 "APPLIED_MODEL_CODE", 
	 "DESTINATION", 
	 "IMPL_DATE_INPUT_COL", 
	 "APPLIED_MODEL", 
	 "ECS_IMPL_REV_NO");

ALTER TABLE "TB003009" ADD CONSTRAINT "TB003009_PK" PRIMARY KEY
	("ECS_NO", 
	 "ECS_REV_NO", 
	 "ECS_ISSUE_REV_NO");

ALTER TABLE "TB003011" ADD CONSTRAINT "TB003011_PK" PRIMARY KEY
	("EVENT_ID");

ALTER TABLE "TB003012" ADD CONSTRAINT "TB003012_PK" PRIMARY KEY
	("MC_DEV_MODEL_CODE", 
	 "EVENT_ID", 
	 "PROD_BASE_CODE");

ALTER TABLE "TB003013" ADD CONSTRAINT "TB003013_PK" PRIMARY KEY
	("ECS_NO", 
	 "ECS_REV_NO");

CREATE VIEW "VW003001" AS
--別添VW003001.sql参照。;

CREATE VIEW "VW003002" AS
--別添VW003002.sql参照。;

