--<ScriptOptions statementTerminator=";"/>

CREATE GLOBAL TEMPORARY TABLE "GT003001" (
		"ECS_NO" CHAR(11) NOT NULL, 
		"ECS_REV_NO" CHAR(1) NOT NULL, 
		"REPR_SIMUL_CLASS" CHAR(1) NOT NULL
	)
	ON COMMIT PRESERVE ROWS
	NOT LOGGED ON ROLLBACK DELETE ROWS;

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
		"MATERIAL" CHAR(48) NOT NULL, 
		"AUTOMATIC_SYMBOL" VARCHAR(1) NOT NULL, 
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
		"APPLIED_MODEL_CODE" CHAR(4) NOT NULL, 
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

CREATE TABLE "TB003012" (
		"MC_DEV_MODEL_CODE" CHAR(4) NOT NULL, 
		"EVENT_ID" CHAR(6) NOT NULL, 
		"PROD_BASE_CODE" CHAR(1) NOT NULL, 
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

CREATE TABLE "TB004001" (
		"PARTS_NO" CHAR(15) NOT NULL, 
		"ENGINEERING_PN_REV_NO" CHAR(3) NOT NULL, 
		"FACTORY_PN_REV_NO" CHAR(3) NOT NULL, 
		"FACTORY_PN_STATUS" CHAR(2) NOT NULL, 
		"APPROVED_DATE" DATE NOT NULL, 
		"APPROVER_USER_ID" CHAR(10) NOT NULL, 
		"EDITOR_USER_ID" CHAR(10) NOT NULL, 
		"ADOPT_DATE" DATE NOT NULL, 
		"ABOLISH_DATE" DATE NOT NULL, 
		"TMP_REGIST_DATE" DATE NOT NULL, 
		"PENDING_DECIDED_DATE" DATE NOT NULL, 
		"JOB_SEQ_NO" CHAR(2) NOT NULL, 
		"SUPPLIER_CODE" CHAR(4) NOT NULL, 
		"PROD_BASE_CODE" CHAR(1) NOT NULL, 
		"DATA_CHECK_RESULT" CHAR(1) NOT NULL, 
		"REPR_OF_MAIN_ECS_NO" CHAR(11) NOT NULL, 
		"SKIP_FLAG" CHAR(1) NOT NULL, 
		"CANCEL_FLAG" CHAR(1) NOT NULL, 
		"PARTS_PROP_REV_NO" CHAR(3) NOT NULL, 
		"TMP_ABOLISH_DATE" DATE NOT NULL, 
		"TMP_CANCEL_FLAG" CHAR(1) NOT NULL, 
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

CREATE TABLE "TB004002" (
		"SUB_PARTS_NO" CHAR(15) NOT NULL, 
		"PARENT_PARTS_NO" CHAR(15) NOT NULL, 
		"PS_REV_NO" CHAR(3) NOT NULL, 
		"FACTORY_PS_REV_NO" CHAR(3) NOT NULL, 
		"FACTORY_PS_STATUS" CHAR(2) NOT NULL, 
		"APPROVED_DATE" DATE NOT NULL, 
		"APPROVER_USER_ID" CHAR(10) NOT NULL, 
		"EDITOR_USER_ID" CHAR(10) NOT NULL, 
		"ADOPT_DATE" DATE NOT NULL, 
		"ABOLISH_DATE" DATE NOT NULL, 
		"TMP_REGIST_DATE" DATE NOT NULL, 
		"PENDING_DECIDED_DATE" DATE NOT NULL, 
		"CONSUMPTION_ROUTING" CHAR(2) NOT NULL, 
		"PROCESSING_CODE" CHAR(1) NOT NULL, 
		"MANAGEMENT_STATUS" CHAR(1) NOT NULL, 
		"SUPPLY_CODE" CHAR(1) NOT NULL, 
		"SHIP_SUPPLY_CLASS" CHAR(1) NOT NULL, 
		"ADOPT_CHECK_CODE" CHAR(1) NOT NULL, 
		"UNIT_CLASS" CHAR(1) NOT NULL, 
		"DATA_CHECK_RESULT" CHAR(1) NOT NULL, 
		"REPR_OF_MAIN_ECS_NO" CHAR(11) NOT NULL, 
		"SKIP_FLAG" CHAR(1) NOT NULL, 
		"CANCEL_FLAG" CHAR(1) NOT NULL, 
		"ENGINEERING_PS_REV_NO" CHAR(3) NOT NULL, 
		"TMP_ABOLISH_DATE" DATE NOT NULL, 
		"TMP_CANCEL_FLAG" CHAR(1) NOT NULL, 
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

CREATE TABLE "TB004003" (
		"SEQUENCING_NO" CHAR(2) NOT NULL, 
		"SEQUENCING_NAME" VARCHAR(100) NOT NULL, 
		"UNIT_CLASS" CHAR(1) NOT NULL, 
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

CREATE TABLE "TB004004" (
		"MAPPING_NO" CHAR(4) NOT NULL, 
		"NEW_CONS_ROUT_NO" CHAR(2) NOT NULL, 
		"NEW_JOB_SEQ_NO" CHAR(2) NOT NULL, 
		"NEW_UNIT_CLASS" CHAR(1) NOT NULL, 
		"SUPPLIER_CODE_COND" VARCHAR(20) NOT NULL, 
		"NEW_SUPPLY_CODE" CHAR(1) NOT NULL, 
		"NEW_PROCESSING_CODE" CHAR(1) NOT NULL, 
		"PRCSSING_CODE_FOR_CHK" CHAR(1) NOT NULL, 
		"SEPICS_CONS_ROUT_NO" CHAR(4) NOT NULL, 
		"SEPICS_RCV_ROUT_NO" CHAR(4) NOT NULL, 
		"SEPICS_JOB_SEQ_NO" CHAR(4) NOT NULL, 
		"SEPICS_UNIT_CLASS" CHAR(1) NOT NULL, 
		"SEPICS_SUPPLY_CODE" CHAR(1) NOT NULL, 
		"SEPICS_PROCESSING_CODE" CHAR(1) NOT NULL, 
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

CREATE TABLE "TB004005" (
		"PROCESSING_CODE" CHAR(1) NOT NULL, 
		"CONTENTS" VARCHAR(100) NOT NULL, 
		"ORDER_MOVE_DIV" CHAR(1) NOT NULL, 
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

CREATE TABLE "TB007003" (
		"MC_DEV_MODEL_CODE" CHAR(4) NOT NULL, 
		"EVENT_ID" CHAR(6) NOT NULL, 
		"SHEET_CODE" CHAR(5) NOT NULL, 
		"REV_NOTIFY_NO" CHAR(2) NOT NULL, 
		"LINE_NO" SMALLINT NOT NULL, 
		"MODEL" CHAR(4) NOT NULL, 
		"BLOCK_NO" CHAR(4) NOT NULL, 
		"WORK_NO" CHAR(10) NOT NULL, 
		"LINE_ID" CHAR(3) NOT NULL, 
		"CONTROL_NO" CHAR(4) NOT NULL, 
		"SPECIAL_MARK" CHAR(1) NOT NULL, 
		"HISTORY" CHAR(1) NOT NULL, 
		"LEVEL" SMALLINT NOT NULL, 
		"UNIT_CLASS" CHAR(1) NOT NULL, 
		"PARTS_NO" CHAR(15) NOT NULL, 
		"REV_NO" CHAR(2) NOT NULL, 
		"PARTS_NAME" VARCHAR(20) NOT NULL, 
		"PURCHASER" CHAR(2) NOT NULL, 
		"SUPPLIER_CODE" CHAR(4) NOT NULL, 
		"PREPARATION" CHAR(1) NOT NULL, 
		"MAN_HOUR" CHAR(1) NOT NULL, 
		"QUANTITY" CHAR(80) NOT NULL, 
		"DELIVERY_LOCATION" CHAR(2) NOT NULL, 
		"SUPPLY_SECTION" CHAR(5) NOT NULL, 
		"CAL_CODE" CHAR(1) NOT NULL, 
		"SIA_CAL_CODE" CHAR(1) NOT NULL, 
		"CKD_CLASS" CHAR(1) NOT NULL, 
		"MASS" CHAR(6) NOT NULL, 
		"ECS_NO" CHAR(11) NOT NULL, 
		"FIRST_MODEL_DUE_DATE" DATE NOT NULL, 
		"DELIVERY_QUANTITY" SMALLINT NOT NULL, 
		"ARRANGEMENT_SIGN" CHAR(1) NOT NULL, 
		"REMARKS" VARCHAR(600) NOT NULL, 
		"REV_REMARKS" VARCHAR(600) NOT NULL, 
		"MATERIAL_DESCRIPTION" CHAR(40) NOT NULL, 
		"DWG_ISSUE_PLAN_DATE" DATE NOT NULL, 
		"CONTENTS" CHAR(6) NOT NULL, 
		"LOGICAL_DEL_FLAG" CHAR(1) NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB007005" (
		"MC_DEV_MODEL_CODE" CHAR(4) NOT NULL, 
		"EVENT_ID" CHAR(6) NOT NULL, 
		"SHEET_CODE" CHAR(5) NOT NULL, 
		"BLOCK_NO" CHAR(4) NOT NULL, 
		"EVENT_PARTS_NO" CHAR(15) NOT NULL, 
		"LINE_ID" CHAR(3) NOT NULL, 
		"REV_NOTIFY_NO" CHAR(2) NOT NULL, 
		"MODEL" CHAR(4) NOT NULL, 
		"WORK_NO" CHAR(10) NOT NULL, 
		"CONTROL_NO" CHAR(4) NOT NULL, 
		"SPECIAL_MARK" CHAR(1) NOT NULL, 
		"HISTORY" CHAR(1) NOT NULL, 
		"LEVEL" SMALLINT NOT NULL, 
		"UNIT_CLASS" CHAR(1) NOT NULL, 
		"REV_NO" CHAR(2) NOT NULL, 
		"PARTS_NAME" VARCHAR(20) NOT NULL, 
		"PURCHASER" CHAR(2) NOT NULL, 
		"SUPPLIER_CODE" CHAR(4) NOT NULL, 
		"PREPARATION" CHAR(1) NOT NULL, 
		"MAN_HOUR" CHAR(1) NOT NULL, 
		"DELIVERY_LOCATION" CHAR(2) NOT NULL, 
		"SUPPLY_SECTION" CHAR(5) NOT NULL, 
		"CAL_CODE" CHAR(1) NOT NULL, 
		"SIA_CAL_CODE" CHAR(1) NOT NULL, 
		"CKD_CLASS" CHAR(1) NOT NULL, 
		"FIRST_MODEL_DUE_DATE" DATE NOT NULL, 
		"ECS_NO" CHAR(11) NOT NULL, 
		"ARRANGEMENT_SIGN" CHAR(1) NOT NULL, 
		"REMARKS" VARCHAR(600) NOT NULL, 
		"REV_REMARKS" VARCHAR(600) NOT NULL, 
		"MATERIAL_DESCRIPTION" CHAR(40) NOT NULL, 
		"DWG_ISSUE_PLAN_DATE" DATE NOT NULL, 
		"MFG_SUPPLY_SECTION" CHAR(5) NOT NULL, 
		"MFG_DELIVERY_LOCATION" CHAR(2) NOT NULL, 
		"MFG_DUE_DATE" DATE NOT NULL, 
		"LOGICAL_DEL_FLAG" CHAR(1) NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB007008" (
		"MC_DEV_MODEL_CODE" CHAR(4) NOT NULL, 
		"EVENT_ID" CHAR(6) NOT NULL, 
		"BLOCK_NO" CHAR(4) NOT NULL, 
		"LEVEL" SMALLINT NOT NULL, 
		"EVENT_PARTS_NO" CHAR(15) NOT NULL, 
		"SUPPLY_SECTION" CHAR(5) NOT NULL, 
		"DELIVERY_LOCATION" CHAR(2) NOT NULL, 
		"DUE_DATE" DATE NOT NULL, 
		"SUMMARY_SYMBOL" CHAR(1) NOT NULL, 
		"CHANGE_REV_NO" CHAR(3) NOT NULL, 
		"TRL_CHANGE_SYMBOL" CHAR(1) NOT NULL, 
		"MFG_CHANGE_SYMBOL" CHAR(1) NOT NULL, 
		"REV_NOTIFY_NO" CHAR(2) NOT NULL, 
		"SPECIAL_MARK" CHAR(1) NOT NULL, 
		"PURCHASER" CHAR(2) NOT NULL, 
		"SUPPLIER_CODE" CHAR(4) NOT NULL, 
		"PARTS_NAME" CHAR(20) NOT NULL, 
		"TRL_SUPPLY_SECTION" CHAR(5) NOT NULL, 
		"PARTS_REV_NO" CHAR(3) NOT NULL, 
		"ECS_NO" CHAR(11) NOT NULL, 
		"TRL_DELIVERY_LOCATION" CHAR(2) NOT NULL, 
		"DWG_PARTS_NO" CHAR(15) NOT NULL, 
		"DWG_PARTS_REV_NO" CHAR(3) NOT NULL, 
		"DWG_ECS_NO" CHAR(11) NOT NULL, 
		"DWG_SUPPLIER_CODE" CHAR(4) NOT NULL, 
		"DWG_CONS_ROUT" CHAR(4) NOT NULL, 
		"PRD_QLT_REMARKS" VARCHAR(600) NOT NULL, 
		"CAL_CODE" CHAR(1) NOT NULL, 
		"UNIT_CLASS" CHAR(1) NOT NULL, 
		"CKD_CLASS" CHAR(1) NOT NULL, 
		"ARRANGEMENT_SIGN" CHAR(1) NOT NULL, 
		"CHANGE_REASON" CHAR(100) NOT NULL, 
		"DISPLAY_ORDER" SMALLINT NOT NULL, 
		"FUNCTION" CHAR(5) NOT NULL, 
		"LOGICAL_DEL_FLAG" CHAR(1) NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB007011" (
		"MC_DEV_MODEL_CODE" CHAR(4) NOT NULL, 
		"EVENT_ID" CHAR(6) NOT NULL, 
		"TRL_DELIVERY_LOCATION" CHAR(2) NOT NULL, 
		"MFG_DELIVERY_LOCATION" CHAR(2) NOT NULL, 
		"DUE_DATE" DATE NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB011012" (
		"MAIL_SEND_CONTROL_NO" CHAR(30) NOT NULL, 
		"MAIL_TEMPLATE_ID" CHAR(10) NOT NULL, 
		"SENDER_MAIL_ADDRESS" VARCHAR(256) NOT NULL, 
		"MAIL_SEND_STATUS" CHAR(1) NOT NULL, 
		"MAIL_SEND_MODE" CHAR(1) NOT NULL, 
		"MAIL_REGISTER_TIME" TIMESTAMP NOT NULL, 
		"MAIL_SEND_TIME" TIMESTAMP NOT NULL, 
		"MAIL_SUBJECT" VARCHAR(600) NOT NULL, 
		"MAIL_BODY" CLOB(2000000) NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

CREATE TABLE "TB011015" (
		"CODE_GROUP_ID" CHAR(10) NOT NULL, 
		"CODE_VALUE" CHAR(10) NOT NULL, 
		"JP_DISPLAY_NAME" VARCHAR(300) NOT NULL, 
		"EN_DISPLAY_NAME" VARCHAR(100) NOT NULL, 
		"CODE_GROUP_CLASS" CHAR(1) NOT NULL, 
		"CODE_GROUP_DESCRIPTION" VARCHAR(600) NOT NULL, 
		"CODE_VALUE_DESCRIPTION" VARCHAR(600) NOT NULL, 
		"CODE_VALUE_NAME" VARCHAR(100) NOT NULL, 
		"CODE_ORDER" SMALLINT NOT NULL, 
		"CREATED_USER_ID" CHAR(10) NOT NULL, 
		"CREATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"CREATED_TIMESTAMP" TIMESTAMP NOT NULL, 
		"UPDATED_USER_ID" CHAR(10) NOT NULL, 
		"UPDATED_APP_EVENT_ID" CHAR(10) NOT NULL, 
		"UPDATED_TIMESTAMP" TIMESTAMP NOT NULL
	)
	DATA CAPTURE NONE 
	COMPRESS NO;

ALTER TABLE "TB001002" ADD CONSTRAINT "TB001002_PK" PRIMARY KEY
	("PARTS_NO", 
	 "ENGINEERING_PN_REV_NO");

ALTER TABLE "TB001004" ADD CONSTRAINT "TB001004_PK" PRIMARY KEY
	("PARENT_PARTS_NO", 
	 "SUB_PARTS_NO", 
	 "ENGINEERING_PS_REV_NO");

ALTER TABLE "TB002019" ADD CONSTRAINT "TB002019_PK" PRIMARY KEY
	("DRAWING_NO", 
	 "DRAWING_REV_NO", 
	 "SUPPLIER_CODE", 
	 "PURCHASE_REV_NO");

ALTER TABLE "TB002020" ADD CONSTRAINT "TB002020_PK" PRIMARY KEY
	("ECS_PROCESS_ID");

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

ALTER TABLE "TB003012" ADD CONSTRAINT "TB003012_PK" PRIMARY KEY
	("MC_DEV_MODEL_CODE", 
	 "EVENT_ID", 
	 "PROD_BASE_CODE");

ALTER TABLE "TB004001" ADD CONSTRAINT "TB004001_PK" PRIMARY KEY
	("PARTS_NO", 
	 "ENGINEERING_PN_REV_NO", 
	 "FACTORY_PN_REV_NO");

ALTER TABLE "TB004002" ADD CONSTRAINT "TB004002_PK" PRIMARY KEY
	("SUB_PARTS_NO", 
	 "PARENT_PARTS_NO", 
	 "PS_REV_NO", 
	 "FACTORY_PS_REV_NO");

ALTER TABLE "TB004003" ADD CONSTRAINT "TB004003_PK" PRIMARY KEY
	("SEQUENCING_NO");

ALTER TABLE "TB004004" ADD CONSTRAINT "TB004004_PK" PRIMARY KEY
	("MAPPING_NO");

ALTER TABLE "TB004005" ADD CONSTRAINT "TB004005_PK" PRIMARY KEY
	("PROCESSING_CODE");

ALTER TABLE "TB007003" ADD CONSTRAINT "TB007003_PK" PRIMARY KEY
	("MC_DEV_MODEL_CODE", 
	 "EVENT_ID", 
	 "SHEET_CODE", 
	 "REV_NOTIFY_NO", 
	 "LINE_NO");

ALTER TABLE "TB007005" ADD CONSTRAINT "TB007005_PK" PRIMARY KEY
	("MC_DEV_MODEL_CODE", 
	 "EVENT_ID", 
	 "SHEET_CODE", 
	 "BLOCK_NO", 
	 "EVENT_PARTS_NO", 
	 "LINE_ID", 
	 "REV_NOTIFY_NO");

ALTER TABLE "TB007008" ADD CONSTRAINT "TB007008_PK" PRIMARY KEY
	("MC_DEV_MODEL_CODE", 
	 "EVENT_ID", 
	 "BLOCK_NO", 
	 "LEVEL", 
	 "EVENT_PARTS_NO", 
	 "SUPPLY_SECTION", 
	 "DELIVERY_LOCATION", 
	 "DUE_DATE", 
	 "SUMMARY_SYMBOL", 
	 "CHANGE_REV_NO");

ALTER TABLE "TB007011" ADD CONSTRAINT "TB007011_PK" PRIMARY KEY
	("MC_DEV_MODEL_CODE", 
	 "EVENT_ID");

ALTER TABLE "TB011012" ADD CONSTRAINT "TB011012_PK" PRIMARY KEY
	("MAIL_SEND_CONTROL_NO");

ALTER TABLE "TB011015" ADD CONSTRAINT "TB011015_PK" PRIMARY KEY
	("CODE_GROUP_ID", 
	 "CODE_VALUE");

