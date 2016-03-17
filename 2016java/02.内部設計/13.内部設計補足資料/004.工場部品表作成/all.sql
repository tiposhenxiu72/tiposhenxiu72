WITH TEMP
	(
		PATH,		/* �u�e���i�ԍ� + ���o���ԍ� + ���o���ԍ���ށv�̃p�X */
		PARPRTNO,	/* �e���i�ԍ� */
		PRTNO,		/* ���i�ԍ� */
		LV			/* �W�J���x�� */
	) AS
	(
		SELECT  
			PRTMST.PARTS_NO || ':' AS PATH,											/* �\�[�g�L�[ TOP���i�ԍ� */
			'' AS PARPRTNO,
			PRTMST.PARTS_NO AS PRTNO,
			CASE 
				WHEN PRTMAX.DRAWING_CLASS='F' THEN 0 								/* TOP���i�̍ŐV�̕��i������F�}�Ȃ�Lv0����AF�}�łȂ����Lv1���� */
				ELSE 1 
			END AS LV
		FROM
			TB001001 PRTMST															/* ���i */
				INNER JOIN TB001003 PRTMAX ON										/* ���i���� (�ő�̏��������ԍ�) */	
					PRTMAX.PARTS_NO=PRTMST.PARTS_NO AND
					EXISTS
					(
						SELECT
							MAX(PRT2.PARTS_PROP_REV_NO)
						FROM
							TB001003 PRT2
						WHERE
							PRT2.PARTS_NO=PRTMAX.PARTS_NO
						GROUP BY
							PRT2.PARTS_NO
						HAVING
							PRTMAX.PARTS_PROP_REV_NO=MAX(PRT2.PARTS_PROP_REV_NO)
					)
		WHERE																			
			EXISTS																														/* �w�肵��mc�J�������A�u���b�NNO���\���ΏۍH�ꕔ�i�f�[�^�ɐݒ肳��Ă��镔�i�ԍ��ł��邱�� */
			(
				SELECT
					*
				FROM
					TB001003 PRT																										/* ���i���� */
						INNER JOIN TB004001 MPRT ON																						/* �H�ꕔ�i��� */
							MPRT.PARTS_NO=PRT.PARTS_NO AND
							MPRT.PARTS_PROP_REV_NO=PRT.PARTS_PROP_REV_NO AND
							PRT.DRAWING_SERIES=':MCMDLCD' AND																			/* ��mc�J�������w��	�w��l��"UNIT"�ł������ꍇ�ɂ͂��̏��������O���� */
							PRT.DRAWING_BLOCK_NO=':BLOCK' 																				/* �u���b�NNO�w�� */
							AND MPRT.CANCEL_FLAG=':CANCEL_FLG' AND																		/* �������t���O���u�L���v */
							(MPRT.FACTORY_PN_STATUS!=':STATUS' OR MPRT.ABOLISH_DATE > TO_DATE(':TODAY', 'YYYY/MM/DD')) AND				/* ���{�o�^�ς݂ł͂Ȃ����A�܂��͉ߋ��p�~�ł͂Ȃ��f�[�^ */
							(MPRT.FACTORY_PN_STATUS=':STATUS' AND MPRT.ADOPT_DATE <= TO_DATE(':DATE', 'YYYY/MM/DD') AND MPRT.ABOLISH_DATE > TO_DATE(':DATE', 'YYYY/MM/DD'))	/* ���ߋ������w�莞�Ɏw�肷����t�����B�{�o�^�ς̂ݕ\������B�u�����N�̏ꍇ�͂��̏��������O���� */
				WHERE
					PRT.PARTS_NO=PRTMST.PARTS_NO AND
					NOT EXISTS														/* �w�肳�ꂽmc�J�������A�u���b�NNO�̐e�\�������݂��Ȃ� */
					(
						SELECT
							*
						FROM
							TB001004 STRC2, 										/* ���i�\�� */
							TB001003 PRT2 											/* ���i���� */
						WHERE
							STRC2.AUTOMATIC_SYMBOL!='D' AND							/* �폜�\���ł͂Ȃ� */
							STRC2.SUB_PARTS_NO=PRT.PARTS_NO AND
							STRC2.PARENT_PARTS_NO!='T' AND							/* �_�~�[�e�\���ł͂Ȃ� */
							PRT2.PARTS_NO=STRC2.PARENT_PARTS_NO AND
							PRT2.DRAWING_BLOCK_NO=PRT.DRAWING_BLOCK_NO
							AND PRT2.DRAWING_SERIES=PRT.DRAWING_SERIES 				/* �� mc�J�������w�肪"UNIT"�ł������ꍇ�ɂ͂��̏��������O���� */
					)
			) OR
			EXISTS																	/* �܂��́A�w��̃��X�g�R�[�h�A�u���b�NNO�Ńt�@�C�i�����i�Ƃ���AL�K�p����Ă��镔�Ԃ����� */
			(
				SELECT
					*
				FROM
					TB008004 AL  													/* AL�K�p */
						INNER JOIN TB009003 LSTCD ON								/* ���X�g�R�[�h */
							LSTCD.LIST_CODE=AL.LIST_CODE AND
							LSTCD.MC_DEV_MODEL_CODE=':MCMDLCD'						/* ��mc�J�������w��	�w��l��"UNIT"�ł������ꍇ�ɂ͂��̏��������O���� */
				WHERE
					AL.BLOCK_NO=':BLOCK' AND										/* �u���b�NNO�w�� */
					AL.FINAL_PARTS_NO=PRTMST.PARTS_NO								/* �t�@�C�i�����i�ԍ� */
			)
		UNION ALL
		SELECT
			(TEMP.PATH || TEMP.PRTNO || '/' || STRC.INDEX || STRC.KIND) AS PATH,	/* �W�J�\���p�X (�u�e���i�ԍ� + ���o���ԍ� + ���o���ԍ���ށv) */
			TEMP.PRTNO AS PARPRTNO,
			PRTMST.PARTS_NO AS PRTNO,
			TEMP.LV + 1 AS LV														/* �W�J���x�� */
		FROM
			TEMP,
			TB001001 PRTMST,														/* ���i */
			TB001004 STRC															/* ���i�\�� */
		WHERE
			TEMP.LV < ':LEVEL' AND													/* �W�J���x���̎w�� */
			EXISTS																	/* �\���W�J����̂ɑÓ��ȍ\���q���i�Ƃ��đ��݂��Ă��� */
			(
				SELECT
					*
				FROM
					TB004002 MSTRC 													/* �H��\����� */
				WHERE
					MSTRC.PARENT_PARTS_NO=TEMP.PRTNO AND								/* �\���W�J */
					MSTRC.SUB_PARTS_NO=PRTMST.PARTS_NO AND
					MSTRC.CANCEL_FLAG=':CANCEL_FLAG' AND																												/* �������t���O���u�L���v */
					(MSTRC.FACTORY_PS_STATUS!=':STATUS' OR MSTRC.ABOLISH_DATE > TO_DATE('TODAY', 'YYYY/MM/DD')) AND														/* ���{�o�^�ς݂ł͂Ȃ����A�܂��͉ߋ��p�~�ł͂Ȃ��f�[�^ */
					(MSTRC.FACTORY_PS_STATUS=':STATUS' AND MSTRC.ADOPT_DATE <= TO_DATE(':DATE', 'YYYY/MM/DD') AND MSTRC.ABOLISH_DATE > TO_DATE(':DATE', 'YYYY/MM/DD'))	/* ���ߋ������w�莞�Ɏw�肷����t�����B�{�o�^�ς̂ݕ\������B�u�����N�̏ꍇ�͂��̏��������O���� */
			) AND
			STRC.PARENT_PARTS_NO=TEMP.PRTNO AND
			STRC.SUB_PARTS_NO=PRTMST.PARTS_NO AND
			EXISTS																	/* �\���ΏۂƂȂ�e�q���Ԃ̋Z�p�Ƃ��Ă̍ŐV�������擾�B���̌��o�������\�[�g�Ɏg�p���� */
			(
				SELECT
					MAX(STRC2.ENGINEERING_PS_REV_NO)
				FROM
					TB001004 STRC2													/* ���i�\�� */
				WHERE
					STRC2.PARENT_PARTS_NO=STRC.PARENT_PARTS_NO AND
					STRC2.SUB_PARTS_NO=STRC.SUB_PARTS_NO
				HAVING
					STRC.ENGINEERING_PS_REV_NO=MAX(STRC2.ENGINEERING_PS_REV_NO)
			)
)
,FBLCK /* F�}�u���b�N, F�}�V���[�Y */
(
	PRTNO,
	FSERIES,
	FBLOCK,
	RNK
) AS
(
	SELECT distinct
		RELPRT.PARTS_NO AS PRTNO,
		PRT.DRAWING_SERIES AS FSERIES,															/* �t�@�C�i�����i�̐}�ʃV���[�Y */
		PRT.DRAWING_BLOCK_NO AS FBLOCK,															/* �t�@�C�i�����i�̃u���b�NNO */
		RANK() OVER(PARTITION BY RELPRT.PARTS_NO ORDER BY PRT.DRAWING_BLOCK_NO) AS RNK
	FROM
		TB001005 RELPRT						/* �֘A���i */
			INNER JOIN 	TB001003 PRT ON		/* ���i���� */
				PRT.PARTS_NO=RELPRT.RELATED_PARTS_NO AND
				EXISTS
				(
					SELECT
						MAX(PRT2.PARTS_PROP_REV_NO)
					FROM
						TB001003 PRT2
					WHERE
							PRT2.PARTS_NO=PRT.PARTS_NO
					GROUP BY
						PRT2.PARTS_NO
					HAVING
						PRT.PARTS_PROP_REV_NO=MAX(PRT2.PARTS_PROP_REV_NO)		/* �ŐV�������擾 */
				)
	WHERE
		RELPRT.RELATION_TYPE='F' AND											/* �֘A�^�C�v='F' (�t�@�C�i��) */
		EXISTS																	/* ���W�J���ꂽ���i�ԍ�(TEMP)�ɑ��݂��� */
		(
			SELECT
				*
			FROM
				TEMP
			WHERE
				TEMP.PRTNO=RELPRT.PARTS_NO
		)
),
FINALBLCKLIST	/* �t�@�C�i���̐}�ʃV���[�Y�A�u���b�N���J���}��؂�Ŏ擾 */
(
	PRTNO,		/* �Ώە��i�ԍ� */
	FSERIESES,	/* F�}�}�ʃV���[�Y���J���}��؂肵������ */
	FBLOCKS,	/* F�}�u���b�N���J���}��؂肵������ */
	RNK,
	ISLEAF
) AS
(
	SELECT
		FB.PRTNO,
		FB.FSERIES AS FSERIESES,
		FB.FBLOCK AS FBLOCKS,
		FB.RNK,
		CASE WHEN 
			(SELECT COUNT(*) 
				FROM FBLCK FB2
			WHERE 
				FB2.PRTNO=FB.PRTNO AND
				FB2.RNK-1=FB.RNK) > 0 
		THEN 0 ELSE 1 END AS ISLEAF
	FROM
		FBLCK FB
	WHERE
		FB.RNK=1
	UNION ALL
	SELECT
		FB.PRTNO,
		(FBL.FSERIESES || ',' || FB.FSERIES) AS FSERIESES,
		(FBL.FBLOCKS || ',' || FB.FBLOCK) AS FBLOCKS,
		FB.RNK,
		CASE WHEN 
			(SELECT COUNT(*) 
				FROM FBLCK FB2
			WHERE 
				FB2.PRTNO=FB.PRTNO AND
				FB2.RNK-1=FB.RNK) > 0 
		THEN 0 ELSE 1 END AS ISLEAF
	FROM
		FBLCK FB,
		FINALBLCKLIST FBL
	WHERE
		FB.PRTNO=FBL.PRTNO AND
		FB.RNK-1=FBL.RNK
)
,SPLR /* �����R�[�h */
(
	PRTNO,
	SPLRCD,
	SRCTYPE,
	RNK
) AS
(
	SELECT distinct
		PRTSPLR1.PARTS_NO AS PRTNO,
		PRTSPLR1.SUPPLIER_CODE AS SPLRCD,																			/* ���i�����R�[�h */
		PRTSPLR1.SOURCE_TYPE AS SRCTYPE,																			/* �������^�C�v */
		RANK() OVER(PARTITION BY PRTSPLR1.PARTS_NO, PRTSPLR1.SOURCE_TYPE ORDER BY PRTSPLR1.SUPPLIER_CODE) AS RNK
	FROM
		TB002017 PRTSPLR1							/* ���i����� */
	WHERE
		EXISTS										/* �W�J���i�ꗗ�ɑ��� */
		(
			SELECT
				*
			FROM
				TEMP
			WHERE
				TEMP.PRTNO=PRTSPLR1.PARTS_NO
		)
),
SPLRLIST	/* ���i�������J���}��؂�Ŏ擾 */
(
	PRTNO,		/* �Ώە��i�ԍ� */
	SRCTYPE,	/* �������^�C�v */
	SPLRCDLIST,	/* ���i�������J���}��؂肵������ */
	RNK,
	ISLEAF
) AS
(
	SELECT
		SP.PRTNO,
		SP.SRCTYPE,
		SP.SPLRCD AS SPLRCDLIST,
		SP.RNK,
		CASE WHEN 
			(
				SELECT 
					COUNT(*) 
				FROM 
					SPLR SP2
				WHERE 
					SP2.PRTNO=SP.PRTNO AND
					SP2.SRCTYPE=SP.SRCTYPE AND
					SP2.RNK-1=SP.RNK
			) > 0 
		THEN 0 ELSE 1 END AS ISLEAF
	FROM
		SPLR SP
	WHERE
		SP.RNK=1
	UNION ALL
	SELECT
		SP.PRTNO,
		SP.SRCTYPE,
		(SPL.SPLRCDLIST || ',' || SP.SPLRCD) AS SPLRCDLIST,
		SP.RNK,
		CASE WHEN 
			(
				SELECT 
					COUNT(*) 
				FROM 
					SPLR SP2
				WHERE 
					SP2.PRTNO=SP.PRTNO AND
					SP2.SRCTYPE=SP.SRCTYPE AND
					SP2.RNK-1=SP.RNK
			) > 0 
		THEN 0 ELSE 1 END AS ISLEAF
	FROM
		SPLR SP,
		SPLRLIST SPL
	WHERE
		SP.PRTNO=SPL.PRTNO AND
		SP.SRCTYPE=SPL.SRCTYPE AND
		SP.RNK-1=SPL.RNK
)
,OLDPRT /* �����i�ԍ� */
(
	PRTNO,
	REVNO,
	OLDPRTNO,
	RNK
) AS
(
	SELECT distinct
		OLDPRT.PARTS_NO AS PRTNO,
		OLDPRT.ENGINEERING_PN_REV_NO AS REVNO,
		OLDPRT.PREV_PARTS_NO AS OLDPRTNO,																				/* �����i�ԍ� */
		RANK() OVER(PARTITION BY OLDPRT.PARTS_NO, OLDPRT.ENGINEERING_PN_REV_NO ORDER BY OLDPRT.PREV_PARTS_NO) AS RNK
	FROM
		TB001006 OLDPRT						/* �����i */
	WHERE
		EXISTS								/* �W�J���i�ꗗ�ɑ��� */
		(
			SELECT
				*
			FROM
				TEMP
			WHERE
				TEMP.PRTNO=OLDPRT.PARTS_NO
		)
),
OLDPRTLIST
(
	PRTNO,			/* �Ώە��i�ԍ� */
	REVNO,			/* �Z�p���i�����ԍ� */
	OLDPRTNOLIST,	/* �����i�ԍ����J���}��؂肵������ */
	RNK,
	ISLEAF
) AS
(
	SELECT
		OLD.PRTNO,
		OLD.REVNO,
		OLD.OLDPRTNO AS OLDPRTNOLIST,
		OLD.RNK,
		CASE WHEN 
			(
				SELECT 
					COUNT(*) 
				FROM 
					OLDPRT OLD2
				WHERE 
					OLD2.PRTNO=OLD.PRTNO AND
					OLD2.REVNO=OLD.REVNO AND
					OLD2.RNK-1=OLD.RNK
			) > 0 
		THEN 0 ELSE 1 END AS ISLEAF
	FROM
		OLDPRT OLD
	WHERE
		OLD.RNK=1
	UNION ALL
	SELECT
		OLD.PRTNO,
		OLD.REVNO,
		(OLDL.OLDPRTNOLIST || ',' || OLD.OLDPRTNO) AS OLDPRTNOLIST,
		OLD.RNK,
		CASE WHEN 
			(
				SELECT 
					COUNT(*) 
				FROM 
					OLDPRT OLD2
				WHERE 
					OLD2.PRTNO=OLD.PRTNO AND
					OLD2.REVNO=OLD.REVNO AND
					OLD2.RNK-1=OLD.RNK
			) > 0 
		THEN 0 ELSE 1 END AS ISLEAF
	FROM
		OLDPRT OLD,
		OLDPRTLIST OLDL
	WHERE
		OLD.PRTNO=OLDL.PRTNO AND
		OLD.REVNO=OLDL.REVNO AND
		OLD.RNK-1=OLDL.RNK
)
SELECT
	SMBL,												/* S */
	CHKRSLT,											/* �f�[�^�`�F�b�N����(�p��) */
	LV,													/* Lv */
	DRWGCLS,											/* (*)Final�}�� */
	ITEMNO,												/* �i��ID�ԍ�  */
	ATFLG,												/* �v���Ӄ}�[�N */
	COUNT(DISTINCT DICITEMNO) AS DICITEMNO,			/* �i�ڎ�������(�i��ID�ԍ�������)�@�i��ID�ԍ����擾�ł��Ȃ������ꍇ�A 1���ȉ�:"N/A" 2���ȏ�:"?" */
	PRTNO,												/* ���i�ԍ� */
	REVNO,												/* �ϔ� */
	MREVNO,												/* �H����� */ 
	PRTNM,												/* ���i���� */ 
	PNSTATUSJP,											/* �H��X�e�[�^�X(���{��) */ 
	PNSTATUSEN,											/* �H��X�e�[�^�X(�p��) */ 
	DNPRCDFLGJP,										/* ��s���s�t���O(���{��) */ 
	DNPRCDFLGEN,										/* ��s���s�t���O(�p��) */ 
	COSRTNG,											/* ����H�� */
	JOBSEQ,												/* �����H�� */
	SPLRCDLIST_DISP,									/* �����R�[�h(�\���p) */
	UNITCLS,											/* ���j�b�g�敪 */
	PRCSCD,												/* ���H�敪 */
	ADPTDT,												/* �̗p�� */
	ABLSDT,												/* �p�~�� (�\�����e���u�����N�Ɣ��f���ꂽ�ꍇ�́A���ʕt�Ŏb��p�~����\��) */
	PENDFLG,											/* �����t���O */
	QTY, 												/* ���� */
	DNNO,												/* ��ݒʑ�\�ݒ� */
	OLDLIST,											/* �����i�ԍ�(�J���}��؂�) */
	RMKS,												/* ���l */
	SERIES,												/* �}�ʃV���[�Y */
	BLCK,												/* �u���b�NNO */
	DRWGNO,												/* �}�ʔԍ� */
	DRWGREV,											/* �}�ʉ����ԍ� */
	FSERIESLIST,										/* F�}�V���[�Y(�J���}��؂�) */
	FBLCKLIST,											/* F�}�u���b�NNO(�J���}��؂�) */
	MINFO,												/* (*2) �Ǘ��敪�A�����R�[�h�A�̊m�R�[�h */
	CANCELFLG,											/* �����t���O(�\�����e���u�����N�Ɣ��f���ꂽ�ꍇ�́A���ʕt�Ŏb�薳���t���O��\��) */
	FCTY_STATUS,										/* �H��X�e�[�^�X */
	TITLE_PRTNO,										/* �^�C�g���}��_ */
	TITLE_REVNO,										/* �^�C�g���}��_�Z�p���i�����ԍ� */
	TITLE_MREVNO,										/* �^�C�g���}��_�H�ꕔ�i�����ԍ� */
	TITLE_DRWGCLS,										/* �^�C�g���}��_Final�}�� */
	RECENTLY_SERIES,									/* �ŐV����_�}�ʃV���[�Y */
	RECENTLY_BLCK,										/* �ŐV����_�u���b�NNO */
	RECENTLY_BUCLS,										/* �ŐV����_BODY/UNIT�敪 */
	RECENTLY_PRTNM,										/* �ŐV����_���i���� */
	SPLRVNTFLG,											/* ����捷�كt���O 0:���قȂ��A1:���ق��� */
	SPLRCDLIST_1,										/* �����R�[�h(�O���f��) CSV�t�@�C���o�͗p */
	SPLRCDLIST_2,										/* �����R�[�h(�i��ID)   CSV�t�@�C���o�͗p */
	SPLRCDLIST_3,										/* �����R�[�h(�w���˗�) CSV�t�@�C���o�͗p */
	SPLRCDLIST_4,										/* �����R�[�h(�z�z����) CSV�t�@�C���o�͗p */
	SPLRCDLIST_5										/* �����R�[�h(����)     CSV�t�@�C���o�͗p */
