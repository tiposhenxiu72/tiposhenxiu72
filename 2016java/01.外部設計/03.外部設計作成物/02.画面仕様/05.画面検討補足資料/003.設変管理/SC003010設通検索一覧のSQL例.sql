-- 【要注意】
-- 　　以下サンプルSQLで提示しているリテラルは適宜JavaではConst値やパラメータ変数で補うようにしてください
-- 

-- �@設通一覧と一意に紐づくデータの取得サンプルSQL
SELECT
	ECS.ECS_NO,					-- 設通NO
	ECS.ECS_REV_NO,				-- 改訂NO
	ECS.ECS_TITLE,				-- 設通件名
	ECS_ST.JP_DISPLAY_NAME,		-- 設通ステータス
	ECS.RECEIVED_DATE,			-- 設通受領日
	EC_MT.ECS_MEETING_DATE,		-- 設審日(最新)
	EC_ISSUE.ECS_ISSUE_DATE,	-- 発行日(最新)
	EC_ISSUE.ECS_ISSUE_REV_NO,	-- 設通工場改訂
	-- 未決の取得 設通ステータス = 設審済（未決有り）ならば未決有り
	CASE
		WHEN ECS.ECS_STATUS = '31' THEN '有り'
		WHEN ECS.ECS_STATUS > '31' THEN '無し'
		ELSE ''
	END MIKETSU,				-- 未決
	PRECEED.JP_DISPLAY_NAME,	-- 先行発行
	ATTENTION.JP_DISPLAY_NAME,	-- 要注意
	REASON.JP_DISPLAY_NAME,		-- 理由
	ARANGE.JP_DISPLAY_NAME,		-- 手配区分
	-- 設通読解きの取得　新システム管理対象かつ設通ステータス = 仮登録済ならば済み
	CASE
		WHEN FMC_MST.NEW_SYS_CONTROL_FLAG = '0' THEN
			CASE
				WHEN ECS.ECS_STATUS >= '20' THEN '済み'
				ELSE ''
			END 
		ELSE ''
	END	SETTSU_YOMITOKI,		-- 設通読解き
	-- 担当読解きの取得　新システム管理対象かつ読み飛ばし以外の部品が全て仮登録済であれば済み
　　-- 但し画面で担当者が指定された場合のみこの値を出力、それ以外はブランク
	CASE
		WHEN FMC_MST.NEW_SYS_CONTROL_FLAG = '0' THEN
			CASE 
				WHEN P.ECS_NO IS NULL THEN '済み'
				ELSE ''
			END 
		ELSE ''
	END TANTO_YOMITOKI 			-- 担当読解き
FROM EC_SUMMARY ECS
-- 設審日の最新を取得する為に設審設通テーブルと結合
LEFT JOIN 
	(SELECT ECS_NO,ECS_REV_NO,MAX(ECS_MEETING_DATE) ECS_MEETING_DATE FROM ECS_MEETING_ECS GROUP BY ECS_NO,ECS_REV_NO)
EC_MT
ON 
	ECS.ECS_NO = EC_MT.ECS_NO AND ECS.ECS_REV_NO = EC_MT.ECS_REV_NO
-- 発行日の最新を取得する為に製管設通発行テーブルと結合
LEFT JOIN 
	(SELECT ECS_NO,ECS_REV_NO,ECS_ISSUE_REV_NO,ECS_ISSUE_DATE FROM ECS_ISSUE WHERE (ECS_NO,ECS_REV_NO,ECS_ISSUE_REV_NO) IN (SELECT ECS_NO,ECS_REV_NO,MAX(ECS_ISSUE_REV_NO) ECS_ISSUE_REV_NO FROM ECS_ISSUE GROUP BY ECS_NO,ECS_REV_NO))
EC_ISSUE
ON
	ECS.ECS_NO = EC_ISSUE.ECS_NO AND ECS.ECS_REV_NO = EC_ISSUE.ECS_REV_NO
-- 設通ステータスを取得する為にコードマスターと結合
LEFT JOIN
	CODE_MASTER ECS_ST
ON
	ECS.ECS_STATUS = ECS_ST.CODE_VALUE AND ECS_ST.CODE_GROUP_ID = 'CDGRP005'
-- 先行発行を取得する為にコードマスターと結合
LEFT JOIN
	CODE_MASTER PRECEED
ON
	ECS.PRECEED_FLAG = PRECEED.CODE_VALUE AND PRECEED.CODE_GROUP_ID = 'CDGRP030'
-- 要注意を取得する為にコードマスターと結合
LEFT JOIN
	CODE_MASTER ATTENTION
ON
	ECS.ATTENTION = ATTENTION.CODE_VALUE AND ATTENTION.CODE_GROUP_ID = 'CDGRP054'
