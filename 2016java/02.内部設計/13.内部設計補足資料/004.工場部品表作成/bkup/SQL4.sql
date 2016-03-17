WITH TEMP
	(
		PATH,		/* 「親部品番号 + 見出し番号 + 見出し番号種類」のパス */
		PARPRTNO,	/* 親部品番号 */
		PRTNO,		/* 部品番号 */
		LV			/* 展開レベル */
	) AS
	(
		SELECT  
			PRTMST.PARTS_NO || ':' AS PATH,											/* ソートキー TOP部品番号 */
			'' AS PARPRTNO,
			PRTMST.PARTS_NO AS PRTNO,
			CASE 
				WHEN PRTMAX.DRAWING_CLASS='F' THEN 0 
				ELSE 1 
			END AS LV
		FROM
			TB001001 PRTMST															/* 部品 */
				INNER JOIN TB001003 PRTMAX ON										/* 部品諸元 (最大の諸元改訂番号) */	
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
			PRTMST.PARTS_NO=:PRTNO AND											/* 部品番号指定 */	
			EXISTS																	/* 指定したmc開発符号、ブロックNOが表示対象工場部品データに設定されている部品番号であること */
			(
				SELECT
					*
				FROM
					TB004001 MPRT 													/* 工場部品情報 */
				WHERE
					MPRT.PARTS_NO=PRTMST.PARTS_NO
					AND MPRT.CANCEL_FLAG='0' AND																		/* 無効フラグが「有効」 */
					(MPRT.FACTORY_PN_STATUS!=:STATUS OR MPRT.ABOLISH_DATE > CAST(:TODAY AS DATE)) AND		/* ◎本登録済みではないか、または過去廃止ではないデータ マスクがOFFになった際には、この条件を除外する */
					(MPRT.FACTORY_PN_STATUS=:STATUS AND MPRT.ADOPT_DATE <= CAST(:DATE AS DATE) AND MPRT.ABOLISH_DATE > CAST(:DATE AS DATE))	/* ◇過去履歴指定時に指定する日付条件。本登録済のみ表示する。ブランクの場合はこの条件を除外する */
			)
		UNION ALL
		SELECT
			(TEMP.PATH || TEMP.PRTNO || '/' || STRC.INDEX || STRC.KIND) AS PATH,	/* 展開表示パス (「親部品番号 + 見出し番号 + 見出し番号種類」) */
			TEMP.PRTNO AS PARPRTNO,
			PRTMST.PARTS_NO AS PRTNO,
			TEMP.LV + 1 AS LV														/* 展開レベル */
		FROM
			TEMP,
			TB001001 PRTMST,														/* 部品 */
			TB001004 STRC															/* 部品構成 */
		WHERE
			TEMP.LV < :LEVEL AND													/* 展開レベルの指定 */
			EXISTS																	/* 構成展開するのに妥当な構成子部品として存在している */
			(
				SELECT
					*
				FROM
					TB004002 MSTRC 													/* 工場構成情報 */
				WHERE
					MSTRC.PARENT_PARTS_NO=TEMP.PRTNO AND							/* 構成展開 */
					MSTRC.SUB_PARTS_NO=PRTMST.PARTS_NO AND
					MSTRC.CANCEL_FLAG='0' AND										/* 無効フラグが「有効」 */
					(MSTRC.FACTORY_PS_STATUS!=:STATUS OR MSTRC.ABOLISH_DATE > CAST(:TODAY AS DATE)) AND		/* ◎本登録済みではないか、または過去廃止ではないデータ マスクがOFFになった際には、この条件を除外する */
					(MSTRC.FACTORY_PS_STATUS=:STATUS AND MSTRC.ADOPT_DATE <= CAST(:DATE AS DATE) AND MSTRC.ABOLISH_DATE > CAST(:DATE AS DATE))	/* ◇過去履歴指定時に指定する日付条件。本登録済のみ表示する。ブランクの場合はこの条件を除外する */
			) AND
			STRC.PARENT_PARTS_NO=TEMP.PRTNO AND
			STRC.SUB_PARTS_NO=PRTMST.PARTS_NO AND
			EXISTS																	/* 表示対象となる親子部番の技術としての最新改訂を取得。この見出し情報をソートに使用する */
			(
				SELECT
					MAX(STRC2.ENGINEERING_PS_REV_NO)
				FROM
					TB001004 STRC2													/* 部品構成 */
				WHERE
					STRC2.PARENT_PARTS_NO=STRC.PARENT_PARTS_NO AND
					STRC2.SUB_PARTS_NO=STRC.SUB_PARTS_NO
				HAVING
					STRC.ENGINEERING_PS_REV_NO=MAX(STRC2.ENGINEERING_PS_REV_NO)
			)
)
,FBLCK /* F図ブロック, F図シリーズ */
(
	PRTNO,
	FSERIES,
	FBLOCK,
	RNK
) AS
(
	SELECT distinct
		RELPRT.PARTS_NO AS PRTNO,
		PRT.DRAWING_SERIES AS FSERIES,															/* ファイナル部品の図面シリーズ */
		PRT.DRAWING_BLOCK_NO AS FBLOCK,															/* ファイナル部品のブロックNO */
		RANK() OVER(PARTITION BY RELPRT.PARTS_NO ORDER BY PRT.DRAWING_BLOCK_NO) AS RNK
	FROM
		TB001005 RELPRT						/* 関連部品 */
			INNER JOIN 	TB001003 PRT ON		/* 部品諸元 */
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
						PRT.PARTS_PROP_REV_NO=MAX(PRT2.PARTS_PROP_REV_NO)		/* 最新改訂を取得 */
				)
	WHERE
		RELPRT.RELATION_TYPE='F' AND											/* 関連タイプ='F' (ファイナル) */
		EXISTS																	/* 正展開された部品番号(TEMP)に存在する */
		(
			SELECT
				*
			FROM
				TEMP
			WHERE
				TEMP.PRTNO=RELPRT.PARTS_NO
		)
),
FINALBLCKLIST	/* ファイナルの図面シリーズ、ブロックをカンマ区切りで取得 */
(
	PRTNO,		/* 対象部品番号 */
	FSERIESES,	/* F図図面シリーズをカンマ区切りしたもの */
	FBLOCKS,	/* F図ブロックをカンマ区切りしたもの */
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
,SPLR /* 取引先コード */
(
	PRTNO,
	SPLRCD,
	SRCTYPE,
	RNK
) AS
(
	SELECT distinct
		PRTSPLR1.PARTS_NO AS PRTNO,
		PRTSPLR1.SUPPLIER_CODE AS SPLRCD,																			/* 部品取引先コード */
		PRTSPLR1.SOURCE_TYPE AS SRCTYPE,																			/* 発生源タイプ */
		RANK() OVER(PARTITION BY PRTSPLR1.PARTS_NO, PRTSPLR1.SOURCE_TYPE ORDER BY PRTSPLR1.SUPPLIER_CODE) AS RNK
	FROM
		TB002017 PRTSPLR1							/* 部品取引先 */
	WHERE
		EXISTS										/* 展開部品一覧に存在 */
		(
			SELECT
				*
			FROM
				TEMP
			WHERE
				TEMP.PRTNO=PRTSPLR1.PARTS_NO
		)
),
SPLRLIST	/* 部品取引先をカンマ区切りで取得 */
(
	PRTNO,		/* 対象部品番号 */
	SRCTYPE,	/* 発生源タイプ */
	SPLRCDLIST,	/* 部品取引先をカンマ区切りしたもの */
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
,OLDPRT /* 旧部品番号 */
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
		OLDSTRC.PREV_SUB_PARTS_NO AS OLDPRTNO,																				/* 部品取引先コード */
		RANK() OVER(PARTITION BY OLDSTRC.PARENT_PARTS_NO, OLDSTRC.SUB_PARTS_NO, OLDSTRC.ENGINEERING_PS_REV_NO ORDER BY OLDSTRC.PREV_SUB_PARTS_NO) AS RNK
	FROM
		TB001007 OLDSTRC					/* 旧構成 */
	WHERE
		EXISTS								/* 展開構成一覧に存在 */
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
	PARPRTNO,		/* 対象親部品番号 */
	PRTNO,			/* 対象部品番号 */
	REVNO,			/* 技術構成改訂番号 */
	OLDPRTNOLIST,	/* 旧部品番号をカンマ区切りしたもの */
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
					/* 結合グループ2 : 正展開した子PNの属性を表示するための情報 */
					LEFT OUTER JOIN TB004001 MPRT1 ON											/* 工場部品情報(子PNとしての工場部品情報) */
						MPRT1.PARTS_NO=MSTRC.SUB_PARTS_NO AND
						EXISTS
						(
							SELECT					/* 1.PSと採廃期間が重複しているもの, 2.工場ステータスが大きいもの, 3.最大の技術部品改訂 + 工場部品改訂 の順で最も優先度の高いデータを取得 */
								MAX(
										CASE WHEN
											MSTRC.ADOPT_DATE < DECODE(MSTRC.FACTORY_PS_STATUS, CAST(:STATUS AS CHAR(2)), DECODE(MPRT2.FACTORY_PN_STATUS, CAST(:STATUS AS CHAR(2)), MPRT2.ABOLISH_DATE, MPRT2.TMP_ABOLISH_DATE), MPRT2.TMP_ABOLISH_DATE) AND
											DECODE(MSTRC.FACTORY_PS_STATUS, CAST(:STATUS AS CHAR(2)), MSTRC.ABOLISH_DATE, MSTRC.TMP_ABOLISH_DATE) <  MPRT2.ADOPT_DATE THEN '1' /* 採廃期間が重複している */
											ELSE '0' /* 採廃期間が重複していない */
										END || MPRT2.FACTORY_PN_STATUS || MPRT2.ENGINEERING_PN_REV_NO || MPRT2.FACTORY_PN_REV_NO
									)
							FROM
								TB004001 MPRT2
							WHERE
								MPRT2.PARTS_NO=MPRT1.PARTS_NO AND
								MPRT2.CANCEL_FLAG='0' AND																									/* 無効フラグが「有効」(子PNは常に有効なデータのみ取得する) */
								(MPRT2.FACTORY_PN_STATUS=:STATUS AND MPRT2.ADOPT_DATE <= CAST(:DATE AS DATE) AND MPRT2.ABOLISH_DATE > CAST(:DATE AS DATE))	/* ◇過去履歴指定時に指定する日付条件。本登録済のみ表示する。ブランクの場合はこの条件を除外する */
							GROUP BY
								MPRT2.PARTS_NO
							HAVING
								(MPRT1.ENGINEERING_PN_REV_NO || MPRT1.FACTORY_PN_REV_NO)=
								RIGHT(MAX(
										CASE WHEN
											MSTRC.ADOPT_DATE < DECODE(MSTRC.FACTORY_PS_STATUS, :STATUS, DECODE(MPRT2.FACTORY_PN_STATUS, :STATUS, MPRT2.ABOLISH_DATE, MPRT2.TMP_ABOLISH_DATE), MPRT2.TMP_ABOLISH_DATE) AND
											DECODE(MSTRC.FACTORY_PS_STATUS, :STATUS, MSTRC.ABOLISH_DATE, MSTRC.TMP_ABOLISH_DATE) <  MPRT2.ADOPT_DATE THEN '1' 				/* 採廃期間が重複している */
											ELSE '0' 																															/* 採廃期間が重複していない */
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
						TEMP 																															/* 部品構成展開結果 */
					WHERE
						TEMP.PARPRTNO=MSTRC.PARENT_PARTS_NO AND
						TEMP.PRTNO=MSTRC.SUB_PARTS_NO
				)
		) 
	WHERE
		CANCEL_FLAG='0' AND																														/* 無効フラグが「有効」 */
		(FACTORY_PS_STATUS!=:STATUS OR ABOLISH_DATE > CAST(:TODAY AS DATE)) AND																	/* ◎本登録済みではないか、または過去廃止ではないデータ。マスクがOFFになった際には、この条件を除外する */
		(FACTORY_PS_STATUS=:STATUS AND ADOPT_DATE <= CAST(:DATE AS DATE) AND ABOLISH_DATE > CAST(:DATE AS DATE)) AND							/* ◇過去履歴指定時に指定する日付条件。本登録済のみ表示する。ブランクの場合はこの条件を除外する */
		PROCESSING_CODE=:PRCS_CD AND																											/* ▼加工区分の指定 */
		CONSUMPTION_ROUTING=:CONS_RTNG AND																										/* □消費工順の指定 */
		JOB_SEQ_NO=:JOB_SEQ AND																													/* ◆発生工順の指定 */
		PROCESSING_CODE NOT IN ('9','R','Z') 																									/* ◎非移動単位は除外。マスクがOFFになった際には、この条件を除外する */
	UNION ALL																																	/* ◎無効フラグが「無効」のデータも取得する。マスクがOFFになった際には、UNION ALL以下のSELECT文を除外する */
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
		MSTRC.CANCEL_FLAG='1' 											/* 無効フラグが「無効」 */
)
SELECT
	SMBL,												/* S */
	CHKRSLT,											/* データチェック結果(英語) */
	LV,													/* Lv */
	DRWGCLS,											/* (*)Final図番 */
	ITEMNO,												/* 品目ID番号  */
	ATFLG,												/* 要注意マーク */
	COUNT(DISTINCT DICITEMNO) AS 品目辞書件数,			/* 品目辞書件数(品目ID番号を除く)　品目ID番号が取得できなかった場合、 1件以下:"N/A" 2件以上:"?" */
	PRTNO,												/* 部品番号 */
	REVNO,												/* 変番 */
	MREVNO,												/* 工場改訂 */ 
	PRTNM,												/* 部品名称 */ 
	PNSTATUSJP,											/* 工場ステータス(日本語) */ 
	PNSTATUSEN,											/* 工場ステータス(英語) */ 
	DNPRCDFLGJP,										/* 先行発行フラグ(日本語) */ 
	DNPRCDFLGEN,										/* 先行発行フラグ(英語) */ 
	COSRTNG,											/* 消費工順 */
	JOBSEQ,												/* 発生工順 */
	SPLRCDLIST_DISP,									/* 取引先コード(表示用) */
	UNITCLS,											/* ユニット区分 */
	PRCSCD,												/* 加工区分 */
	ADPTDT,												/* 採用日 */
	ABLSDT,												/* 廃止日 (表示内容がブランクと判断された場合は、括弧付で暫定廃止日を表示) */
	PENDFLG,											/* 未決フラグ */
	QTY, 												/* 員数 */
	DNNO,												/* 主設通代表設通 */
	OLDLIST,											/* 旧部品番号(カンマ区切り) */
	RMKS,												/* 備考 */
	SERIES,												/* 図面シリーズ */
	BLCK,												/* ブロックNO */
	DRWGNO,												/* 図面番号 */
	DRWGREV,											/* 図面改訂番号 */
	FSERIESLIST,										/* F図シリーズ(カンマ区切り) */
	FBLCKLIST,											/* F図ブロックNO(カンマ区切り) */
	MINFO,												/* (*2) 管理区分、供給コード、採確コード */
	CANCELFLG,											/* 無効フラグ(表示内容がブランクと判断された場合は、括弧付で暫定無効フラグを表示) */
	FCTY_STATUS,										/* 工場ステータス */
	TITLE_PRTNO,										/* タイトル図面_ */
	TITLE_REVNO,										/* タイトル図面_技術部品改訂番号 */
	TITLE_MREVNO,										/* タイトル図面_工場部品改訂番号 */
	TITLE_DRWGCLS,										/* タイトル図面_Final図番 */
	RECENTLY_SERIES,									/* 最新諸元_図面シリーズ */
	RECENTLY_BLCK,										/* 最新諸元_ブロックNO */
	RECENTLY_BUCLS,										/* 最新諸元_BODY/UNIT区分 */
	RECENTLY_PRTNM,										/* 最新諸元_部品名称 */
	SPLRVNTFLG,											/* 取引先差異フラグ 0:差異なし、1:差異あり */
	SPLRCDLIST_1,										/* 取引先コード(前モデル) CSVファイル出力用 */
	SPLRCDLIST_2,										/* 取引先コード(品目ID)   CSVファイル出力用 */
	SPLRCDLIST_3,										/* 取引先コード(購買依頼) CSVファイル出力用 */
	SPLRCDLIST_4,										/* 取引先コード(配布実績) CSVファイル出力用 */
	SPLRCDLIST_5										/* 取引先コード(入力)     CSVファイル出力用 */
FROM
(
	SELECT
		TEMP.PATH,																														/* 展開ソートキー */
		NVL(STRC.AUTOMATIC_SYMBOL, '') AS SMBL,																							/* S */
		NVL(MSTRC.DATA_CHECK_RESULT, '') AS CHKRSLT,																					/* データチェック結果(英語) */
		TEMP.LV,																														/* Lv */
		CASE 
			WHEN TEMP.PARPRTNO='' THEN PRTMAX.DRAWING_CLASS
			ELSE NVL(PRT.DRAWING_CLASS, '') 
		END AS DRWGCLS,																													/* (*)Final図番 */
		NVL(ITEM.ITEM_ID_NO, '') AS ITEMNO,																								/* 品目ID番号  */
		NVL(ITEM.ATTENTION_FLAG, '') AS ATFLG,																							/* 要注意マーク */
		ITEMDIC.ITEM_ID_NO AS DICITEMNO,																								/* 品目辞書に登録されている指定開発符号の品目ID */
		TEMP.PRTNO AS PRTNO,																											/* 部品番号 */
		NVL(MSTRC.PS_REV_NO, '') AS REVNO,																								/* 変番 */
		NVL(MSTRC.FACTORY_PS_REV_NO, '') AS MREVNO,																						/* 工場改訂 */ 
		CASE 
			WHEN TEMP.PARPRTNO='' THEN PRTMAX.PARTS_NAME
			ELSE NVL(PRT.PARTS_NAME, '') 
		END AS PRTNM,																													/* 部品名称 */ 
		NVL(CDMST1.JP_DISPLAY_NAME, '') AS PNSTATUSJP,																					/* 工場ステータス(日本語) */ 
		NVL(CDMST1.EN_DISPLAY_NAME, '') AS PNSTATUSEN,																					/* 工場ステータス(英語) */ 
		NVL(CDMST2.JP_DISPLAY_NAME, '') AS DNPRCDFLGJP,																					/* 先行発行フラグ(日本語) */ 
		NVL(CDMST2.EN_DISPLAY_NAME, '') AS DNPRCDFLGEN,																					/* 先行発行フラグ(英語) */ 
		NVL(MSTRC.CONSUMPTION_ROUTING, '') AS COSRTNG,																					/* 消費工順 */
		NVL(MPRT1.JOB_SEQ_NO, '') AS JOBSEQ,																							/* 発生工順 */
		DECODE(MPRT1.SUPPLIER_CODE, NULL, '', DECODE(TRIM(MPRT1.SUPPLIER_CODE), '', SPL_DISP.SPLRCDLIST, MPRT1.SUPPLIER_CODE)) AS SPLRCDLIST_DISP,																											/* 取引先コード(表示用) */
		NVL(MSTRC.UNIT_CLASS, '') AS UNITCLS,																							/* ユニット区分 */
		NVL(MSTRC.PROCESSING_CODE, '') AS PRCSCD,																						/* 加工区分 */
		DECODE(MSTRC.ADOPT_DATE, CAST(:FINAL_DATE AS DATE), '', TO_CHAR(MSTRC.ADOPT_DATE, 'YYYY/MM/DD')) AS ADPTDT,			/* 採用日 */
		DECODE(DECODE(MSTRC.ABOLISH_DATE, CAST(:FINAL_DATE AS DATE), '', TO_CHAR(MSTRC.ABOLISH_DATE, 'YYYY/MM/DD')), '', DECODE(MSTRC.TMP_ABOLISH_DATE, CAST(:FINAL_DATE AS DATE), '', '(' || TO_CHAR(MSTRC.TMP_ABOLISH_DATE, 'YYYY/MM/DD')|| ')') ) AS ABLSDT,		/* 廃止日 (表示内容がブランクと判断された場合は、括弧付で暫定廃止日を表示) */
		DECODE(MSTRC.PENDING_DECIDED_DATE, CAST(:FINAL_DATE AS DATE) , '', '*') AS PENDFLG,									/* 未決フラグ */
		NVL(STRC.QUANTITY, 1) AS QTY, 																											/* 員数 */
		NVL(MSTRC.REPR_OF_MAIN_ECS_NO, '') AS DNNO,																						/* 主設通代表設通 */
		NVL(OLDPRTLIST.OLDPRTNOLIST, '') AS OLDLIST,																					/* 旧部品番号(カンマ区切り) */
		NVL(MSTRC.REMARKS, '') AS RMKS,																									/* 備考 */
		NVL(PRT_TITLE.DRAWING_SERIES, '') AS SERIES,																					/* 図面シリーズ */
		NVL(PRT_TITLE.DRAWING_BLOCK_NO, '') AS BLCK,																					/* ブロックNO */
		NVL(PRTDRWG_TITLE.DRAWING_NO, '') AS DRWGNO,																					/* 図面番号 */
		NVL(PRTDRWG_TITLE.DRAWING_REV_NO, '') AS DRWGREV,																				/* 図面改訂番号 */
		NVL(FBL.FSERIESES, '') AS FSERIESLIST,																									/* F図シリーズ(カンマ区切り) */
		NVL(FBL.FBLOCKS, '') AS FBLCKLIST,																										/* F図ブロックNO(カンマ区切り) */
		('1:' || NVL(MSTRC.MANAGEMENT_STATUS, '') || '2:' || NVL(MSTRC.SUPPLY_CODE, '') || '3:' || NVL(MSTRC.ADOPT_CHECK_CODE, '')) AS MINFO,	/* (*2) 管理区分、供給コード、採確コード */
		DECODE(TRIM(NVL(MSTRC.CANCEL_FLAG, '')), '', DECODE(TRIM(NVL(MSTRC.TMP_CANCEL_FLAG, '')), '', '', '(' || NVL(MSTRC.TMP_CANCEL_FLAG, '') || ')')) AS CANCELFLG,											/* 無効フラグ(表示内容がブランクと判断された場合は、括弧付で暫定無効フラグを表示) */
		NVL(MSTRC.FACTORY_PS_STATUS, '') AS FCTY_STATUS,																							/* 工場ステータス */
		NVL(MPRT_TITLE.PARTS_NO, '') AS TITLE_PRTNO,																					/* タイトル図面_部品番号 */
		NVL(MPRT_TITLE.ENGINEERING_PN_REV_NO, '') AS TITLE_REVNO,																		/* タイトル図面_技術部品改訂番号 */
		NVL(MPRT_TITLE.FACTORY_PN_REV_NO, '') AS TITLE_MREVNO,																			/* タイトル図面_工場部品改訂番号 */
		NVL(PRT_TITLE.DRAWING_CLASS, '') AS TITLE_DRWGCLS,																				/* タイトル図面_Final図番 */
		PRTMAX.DRAWING_SERIES AS RECENTLY_SERIES,																						/* 最新諸元_図面シリーズ */
		PRTMAX.DRAWING_BLOCK_NO AS RECENTLY_BLCK,																						/* 最新諸元_ブロックNO */
		BLCK.BODY_UNIT_DIV AS RECENTLY_BUCLS,																							/* 最新諸元_BODY/UNIT区分 */
		PRTMAX.PARTS_NAME AS RECENTLY_PRTNM,																							/* 最新諸元_部品名称 */
		CASE
			WHEN SPL4.SPLRCDLIST IS NULL OR SPL4.SPLRCDLIST LIKE '%' || MPRT1.SUPPLIER_CODE || '%' THEN '0' 
			ELSE '1' 
		END AS SPLRVNTFLG,																												/* 取引先差異フラグ 0:差異なし、1:差異あり */
		NVL(SPL1.SPLRCDLIST, '') AS SPLRCDLIST_1,																								/* 取引先コード(前モデル) CSVファイル出力用 */
		NVL(SPL2.SPLRCDLIST, '') AS SPLRCDLIST_2,																								/* 取引先コード(品目ID)   CSVファイル出力用 */
		NVL(SPL3.SPLRCDLIST, '') AS SPLRCDLIST_3,																								/* 取引先コード(購買依頼) CSVファイル出力用 */
		NVL(SPL4.SPLRCDLIST, '') AS SPLRCDLIST_4,																								/* 取引先コード(配布実績) CSVファイル出力用 */
		NVL(TRIM(MPRT1.SUPPLIER_CODE), '') AS SPLRCDLIST_5																								/* 取引先コード(入力) CSVファイル出力用 */
	FROM
		TEMP 																														/* 部品構成展開結果 */
		/* 結合グループ1 : 正展開したPSの情報を取得 */
			LEFT OUTER JOIN RESULT MSTRC ON																							/* 工場構成情報 */
				MSTRC.PARENT_PARTS_NO=TEMP.PARPRTNO AND
				MSTRC.SUB_PARTS_NO=TEMP.PRTNO 
			LEFT OUTER JOIN TB001004 STRC ON																							/* 部品構成 */
				STRC.PARENT_PARTS_NO=MSTRC.PARENT_PARTS_NO AND
				STRC.SUB_PARTS_NO=MSTRC.SUB_PARTS_NO AND
				STRC.ENGINEERING_PS_REV_NO=MSTRC.ENGINEERING_PS_REV_NO
			LEFT OUTER JOIN OLDPRTLIST ON																								/* 旧部品番号 (カンマ区切り) */
				OLDPRTLIST.PRTNO=STRC.SUB_PARTS_NO AND
				OLDPRTLIST.REVNO=STRC.ENGINEERING_PS_REV_NO AND
				OLDPRTLIST.ISLEAF=1
			LEFT OUTER JOIN TB003001 DSGN1 ON																							/* 設計通知 */
				DSGN1.ECS_NO=MSTRC.REPR_OF_MAIN_ECS_NO AND
				EXISTS																													/* 最古の設通改訂 */
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
			LEFT OUTER JOIN TB004001 MPRT_TITLE ON																						/* 工場部品情報 (この工場部品情報が属するタイトル図面としての工場部品情報) */
					MPRT_TITLE.PARTS_NO=MSTRC.PARENT_PARTS_NO AND
					MPRT_TITLE.REPR_OF_MAIN_ECS_NO=MSTRC.REPR_OF_MAIN_ECS_NO
			LEFT OUTER JOIN TB001002 PRTDRWG_TITLE ON																					/* 部品図面 (この工場部品情報が属するタイトル図面としての部品図面)*/
					PRTDRWG_TITLE.PARTS_NO=MPRT_TITLE.PARTS_NO AND
					PRTDRWG_TITLE.ENGINEERING_PN_REV_NO=MPRT_TITLE.ENGINEERING_PN_REV_NO
			LEFT OUTER JOIN TB001003 PRT_TITLE ON																						/* 部品諸元 (この工場部品情報が属するタイトル図面としての部品諸元) */
					PRT_TITLE.PARTS_NO=MPRT_TITLE.PARTS_NO AND
					PRT_TITLE.PARTS_PROP_REV_NO=MPRT_TITLE.PARTS_PROP_REV_NO
			LEFT OUTER JOIN TB011015 CDMST1 ON																							/* コードマスター(工場情報ステータス取得用) */
				CDMST1.CODE_GROUP_ID='CDGRP005' AND																						/* 工場情報ステータス */
				CDMST1.CODE_VALUE=MSTRC.FACTORY_PS_STATUS
			LEFT OUTER JOIN TB011015 CDMST2 ON																							/* コードマスター(先行発行フラグ取得用) */
				CDMST2.CODE_GROUP_ID='CDGRP030' AND																						/* 先行発行フラグ */
				CDMST2.CODE_VALUE=DSGN1.PRECEDE_FLAG
			LEFT OUTER JOIN FINALBLCKLIST FBL ON																						/* F図ブロック、F図シリーズ(カンマ区切り) */
				FBL.PRTNO=TEMP.PRTNO AND
				FBL.ISLEAF=1
		/* 結合グループ2 : 正展開した構成の子PNの品目IDを取得するための情報 */
			INNER JOIN TB001003 PRTMAX ON																								/* 部品諸元 (子PNの最大の諸元改訂番号) */	
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
			INNER JOIN TB009005 BLCK ON																									/* ブロック (PRTMAXとJOIN) */
				BLCK.BLOCK_NO=PRTMAX.DRAWING_BLOCK_NO
			LEFT OUTER JOIN TB006001 ITEM ON																							/* 品目ID */
				EXISTS
				(
					SELECT
						*
					FROM
						TB006006 PRTITEM
					WHERE
						PRTITEM.MC_DEV_MODEL_CODE=DECODE(TRIM(:MCMDLCD), '', DECODE(BLCK.BODY_UNIT_DIV, 'U', :UNTN, PRTMAX.DRAWING_SERIES), DECODE(:MCMDLCD, 'UNIT', :UNTN, :MCMDLCD)) AND
						PRTITEM.PARTS_NO=PRTMAX.PARTS_NO AND																					/* 部品番号 */
						PRTITEM.ITEM_ID_NO=ITEM.ITEM_ID_NO
				)
			LEFT OUTER JOIN TB006002 ITEMDIC ON																								/* 品目辞書(部品品目管理に登録されているIDは除外 */
				ITEMDIC.FUNCTION=SUBSTR(PRTMAX.PARTS_NO, 1, 5) AND																			/* ファンクション(部品番号の上5桁) */
				EXISTS
				(
					SELECT
						*
					FROM
						TB006004 MDLITEM
					WHERE
						MDLITEM.MC_DEV_MODEL_CODE=DECODE(TRIM(:MCMDLCD), '', DECODE(BLCK.BODY_UNIT_DIV, 'U', :UNTN, PRTMAX.DRAWING_SERIES), DECODE(:MCMDLCD, 'UNIT', :UNTN, :MCMDLCD)) AND
						MDLITEM.ITEM_ID_NO=ITEMDIC.ITEM_ID_NO																				/* 品目ID番号 */
				) AND
				ITEMDIC.ITEM_NAME=PRTMAX.PARTS_NAME AND																						/* 最新諸元の部品名称 */
				ITEMDIC.ITEM_ID_NO!=NVL(ITEM.ITEM_ID_NO, '')
		/* 結合グループ2 : 正展開した子PNの属性を表示するための情報 */
			LEFT OUTER JOIN TB004001 MPRT1 ON											/* 工場部品情報(子PNとしての工場部品情報) */
				MPRT1.PARTS_NO=MSTRC.SUB_PARTS_NO AND
				EXISTS
				(
					SELECT					/* 1.PSと採廃期間が重複しているもの, 2.工場ステータスが大きいもの, 3.最大の技術部品改訂 + 工場部品改訂 の順で最も優先度の高いデータを取得 */
						MAX(
								CASE WHEN
									MSTRC.ADOPT_DATE < DECODE(MSTRC.FACTORY_PS_STATUS, CAST(:STATUS AS CHAR(2)), DECODE(MPRT2.FACTORY_PN_STATUS, CAST(:STATUS AS CHAR(2)), MPRT2.ABOLISH_DATE, MPRT2.TMP_ABOLISH_DATE), MPRT2.TMP_ABOLISH_DATE) AND
									DECODE(MSTRC.FACTORY_PS_STATUS, CAST(:STATUS AS CHAR(2)), MSTRC.ABOLISH_DATE, MSTRC.TMP_ABOLISH_DATE) <  MPRT2.ADOPT_DATE THEN '1' /* 採廃期間が重複している */
									ELSE '0' /* 採廃期間が重複していない */
								END || MPRT2.FACTORY_PN_STATUS || MPRT2.ENGINEERING_PN_REV_NO || MPRT2.FACTORY_PN_REV_NO
							)
					FROM
						TB004001 MPRT2
					WHERE
						MPRT2.PARTS_NO=MPRT1.PARTS_NO AND
						MPRT2.CANCEL_FLAG='0' AND																									/* 無効フラグが「有効」(子PNは常に有効なデータのみ取得する) */
						(MPRT2.FACTORY_PN_STATUS=:STATUS AND MPRT2.ADOPT_DATE <= CAST(:DATE AS DATE) AND MPRT2.ABOLISH_DATE > CAST(:DATE AS DATE))	/* ◇過去履歴指定時に指定する日付条件。本登録済のみ表示する。ブランクの場合はこの条件を除外する */
					GROUP BY
						MPRT2.PARTS_NO
					HAVING
						(MPRT1.ENGINEERING_PN_REV_NO || MPRT1.FACTORY_PN_REV_NO)=
						RIGHT(MAX(
								CASE WHEN
									MSTRC.ADOPT_DATE < DECODE(MSTRC.FACTORY_PS_STATUS, :STATUS, DECODE(MPRT2.FACTORY_PN_STATUS, :STATUS, MPRT2.ABOLISH_DATE, MPRT2.TMP_ABOLISH_DATE), MPRT2.TMP_ABOLISH_DATE) AND
									DECODE(MSTRC.FACTORY_PS_STATUS, :STATUS, MSTRC.ABOLISH_DATE, MSTRC.TMP_ABOLISH_DATE) <  MPRT2.ADOPT_DATE THEN '1' 				/* 採廃期間が重複している */
									ELSE '0' 																															/* 採廃期間が重複していない */
								END || MPRT2.FACTORY_PN_STATUS || MPRT2.ENGINEERING_PN_REV_NO || MPRT2.FACTORY_PN_REV_NO
								)
							, 6)
				)
			LEFT JOIN TB001003 PRT ON																									/* 部品諸元 (子PN工場部品情報の諸元改訂番号と合致) */	
				PRT.PARTS_NO=MPRT1.PARTS_NO AND
				PRT.PARTS_PROP_REV_NO=MPRT1.PARTS_PROP_REV_NO
			LEFT OUTER JOIN SPLRLIST SPL_DISP ON																						/* 取引先コード(発生源タイプが最大の取引先コードをカンマ区切り) */
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
			LEFT OUTER JOIN SPLRLIST SPL1 ON																								/* 取引先コード（前モデル） */
				SPL1.PRTNO=MPRT1.PARTS_NO AND
				SPL1.SRCTYPE='1' AND
				SPL1.ISLEAF=1
			LEFT OUTER JOIN SPLRLIST SPL2 ON																								/* 取引先コード（品目ID） */
				SPL2.PRTNO=MPRT1.PARTS_NO AND
				SPL2.SRCTYPE='2' AND
				SPL2.ISLEAF=1
			LEFT OUTER JOIN SPLRLIST SPL3 ON																								/* 取引先コード（購買依頼） */
				SPL3.PRTNO=MPRT1.PARTS_NO AND
				SPL3.SRCTYPE='3' AND
				SPL3.ISLEAF=1
			LEFT OUTER JOIN SPLRLIST SPL4 ON																								/* 取引先コード（配布実績） */
				SPL4.PRTNO=MPRT1.PARTS_NO AND
				SPL4.SRCTYPE='4' AND
				SPL4.ISLEAF=1
	WHERE
		TEMP.PARPRTNO!='' AND 
		MSTRC.SUB_PARTS_NO IS NULL			/* 展開した下位構成データであるにもかかわらず、工場構成情報が取得できなかったレコードは表示対象外 */
)
GROUP BY
	PATH,
	SMBL,																																	/* S */
	CHKRSLT,																																/* データチェック結果(英語) */
	LV,																																		/* Lv */
	DRWGCLS,																																/* (*)Final図番 */
	ITEMNO,																																	/* 品目ID番号  */
	ATFLG,																																	/* 要注意マーク */
	PRTNO,																																	/* 部品番号 */
	REVNO,																																	/* 変番 */
	MREVNO,																																	/* 工場改訂 */ 
	PRTNM,																																	/* 部品名称 */ 
	PNSTATUSJP,																																/* 工場ステータス(日本語) */ 
	PNSTATUSEN,																																/* 工場ステータス(英語) */ 
	DNPRCDFLGJP,																															/* 先行発行フラグ(日本語) */ 
	DNPRCDFLGEN,																															/* 先行発行フラグ(英語) */ 
	COSRTNG,																																/* 消費工順 */
	JOBSEQ,																																	/* 発生工順 */
	SPLRCDLIST_DISP,																														/* 取引先コード(表示用) */
	UNITCLS,																																/* ユニット区分 */
	PRCSCD,																																	/* 加工区分 */
	ADPTDT,																																	/* 採用日 */
	ABLSDT,																																	/* 廃止日 (表示内容がブランクと判断された場合は、括弧付で暫定廃止日を表示) */
	PENDFLG,																																/* 未決フラグ */
	QTY, 																																	/* 員数 */
	DNNO,																																	/* 主設通代表設通 */
	OLDLIST,																																/* 旧部品番号(カンマ区切り) */
	RMKS,																																	/* 備考 */
	SERIES,																																	/* 図面シリーズ */
	BLCK,																																	/* ブロックNO */
	DRWGNO,																																	/* 図面番号 */
	DRWGREV,																																/* 図面改訂番号 */
	FSERIESLIST,																															/* F図シリーズ(カンマ区切り) */
	FBLCKLIST,																																/* F図ブロックNO(カンマ区切り) */
	MINFO,																																	/* (*2) 管理区分、供給コード、採確コード */
	CANCELFLG,																																/* 無効フラグ(表示内容がブランクと判断された場合は、括弧付で暫定無効フラグを表示) */
	FCTY_STATUS,																															/* 工場ステータス */
	TITLE_PRTNO,																															/* タイトル図面_ */
	TITLE_REVNO,																															/* タイトル図面_技術部品改訂番号 */
	TITLE_MREVNO,																															/* タイトル図面_工場部品改訂番号 */
	TITLE_DRWGCLS,																															/* タイトル図面_Final図番 */
	RECENTLY_SERIES,																														/* 最新諸元_図面シリーズ */
	RECENTLY_BLCK,																															/* 最新諸元_ブロックNO */
	RECENTLY_BUCLS,																															/* 最新諸元_BODY/UNIT区分 */
	RECENTLY_PRTNM,																															/* 最新諸元_部品名称 */
	SPLRVNTFLG,																																/* 取引先差異フラグ 0:差異なし、1:差異あり */
	SPLRCDLIST_1,																															/* 取引先コード(前モデル) CSVファイル出力用 */
	SPLRCDLIST_2,																															/* 取引先コード(品目ID)   CSVファイル出力用 */
	SPLRCDLIST_3,																															/* 取引先コード(購買依頼) CSVファイル出力用 */
	SPLRCDLIST_4,																															/* 取引先コード(配布実績) CSVファイル出力用 */
	SPLRCDLIST_5																															/* 取引先コード(入力) CSVファイル出力用 */
ORDER BY 
	PATH,												/* 展開パス (親部品番号 + 見出し番号 + 見出し番号種類」の連結キー) */
	PRTNO,												/* 部品番号 (見出し番号 + 見出し番号種類のみで正常に並ぶはずだが、念のため追加) */
	REVNO,												/* 変番 */
	MREVNO												/* 工場改訂 */ 
;
