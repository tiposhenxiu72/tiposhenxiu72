WITH 
-- 検索条件に合致する設通番号を取得する
ECS_KEY_LIST (ECS_NO,ECS_REV_NO,REPR_ECS_NO) AS 
(
    SELECT 
        DISTINCT
        ECS.ECS_NO,
        ECS.ECS_REV_NO,
        DECODE(ECS.REPR_SIMUL_CLASS,CAST(:SIMUL_CLS as char(1)),SIMUL_ECS.REPR_ECS_NO,ECS.ECS_NO) AS REPR_ECS_NO
    FROM TB003001 ECS 
    LEFT JOIN TB003002 SIMUL_ECS
    ON
        ECS.ECS_NO = SIMUL_ECS.SIMULTANEOUS_ECS_NO AND 
        -- 改訂は正しい結合ではないが、理論上は合致する
        ECS.ECS_REV_NO = SIMUL_ECS.REPR_ECS_REV_NO AND
        ECS.REPR_SIMUL_CLASS = CAST(:SIMUL_CLS as char(1))
    -- 設審設通は設通番号で結合する
    LEFT JOIN TB003007 ECS_MT
    ON
        ECS.ECS_NO = ECS_MT.ECS_NO AND
        ECS.ECS_REV_NO = ECS_MT.ECS_REV_NO
    LEFT JOIN TB003005 MT
    ON
        ECS_MT.ECS_SERIES = MT.ECS_SERIES AND
        ECS_MT.ECS_MEETING_DATE = MT.ECS_MEETING_DATE AND
        ECS_MT.ECS_MTG_LOCATION = MT.ECS_MTG_LOCATION
    -- 実施時期は代表設通番号で結合する
    -- 改訂は理論上合致するので、設通であてる
    LEFT JOIN TB003008 ECS_IMPL
    ON
        DECODE(ECS.REPR_SIMUL_CLASS,CAST(:SIMUL_CLS as char(1)),SIMUL_ECS.REPR_ECS_NO,ECS.ECS_NO) = ECS_IMPL.ECS_NO AND
        ECS.ECS_REV_NO = ECS_IMPL.ECS_REV_NO
    WHERE 
        -- 設通シリーズが入力された場合
        ECS.ECS_SERIES = :ECS_SERIES AND
        -- 課コードが入力された場合
        ECS.SECTION_CODE IN (CAST(:SEC_CD AS VARCHAR(30))) AND
        -- 一連NOが入力された場合
        ECS.SERIAL_NO LIKE CONCAT(:SER_NO,'%') AND
        -- 設審日が入力された場合
        ECS_MT.ECS_MEETING_DATE = :MT_DATE AND
        -- 未設定のみ表示が指定された場合
        (ECS_MT.ECS_MEETING_DATE IS NULL OR ECS_MT.ECS_MEETING_DATE < SYSDATE) AND
        -- 受領日が入力された場合
        ECS.RECEIVED_DATE >= :RECEIVE_DATE_FROM AND
        ECS.RECEIVED_DATE <= :RECEIVE_DATE_TO AND
        -- 設審場所が指定された場合
        ECS_MT.ECS_MTG_LOCATION = :ECS_MT_LOC AND
        -- 設審名称が指定された場合
        MT.ECS_MEETING_NAME LIKE CONCAT(:ECS_MT_NAME,'%') AND
        -- 仕向け地が指定された場合
        ECS_IMPL.DESTINATION = :DEST AND
        -- 読解きが指定された場合
        ECS.ECS_STATUS IN (DECODE(CAST(:YOMITOKI as char(1)),'0',CAST(:YOMITOKI_MISUMI as varchar(100)),'1',cast(:YOMITOKI_SUMI as varchar(100)))) AND 
        -- 先行発行が指定された場合
        ECS.PRECEDE_FLAG = :PRECEDE AND
        -- 理由が指定された場合
        ECS.REASON = :REASON AND
        -- 設審日が入力されなかった場合は設通ステータスは設審可能なステータスに絞る
        (
            -- 設審可能なステータス：受領、仮登録中、仮登録済、設審中、設審済（未決有り）
        --  (ECS.ECS_STATUS IN (:STS_RECEIVE || ',' :STS_TMP_REG || ',' :STS_UNDERSTOOD || ',' :STS_EXAMINING || ',' :STS_EXAMED_TBD)) OR
            (ECS.ECS_STATUS IN (cast(:STS_EXAMINABLED as varchar(100)))) OR
            -- または先行発行で設審が終わっていないデータ
            (ECS.PRECEDE_FLAG = :PRECEDE_ON AND (ECS_MT.ECS_MEETING_DATE IS NULL OR ECS_MT.ECS_MEETING_DATE >= SYSDATE))
        )
    -- 期間に関係なく未決を表示が指定された場合
    UNION 
    SELECT 
        ECS.ECS_NO,
        ECS.ECS_REV_NO,
        DECODE(ECS.REPR_SIMUL_CLASS,CAST(:SIMUL_CLS as char(1)),SIMUL_ECS.REPR_ECS_NO,ECS.ECS_NO) AS REPR_ECS_NO
    FROM TB003001 ECS
    LEFT JOIN TB003002 SIMUL_ECS
    ON
        ECS.ECS_NO = SIMUL_ECS.SIMULTANEOUS_ECS_NO AND 
        -- 改訂は正しい結合ではないが、理論上は合致する
        ECS.ECS_REV_NO = SIMUL_ECS.REPR_ECS_REV_NO AND
        ECS.REPR_SIMUL_CLASS = CAST(:SIMUL_CLS as char(1))
    WHERE 
        ECS.ECS_STATUS = :STS_EXAMED_TBD
),
-- 設通に関連づくブロックNOをカンマ区切りで取得する
/* 旧部品情報のカンマ区切り情報（再帰SQL用並び順） */
ECS_BLOCK_ORDER (REPR_OF_MAIN_ECS_NO,DRAWING_BLOCK_NO,ORDER_NUM)
AS (
    SELECT 
        REPR_OF_MAIN_ECS_NO,
        DRAWING_BLOCK_NO,
        ROW_NUMBER() OVER(PARTITION BY REPR_OF_MAIN_ECS_NO ORDER BY DRAWING_BLOCK_NO ) AS ORDER_NUM
    FROM
        (
            SELECT
                FPN.REPR_OF_MAIN_ECS_NO,                                    -- 代表設通番号
                -- 関連部品のタイプ=Fが無ければ、対象部品の標題欄図面ブロックNO、あれば関連部品の標題欄図面ブロックNO
                CASE 
                    WHEN RP.RELATED_PARTS_NO IS NULL THEN
                        EPN.DRAWING_BLOCK_NO
                    ELSE
                        EPN_F.DRAWING_BLOCK_NO
                END DRAWING_BLOCK_NO                        -- ブロックNO
            FROM TB004001 FPN
            -- 関連部品のタイプ=Fと外部結合
            LEFT JOIN TB001005 RP 
            ON
                FPN.PARTS_NO = RP.PARTS_NO AND RP.RELATION_TYPE = 'F'
            -- 関連部品のタイプ=Fの部品諸元を取得
            LEFT JOIN TB001003 EPN_F
            ON
                EPN_F.PARTS_NO = RP.RELATED_PARTS_NO AND
                EPN_F.PARTS_PROP_REV_NO IN (SELECT MAX(TEPN_F.PARTS_PROP_REV_NO) FROM TB001003 TEPN_F WHERE TEPN_F.PARTS_NO = RP.RELATED_PARTS_NO GROUP BY TEPN_F.PARTS_NO)
            -- 自部品のタイプの部品諸元を取得
            INNER JOIN TB001003 EPN
            ON
                FPN.PARTS_NO = EPN.PARTS_NO AND
                FPN.PARTS_PROP_REV_NO = EPN.PARTS_PROP_REV_NO
            WHERE 
                FPN.SKIP_FLAG = '0'                     -- 読み飛ばし=0(：読み飛ばし以外)
                AND EXISTS (SELECT 1 FROM ECS_KEY_LIST L WHERE FPN.REPR_OF_MAIN_ECS_NO = L.ECS_NO)
        ) X
    GROUP BY 
        REPR_OF_MAIN_ECS_NO,DRAWING_BLOCK_NO
)
,
/*  ブロック情報のカンマ区切り情報 */
ECS_BLOCK_PATH (REPR_OF_MAIN_ECS_NO, ORDER_NUM,ISLEAF, DEPTH_LVL, PATH)
  AS (
    SELECT REPR_OF_MAIN_ECS_NO,
             ORDER_NUM,
             NVL((SELECT '1' FROM ECS_BLOCK_ORDER E WHERE C.ORDER_NUM+1 = E.ORDER_NUM AND E.REPR_OF_MAIN_ECS_NO = C.REPR_OF_MAIN_ECS_NO),'0') ISLEAF,
             1 AS DEPTH_LVL,
             '' || CAST(RTRIM(DRAWING_BLOCK_NO) AS VARCHAR(400))  PATH
        FROM ECS_BLOCK_ORDER C
       WHERE C.ORDER_NUM = 1
      UNION ALL
      SELECT B.REPR_OF_MAIN_ECS_NO,
             B.ORDER_NUM,
             NVL((SELECT '1' FROM ECS_BLOCK_ORDER E WHERE B.ORDER_NUM+1 = E.ORDER_NUM AND E.REPR_OF_MAIN_ECS_NO = B.REPR_OF_MAIN_ECS_NO),'0') ISLEAF,
             ECS_BLOCK_PATH.DEPTH_LVL + 1,
             ECS_BLOCK_PATH.PATH || ',' || RTRIM(B.DRAWING_BLOCK_NO)
        FROM ECS_BLOCK_ORDER B, ECS_BLOCK_PATH
       WHERE B.ORDER_NUM  = ECS_BLOCK_PATH.ORDER_NUM + 1 AND ECS_BLOCK_PATH.REPR_OF_MAIN_ECS_NO = B.REPR_OF_MAIN_ECS_NO
    )