-- 理由を取得する為にコードマスターと結合
LEFT JOIN
	CODE_MASTER REASON
ON
	ECS.REASON = REASON.CODE_VALUE AND REASON.CODE_GROUP_ID = 'CDGRP033'
-- 手配区分を取得する為にコードマスターと結合
LEFT JOIN
	CODE_MASTER ARANGE
ON
	ECS.ARRANGE_CLASS = ARANGE.CODE_VALUE AND ARANGE.CODE_GROUP_ID = 'CDGRP053'
-- 担当読解きを取得する為に工場部品情報と結合
LEFT JOIN (
	SELECT DISTINCT 
		ECS_NO
	FROM 
	(
		SELECT 
			FPN.PARTS_NO ,								-- 部品番号
			FPN.ENGINEERING_REV_NO,						-- 技術改訂番号
			-- 関連部品のタイプ=Fが無ければ、対象部品の標題欄図面シリーズ、あれば関連部品の標題欄図面シリーズ
			CASE 
				WHEN RP.RELATED_PARTS_NO IS NULL THEN
					EPN.DRAWING_SERIES
				ELSE
					EPN_F.DRAWING_SERIES
			END DRAWING_SERIES,							-- 標題欄図面シリーズ
			-- 関連部品のタイプ=Fが無ければ、対象部品の標題欄図面ブロックNO、あれば関連部品の標題欄図面ブロックNO
			CASE 
				WHEN RP.RELATED_PARTS_NO IS NULL THEN
					EPN.DRAWING_BLOCK_NO
				ELSE
					EPN_F.DRAWING_BLOCK_NO
			END DRAWING_BLOCK_NO,						-- 標題欄図面ブロックNO
			FPN.FACT_PN_STATUS,							-- 工場部品ステータス
			FPN.ECS_NO									-- 設通NO
		FROM FACTORY_PN_INFORMATION FPN
		-- 関連部品のタイプ=Fと外部結合
		LEFT JOIN RELATED_PARTS RP 
		ON
			FPN.PARTS_NO = RP.PARTS_NO AND RP.RELATION_TYPE = 'F'
		-- 関連部品のタイプ=Fの部品諸元を取得
		LEFT JOIN PARTS_PROPERTIES EPN_F
		ON
			EPN_F.PARTS_NO = RP.RELATED_PARTS_NO AND
			EPN_F.PARTS_PROP_REV_NO IN (SELECT MAX(TEPN_F.PARTS_PROP_REV_NO) FROM PARTS_PROPERTIES TEPN_F WHERE TEPN_F.PARTS_NO = RP.PARTS_NO GROUP BY TEPN_F.PARTS_NO)
		-- 自部品のタイプ=Fの部品諸元を取得
		INNER JOIN PARTS_PROPERTIES EPN
		ON
			FPN.PARTS_NO = EPN.PARTS_NO AND
			FPN.PARTS_PROP_REV_NO = EPN.PARTS_PROP_REV_NO
		WHERE FPN.SKIP_FLAG = '0'						-- 読み飛ばし=0(：読み飛ばし以外)
	) X 	
	WHERE X.DRAWING_BLOCK_NO IN 
	(SELECT BC.BLOCK_NO FROM BLOCK BC WHERE BC.USER_ID = 'NAGA') -- 指示されたブロック担当者のユーザID
	AND X.FACT_PN_STATUS < '20'							-- 仮登録中、または受領
) P
ON 
	ECS.ECS_NO = P.ECS_NO
-- 新システム対象フラグを取得する為にFMC開発車と結合
INNER JOIN
	FMC_DEVELOPMENT_MODEL FMC_MST
ON
	ECS.ECS_SERIES = FMC_MST.FMC_DEV_MODEL_CODE
/* ここに画面で指定された条件で絞ってください
WHERE
	XXXX = XXXX 
*/
ORDER BY ECS.ECS_NO,ECS.ECS_REV_NO
;

-- �A取得した設通の代表設通番号を取得
SELECT
	CASE
		WHEN REPR_SIMUL_CLASS = '0' THEN 
			ECS.ECS_NO						-- 代表設通NO
		ELSE
			SIMUL.REPR_ECS_NO				-- 代表設通NO
	END REPR_ECS_NO,
	ECS.ECS_REV_NO							-- 代表設通改訂NO
FROM EC_SUMMARY ECS
LEFT JOIN (SELECT DISTICT REPR_ECS_NO,SIMULTANEOUS_ECS_NO FROM SIMULTANEOUS_ECS) SIMUL
ON
	ECS.ECS_NO = SIMUL.SIMULTANEOUS_ECS_NO
WHERE
	(ECS.ECS_NO,ECS.ECS_REV_NO) IN (('HR3 -L0001',' '),('HR3 -L0001','1')) -- �@で取得した設通番号
