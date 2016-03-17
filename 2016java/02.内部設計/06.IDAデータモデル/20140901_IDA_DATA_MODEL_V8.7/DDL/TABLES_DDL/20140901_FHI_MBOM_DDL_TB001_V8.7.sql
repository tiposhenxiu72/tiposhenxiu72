--<ScriptOptions statementTerminator=";"/>

CREATE TABLE "TB001001" (
		"PARTS_NO" CHAR(15) NOT NULL, 
		"PARTS_FUNCTION" CHAR(5) NOT NULL, 
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

CREATE TABLE "TB001002" (
		"PARTS_NO" CHAR(15) NOT NULL, 
		"ENGINEERING_PN_REV_NO" CHAR(3) NOT NULL, 
		"DRAWING_NO" CHAR(15) NOT NULL, 
		"DRAWING_REV_NO" CHAR(2) NOT NULL, 
		"START_DATE" DATE NOT NULL, 
		"END_DATE" DATE NOT NULL, 
		"AUTOMATIC_SYMBOL" CHAR(1) NOT NULL, 
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

CREATE TABLE "TB001003" (
		"PARTS_NO" CHAR(15) NOT NULL, 
		"PARTS_PROP_REV_NO" CHAR(3) NOT NULL, 
		"DRAWING_NO" CHAR(15) NOT NULL, 
		"START_DATE" DATE NOT NULL, 
		"END_DATE" DATE NOT NULL, 
		"DRAWING_SERIES" CHAR(4) NOT NULL, 
		"DRAWING_BLOCK_NO" CHAR(4) NOT NULL, 
		"DRAWING_OVER" CHAR(1) NOT NULL, 
		"DRAWING_COL" CHAR(1) NOT NULL, 
		"PARTS_NAME" CHAR(20) NOT NULL, 
		"SUPPL_NAME" CHAR(3) NOT NULL, 
		"DRAWING_SYMBOL" CHAR(1) NOT NULL, 
		"MASS" VARCHAR(6) NOT NULL, 
		"METAL_MASS" VARCHAR(6) NOT NULL, 
		"DRAWING_CLASS" CHAR(1) NOT NULL, 
		"THICKNESS" CHAR(5) NOT NULL, 
		"MATERIAL" VARCHAR(48) NOT NULL, 
		"AUTOMATIC_SYMBOL" CHAR(1) NOT NULL, 
		"REPR_OF_MAIN_ECS_NO" CHAR(11) NOT NULL, 
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

CREATE TABLE "TB001004" (
		"PARENT_PARTS_NO" CHAR(15) NOT NULL, 
		"SUB_PARTS_NO" CHAR(15) NOT NULL, 
		"ENGINEERING_PS_REV_NO" CHAR(3) NOT NULL, 
		"DRAWING_NO" CHAR(15) NOT NULL, 
		"START_DATE" DATE NOT NULL, 
		"END_DATE" DATE NOT NULL, 
		"DRAWING_OVER" CHAR(1) NOT NULL, 
		"DRAWING_SYMBOL" CHAR(1) NOT NULL, 
		"INDEX" CHAR(2) NOT NULL, 
		"KIND" CHAR(1) NOT NULL, 
		"DWG_JDG_CODE" CHAR(1) NOT NULL, 
		"REFERENCE" CHAR(1) NOT NULL, 
		"PS_NAME" CHAR(20) NOT NULL, 
		"QUANTITY" SMALLINT NOT NULL, 
		"DOMESTIC_CAL_CODE" CHAR(1) NOT NULL, 
		"FOREIGN_CAL_CODE" CHAR(1) NOT NULL, 
		"CKD_CLASS" CHAR(1) NOT NULL, 
		"THICKNESS" CHAR(5) NOT NULL, 
		"MATERIAL" VARCHAR(48) NOT NULL, 
		"AUTOMATIC_SYMBOL" CHAR(1) NOT NULL, 
		"REPR_OF_MAIN_ECS_NO" CHAR(11) NOT NULL, 
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

CREATE TABLE "TB001005" (
		"PARTS_NO" CHAR(15) NOT NULL, 
		"RELATED_PARTS_NO" CHAR(15) NOT NULL, 
		"REL_PN_REV_NO" CHAR(3) NOT NULL, 
		"RELATION_TYPE" CHAR(1) NOT NULL, 
		"START_DATE" DATE NOT NULL, 
		"END_DATE" DATE NOT NULL, 
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

CREATE TABLE "TB001006" (
		"PARTS_NO" CHAR(15) NOT NULL, 
		"ENGINEERING_PN_REV_NO" CHAR(3) NOT NULL, 
		"PREV_PARTS_NO" CHAR(15) NOT NULL, 
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

CREATE TABLE "TB001007" (
		"PARENT_PARTS_NO" CHAR(15) NOT NULL, 
		"SUB_PARTS_NO" CHAR(15) NOT NULL, 
		"ENGINEERING_PS_REV_NO" CHAR(3) NOT NULL, 
		"PREV_PARENT_PARTS_NO" CHAR(15) NOT NULL, 
		"PREV_SUB_PARTS_NO" CHAR(15) NOT NULL, 
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

ALTER TABLE "TB001001" ADD CONSTRAINT "TB001001_PK" PRIMARY KEY
	("PARTS_NO");

ALTER TABLE "TB001002" ADD CONSTRAINT "TB001002_PK" PRIMARY KEY
	("PARTS_NO", 
	 "ENGINEERING_PN_REV_NO");

ALTER TABLE "TB001003" ADD CONSTRAINT "TB001003_PK" PRIMARY KEY
	("PARTS_NO", 
	 "PARTS_PROP_REV_NO");

ALTER TABLE "TB001004" ADD CONSTRAINT "TB001004_PK" PRIMARY KEY
	("PARENT_PARTS_NO", 
	 "SUB_PARTS_NO", 
	 "ENGINEERING_PS_REV_NO");

ALTER TABLE "TB001005" ADD CONSTRAINT "TB001005_PK" PRIMARY KEY
	("PARTS_NO", 
	 "RELATED_PARTS_NO", 
	 "REL_PN_REV_NO", 
	 "RELATION_TYPE");

ALTER TABLE "TB001006" ADD CONSTRAINT "TB001006_PK" PRIMARY KEY
	("PARTS_NO", 
	 "ENGINEERING_PN_REV_NO", 
	 "PREV_PARTS_NO");

ALTER TABLE "TB001007" ADD CONSTRAINT "TB001007_PK" PRIMARY KEY
	("PARENT_PARTS_NO", 
	 "SUB_PARTS_NO", 
	 "ENGINEERING_PS_REV_NO", 
	 "PREV_PARENT_PARTS_NO", 
	 "PREV_SUB_PARTS_NO");