,
/* 同指示設通のカンマ区切り情報（再帰SQL用並び順） */
SIMULTANEOUS_ECS_ORDER (REPR_ECS_NO,REPR_ECS_REV_NO,SIMULTANEOUS_ECS_NO,ORDER_NUM)
AS (
    SELECT
        A.REPR_ECS_NO,
        A.REPR_ECS_REV_NO,
        A.SIMULTANEOUS_ECS_NO,
        ROW_NUMBER() OVER(PARTITION BY A.REPR_ECS_NO,A.REPR_ECS_REV_NO ORDER BY A.SIMULTANEOUS_ECS_ORDER ) AS ORDER_NUM
    FROM VW003001 A
    WHERE 
        EXISTS (SELECT 1 FROM ECS_KEY_LIST L WHERE A.REPR_ECS_NO = L.ECS_NO AND A.REPR_ECS_REV_NO = L.ECS_REV_NO)
)
,
/* 同指示設通のカンマ区切り情報 */
SIMULTANEOUS_ECS_PATH (REPR_ECS_NO, REPR_ECS_REV_NO,ORDER_NUM,ISLEAF, DEPTH_LVL, PATH)
  AS (SELECT REPR_ECS_NO,
             REPR_ECS_REV_NO,
             ORDER_NUM,
             NVL((SELECT '1' FROM SIMULTANEOUS_ECS_ORDER E WHERE C.ORDER_NUM+1 = E.ORDER_NUM AND E.REPR_ECS_NO = C.REPR_ECS_NO AND E.REPR_ECS_REV_NO = C.REPR_ECS_REV_NO),'0') ISLEAF,
             1 AS DEPTH_LVL,
             '' || CAST(RTRIM(SIMULTANEOUS_ECS_NO) AS VARCHAR(400))  PATH
        FROM SIMULTANEOUS_ECS_ORDER C
       WHERE C.ORDER_NUM = 1
      UNION ALL
      SELECT B.REPR_ECS_NO,
             B.REPR_ECS_REV_NO,
             B.ORDER_NUM,
             NVL((SELECT '1' FROM SIMULTANEOUS_ECS_ORDER E WHERE B.ORDER_NUM+1 = E.ORDER_NUM AND E.REPR_ECS_NO = B.REPR_ECS_NO AND E.REPR_ECS_REV_NO = B.REPR_ECS_REV_NO),'0') ISLEAF,
             SIMULTANEOUS_ECS_PATH.DEPTH_LVL + 1,
             SIMULTANEOUS_ECS_PATH.PATH || ',' || RTRIM(B.SIMULTANEOUS_ECS_NO)
        FROM SIMULTANEOUS_ECS_ORDER B, SIMULTANEOUS_ECS_PATH
       WHERE B.ORDER_NUM  = SIMULTANEOUS_ECS_PATH.ORDER_NUM + 1 AND SIMULTANEOUS_ECS_PATH.REPR_ECS_NO = B.REPR_ECS_NO AND SIMULTANEOUS_ECS_PATH.REPR_ECS_REV_NO = B.REPR_ECS_REV_NO
    )