ORDER BY
	ECS.ECS_NO,ECS.ECS_REV_NO

-- �B設通に紐づく同指示設通データの取得例
SELECT
	SIMUL.REPR_ECS_NO,						-- 代表設通NO
	SIMUL.REPR_ECS_REV_NO,					-- 代表設通改訂NO
	SIMUL.SIMULTANEOUS_ECS_NO				-- 同指示設通NO　⇒　これをカンマ区切りにしてください
FROM SIMULTANEOUS_OVERFLOW_ECS SIMUL
WHERE
	(SIMUL.REPR_ECS_NO,SIMUL.REPR_ECS_REV_NO) IN (('HR3 -L0001',' '),('HR3 -L0001','1')) -- �Aで取得した代表設通番号
ORDER BY
	SIMUL.SIMULTANEOUS_ECS_ORDER
;	

-- �C設通に紐づく関連設通データの取得例
SELECT
	RELATED.REPR_ECS_NO,					-- 代表設通NO
	RELATED.REPR_ECS_REV_NO,				-- 代表設通改訂NO
	RELATED.RELATED_ECS_NO					-- 関連設通NO　⇒　これをカンマ区切りにしてください
FROM RELATED_OVERFLOW_ECS RELATED			-- 
WHERE
	(RELATED.REPR_ECS_NO,RELATED.REPR_ECS_REV_NO) IN (('HR3 -L0001',' '),('HR3 -L0001','1')) -- �Aで取得した代表設通番号
ORDER BY
	RELATED.RELATED_ECS_ORDER
;	

-- �D自設通を関連設通に指定している代表設通の取得例
SELECT
	ECS.ECS_NO,								-- 代表設通NO
	ECS.ECS_REV_NO,							-- 代表設通改訂NO
	RELATED.REPR_ECS_NO						-- 関連設通代表設通NO　⇒　これをカンマ区切りにしてください
FROM EC_SUMMARY ECS
LEFT JOIN (SELECT DISTINCT REPR_ECS_NO,RELATED_ECS_NO FROM RELATED_ECS) RELATED
ON
	RELATED.RELATED_ECS_NO = ECS.ECS_NO
WHERE
	(ECS.ECS_NO,ECS.ECS_REV_NO) IN (('HR3 -L0001',' '),('HR3 -L0001','1')) -- �Aで取得した代表設通番号
ORDER BY
	ECS.ECS_NO,ECS.ECS_REV_NO
;

-- �E設通に紐づくブロックの取得例
SELECT DISTINCT
	FPN.ECS_NO,									-- 代表設通番号
	-- 関連部品のタイプ=Fが無ければ、対象部品の標題欄図面ブロックNO、あれば関連部品の標題欄図面ブロックNO
	CASE 
		WHEN RP.RELATED_PARTS_NO IS NULL THEN
			EPN.DRAWING_BLOCK_NO
		ELSE
			EPN_F.DRAWING_BLOCK_NO
	END DRAWING_BLOCK_NO						-- ブロックNO
FROM FACTORY_PN_INFORMATION FPN
-- 関連部品のタイプ=Fと外部結合
LEFT JOIN RELATED_PARTS RP 
ON
	FPN.PARTS_NO = RP.PARTS_NO AND RP.RELATION_TYPE = 'F'
-- 関連部品のタイプ=Fの部品諸元を取得
LEFT JOIN PARTS_PROPERTIES EPN_F
ON
	EPN_F.PARTS_NO = RP.RELATED_PARTS_NO AND
	EPN_F.PARTS_PROP_REV_NO IN (SELECT MAX(TEPN_F.PARTS_PROP_REV_NO) FROM PARTS_PROPERTIES TEPN_F WHERE TEPN_F.PARTS_NO = RP.PARTS_NO GROUP BY TEPN_F.PARTS_NO)
-- 自部品のタイプ=Fの部品諸元を取得
INNER JOIN PARTS_PROPERTIES EPN
ON
	FPN.PARTS_NO = EPN.PARTS_NO AND
	FPN.PARTS_PROP_REV_NO = EPN.PARTS_PROP_REV_NO
WHERE 
	FPN.SKIP_FLAG = '0' AND						-- 読み飛ばし=0(：読み飛ばし以外)
	FPN.ECS_NO IN ('HR3 -L0001','HR3 -L0002') 	-- �Aで取得した代表設通番号
ORDER BY 
	FPN.ECS_NO,DRAWING_BLOCK_NO
;

-- �F設通に紐づくブロック担当者の取得例
SELECT DISTINCT
	BLK.USER_ID							-- ユーザID
FROM BLOCK BLK
WHERE
	BLK.BLOCK_NO IN ('100A','200A') 	-- �Eで取得したブロックNO
;