FROM
(
	SELECT
		PRTDRWG.AUTOMATIC_SYMBOL AS SMBL,																								/* S */
		MPRT.DATA_CHECK_RESULT AS CHKRSLT,																								/* �f�[�^�`�F�b�N����(�p��) */
		'' AS LV,																														/* Lv */
		PRT.DRAWING_CLASS AS DRWGCLS,																									/* (*)Final�}�� */
		NVL(ITEM.ITEM_ID_NO, '') AS ITEMNO,																								/* �i��ID�ԍ�  */
		ITEM.ATTENTION_FLAG AS ATFLG,																									/* �v���Ӄ}�[�N */
		ITEMDIC.ITEM_ID_NO AS DICITEMNO,																								/* �i�ڎ����ɓo�^����Ă���w��J�������̕i��ID */
		MPRT.PARTS_NO AS PRTNO,																											/* ���i�ԍ� */
		MPRT.ENGINEERING_PN_REV_NO AS REVNO,																							/* �ϔ� */
		MPRT.FACTORY_PN_REV_NO AS MREVNO,																								/* �H����� */ 
		PRT.PARTS_NAME AS PRTNM,																										/* ���i���� */ 
		CDMST1.JP_DISPLAY_NAME AS PNSTATUSJP,																							/* �H��X�e�[�^�X(���{��) */ 
		CDMST1.EN_DISPLAY_NAME AS PNSTATUSEN,																							/* �H��X�e�[�^�X(�p��) */ 
		CDMST2.JP_DISPLAY_NAME AS DNPRCDFLGJP,																							/* ��s���s�t���O(���{��) */ 
		CDMST2.EN_DISPLAY_NAME AS DNPRCDFLGEN,																							/* ��s���s�t���O(�p��) */ 
		DECODE(PRT.DRAWING_CLASS, 'F', MSTRCDUMMY.CONSUMPTION_ROUTING, '') AS COSRTNG,													/* ����H�� */
		MPRT.JOB_SEQ_NO AS JOBSEQ,																										/* �����H�� */
		DECODE(TRIM(MPRT.SUPPLIER_CODE), '', NVL(SPL_DISP.SPLRCDLIST, ''), MPRT.SUPPLIER_CODE) AS SPLRCDLIST_DISP,						/* �����R�[�h(�\���p) */
		DECODE(PRT.DRAWING_CLASS, 'F', MSTRCDUMMY.UNIT_CLASS, '') AS UNITCLS,															/* ���j�b�g�敪 */
		DECODE(PRT.DRAWING_CLASS, 'F', MSTRCDUMMY.PROCESSING_CODE, '') AS PRCSCD,														/* ���H�敪 */
		DECODE(TO_CHAR(MPRT.ADOPT_DATE, 'YYYY/MM/DD'), ':FINAL_DATE', '', TO_CHAR(MPRT.ADOPT_DATE, 'YYYY/MM/DD')) AS ADPTDT,			/* �̗p�� */
		DECODE(DECODE(TO_CHAR(MPRT.ABOLISH_DATE, 'YYYY/MM/DD'), ':FINAL_DATE', '', TO_CHAR(MPRT.ABOLISH_DATE, 'YYYY/MM/DD')), '', DECODE(TO_CHAR(MPRT.TMP_ABOLISH_DATE, 'YYYY/MM/DD'), ':FINAL_DATE', '', '(' || TO_CHAR(MPRT.TMP_ABOLISH_DATE, 'YYYY/MM/DD')|| ')') ) AS ABLSDT,		/* �p�~�� (�\�����e���u�����N�Ɣ��f���ꂽ�ꍇ�́A���ʕt�Ŏb��p�~����\��) */
		DECODE(TO_CHAR(MPRT.PENDING_DECIDED_DATE, 'YYYY/MM/DD'), ':FINAL_DATE' , '', '*') AS PENDFLG,									/* �����t���O */
		'' AS QTY, 																														/* ���� */
		MPRT.REPR_OF_MAIN_ECS_NO AS DNNO,																								/* ��ݒʑ�\�ݒ� */
		NVL(OLDPRTLIST.OLDPRTNOLIST, '') AS OLDLIST,																								/* �����i�ԍ�(�J���}��؂�) */
		MPRT.REMARKS AS RMKS,																											/* ���l */
		PRT.DRAWING_SERIES AS SERIES,																									/* �}�ʃV���[�Y */
		PRT.DRAWING_BLOCK_NO AS BLCK,																									/* �u���b�NNO */
		PRTDRWG.DRAWING_NO AS DRWGNO,																									/* �}�ʔԍ� */
		PRTDRWG.DRAWING_REV_NO AS DRWGREV,																								/* �}�ʉ����ԍ� */
		NVL(FBL.FSERIESES, '') AS FSERIESLIST,																									/* F�}�V���[�Y(�J���}��؂�) */
		NVL(FBL.FBLOCKS, '') AS FBLCKLIST,																										/* F�}�u���b�NNO(�J���}��؂�) */
		'' AS MINFO,																													/* (*2) �Ǘ��敪�A�����R�[�h�A�̊m�R�[�h */
		DECODE(TRIM(MPRT.CANCEL_FLAG), '', '(' || MPRT.TMP_CANCEL_FLAG || ')') AS CANCELFLG,											/* �����t���O(�\�����e���u�����N�Ɣ��f���ꂽ�ꍇ�́A���ʕt�Ŏb�薳���t���O��\��) */
		MPRT.FACTORY_PN_STATUS AS FCTY_STATUS,																							/* �H��X�e�[�^�X */
		MPRT.PARTS_NO AS TITLE_PRTNO,																									/* �^�C�g���}��_ */
		MPRT.ENGINEERING_PN_REV_NO AS TITLE_REVNO,																						/* �^�C�g���}��_�Z�p���i�����ԍ� */
		MPRT.FACTORY_PN_REV_NO AS TITLE_MREVNO,																							/* �^�C�g���}��_�H�ꕔ�i�����ԍ� */
		PRT.DRAWING_CLASS AS TITLE_DRWGCLS,																								/* �^�C�g���}��_Final�}�� */
		PRTMAX.DRAWING_SERIES AS RECENTLY_SERIES,																						/* �ŐV����_�}�ʃV���[�Y */
		PRTMAX.DRAWING_BLOCK_NO AS RECENTLY_BLCK,																						/* �ŐV����_�u���b�NNO */
		BLCK.BODY_UNIT_DIV AS RECENTLY_BUCLS,																							/* �ŐV����_BODY/UNIT�敪 */
		PRTMAX.PARTS_NAME AS RECENTLY_PRTNM,																							/* �ŐV����_���i���� */
		CASE
			WHEN SPL4.SPLRCDLIST IS NULL OR SPL4.SPLRCDLIST LIKE '%' || MPRT.SUPPLIER_CODE || '%' THEN '0' 
			ELSE '1' 
		END AS SPLRVNTFLG,																												/* ����捷�كt���O 0:���قȂ��A1:���ق��� */
		NVL(SPL1.SPLRCDLIST, '') AS SPLRCDLIST_1,																						/* �����R�[�h(�O���f��) CSV�t�@�C���o�͗p */
		NVL(SPL2.SPLRCDLIST, '') AS SPLRCDLIST_2,																						/* �����R�[�h(�i��ID)   CSV�t�@�C���o�͗p */
		NVL(SPL3.SPLRCDLIST, '') AS SPLRCDLIST_3,																						/* �����R�[�h(�w���˗�) CSV�t�@�C���o�͗p */
		NVL(SPL4.SPLRCDLIST, '') AS SPLRCDLIST_4,																						/* �����R�[�h(�z�z����) CSV�t�@�C���o�͗p */
		TRIM(MPRT.SUPPLIER_CODE) AS SPLRCDLIST_5																						/* �����R�[�h(����) CSV�t�@�C���o�͗p */
	FROM
		TB004001 MPRT																													/* �H�ꕔ�i��� */
		/* �����O���[�v1 : ���W�J����PN�̏����擾 */
			INNER JOIN TB001003 PRT ON																									/* ���i���� (�H�ꕔ�i���̏��������ԍ��ƍ��v) */	
				PRT.PARTS_NO=MPRT.PARTS_NO AND
				PRT.PARTS_PROP_REV_NO=MPRT.PARTS_PROP_REV_NO
			INNER JOIN TB001002 PRTDRWG ON																								/* ���i�}�� */
				PRTDRWG.PARTS_NO=MPRT.PARTS_NO AND
				PRTDRWG.ENGINEERING_PN_REV_NO=MPRT.ENGINEERING_PN_REV_NO
			LEFT OUTER JOIN TB004002 MSTRCDUMMY ON																						/* �H��\����� (�_�~�[�e�\���B���i�̗̍p���ԂɑΉ�����f�[�^���擾�B�d�l��2���R�[�h�ȏ�擾����Ȃ��͂��B) */
				MSTRCDUMMY.SUB_PARTS_NO=MPRT.PARTS_NO AND
				MSTRCDUMMY.PARENT_PARTS_NO='T' AND
				MSTRCDUMMY.REPR_OF_MAIN_ECS_NO=MPRT.REPR_OF_MAIN_ECS_NO
			LEFT OUTER JOIN TB003001 DSGN1 ON																							/* �݌v�ʒm */
				DSGN1.ECS_NO=MPRT.REPR_OF_MAIN_ECS_NO AND
				EXISTS																													/* �ŌÂ̐ݒʉ��� */
				(
					SELECT
						MIN(DSGN2.ECS_REV_NO)
					FROM
						TB003001 DSGN2
					WHERE
						DSGN2.ECS_NO=DSGN1.ECS_NO 
					GROUP BY
						DSGN2.ECS_NO
					HAVING
						DSGN1.ECS_REV_NO=MIN(DSGN2.ECS_REV_NO)
				)
			LEFT OUTER JOIN SPLRLIST SPL1 ON																								/* �����R�[�h�i�O���f���j */
				SPL1.PRTNO=MPRT.PARTS_NO AND
				SPL1.SRCTYPE='1' AND
				SPL1.ISLEAF=1
			LEFT OUTER JOIN SPLRLIST SPL2 ON																								/* �����R�[�h�i�i��ID�j */
				SPL2.PRTNO=MPRT.PARTS_NO AND
				SPL2.SRCTYPE='2' AND
				SPL2.ISLEAF=1
			LEFT OUTER JOIN SPLRLIST SPL3 ON																								/* �����R�[�h�i�w���˗��j */
				SPL3.PRTNO=MPRT.PARTS_NO AND
				SPL3.SRCTYPE='3' AND
				SPL3.ISLEAF=1
			LEFT OUTER JOIN SPLRLIST SPL4 ON																								/* �����R�[�h�i�z�z���сj */
				SPL4.PRTNO=MPRT.PARTS_NO AND
				SPL4.SRCTYPE='4' AND
				SPL4.ISLEAF=1
			LEFT OUTER JOIN OLDPRTLIST ON																									/* �����i�ԍ� (�J���}��؂�) */
				OLDPRTLIST.PRTNO=MPRT.PARTS_NO AND
				OLDPRTLIST.REVNO=MPRT.ENGINEERING_PN_REV_NO AND
				OLDPRTLIST.ISLEAF=1
			LEFT OUTER JOIN TB011015 CDMST1 ON																							/* �R�[�h�}�X�^�[(�H����X�e�[�^�X�擾�p) */
				CDMST1.CODE_GROUP_ID='CDGRP005' AND																						/* �H����X�e�[�^�X */
				CDMST1.CODE_VALUE=MPRT.FACTORY_PN_STATUS
			LEFT OUTER JOIN TB011015 CDMST2 ON																							/* �R�[�h�}�X�^�[(��s���s�t���O�擾�p) */
				CDMST2.CODE_GROUP_ID='CDGRP030' AND																						/* ��s���s�t���O */
				CDMST2.CODE_VALUE=DSGN1.PRECEDE_FLAG
			LEFT OUTER JOIN FINALBLCKLIST FBL ON																						/* F�}�u���b�N�AF�}�V���[�Y(�J���}��؂�) */
				FBL.PRTNO=MPRT.PARTS_NO AND
				FBL.ISLEAF=1
			LEFT OUTER JOIN SPLRLIST SPL_DISP ON																						/* �����R�[�h(�������^�C�v���ő�̎����R�[�h���J���}��؂�) */
				SPL_DISP.PRTNO=MPRT.PARTS_NO AND
				SPL_DISP.ISLEAF=1 AND
				EXISTS
				(
					SELECT
						PRTSPLR.PARTS_NO,
						MAX(PRTSPLR.SOURCE_TYPE)
					FROM
						TB002017 PRTSPLR
					WHERE
						PRTSPLR.PARTS_NO=SPL_DISP.PRTNO
					GROUP BY
						PRTSPLR.PARTS_NO
					HAVING
						SPL_DISP.SRCTYPE=MAX(PRTSPLR.SOURCE_TYPE)
				)
		/* �����O���[�v2 : ���W�J����PN�̕i��ID���擾���邽�߂̏�� */
			INNER JOIN TB001003 PRTMAX ON																								/* ���i���� (�ő�̏��������ԍ�) */	
				PRTMAX.PARTS_NO=MPRT.PARTS_NO AND
				EXISTS
				(
					SELECT
						MAX(PRT2.PARTS_PROP_REV_NO)
					FROM
						TB001003 PRT2
					WHERE
						PRT2.PARTS_NO=PRTMAX.PARTS_NO
					GROUP BY
						PRT2.PARTS_NO
					HAVING
						PRTMAX.PARTS_PROP_REV_NO=MAX(PRT2.PARTS_PROP_REV_NO)
				)
			INNER JOIN TB009005 BLCK ON																									/* �u���b�N (PRTMAX��JOIN) */
				BLCK.BLOCK_NO=PRTMAX.DRAWING_BLOCK_NO
			LEFT OUTER JOIN TB006001 ITEM ON																								/* �i��ID */
				EXISTS
				(
					SELECT
						*
					FROM
						TB006006 PRTITEM
					WHERE
						PRTITEM.MC_DEV_MODEL_CODE=DECODE(TRIM(':MCMDLCD'), '', DECODE(BLCK.BODY_UNIT_DIV, 'U', ':UNTN', PRTMAX.DRAWING_SERIES), DECODE(':MCMDLCD', 'UNIT', ':UNTN', ':MCMDLCD')) AND 
						PRTITEM.PARTS_NO=PRT.PARTS_NO AND																					/* ���i�ԍ� */
						PRTITEM.ITEM_ID_NO=ITEM.ITEM_ID_NO
				)
			LEFT OUTER JOIN TB006002 ITEMDIC ON																								/* �i�ڎ���(���i�i�ڊǗ��ɓo�^����Ă���ID�͏��O */
				ITEMDIC.FUNCTION=SUBSTR(MPRT.PARTS_NO, 1, 5) AND																			/* �t�@���N�V����(���i�ԍ��̏�5��) */
				EXISTS
				(
					SELECT
						*
					FROM
						TB006004 MDLITEM
					WHERE
						MDLITEM.MC_DEV_MODEL_CODE=DECODE(TRIM(':MCMDLCD'), '', DECODE(BLCK.BODY_UNIT_DIV, 'U', ':UNTN', PRTMAX.DRAWING_SERIES), DECODE(':MCMDLCD', 'UNIT', ':UNTN', ':MCMDLCD')) AND 
						MDLITEM.ITEM_ID_NO=ITEMDIC.ITEM_ID_NO																				/* �i��ID�ԍ� */
				) AND
				ITEMDIC.ITEM_NAME=PRTMAX.PARTS_NAME AND																						/* �ŐV�����̕��i���� */
				ITEMDIC.ITEM_ID_NO!=NVL(ITEM.ITEM_ID_NO, '')
	WHERE
		EXISTS																																/* �W�J�������i�ԍ��ꗗ�ɑ��݂��Ă��镔�i�ԍ� */
		(
			SELECT
				*
			FROM
				TEMP
			WHERE
				TEMP.PRTNO=MPRT.PARTS_NO
		) AND
		MPRT.CANCEL_FLAG=':CANCEL_FLAG' AND																									/* �������t���O���u�L���v */
		(MPRT.FACTORY_PN_STATUS!=':STATUS' OR MPRT.ABOLISH_DATE > TO_DATE(':TODAY', 'YYYY/MM/DD')) AND										/* ���{�o�^�ς݂ł͂Ȃ����A�܂��͉ߋ��p�~�ł͂Ȃ��f�[�^ */
		MPRT.JOB_SEQ_NO	=':JOBSEQ' AND																										/* �������H���̎w�� */
		(MPRT.FACTORY_PN_STATUS=':STATUS' AND MPRT.ADOPT_DATE <= TO_DATE(':DATE', 'YYYY/MM/DD') AND MPRT.ABOLISH_DATE > TO_DATE(':DATE', 'YYYY/MM/DD'))	/* ���ߋ������w�莞�Ɏw�肷����t�����B�{�o�^�ς̂ݕ\������B�u�����N�̏ꍇ�͂��̏��������O���� */
)
GROUP BY
	SMBL,																																	/* S */
	CHKRSLT,																																/* �f�[�^�`�F�b�N����(�p��) */
	LV,																																		/* Lv */
	DRWGCLS,																																/* (*)Final�}�� */
	ITEMNO,																																	/* �i��ID�ԍ� */
	ATFLG,																																	/* �v���Ӄ}�[�N */
	PRTNO,																																	/* ���i�ԍ� */
	REVNO,																																	/* �ϔ� */
	MREVNO,																																	/* �H����� */ 
	PRTNM,																																	/* ���i���� */ 
	PNSTATUSJP,																																/* �H��X�e�[�^�X(���{��) */ 
	PNSTATUSEN,																																/* �H��X�e�[�^�X(�p��) */ 
	DNPRCDFLGJP,																															/* ��s���s�t���O(���{��) */ 
	DNPRCDFLGEN,																															/* ��s���s�t���O(�p��) */ 
	COSRTNG,																																/* ����H�� */
	JOBSEQ,																																	/* �����H�� */
	SPLRCDLIST_DISP,																														/* �����R�[�h(�\���p) */
	UNITCLS,																																/* ���j�b�g�敪 */
	PRCSCD,																																	/* ���H�敪 */
	ADPTDT,																																	/* �̗p�� */
	ABLSDT,																																	/* �p�~�� (�\�����e���u�����N�Ɣ��f���ꂽ�ꍇ�́A���ʕt�Ŏb��p�~����\��) */
	PENDFLG,																																/* �����t���O */
	QTY, 																																	/* ���� */
	DNNO,																																	/* ��ݒʑ�\�ݒ� */
	OLDLIST,																																/* �����i�ԍ�(�J���}��؂�) */
	RMKS,																																	/* ���l */
	SERIES,																																	/* �}�ʃV���[�Y */
	BLCK,																																	/* �u���b�NNO */
	DRWGNO,																																	/* �}�ʔԍ� */
	DRWGREV,																																/* �}�ʉ����ԍ� */
	FSERIESLIST,																															/* F�}�V���[�Y(�J���}��؂�) */
	FBLCKLIST,																																/* F�}�u���b�NNO(�J���}��؂�) */
	MINFO,																																	/* (*2) �Ǘ��敪�A�����R�[�h�A�̊m�R�[�h */
	CANCELFLG,																																/* �����t���O(�\�����e���u�����N�Ɣ��f���ꂽ�ꍇ�́A���ʕt�Ŏb�薳���t���O��\��) */
	FCTY_STATUS,																															/* �H��X�e�[�^�X */
	TITLE_PRTNO,																															/* �^�C�g���}��_ */
	TITLE_REVNO,																															/* �^�C�g���}��_�Z�p���i�����ԍ� */
	TITLE_MREVNO,																															/* �^�C�g���}��_�H�ꕔ�i�����ԍ� */
	TITLE_DRWGCLS,																															/* �^�C�g���}��_Final�}�� */
	RECENTLY_SERIES,																														/* �ŐV����_�}�ʃV���[�Y */
	RECENTLY_BLCK,																															/* �ŐV����_�u���b�NNO */
	RECENTLY_BUCLS,																															/* �ŐV����_BODY/UNIT�敪 */
	RECENTLY_PRTNM,																															/* �ŐV����_���i���� */
	SPLRVNTFLG,																																/* ����捷�كt���O 0:���قȂ��A1:���ق��� */
	SPLRCDLIST_1,																															/* �����R�[�h(�O���f��) CSV�t�@�C���o�͗p */
	SPLRCDLIST_2,																															/* �����R�[�h(�i��ID)   CSV�t�@�C���o�͗p */
	SPLRCDLIST_3,																															/* �����R�[�h(�w���˗�) CSV�t�@�C���o�͗p */
	SPLRCDLIST_4,																															/* �����R�[�h(�z�z����) CSV�t�@�C���o�͗p */
	SPLRCDLIST_5																															/* �����R�[�h(����) CSV�t�@�C���o�͗p */
ORDER BY 
	PRTNO,																																	/* ���i�ԍ� */
	REVNO,																																	/* �ϔ� */
	MREVNO																																	/* �H����� */
;