SELECT  
    DECODE(ECS.REPR_SIMUL_CLASS,'0','','1','同','同') AS SIMAL_CLS,                                     /* 同指 */
    ECS.RECEIVED_DATE,                                                                                  /* 設通受領日 */
    ECS.ECS_NO,                                                                                         /* 設通番号 */
    ECS.ECS_REV_NO,                                                                                     /* 設通改訂NO */
    ECS.ECS_TITLE_JP,                                                                                   /* 件名（和文） */
    ECS.ECS_TITLE_EN,                                                                                   /* 件名（英文） */
    CASE WHEN ECS.ECS_STATUS >= :STS_UNDERSTOOD THEN '済' ELSE '未完了' END AS YOMITOKI,                /* 読解き */
    ECS_MT.ECS_MEETING_DATE,                                                                            /* 設審日 */
    LOC.ECS_MTG_LOC_NAME,                                                                               /* 設審場所 */
    MT.ECS_MEETING_NAME,                                                                                /* 設審名称 */
    ECS.DESIGN_SECTION,                                                                                 /* 設計課 */
    ECS.ECS_ISSUE_MEMBER,                                                                               /* 設計担当者 */
    ECS.DESIGN_PHONE_NO,                                                                                /* 電話番号 */
    BLC_PATH.PATH AS BLOCK_NO,                                                                          /* ブロックNO */
    PRECEDE_MST.JP_DISPLAY_NAME AS PRECEDE_JP,                                                          /* 先行発行（和文） */
    PRECEDE_MST.EN_DISPLAY_NAME AS PRECEDE_EN,                                                          /* 先行発行（英文） */
    ATTENTION_MST.JP_DISPLAY_NAME AS ATTENTION_JP,                                                      /* 要注意（和文） */
    ATTENTION_MST.EN_DISPLAY_NAME AS ATTENTION_EN,                                                      /* 要注意（英文） */
    REASON_MST.JP_DISPLAY_NAME AS REASON_JP,                                                            /* 理由（和文） */
    REASON_MST.EN_DISPLAY_NAME AS REASON_EN,                                                            /* 理由（英文） */
    NVL(REPR_ECS.REPR_ECS_NO,'') AS REPR_ECS_NO,                                                        /* 代表設通NO */
    NVL(REPR_ECS_MT.ECS_MEETING_DATE,'') AS REPR_ECS_MT_DATE,                                           /* 代表設通 設審日（最新） */
    SIMUL_PATH.PATH AS SIMUL_ECS,                                                                       /* 同指示設通 */
    DECODE(ECS.ECS_STATUS,CAST(:STS_EXAMED_TBD AS CHAR(2)),SYSDATE - ECS_MT_FIRST.ECS_MEETING_DATE,0) AS PASSED_DATE,    /* 経過日 */
    DECODE(ECS.ECS_STATUS,CAST(:STS_EXAMED_TBD AS CHAR(2)),ECS_MT_FIRST.ECS_MEETING_DATE,'') AS FIRST_MEETING_DATE,      /* 初回設審日 */
    BASE.APPLIED_MODEL_CODE,                                                                            /* 対象年改符号 */
    DEST_MST.DESTINATION_NAME,                                                                          /* 仕向け地 */
    APPLIED_MODEL_MST.JP_DISPLAY_NAME AS APPLIED_MODEL_NAME_JP,                                         /* 適用車種（和文） */
    APPLIED_MODEL_MST.EN_DISPLAY_NAME AS APPLIED_MODEL_NAME_EN,                                         /* 適用車種 （英文）*/
    DGN_REQD_MST.JP_DISPLAY_NAME AS DGN_REQD_JP,                                                        /* 設計希望時期（和文） */
    DGN_REQD_MST.EN_DISPLAY_NAME AS DGN_REQD_EN,                                                        /* 設計希望時期（英文） */
    DECODE(ECS_IMPL_0.IMPLEMENT_EVENT_ID,
                '',ECS_IMPL_0.DECIDED_IMPL_DATE,
                IMPL_0_EV_MST.EVENT_NAME) AS DESIDED_IMPL_DATE_0,                                       /* 国内生産_実施時期 */
    DECODE(ECS_IMPL_0.PARTIAL_PENDING_FLAG,'1','有り','') AS PARTIAL_FLAG_0,                            /* 国内生産_部分未決フラグ */
    ECS_IMPL_0.REMARKS AS REMARKS_0,                                                                    /* 国内生産_備考 */
    DECODE(ECS_IMPL_1.IMPLEMENT_EVENT_ID,
                '',ECS_IMPL_1.DECIDED_IMPL_DATE,
                IMPL_1_EV_MST.EVENT_NAME) AS DESIDED_IMPL_DATE_1,                                       /* 海外生産(国内決定)_実施時期 */
    DECODE(ECS_IMPL_1.PARTIAL_PENDING_FLAG,'1','有り','') AS PARTIAL_FLAG_1,                            /* 海外生産(国内決定)_部分未決フラグ */
    ECS_IMPL_1.REMARKS AS REMARKS_1,                                                                    /* 海外生産(国内決定)_備考 */
    DECODE(ECS_IMPL_2.IMPLEMENT_EVENT_ID,
                '',ECS_IMPL_2.DECIDED_IMPL_DATE,
                IMPL_1_EV_MST.EVENT_NAME) AS DESIDED_IMPL_DATE_2,                                       /* 海外生産(SIA設審状況)_実施時期 */
    DECODE(ECS_IMPL_2.PARTIAL_PENDING_FLAG,'1','有り','') AS PARTIAL_FLAG_2,                            /* 海外生産(SIA設審状況)_部分未決フラグ */
    ECS_IMPL_2.REMARKS AS REMARKS_2,                                                                    /* 海外生産(SIA設審状況)_備考 */
    FMC_MST.NEW_SYS_CONTROL_FLAG,                                                                        /* 新システム管理対象フラグ(システム管理用) */
    ECS.ECS_STATUS                                                                                  /* 設通ステータス(システム管理用)*/
