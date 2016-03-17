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
				WHEN PRTMAX.DRAWING_CLASS='F' THEN 0 
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
			PRTMST.PARTS_NO=:PRTNO AND											/* ���i�ԍ��w�� */	
			EXISTS																	/* �w�肵��mc�J�������A�u���b�NNO���\���ΏۍH�ꕔ�i�f�[�^�ɐݒ肳��Ă��镔�i�ԍ��ł��邱�� */
			(
				SELECT
					*
				FROM
					TB004001 MPRT 													/* �H�ꕔ�i��� */
				WHERE
					MPRT.PARTS_NO=PRTMST.PARTS_NO
					AND MPRT.CANCEL_FLAG='0' AND																		/* �����t���O���u�L���v */
					(MPRT.FACTORY_PN_STATUS!=:STATUS OR MPRT.ABOLISH_DATE > CAST(:TODAY AS DATE)) AND		/* ���{�o�^�ς݂ł͂Ȃ����A�܂��͉ߋ��p�~�ł͂Ȃ��f�[�^ �}�X�N��OFF�ɂȂ����ۂɂ́A���̏��������O���� */
					(MPRT.FACTORY_PN_STATUS=:STATUS AND MPRT.ADOPT_DATE <= CAST(:DATE AS DATE) AND MPRT.ABOLISH_DATE > CAST(:DATE AS DATE))	/* ���ߋ������w�莞�Ɏw�肷����t�����B�{�o�^�ς̂ݕ\������B�u�����N�̏ꍇ�͂��̏��������O���� */
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
			TEMP.LV < :LEVEL AND													/* �W�J���x���̎w�� */
			EXISTS																	/* �\���W�J����̂ɑÓ��ȍ\���q���i�Ƃ��đ��݂��Ă��� */
			(
				SELECT
					*
				FROM
					TB004002 MSTRC 													/* �H��\����� */
				WHERE
					MSTRC.PARENT_PARTS_NO=TEMP.PRTNO AND							/* �\���W�J */
					MSTRC.SUB_PARTS_NO=PRTMST.PARTS_NO AND
					MSTRC.CANCEL_FLAG='0' AND										/* �����t���O���u�L���v */
					(MSTRC.FACTORY_PS_STATUS!=:STATUS OR MSTRC.ABOLISH_DATE > CAST(:TODAY AS DATE)) AND		/* ���{�o�^�ς݂ł͂Ȃ����A�܂��͉ߋ��p�~�ł͂Ȃ��f�[�^ �}�X�N��OFF�ɂȂ����ۂɂ́A���̏��������O���� */
					(MSTRC.FACTORY_PS_STATUS=:STATUS AND MSTRC.ADOPT_DATE <= CAST(:DATE AS DATE) AND MSTRC.ABOLISH_DATE > CAST(:DATE AS DATE))	/* ���ߋ������w�莞�Ɏw�肷����t�����B�{�o�^�ς̂ݕ\������B�u�����N�̏ꍇ�͂��̏��������O���� */
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
	PARPRTNO,
	PRTNO,
	REVNO,
	OLDPRTNO,
	RNK
) AS
(
	SELECT distinct
		OLDSTRC.PARENT_PARTS_NO AS PARPRTNO,
		OLDSTRC.SUB_PARTS_NO AS PRTNO,
		OLDSTRC.ENGINEERING_PS_REV_NO AS REVNO,
		OLDSTRC.PREV_SUB_PARTS_NO AS OLDPRTNO,																				/* ���i�����R�[�h */
		RANK() OVER(PARTITION BY OLDSTRC.PARENT_PARTS_NO, OLDSTRC.SUB_PARTS_NO, OLDSTRC.ENGINEERING_PS_REV_NO ORDER BY OLDSTRC.PREV_SUB_PARTS_NO) AS RNK
	FROM
		TB001007 OLDSTRC					/* ���\�� */
	WHERE
		EXISTS								/* �W�J�\���ꗗ�ɑ��� */
		(
			SELECT
				*
			FROM
				TEMP
			WHERE
				TEMP.PRTNO=OLDSTRC.PARENT_PARTS_NO AND
				TEMP.PARPRTNO=OLDSTRC.SUB_PARTS_NO
		)
),
OLDPRTLIST
(
	PARPRTNO,		/* �Ώېe���i�ԍ� */
	PRTNO,			/* �Ώە��i�ԍ� */
	REVNO,			/* �Z�p�\�������ԍ� */
	OLDPRTNOLIST,	/* �����i�ԍ����J���}��؂肵������ */
	RNK,
	ISLEAF
) AS
(
	SELECT
		OLD.PARPRTNO,
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
					OLD2.PARPRTNO=OLD.PARPRTNO AND
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
		OLD.PARPRTNO,
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
					OLD2.PARPRTNO=OLD.PARPRTNO AND
					OLD2.PRTNO=OLD.PRTNO AND
					OLD2.REVNO=OLD.REVNO AND
					OLD2.RNK-1=OLD.RNK
			) > 0 
		THEN 0 ELSE 1 END AS ISLEAF
	FROM
		OLDPRT OLD,
		OLDPRTLIST OLDL
	WHERE
		OLD.PARPRTNO=OLDL.PARPRTNO AND
		OLD.PRTNO=OLDL.PRTNO AND
		OLD.REVNO=OLDL.REVNO AND
		OLD.RNK-1=OLDL.RNK
)
,RESULT 
(
	SUB_PARTS_NO,
	PARENT_PARTS_NO,
	PS_REV_NO,
	FACTORY_PS_REV_NO,
	FACTORY_PS_STATUS,
	APPROVED_DATE,
	APPROVER_USER_ID,
	EDITOR_USER_ID,
	ADOPT_DATE,
	ABOLISH_DATE,
	TMP_REGIST_DATE,
	PENDING_DECIDED_DATE,
	CONSUMPTION_ROUTING,
	PROCESSING_CODE,
	MANAGEMENT_STATUS,
	SUPPLY_CODE,
	SHIP_SUPPLY_CLASS,
	ADOPT_CHECK_CODE,
	UNIT_CLASS,
	DATA_CHECK_RESULT,
	REPR_OF_MAIN_ECS_NO,
	SKIP_FLAG,
	CANCEL_FLAG,
	ENGINEERING_PS_REV_NO,
	TMP_ABOLISH_DATE,
	TMP_CANCEL_FLAG,
	REMARKS,
	CREATED_USER_ID,
	CREATED_APP_EVENT_ID,
	CREATED_TIMESTAMP,
	UPDATED_USER_ID,
	UPDATED_APP_EVENT_ID,
	UPDATED_TIMESTAMP
) AS
(
	SELECT
		SUB_PARTS_NO,
		PARENT_PARTS_NO,
		PS_REV_NO,
		FACTORY_PS_REV_NO,
		FACTORY_PS_STATUS,
		APPROVED_DATE,
		APPROVER_USER_ID,
		EDITOR_USER_ID,
		ADOPT_DATE,
		ABOLISH_DATE,
		TMP_REGIST_DATE,
		PENDING_DECIDED_DATE,
		CONSUMPTION_ROUTING,
		PROCESSING_CODE,
		MANAGEMENT_STATUS,
		SUPPLY_CODE,
		SHIP_SUPPLY_CLASS,
		ADOPT_CHECK_CODE,
		UNIT_CLASS,
		DATA_CHECK_RESULT,
		REPR_OF_MAIN_ECS_NO,
		SKIP_FLAG,
		CANCEL_FLAG,
		ENGINEERING_PS_REV_NO,
		TMP_ABOLISH_DATE,
		TMP_CANCEL_FLAG,
		REMARKS,
		CREATED_USER_ID,
		CREATED_APP_EVENT_ID,
		CREATED_TIMESTAMP,
		UPDATED_USER_ID,
		UPDATED_APP_EVENT_ID,
		UPDATED_TIMESTAMP
	FROM
		(
			SELECT
				MSTRC.SUB_PARTS_NO,
				MSTRC.PARENT_PARTS_NO,
				MSTRC.PS_REV_NO,
				MSTRC.FACTORY_PS_REV_NO,
				MSTRC.FACTORY_PS_STATUS,
				MSTRC.APPROVED_DATE,
				MSTRC.APPROVER_USER_ID,
				MSTRC.EDITOR_USER_ID,
				MSTRC.ADOPT_DATE,
				MSTRC.ABOLISH_DATE,
				MSTRC.TMP_REGIST_DATE,
				MSTRC.PENDING_DECIDED_DATE,
				MSTRC.CONSUMPTION_ROUTING,
				MSTRC.PROCESSING_CODE,
				MSTRC.MANAGEMENT_STATUS,
				MSTRC.SUPPLY_CODE,
				MSTRC.SHIP_SUPPLY_CLASS,
				MSTRC.ADOPT_CHECK_CODE,
				MSTRC.UNIT_CLASS,
				MSTRC.DATA_CHECK_RESULT,
				MSTRC.REPR_OF_MAIN_ECS_NO,
				MSTRC.SKIP_FLAG,
				MSTRC.CANCEL_FLAG,
				MSTRC.ENGINEERING_PS_REV_NO,
				MSTRC.TMP_ABOLISH_DATE,
				MSTRC.TMP_CANCEL_FLAG,
				MSTRC.REMARKS,
				MSTRC.CREATED_USER_ID,
				MSTRC.CREATED_APP_EVENT_ID,
				MSTRC.CREATED_TIMESTAMP,
				MSTRC.UPDATED_USER_ID,
				MSTRC.UPDATED_APP_EVENT_ID,
				MSTRC.UPDATED_TIMESTAMP,
				MPRT1.JOB_SEQ_NO
			FROM
				TB004002 MSTRC
					/* �����O���[�v2 : ���W�J�����qPN�̑�����\�����邽�߂̏�� */
					LEFT OUTER JOIN TB004001 MPRT1 ON											/* �H�ꕔ�i���(�qPN�Ƃ��Ă̍H�ꕔ�i���) */
						MPRT1.PARTS_NO=MSTRC.SUB_PARTS_NO AND
						EXISTS
						(
							SELECT					/* 1.PS�ƍ̔p���Ԃ��d�����Ă������, 2.�H��X�e�[�^�X���傫������, 3.�ő�̋Z�p���i���� + �H�ꕔ�i���� �̏��ōł��D��x�̍����f�[�^���擾 */
								MAX(
										CASE WHEN
											MSTRC.ADOPT_DATE < DECODE(MSTRC.FACTORY_PS_STATUS, CAST(:STATUS AS CHAR(2)), DECODE(MPRT2.FACTORY_PN_STATUS, CAST(:STATUS AS CHAR(2)), MPRT2.ABOLISH_DATE, MPRT2.TMP_ABOLISH_DATE), MPRT2.TMP_ABOLISH_DATE) AND
											DECODE(MSTRC.FACTORY_PS_STATUS, CAST(:STATUS AS CHAR(2)), MSTRC.ABOLISH_DATE, MSTRC.TMP_ABOLISH_DATE) <  MPRT2.ADOPT_DATE THEN '1' /* �̔p���Ԃ��d�����Ă��� */
											ELSE '0' /* �̔p���Ԃ��d�����Ă��Ȃ� */
										END || MPRT2.FACTORY_PN_STATUS || MPRT2.ENGINEERING_PN_REV_NO || MPRT2.FACTORY_PN_REV_NO
									)
							FROM
								TB004001 MPRT2
							WHERE
								MPRT2.PARTS_NO=MPRT1.PARTS_NO AND
								MPRT2.CANCEL_FLAG='0' AND																									/* �����t���O���u�L���v(�qPN�͏�ɗL���ȃf�[�^�̂ݎ擾����) */
								(MPRT2.FACTORY_PN_STATUS=:STATUS AND MPRT2.ADOPT_DATE <= CAST(:DATE AS DATE) AND MPRT2.ABOLISH_DATE > CAST(:DATE AS DATE))	/* ���ߋ������w�莞�Ɏw�肷����t�����B�{�o�^�ς̂ݕ\������B�u�����N�̏ꍇ�͂��̏��������O���� */
							GROUP BY
								MPRT2.PARTS_NO
							HAVING
								(MPRT1.ENGINEERING_PN_REV_NO || MPRT1.FACTORY_PN_REV_NO)=
								RIGHT(MAX(
										CASE WHEN
											MSTRC.ADOPT_DATE < DECODE(MSTRC.FACTORY_PS_STATUS, :STATUS, DECODE(MPRT2.FACTORY_PN_STATUS, :STATUS, MPRT2.ABOLISH_DATE, MPRT2.TMP_ABOLISH_DATE), MPRT2.TMP_ABOLISH_DATE) AND
											DECODE(MSTRC.FACTORY_PS_STATUS, :STATUS, MSTRC.ABOLISH_DATE, MSTRC.TMP_ABOLISH_DATE) <  MPRT2.ADOPT_DATE THEN '1' 				/* �̔p���Ԃ��d�����Ă��� */
											ELSE '0' 																															/* �̔p���Ԃ��d�����Ă��Ȃ� */
										END || MPRT2.FACTORY_PN_STATUS || MPRT2.ENGINEERING_PN_REV_NO || MPRT2.FACTORY_PN_REV_NO
										)
									, 6)
						)
			WHERE
				EXISTS
				(
					SELECT
						*
					FROM
						TEMP 																															/* ���i�\���W�J���� */
					WHERE
						TEMP.PARPRTNO=MSTRC.PARENT_PARTS_NO AND
						TEMP.PRTNO=MSTRC.SUB_PARTS_NO
				)
		) 
	WHERE
		CANCEL_FLAG='0' AND																														/* �����t���O���u�L���v */
		(FACTORY_PS_STATUS!=:STATUS OR ABOLISH_DATE > CAST(:TODAY AS DATE)) AND																	/* ���{�o�^�ς݂ł͂Ȃ����A�܂��͉ߋ��p�~�ł͂Ȃ��f�[�^�B�}�X�N��OFF�ɂȂ����ۂɂ́A���̏��������O���� */
		(FACTORY_PS_STATUS=:STATUS AND ADOPT_DATE <= CAST(:DATE AS DATE) AND ABOLISH_DATE > CAST(:DATE AS DATE)) AND							/* ���ߋ������w�莞�Ɏw�肷����t�����B�{�o�^�ς̂ݕ\������B�u�����N�̏ꍇ�͂��̏��������O���� */
		PROCESSING_CODE=:PRCS_CD AND																											/* �����H�敪�̎w�� */
		CONSUMPTION_ROUTING=:CONS_RTNG AND																										/* ������H���̎w�� */
		JOB_SEQ_NO=:JOB_SEQ AND																													/* �������H���̎w�� */
		PROCESSING_CODE NOT IN ('9','R','Z') 																									/* ����ړ��P�ʂ͏��O�B�}�X�N��OFF�ɂȂ����ۂɂ́A���̏��������O���� */
	UNION ALL																																	/* �������t���O���u�����v�̃f�[�^���擾����B�}�X�N��OFF�ɂȂ����ۂɂ́AUNION ALL�ȉ���SELECT�������O���� */
	SELECT
		MSTRC.SUB_PARTS_NO, 
		MSTRC.PARENT_PARTS_NO,
		MSTRC.PS_REV_NO,
		MSTRC.FACTORY_PS_REV_NO,
		MSTRC.FACTORY_PS_STATUS,
		MSTRC.APPROVED_DATE,
		MSTRC.APPROVER_USER_ID,
		MSTRC.EDITOR_USER_ID,
		MSTRC.ADOPT_DATE,
		MSTRC.ABOLISH_DATE,
		MSTRC.TMP_REGIST_DATE,
		MSTRC.PENDING_DECIDED_DATE,
		MSTRC.CONSUMPTION_ROUTING,
		MSTRC.PROCESSING_CODE,
		MSTRC.MANAGEMENT_STATUS,
		MSTRC.SUPPLY_CODE,
		MSTRC.SHIP_SUPPLY_CLASS,
		MSTRC.ADOPT_CHECK_CODE,
		MSTRC.UNIT_CLASS,
		MSTRC.DATA_CHECK_RESULT,
		MSTRC.REPR_OF_MAIN_ECS_NO,
		MSTRC.SKIP_FLAG,
		MSTRC.CANCEL_FLAG,
		MSTRC.ENGINEERING_PS_REV_NO,
		MSTRC.TMP_ABOLISH_DATE,
		MSTRC.TMP_CANCEL_FLAG,
		MSTRC.REMARKS,
		MSTRC.CREATED_USER_ID,
		MSTRC.CREATED_APP_EVENT_ID,
		MSTRC.CREATED_TIMESTAMP,
		MSTRC.UPDATED_USER_ID,
		MSTRC.UPDATED_APP_EVENT_ID,
		MSTRC.UPDATED_TIMESTAMP
	FROM
		TB004002 MSTRC,
		RESULT 
	WHERE
		MSTRC.PARENT_PARTS_NO=RESULT.PARENT_PARTS_NO AND
		MSTRC.SUB_PARTS_NO=RESULT.SUB_PARTS_NO AND
		MSTRC.PS_REV_NO=RESULT.PS_REV_NO AND
		MSTRC.FACTORY_PS_REV_NO=LTRIM(TO_CHAR(RESULT.FACTORY_PS_REV_NO - 1, '000')) AND
		MSTRC.CANCEL_FLAG='1' 											/* �����t���O���u�����v */
)
SELECT
	SMBL,												/* S */
	CHKRSLT,											/* �f�[�^�`�F�b�N����(�p��) */
	LV,													/* Lv */
	DRWGCLS,											/* (*)Final�}�� */
	ITEMNO,												/* �i��ID�ԍ�  */
	ATFLG,												/* �v���Ӄ}�[�N */
	COUNT(DISTINCT DICITEMNO) AS �i�ڎ�������,			/* �i�ڎ�������(�i��ID�ԍ�������)�@�i��ID�ԍ����擾�ł��Ȃ������ꍇ�A 1���ȉ�:"N/A" 2���ȏ�:"?" */
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
		TEMP.PATH,																														/* �W�J�\�[�g�L�[ */
		NVL(STRC.AUTOMATIC_SYMBOL, '') AS SMBL,																							/* S */
		NVL(MSTRC.DATA_CHECK_RESULT, '') AS CHKRSLT,																					/* �f�[�^�`�F�b�N����(�p��) */
		TEMP.LV,																														/* Lv */
		CASE 
			WHEN TEMP.PARPRTNO='' THEN PRTMAX.DRAWING_CLASS
			ELSE NVL(PRT.DRAWING_CLASS, '') 
		END AS DRWGCLS,																													/* (*)Final�}�� */
		NVL(ITEM.ITEM_ID_NO, '') AS ITEMNO,																								/* �i��ID�ԍ�  */
		NVL(ITEM.ATTENTION_FLAG, '') AS ATFLG,																							/* �v���Ӄ}�[�N */
		ITEMDIC.ITEM_ID_NO AS DICITEMNO,																								/* �i�ڎ����ɓo�^����Ă���w��J�������̕i��ID */
		TEMP.PRTNO AS PRTNO,																											/* ���i�ԍ� */
		NVL(MSTRC.PS_REV_NO, '') AS REVNO,																								/* �ϔ� */
		NVL(MSTRC.FACTORY_PS_REV_NO, '') AS MREVNO,																						/* �H����� */ 
		CASE 
			WHEN TEMP.PARPRTNO='' THEN PRTMAX.PARTS_NAME
			ELSE NVL(PRT.PARTS_NAME, '') 
		END AS PRTNM,																													/* ���i���� */ 
		NVL(CDMST1.JP_DISPLAY_NAME, '') AS PNSTATUSJP,																					/* �H��X�e�[�^�X(���{��) */ 
		NVL(CDMST1.EN_DISPLAY_NAME, '') AS PNSTATUSEN,																					/* �H��X�e�[�^�X(�p��) */ 
		NVL(CDMST2.JP_DISPLAY_NAME, '') AS DNPRCDFLGJP,																					/* ��s���s�t���O(���{��) */ 
		NVL(CDMST2.EN_DISPLAY_NAME, '') AS DNPRCDFLGEN,																					/* ��s���s�t���O(�p��) */ 
		NVL(MSTRC.CONSUMPTION_ROUTING, '') AS COSRTNG,																					/* ����H�� */
		NVL(MPRT1.JOB_SEQ_NO, '') AS JOBSEQ,																							/* �����H�� */
		DECODE(MPRT1.SUPPLIER_CODE, NULL, '', DECODE(TRIM(MPRT1.SUPPLIER_CODE), '', SPL_DISP.SPLRCDLIST, MPRT1.SUPPLIER_CODE)) AS SPLRCDLIST_DISP,																											/* �����R�[�h(�\���p) */
		NVL(MSTRC.UNIT_CLASS, '') AS UNITCLS,																							/* ���j�b�g�敪 */
		NVL(MSTRC.PROCESSING_CODE, '') AS PRCSCD,																						/* ���H�敪 */
		DECODE(MSTRC.ADOPT_DATE, CAST(:FINAL_DATE AS DATE), '', TO_CHAR(MSTRC.ADOPT_DATE, 'YYYY/MM/DD')) AS ADPTDT,			/* �̗p�� */
		DECODE(DECODE(MSTRC.ABOLISH_DATE, CAST(:FINAL_DATE AS DATE), '', TO_CHAR(MSTRC.ABOLISH_DATE, 'YYYY/MM/DD')), '', DECODE(MSTRC.TMP_ABOLISH_DATE, CAST(:FINAL_DATE AS DATE), '', '(' || TO_CHAR(MSTRC.TMP_ABOLISH_DATE, 'YYYY/MM/DD')|| ')') ) AS ABLSDT,		/* �p�~�� (�\�����e���u�����N�Ɣ��f���ꂽ�ꍇ�́A���ʕt�Ŏb��p�~����\��) */
		DECODE(MSTRC.PENDING_DECIDED_DATE, CAST(:FINAL_DATE AS DATE) , '', '*') AS PENDFLG,									/* �����t���O */
		NVL(STRC.QUANTITY, 1) AS QTY, 																											/* ���� */
		NVL(MSTRC.REPR_OF_MAIN_ECS_NO, '') AS DNNO,																						/* ��ݒʑ�\�ݒ� */
		NVL(OLDPRTLIST.OLDPRTNOLIST, '') AS OLDLIST,																					/* �����i�ԍ�(�J���}��؂�) */
		NVL(MSTRC.REMARKS, '') AS RMKS,																									/* ���l */
		NVL(PRT_TITLE.DRAWING_SERIES, '') AS SERIES,																					/* �}�ʃV���[�Y */
		NVL(PRT_TITLE.DRAWING_BLOCK_NO, '') AS BLCK,																					/* �u���b�NNO */
		NVL(PRTDRWG_TITLE.DRAWING_NO, '') AS DRWGNO,																					/* �}�ʔԍ� */
		NVL(PRTDRWG_TITLE.DRAWING_REV_NO, '') AS DRWGREV,																				/* �}�ʉ����ԍ� */
		NVL(FBL.FSERIESES, '') AS FSERIESLIST,																									/* F�}�V���[�Y(�J���}��؂�) */
		NVL(FBL.FBLOCKS, '') AS FBLCKLIST,																										/* F�}�u���b�NNO(�J���}��؂�) */
		('1:' || NVL(MSTRC.MANAGEMENT_STATUS, '') || '2:' || NVL(MSTRC.SUPPLY_CODE, '') || '3:' || NVL(MSTRC.ADOPT_CHECK_CODE, '')) AS MINFO,	/* (*2) �Ǘ��敪�A�����R�[�h�A�̊m�R�[�h */
		DECODE(TRIM(NVL(MSTRC.CANCEL_FLAG, '')), '', DECODE(TRIM(NVL(MSTRC.TMP_CANCEL_FLAG, '')), '', '', '(' || NVL(MSTRC.TMP_CANCEL_FLAG, '') || ')')) AS CANCELFLG,											/* �����t���O(�\�����e���u�����N�Ɣ��f���ꂽ�ꍇ�́A���ʕt�Ŏb�薳���t���O��\��) */
		NVL(MSTRC.FACTORY_PS_STATUS, '') AS FCTY_STATUS,																							/* �H��X�e�[�^�X */
		NVL(MPRT_TITLE.PARTS_NO, '') AS TITLE_PRTNO,																					/* �^�C�g���}��_���i�ԍ� */
		NVL(MPRT_TITLE.ENGINEERING_PN_REV_NO, '') AS TITLE_REVNO,																		/* �^�C�g���}��_�Z�p���i�����ԍ� */
		NVL(MPRT_TITLE.FACTORY_PN_REV_NO, '') AS TITLE_MREVNO,																			/* �^�C�g���}��_�H�ꕔ�i�����ԍ� */
		NVL(PRT_TITLE.DRAWING_CLASS, '') AS TITLE_DRWGCLS,																				/* �^�C�g���}��_Final�}�� */
		PRTMAX.DRAWING_SERIES AS RECENTLY_SERIES,																						/* �ŐV����_�}�ʃV���[�Y */
		PRTMAX.DRAWING_BLOCK_NO AS RECENTLY_BLCK,																						/* �ŐV����_�u���b�NNO */
		BLCK.BODY_UNIT_DIV AS RECENTLY_BUCLS,																							/* �ŐV����_BODY/UNIT�敪 */
		PRTMAX.PARTS_NAME AS RECENTLY_PRTNM,																							/* �ŐV����_���i���� */
		CASE
			WHEN SPL4.SPLRCDLIST IS NULL OR SPL4.SPLRCDLIST LIKE '%' || MPRT1.SUPPLIER_CODE || '%' THEN '0' 
			ELSE '1' 
		END AS SPLRVNTFLG,																												/* ����捷�كt���O 0:���قȂ��A1:���ق��� */
		NVL(SPL1.SPLRCDLIST, '') AS SPLRCDLIST_1,																								/* �����R�[�h(�O���f��) CSV�t�@�C���o�͗p */
		NVL(SPL2.SPLRCDLIST, '') AS SPLRCDLIST_2,																								/* �����R�[�h(�i��ID)   CSV�t�@�C���o�͗p */
		NVL(SPL3.SPLRCDLIST, '') AS SPLRCDLIST_3,																								/* �����R�[�h(�w���˗�) CSV�t�@�C���o�͗p */
		NVL(SPL4.SPLRCDLIST, '') AS SPLRCDLIST_4,																								/* �����R�[�h(�z�z����) CSV�t�@�C���o�͗p */
		NVL(TRIM(MPRT1.SUPPLIER_CODE), '') AS SPLRCDLIST_5																								/* �����R�[�h(����) CSV�t�@�C���o�͗p */
	FROM
		TEMP 																														/* ���i�\���W�J���� */
		/* �����O���[�v1 : ���W�J����PS�̏����擾 */
			LEFT OUTER JOIN RESULT MSTRC ON																							/* �H��\����� */
				MSTRC.PARENT_PARTS_NO=TEMP.PARPRTNO AND
				MSTRC.SUB_PARTS_NO=TEMP.PRTNO 
			LEFT OUTER JOIN TB001004 STRC ON																							/* ���i�\�� */
				STRC.PARENT_PARTS_NO=MSTRC.PARENT_PARTS_NO AND
				STRC.SUB_PARTS_NO=MSTRC.SUB_PARTS_NO AND
				STRC.ENGINEERING_PS_REV_NO=MSTRC.ENGINEERING_PS_REV_NO
			LEFT OUTER JOIN OLDPRTLIST ON																								/* �����i�ԍ� (�J���}��؂�) */
				OLDPRTLIST.PRTNO=STRC.SUB_PARTS_NO AND
				OLDPRTLIST.REVNO=STRC.ENGINEERING_PS_REV_NO AND
				OLDPRTLIST.ISLEAF=1
			LEFT OUTER JOIN TB003001 DSGN1 ON																							/* �݌v�ʒm */
				DSGN1.ECS_NO=MSTRC.REPR_OF_MAIN_ECS_NO AND
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
			LEFT OUTER JOIN TB004001 MPRT_TITLE ON																						/* �H�ꕔ�i��� (���̍H�ꕔ�i��񂪑�����^�C�g���}�ʂƂ��Ă̍H�ꕔ�i���) */
					MPRT_TITLE.PARTS_NO=MSTRC.PARENT_PARTS_NO AND
					MPRT_TITLE.REPR_OF_MAIN_ECS_NO=MSTRC.REPR_OF_MAIN_ECS_NO
			LEFT OUTER JOIN TB001002 PRTDRWG_TITLE ON																					/* ���i�}�� (���̍H�ꕔ�i��񂪑�����^�C�g���}�ʂƂ��Ă̕��i�}��)*/
					PRTDRWG_TITLE.PARTS_NO=MPRT_TITLE.PARTS_NO AND
					PRTDRWG_TITLE.ENGINEERING_PN_REV_NO=MPRT_TITLE.ENGINEERING_PN_REV_NO
			LEFT OUTER JOIN TB001003 PRT_TITLE ON																						/* ���i���� (���̍H�ꕔ�i��񂪑�����^�C�g���}�ʂƂ��Ă̕��i����) */
					PRT_TITLE.PARTS_NO=MPRT_TITLE.PARTS_NO AND
					PRT_TITLE.PARTS_PROP_REV_NO=MPRT_TITLE.PARTS_PROP_REV_NO
			LEFT OUTER JOIN TB011015 CDMST1 ON																							/* �R�[�h�}�X�^�[(�H����X�e�[�^�X�擾�p) */
				CDMST1.CODE_GROUP_ID='CDGRP005' AND																						/* �H����X�e�[�^�X */
				CDMST1.CODE_VALUE=MSTRC.FACTORY_PS_STATUS
			LEFT OUTER JOIN TB011015 CDMST2 ON																							/* �R�[�h�}�X�^�[(��s���s�t���O�擾�p) */
				CDMST2.CODE_GROUP_ID='CDGRP030' AND																						/* ��s���s�t���O */
				CDMST2.CODE_VALUE=DSGN1.PRECEDE_FLAG
			LEFT OUTER JOIN FINALBLCKLIST FBL ON																						/* F�}�u���b�N�AF�}�V���[�Y(�J���}��؂�) */
				FBL.PRTNO=TEMP.PRTNO AND
				FBL.ISLEAF=1
		/* �����O���[�v2 : ���W�J�����\���̎qPN�̕i��ID���擾���邽�߂̏�� */
			INNER JOIN TB001003 PRTMAX ON																								/* ���i���� (�qPN�̍ő�̏��������ԍ�) */	
				PRTMAX.PARTS_NO=TEMP.PRTNO AND
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
			LEFT OUTER JOIN TB006001 ITEM ON																							/* �i��ID */
				EXISTS
				(
					SELECT
						*
					FROM
						TB006006 PRTITEM
					WHERE
						PRTITEM.MC_DEV_MODEL_CODE=DECODE(TRIM(:MCMDLCD), '', DECODE(BLCK.BODY_UNIT_DIV, 'U', :UNTN, PRTMAX.DRAWING_SERIES), DECODE(:MCMDLCD, 'UNIT', :UNTN, :MCMDLCD)) AND
						PRTITEM.PARTS_NO=PRTMAX.PARTS_NO AND																					/* ���i�ԍ� */
						PRTITEM.ITEM_ID_NO=ITEM.ITEM_ID_NO
				)
			LEFT OUTER JOIN TB006002 ITEMDIC ON																								/* �i�ڎ���(���i�i�ڊǗ��ɓo�^����Ă���ID�͏��O */
				ITEMDIC.FUNCTION=SUBSTR(PRTMAX.PARTS_NO, 1, 5) AND																			/* �t�@���N�V����(���i�ԍ��̏�5��) */
				EXISTS
				(
					SELECT
						*
					FROM
						TB006004 MDLITEM
					WHERE
						MDLITEM.MC_DEV_MODEL_CODE=DECODE(TRIM(:MCMDLCD), '', DECODE(BLCK.BODY_UNIT_DIV, 'U', :UNTN, PRTMAX.DRAWING_SERIES), DECODE(:MCMDLCD, 'UNIT', :UNTN, :MCMDLCD)) AND
						MDLITEM.ITEM_ID_NO=ITEMDIC.ITEM_ID_NO																				/* �i��ID�ԍ� */
				) AND
				ITEMDIC.ITEM_NAME=PRTMAX.PARTS_NAME AND																						/* �ŐV�����̕��i���� */
				ITEMDIC.ITEM_ID_NO!=NVL(ITEM.ITEM_ID_NO, '')
		/* �����O���[�v2 : ���W�J�����qPN�̑�����\�����邽�߂̏�� */
			LEFT OUTER JOIN TB004001 MPRT1 ON											/* �H�ꕔ�i���(�qPN�Ƃ��Ă̍H�ꕔ�i���) */
				MPRT1.PARTS_NO=MSTRC.SUB_PARTS_NO AND
				EXISTS
				(
					SELECT					/* 1.PS�ƍ̔p���Ԃ��d�����Ă������, 2.�H��X�e�[�^�X���傫������, 3.�ő�̋Z�p���i���� + �H�ꕔ�i���� �̏��ōł��D��x�̍����f�[�^���擾 */
						MAX(
								CASE WHEN
									MSTRC.ADOPT_DATE < DECODE(MSTRC.FACTORY_PS_STATUS, CAST(:STATUS AS CHAR(2)), DECODE(MPRT2.FACTORY_PN_STATUS, CAST(:STATUS AS CHAR(2)), MPRT2.ABOLISH_DATE, MPRT2.TMP_ABOLISH_DATE), MPRT2.TMP_ABOLISH_DATE) AND
									DECODE(MSTRC.FACTORY_PS_STATUS, CAST(:STATUS AS CHAR(2)), MSTRC.ABOLISH_DATE, MSTRC.TMP_ABOLISH_DATE) <  MPRT2.ADOPT_DATE THEN '1' /* �̔p���Ԃ��d�����Ă��� */
									ELSE '0' /* �̔p���Ԃ��d�����Ă��Ȃ� */
								END || MPRT2.FACTORY_PN_STATUS || MPRT2.ENGINEERING_PN_REV_NO || MPRT2.FACTORY_PN_REV_NO
							)
					FROM
						TB004001 MPRT2
					WHERE
						MPRT2.PARTS_NO=MPRT1.PARTS_NO AND
						MPRT2.CANCEL_FLAG='0' AND																									/* �����t���O���u�L���v(�qPN�͏�ɗL���ȃf�[�^�̂ݎ擾����) */
						(MPRT2.FACTORY_PN_STATUS=:STATUS AND MPRT2.ADOPT_DATE <= CAST(:DATE AS DATE) AND MPRT2.ABOLISH_DATE > CAST(:DATE AS DATE))	/* ���ߋ������w�莞�Ɏw�肷����t�����B�{�o�^�ς̂ݕ\������B�u�����N�̏ꍇ�͂��̏��������O���� */
					GROUP BY
						MPRT2.PARTS_NO
					HAVING
						(MPRT1.ENGINEERING_PN_REV_NO || MPRT1.FACTORY_PN_REV_NO)=
						RIGHT(MAX(
								CASE WHEN
									MSTRC.ADOPT_DATE < DECODE(MSTRC.FACTORY_PS_STATUS, :STATUS, DECODE(MPRT2.FACTORY_PN_STATUS, :STATUS, MPRT2.ABOLISH_DATE, MPRT2.TMP_ABOLISH_DATE), MPRT2.TMP_ABOLISH_DATE) AND
									DECODE(MSTRC.FACTORY_PS_STATUS, :STATUS, MSTRC.ABOLISH_DATE, MSTRC.TMP_ABOLISH_DATE) <  MPRT2.ADOPT_DATE THEN '1' 				/* �̔p���Ԃ��d�����Ă��� */
									ELSE '0' 																															/* �̔p���Ԃ��d�����Ă��Ȃ� */
								END || MPRT2.FACTORY_PN_STATUS || MPRT2.ENGINEERING_PN_REV_NO || MPRT2.FACTORY_PN_REV_NO
								)
							, 6)
				)
			LEFT JOIN TB001003 PRT ON																									/* ���i���� (�qPN�H�ꕔ�i���̏��������ԍ��ƍ��v) */	
				PRT.PARTS_NO=MPRT1.PARTS_NO AND
				PRT.PARTS_PROP_REV_NO=MPRT1.PARTS_PROP_REV_NO
			LEFT OUTER JOIN SPLRLIST SPL_DISP ON																						/* �����R�[�h(�������^�C�v���ő�̎����R�[�h���J���}��؂�) */
				SPL_DISP.PRTNO=MPRT1.PARTS_NO AND
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
			LEFT OUTER JOIN SPLRLIST SPL1 ON																								/* �����R�[�h�i�O���f���j */
				SPL1.PRTNO=MPRT1.PARTS_NO AND
				SPL1.SRCTYPE='1' AND
				SPL1.ISLEAF=1
			LEFT OUTER JOIN SPLRLIST SPL2 ON																								/* �����R�[�h�i�i��ID�j */
				SPL2.PRTNO=MPRT1.PARTS_NO AND
				SPL2.SRCTYPE='2' AND
				SPL2.ISLEAF=1
			LEFT OUTER JOIN SPLRLIST SPL3 ON																								/* �����R�[�h�i�w���˗��j */
				SPL3.PRTNO=MPRT1.PARTS_NO AND
				SPL3.SRCTYPE='3' AND
				SPL3.ISLEAF=1
			LEFT OUTER JOIN SPLRLIST SPL4 ON																								/* �����R�[�h�i�z�z���сj */
				SPL4.PRTNO=MPRT1.PARTS_NO AND
				SPL4.SRCTYPE='4' AND
				SPL4.ISLEAF=1
	WHERE
		TEMP.PARPRTNO!='' AND 
		MSTRC.SUB_PARTS_NO IS NULL			/* �W�J�������ʍ\���f�[�^�ł���ɂ�������炸�A�H��\����񂪎擾�ł��Ȃ��������R�[�h�͕\���ΏۊO */
)
GROUP BY
	PATH,
	SMBL,																																	/* S */
	CHKRSLT,																																/* �f�[�^�`�F�b�N����(�p��) */
	LV,																																		/* Lv */
	DRWGCLS,																																/* (*)Final�}�� */
	ITEMNO,																																	/* �i��ID�ԍ�  */
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
	PATH,												/* �W�J�p�X (�e���i�ԍ� + ���o���ԍ� + ���o���ԍ���ށv�̘A���L�[) */
	PRTNO,												/* ���i�ԍ� (���o���ԍ� + ���o���ԍ���ނ݂̂Ő���ɕ��Ԃ͂������A�O�̂��ߒǉ�) */
	REVNO,												/* �ϔ� */
	MREVNO												/* �H����� */ 
;