FROM ECS_KEY_LIST KEYLIST
INNER JOIN TB003001 ECS
ON
    KEYLIST.ECS_NO = ECS.ECS_NO AND
    KEYLIST.ECS_REV_NO = ECS.ECS_REV_NO
-- 設審設通は設通番号で結合する
LEFT JOIN TB003007 ECS_MT
ON
    ECS.ECS_NO = ECS_MT.ECS_NO AND
    ECS.ECS_REV_NO = ECS_MT.ECS_REV_NO AND
    EXISTS
        (SELECT 1 
         FROM TB003007 TMP_MT 
         WHERE 
            ECS_MT.ECS_SERIES = TMP_MT.ECS_SERIES AND 
            ECS_MT.ECS_MTG_LOCATION = TMP_MT.ECS_MTG_LOCATION AND 
            ECS_MT.ECS_NO = TMP_MT.ECS_NO AND
            ECS_MT.ECS_REV_NO = TMP_MT.ECS_REV_NO AND
            ECS_MT.ECS_MEETING_DATE >= SYSDATE
         GROUP BY 
            TMP_MT.ECS_SERIES,TMP_MT.ECS_MTG_LOCATION,TMP_MT.ECS_NO,TMP_MT.ECS_REV_NO
         HAVING
            ECS_MT.ECS_MEETING_DATE = MIN(TMP_MT.ECS_MEETING_DATE)
        )
LEFT JOIN TB003005 MT
ON
    ECS_MT.ECS_SERIES = MT.ECS_SERIES AND
    ECS_MT.ECS_MEETING_DATE = MT.ECS_MEETING_DATE AND
    ECS_MT.ECS_MTG_LOCATION = MT.ECS_MTG_LOCATION
LEFT JOIN TB003006 LOC
ON
    ECS_MT.ECS_MTG_LOCATION = LOC.ECS_MTG_LOCATION
-- ブロックは代表設通番号で結合する
LEFT JOIN ECS_BLOCK_PATH BLC_PATH
ON
    KEYLIST.REPR_ECS_NO = BLC_PATH.REPR_OF_MAIN_ECS_NO AND
    BLC_PATH.ISLEAF = '0'
LEFT JOIN TB011015 PRECEDE_MST
ON
    PRECEDE_MST.CODE_GROUP_ID = :CDGRP030 AND
    ECS.PRECEDE_FLAG = PRECEDE_MST.CODE_VALUE
LEFT JOIN TB011015 ATTENTION_MST
ON
    ATTENTION_MST.CODE_GROUP_ID = :CDGRP054 AND
    ECS.ARRANGE_CLASS = ATTENTION_MST.CODE_VALUE
LEFT JOIN TB011015 REASON_MST
ON
    REASON_MST.CODE_GROUP_ID = :CDGRP033 AND
    ECS.REASON = REASON_MST.CODE_VALUE
-- 同指示は設通番号で結合する
LEFT JOIN SIMULTANEOUS_ECS_PATH SIMUL_PATH
ON
    ECS.ECS_NO = SIMUL_PATH.REPR_ECS_NO AND
    ECS.ECS_REV_NO = SIMUL_PATH.REPR_ECS_REV_NO AND
    SIMUL_PATH.ISLEAF = '0'
-- 初回設審は設通番号で結合する
LEFT JOIN TB003007 ECS_MT_FIRST
ON
    ECS.ECS_NO = ECS_MT_FIRST.ECS_NO AND
    ECS.ECS_REV_NO = ECS_MT_FIRST.ECS_REV_NO AND
    EXISTS
        (SELECT 1 
         FROM TB003007 TMP_MT 
         WHERE 
            ECS_MT_FIRST.ECS_SERIES = TMP_MT.ECS_SERIES AND 
            ECS_MT_FIRST.ECS_MTG_LOCATION = TMP_MT.ECS_MTG_LOCATION AND 
            ECS_MT_FIRST.ECS_NO = TMP_MT.ECS_NO AND
            ECS_MT_FIRST.ECS_REV_NO = TMP_MT.ECS_REV_NO
         GROUP BY 
            TMP_MT.ECS_SERIES,TMP_MT.ECS_MTG_LOCATION,TMP_MT.ECS_NO,TMP_MT.ECS_REV_NO
         HAVING
            ECS_MT_FIRST.ECS_MEETING_DATE = MIN(TMP_MT.ECS_MEETING_DATE)
        )
-- 同指示は設通番号で結合する（自身が代表設通の場合はブランク）
LEFT JOIN TB003002 REPR_ECS
ON
    ECS.ECS_NO = REPR_ECS.SIMULTANEOUS_ECS_NO AND
    -- 改訂は正しい結合ではないが、理論上は合致する
    ECS.ECS_REV_NO = REPR_ECS.REPR_ECS_REV_NO AND
    ECS.REPR_SIMUL_CLASS = :SIMUL_CLS
-- 代表設通の設審は代表設通で結合する（自身が代表設通の場合はブランク）
LEFT JOIN TB003007 REPR_ECS_MT
ON
    REPR_ECS.REPR_ECS_NO = REPR_ECS_MT.ECS_NO AND
    REPR_ECS.REPR_ECS_REV_NO = REPR_ECS_MT.ECS_REV_NO AND
    EXISTS
        (SELECT 1 
         FROM TB003007 TMP_MT 
         WHERE 
            REPR_ECS_MT.ECS_SERIES = TMP_MT.ECS_SERIES AND 
            REPR_ECS_MT.ECS_MTG_LOCATION = TMP_MT.ECS_MTG_LOCATION AND 
            REPR_ECS_MT.ECS_NO = TMP_MT.ECS_NO AND
            REPR_ECS_MT.ECS_REV_NO = TMP_MT.ECS_REV_NO
         GROUP BY 
            TMP_MT.ECS_SERIES,TMP_MT.ECS_MTG_LOCATION,TMP_MT.ECS_NO,TMP_MT.ECS_REV_NO
         HAVING
            REPR_ECS_MT.ECS_MEETING_DATE = MAX(TMP_MT.ECS_MEETING_DATE)
        )
--実施時期の集約列は代表設通で結合する
LEFT JOIN 
    (SELECT 
        ECS_NO, ECS_REV_NO, APPLIED_MODEL_CODE, DESTINATION, APPLIED_MODEL,DGN_REQD_START_DATE,DISPLAY_ORDER
     FROM TB003008 BASE
     WHERE 
        EXISTS (SELECT 1 FROM ECS_KEY_LIST L WHERE BASE.ECS_NO = L.ECS_NO AND BASE.ECS_REV_NO = L.ECS_REV_NO)
     GROUP BY 
        BASE.ECS_NO,BASE.ECS_REV_NO, BASE.APPLIED_MODEL_CODE, BASE.DESTINATION, BASE.APPLIED_MODEL,DGN_REQD_START_DATE,DISPLAY_ORDER
    ) BASE
ON
    KEYLIST.REPR_ECS_NO  = BASE.ECS_NO AND
    ECS.ECS_REV_NO = BASE.ECS_REV_NO
--実施時期の各列は集約列と結合する（結果的に代表設通で結合）
LEFT JOIN TB003008 ECS_IMPL_0
ON
    BASE.ECS_NO = ECS_IMPL_0.ECS_NO AND
    BASE.ECS_REV_NO = ECS_IMPL_0.ECS_REV_NO AND
    BASE.APPLIED_MODEL_CODE = ECS_IMPL_0.APPLIED_MODEL_CODE AND
    BASE.DESTINATION = ECS_IMPL_0.DESTINATION AND
    BASE.APPLIED_MODEL = ECS_IMPL_0.APPLIED_MODEL AND
    ECS_IMPL_0.IMPL_DATE_INPUT_COL = :DOM_COL AND
    EXISTS
        (SELECT 1 FROM TB003008 TMP_IMPL WHERE ECS_IMPL_0.ECS_NO = TMP_IMPL.ECS_NO AND ECS_IMPL_0.ECS_REV_NO = TMP_IMPL.ECS_REV_NO GROUP BY TMP_IMPL.ECS_NO,TMP_IMPL.ECS_REV_NO HAVING ECS_IMPL_0.ECS_IMPL_REV_NO = MAX(TMP_IMPL.ECS_IMPL_REV_NO))
--実施時期の各列は集約列と結合する（結果的に代表設通で結合）
LEFT JOIN TB003008 ECS_IMPL_1
ON
    ECS.ECS_NO = ECS_IMPL_1.ECS_NO AND
    ECS.ECS_REV_NO = ECS_IMPL_1.ECS_REV_NO AND
    BASE.APPLIED_MODEL_CODE = ECS_IMPL_1.APPLIED_MODEL_CODE AND
    BASE.DESTINATION = ECS_IMPL_1.DESTINATION AND
    BASE.APPLIED_MODEL = ECS_IMPL_1.APPLIED_MODEL AND
    ECS_IMPL_1.IMPL_DATE_INPUT_COL = :FOREIGN_DOM_COL AND
    EXISTS
        (SELECT 1 FROM TB003008 TMP_IMPL WHERE ECS_IMPL_1.ECS_NO = TMP_IMPL.ECS_NO AND ECS_IMPL_1.ECS_REV_NO = TMP_IMPL.ECS_REV_NO GROUP BY TMP_IMPL.ECS_NO,TMP_IMPL.ECS_REV_NO HAVING ECS_IMPL_1.ECS_IMPL_REV_NO = MAX(TMP_IMPL.ECS_IMPL_REV_NO))
--実施時期の各列は集約列と結合する（結果的に代表設通で結合）
LEFT JOIN TB003008 ECS_IMPL_2
ON
    ECS.ECS_NO = ECS_IMPL_2.ECS_NO AND
    ECS.ECS_REV_NO = ECS_IMPL_2.ECS_REV_NO AND
    BASE.APPLIED_MODEL_CODE = ECS_IMPL_2.APPLIED_MODEL_CODE AND
    BASE.DESTINATION = ECS_IMPL_2.DESTINATION AND
    BASE.APPLIED_MODEL = ECS_IMPL_2.APPLIED_MODEL AND
    ECS_IMPL_2.IMPL_DATE_INPUT_COL = :FOREIGN_COL AND
    EXISTS
        (SELECT 1 FROM TB003008 TMP_IMPL WHERE ECS_IMPL_2.ECS_NO = TMP_IMPL.ECS_NO AND ECS_IMPL_2.ECS_REV_NO = TMP_IMPL.ECS_REV_NO GROUP BY TMP_IMPL.ECS_NO,TMP_IMPL.ECS_REV_NO HAVING ECS_IMPL_2.ECS_IMPL_REV_NO = MAX(TMP_IMPL.ECS_IMPL_REV_NO))
LEFT JOIN TB011015 DGN_REQD_MST
ON
    REASON_MST.CODE_GROUP_ID = :CDGRP044 AND
    BASE.DGN_REQD_START_DATE = REASON_MST.CODE_VALUE
LEFT JOIN TB003011 IMPL_0_EV_MST
ON
    ECS_IMPL_0.CREATED_APP_EVENT_ID = IMPL_0_EV_MST.EVENT_ID
LEFT JOIN TB003011 IMPL_1_EV_MST
ON
    ECS_IMPL_1.CREATED_APP_EVENT_ID = IMPL_1_EV_MST.EVENT_ID
LEFT JOIN TB003011 IMPL_2_EV_MST
ON
    ECS_IMPL_2.CREATED_APP_EVENT_ID = IMPL_2_EV_MST.EVENT_ID
LEFT JOIN TB009001 FMC_MST
ON
    ECS.ECS_SERIES = FMC_MST.FMC_DEV_MODEL_CODE
LEFT JOIN TB009008 DEST_MST
ON
	BASE.DESTINATION = DEST_MST.DESTINATION
LEFT JOIN TB011015 APPLIED_MODEL_MST
ON
    APPLIED_MODEL_MST.CODE_GROUP_ID = :CDGRP020 AND
    BASE.APPLIED_MODEL = APPLIED_MODEL_MST.CODE_VALUE
ORDER BY 
    ECS.RECEIVED_DATE,ECS.DESIGN_SECTION,BASE.DISPLAY_ORDER
;
