        WITH
        /* 最初に表示する工場部品情報のキーリストを取得する */
        ARRANGEMENT_FPN_KEY_LIST (PARTS_NO,ENGINEERING_PN_REV_NO,FACTORY_PN_REV_NO,NEWOLD,DATA_TYPE,ADOPT_DATE,ABOLISH_DATE,FACTORY_PN_STATUS)
        AS
        (
        /* NEWのP/Nデータを工場部品情報より設計通知をキーに取得する */
        SELECT
            FPN.PARTS_NO,
            FPN.ENGINEERING_PN_REV_NO,
            FPN.FACTORY_PN_REV_NO,
            CAST(:NEW AS VARCHAR(3)) AS NEWOLD,
            '1' AS DATA_TYPE, /* 1:P/Nデータ */
            FPN.ADOPT_DATE,
            FPN.ABOLISH_DATE,
            FPN.FACTORY_PN_STATUS
        FROM TB004001 FPN
        WHERE FPN.REPR_OF_MAIN_ECS_NO = :ECS_NO
        UNION ALL
        /* OLDのP/Nデータを工場部品情報よりNEWデータより改訂番号が小さいうちの最大の改訂として取得する */
        SELECT
            FPN.PARTS_NO,
            FPN.ENGINEERING_PN_REV_NO,
            FPN.FACTORY_PN_REV_NO,
            CAST(:OLD AS VARCHAR(3)) AS NEWOLD,
            '1', /* 1:P/Nデータ */
            FPN.ADOPT_DATE,
            FPN.ABOLISH_DATE,
            FPN.FACTORY_PN_STATUS
        FROM TB004001 FPN
        WHERE
            (FPN.PARTS_NO,FPN.ENGINEERING_PN_REV_NO || FPN.FACTORY_PN_REV_NO ) IN
            (
                SELECT
                    FPN_T.PARTS_NO,
                    MAX(FPN_T.ENGINEERING_PN_REV_NO || FPN_T.FACTORY_PN_REV_NO) AS REV_NO
                FROM TB004001 FPN_T
                INNER JOIN
                    (SELECT
                        FPN_TT.PARTS_NO,
                        FPN_TT.ENGINEERING_PN_REV_NO || FPN_TT.FACTORY_PN_REV_NO AS REV_NO
                        FROM TB004001 FPN_TT
                        WHERE
                                 FPN_TT.REPR_OF_MAIN_ECS_NO = :ECS_NO
                    )
                FPN_TT
                ON
                    FPN_T.PARTS_NO = FPN_TT.PARTS_NO
                WHERE
                    FPN_T.ENGINEERING_PN_REV_NO || FPN_T.FACTORY_PN_REV_NO < FPN_TT.REV_NO
                GROUP BY FPN_T.PARTS_NO
            )
        UNION ALL
        /* P/S行に表示する為のNEWのP/N情報を子部品が存在するP/Nに絞って取得する */
        SELECT
            FPN.PARTS_NO,
            FPN.ENGINEERING_PN_REV_NO,
            FPN.FACTORY_PN_REV_NO,
            CAST(:NEW AS VARCHAR(3)) AS NEWOLD,
            '2', /* 2:P/S用P/Nデータ */
            FPN.ADOPT_DATE,
            FPN.ABOLISH_DATE,
            FPN.FACTORY_PN_STATUS
        FROM TB004001 FPN
        WHERE FPN.REPR_OF_MAIN_ECS_NO = :ECS_NO
        AND EXISTS
            (SELECT 1 FROM TB004002 FPS WHERE FPN.PARTS_NO = FPS.PARENT_PARTS_NO AND FPN.REPR_OF_MAIN_ECS_NO = FPS.REPR_OF_MAIN_ECS_NO)
        ),
        /* 旧部品情報のカンマ区切り情報（再帰SQL用並び順） */
        PREV_PARTS_ORDER (PARTS_NO,ENGINEERING_PN_REV_NO,PREV_PARTS_NO,PREV_DRAWING_REV_NO,ORDER_NUM)
        AS (
        SELECT
            A.PARTS_NO,
            A.ENGINEERING_PN_REV_NO,
            A.PREV_PARTS_NO,
            A.PREV_DWG_REV_NO,
            ROW_NUMBER() OVER(PARTITION BY A.PARTS_NO,A.ENGINEERING_PN_REV_NO ORDER BY A.PREV_PARTS_NO ) AS ORDER_NUM
        FROM TB001006 A
        WHERE
            EXISTS (SELECT 1 FROM ARRANGEMENT_FPN_KEY_LIST L WHERE A.PARTS_NO = L.PARTS_NO AND A.ENGINEERING_PN_REV_NO = L.ENGINEERING_PN_REV_NO)
        )
        ,
        /* 旧部品情報のカンマ区切り情報 */
        PREV_PARTS_PATH (PARTS_NO, ENGINEERING_PN_REV_NO,ORDER_NUM,ISLEAF, DEPTH_LVL, PATH,PREV_DRAWING_REV_PATH)
          AS (SELECT PARTS_NO,
                     ENGINEERING_PN_REV_NO,
                     ORDER_NUM,
                     NVL((SELECT '1' FROM PREV_PARTS_ORDER E WHERE C.ORDER_NUM+1 = E.ORDER_NUM AND E.PARTS_NO = C.PARTS_NO AND E.ENGINEERING_PN_REV_NO = C.ENGINEERING_PN_REV_NO),'0') ISLEAF,
                     1 AS DEPTH_LVL,
                     '' || RTRIM(PREV_PARTS_NO)  PATH,
                     '' || RTRIM(PREV_DRAWING_REV_NO) PREV_DRAWING_REV_PATH
                FROM PREV_PARTS_ORDER C
               WHERE C.ORDER_NUM = 1
              UNION ALL
              SELECT B.PARTS_NO,
                     B.ENGINEERING_PN_REV_NO,
                     B.ORDER_NUM,
                     NVL((SELECT '1' FROM PREV_PARTS_ORDER E WHERE B.ORDER_NUM+1 = E.ORDER_NUM AND E.PARTS_NO = B.PARTS_NO AND E.ENGINEERING_PN_REV_NO = B.ENGINEERING_PN_REV_NO),'0') ISLEAF,
                     PREV_PARTS_PATH.DEPTH_LVL + 1,
                     PREV_PARTS_PATH.PATH || ',' || RTRIM(B.PREV_PARTS_NO),
                     PREV_PARTS_PATH.PREV_DRAWING_REV_PATH || ',' || RTRIM(B.PREV_DRAWING_REV_NO)
                FROM PREV_PARTS_ORDER B, PREV_PARTS_PATH
               WHERE B.ORDER_NUM  = PREV_PARTS_PATH.ORDER_NUM + 1 AND PREV_PARTS_PATH.PARTS_NO = B.PARTS_NO AND PREV_PARTS_PATH.ENGINEERING_PN_REV_NO = B.ENGINEERING_PN_REV_NO
            )
        ,
        /* 最初に表示する工場構成情報のキーリストを取得する */
        ARRANGEMENT_FPS_KEY_LIST (SUB_PARTS_NO,PARENT_PARTS_NO,PS_REV_NO,FACTORY_PS_REV_NO,NEWOLD,DATA_TYPE,ADOPT_DATE,ABOLISH_DATE,FACTORY_PS_STATUS,ENGINEERING_PS_REV_NO)
        AS
        (
        /* NEWのP/Sデータを工場構成情報より設計通知をキーに取得する */
        SELECT
            FPS.SUB_PARTS_NO,
            FPS.PARENT_PARTS_NO,
            FPS.PS_REV_NO,
            FPS.FACTORY_PS_REV_NO,
            CAST(:NEW AS VARCHAR(3)) AS NEWOLD,
            '3' AS DATA_TYPE, /* 3:P/Sデータ */
            FPS.ADOPT_DATE,
            FPS.ABOLISH_DATE,
            FPS.FACTORY_PS_STATUS,
            FPS.ENGINEERING_PS_REV_NO
        FROM TB004002 FPS
        WHERE FPS.REPR_OF_MAIN_ECS_NO = :ECS_NO
        UNION ALL
        /* OLDのP/Sデータを工場構成情報よりNEWデータより改訂番号が小さいうちの最大の改訂として取得する */
        SELECT
            FPS.SUB_PARTS_NO,
            FPS.PARENT_PARTS_NO,
            FPS.PS_REV_NO,
            FPS.FACTORY_PS_REV_NO,
            CAST(:OLD AS VARCHAR(3)) AS NEWOLD,
            '3' AS DATA_TYPE, /* 3:P/Sデータ */
            FPS.ADOPT_DATE,
            FPS.ABOLISH_DATE,
            FPS.FACTORY_PS_STATUS,
            FPS.ENGINEERING_PS_REV_NO
        FROM TB004002 FPS
        WHERE
            (FPS.SUB_PARTS_NO,FPS.PARENT_PARTS_NO,FPS.PS_REV_NO || FPS.FACTORY_PS_REV_NO ) IN
            (
                SELECT
                    FPS_T.SUB_PARTS_NO,
                    FPS_T.PARENT_PARTS_NO,
                    MAX(FPS_T.PS_REV_NO || FPS_T.FACTORY_PS_REV_NO) AS REV_NO
                FROM TB004002 FPS_T
                INNER JOIN
                    (SELECT
                        FPS_TT.SUB_PARTS_NO,
                        FPS_TT.PARENT_PARTS_NO,
                        FPS_TT.PS_REV_NO || FPS_TT.FACTORY_PS_REV_NO AS REV_NO
                        FROM TB004002 FPS_TT
                        WHERE
                                 FPS_TT.REPR_OF_MAIN_ECS_NO = :ECS_NO
                    )
                FPS_TT
                ON
                    FPS_T.SUB_PARTS_NO = FPS_TT.SUB_PARTS_NO AND
                    FPS_T.PARENT_PARTS_NO = FPS_TT.PARENT_PARTS_NO
                WHERE
                    FPS_T.PS_REV_NO || FPS_T.FACTORY_PS_REV_NO < FPS_TT.REV_NO
                GROUP BY FPS_T.SUB_PARTS_NO,FPS_T.PARENT_PARTS_NO
            )
        )
        ,
        /* 旧部品構成情報のカンマ区切り情報（再帰SQL用並び順） */
        PREV_PARTS_STRUCTURE_ORDER (PARENT_PARTS_NO,SUB_PARTS_NO,ENGINEERING_PS_REV_NO,PREV_PARENT_PARTS_NO,PREV_SUB_PARTS_NO,PREV_DRAWING_REV_NO,ORDER_NUM)
        AS (
        SELECT
            A.PARENT_PARTS_NO,
            A.SUB_PARTS_NO,
            A.ENGINEERING_PS_REV_NO,
            A.PREV_PARENT_PARTS_NO,
            A.PREV_SUB_PARTS_NO,
            A.PREV_DWG_REV_NO,
            ROW_NUMBER() OVER(PARTITION BY A.PARENT_PARTS_NO,A.SUB_PARTS_NO,A.ENGINEERING_PS_REV_NO ORDER BY A.PREV_PARENT_PARTS_NO, A.PREV_SUB_PARTS_NO ) AS ORDER_NUM
        FROM TB001007 A
        WHERE
            EXISTS (SELECT 1 FROM ARRANGEMENT_FPS_KEY_LIST L WHERE A.SUB_PARTS_NO = L.SUB_PARTS_NO AND A.PARENT_PARTS_NO = L.PARENT_PARTS_NO AND A.ENGINEERING_PS_REV_NO = L.ENGINEERING_PS_REV_NO)
        )
        ,
        /* 旧部品構成情報のカンマ区切り情報 */
        PREV_PARTS_STRUCTURE_PATH (PARENT_PARTS_NO, SUB_PARTS_NO,ENGINEERING_PS_REV_NO,ORDER_NUM,ISLEAF, DEPTH_LVL,PARENT_PATH, PATH,PREV_DRAWING_REV_PATH)
          AS (SELECT PARENT_PARTS_NO,
                     SUB_PARTS_NO,
                     ENGINEERING_PS_REV_NO,
                     ORDER_NUM,
                     NVL((SELECT '1' FROM PREV_PARTS_STRUCTURE_ORDER E WHERE C.ORDER_NUM+1 = E.ORDER_NUM AND E.PARENT_PARTS_NO = C.PARENT_PARTS_NO AND E.SUB_PARTS_NO = C.SUB_PARTS_NO AND E.ENGINEERING_PS_REV_NO = C.ENGINEERING_PS_REV_NO),'0') ISLEAF,
                     1 AS DEPTH_LVL,
                     '' || RTRIM(PREV_PARENT_PARTS_NO)  PARENT_PATH,
                     '' || RTRIM(PREV_SUB_PARTS_NO)  PATH,
                     '' || RTRIM(PREV_DRAWING_REV_NO) PREV_DRAWING_REV_PATH
                FROM PREV_PARTS_STRUCTURE_ORDER C
               WHERE C.ORDER_NUM = 1
              UNION ALL
              SELECT B.PARENT_PARTS_NO,
                     B.SUB_PARTS_NO,
                     B.ENGINEERING_PS_REV_NO,
                     B.ORDER_NUM,
                     NVL((SELECT '1' FROM PREV_PARTS_STRUCTURE_ORDER E WHERE B.ORDER_NUM+1 = E.ORDER_NUM AND E.PARENT_PARTS_NO = B.PARENT_PARTS_NO AND E.SUB_PARTS_NO = B.SUB_PARTS_NO  AND E.ENGINEERING_PS_REV_NO = B.ENGINEERING_PS_REV_NO),'0') ISLEAF,
                     PREV_PARTS_STRUCTURE_PATH.DEPTH_LVL + 1,
                     PREV_PARTS_STRUCTURE_PATH.PARENT_PATH || ',' || RTRIM(B.PREV_PARENT_PARTS_NO),
                     PREV_PARTS_STRUCTURE_PATH.PATH || ',' || RTRIM(B.PREV_SUB_PARTS_NO),
                     PREV_PARTS_STRUCTURE_PATH.PREV_DRAWING_REV_PATH || ',' || RTRIM(B.PREV_DRAWING_REV_NO)
                FROM PREV_PARTS_STRUCTURE_ORDER B, PREV_PARTS_STRUCTURE_PATH
               WHERE B.ORDER_NUM  = PREV_PARTS_STRUCTURE_PATH.ORDER_NUM + 1 AND PREV_PARTS_STRUCTURE_PATH.PARENT_PARTS_NO = B.PARENT_PARTS_NO AND PREV_PARTS_STRUCTURE_PATH.SUB_PARTS_NO = B.SUB_PARTS_NO
        AND PREV_PARTS_STRUCTURE_PATH.ENGINEERING_PS_REV_NO = B.ENGINEERING_PS_REV_NO
            )
        ,
        /* 取引先情報のカンマ区切り情報（最大の発生源タイプで絞る） */
        PARTS_SUPPLIER_MAX_SOURCE_TYPE(PARTS_NO,SOURCE_TYPE)
        AS (
        SELECT
            A.PARTS_NO,
            MAX(A.SOURCE_TYPE) SOURCE_TYPE
        FROM TB002017 A
        WHERE EXISTS (SELECT 1 FROM ARRANGEMENT_FPN_KEY_LIST FPN_KEY WHERE A.PARTS_NO = FPN_KEY.PARTS_NO UNION ALL SELECT 1 FROM ARRANGEMENT_FPS_KEY_LIST FPS_KEY WHERE A.PARTS_NO = FPS_KEY.SUB_PARTS_NO )
        GROUP BY A.PARTS_NO)
        /* 取引先情報のカンマ区切り情報（再帰SQL用並び順） */
        ,PARTS_SUPPLIER_ORDER (PARTS_NO,SOURCE_TYPE,SUPPLIER_CODE,ORDER_NUM)
        AS (
        SELECT
            A.PARTS_NO,
            A.SOURCE_TYPE,
            A.SUPPLIER_CODE,
            ROW_NUMBER() OVER(PARTITION BY A.PARTS_NO,A.SOURCE_TYPE ORDER BY A.SUPPLIER_CODE ) AS ORDER_NUM
        FROM TB002017 A
        INNER JOIN PARTS_SUPPLIER_MAX_SOURCE_TYPE B
        ON A.PARTS_NO = B.PARTS_NO AND A.SOURCE_TYPE = B.SOURCE_TYPE
        )
        ,
        /* 取引先情報のカンマ区切り情報 */
        PARTS_SUPPLIER_PATH (PARTS_NO, SOURCE_TYPE,ORDER_NUM,ISLEAF, DEPTH_LVL, PATH)
          AS (SELECT PARTS_NO,
                     SOURCE_TYPE,
                     ORDER_NUM,
                     NVL((SELECT '1' FROM PARTS_SUPPLIER_ORDER E WHERE C.ORDER_NUM+1 = E.ORDER_NUM AND E.PARTS_NO = C.PARTS_NO AND E.SOURCE_TYPE = C.SOURCE_TYPE ),'0') ISLEAF,
                     1 AS DEPTH_LVL,
                     '' || RTRIM(SUPPLIER_CODE) PATH
                FROM PARTS_SUPPLIER_ORDER C
               WHERE C.ORDER_NUM = 1
              UNION ALL
              SELECT B.PARTS_NO,
                     B.SOURCE_TYPE,
                     B.ORDER_NUM,
                     NVL((SELECT '1' FROM PARTS_SUPPLIER_ORDER E WHERE B.ORDER_NUM+1 = E.ORDER_NUM AND E.PARTS_NO = B.PARTS_NO AND E.SOURCE_TYPE = B.SOURCE_TYPE ),'0') ISLEAF,
                     PARTS_SUPPLIER_PATH.DEPTH_LVL + 1,
                     PARTS_SUPPLIER_PATH.PATH || ',' || RTRIM(B.SUPPLIER_CODE)
                FROM PARTS_SUPPLIER_ORDER B, PARTS_SUPPLIER_PATH
               WHERE B.ORDER_NUM  = PARTS_SUPPLIER_PATH.ORDER_NUM + 1 AND PARTS_SUPPLIER_PATH.PARTS_NO = B.PARTS_NO AND PARTS_SUPPLIER_PATH.SOURCE_TYPE = B.SOURCE_TYPE
            )
        /* ファイナルのブロックがユニットとボディで混在する部品図面集合 */
        /* 技術の特に日付は条件にいれずに部品図面単位に対象部品に関連付くファイナル部品のブロックを参照して */
        /* ボディ／ユニット区分が2件以上（混在）存在している場合に部品図面のキーを作る */
        ,FINAL_BLOCK_EPND(PARTS_NO,ENGINEERING_PN_REV_NO)
        AS
        (
            SELECT
                T_EPND.PARTS_NO,
                T_EPND.ENGINEERING_PN_REV_NO
            FROM TB001002 T_EPND
            INNER JOIN TB001005 REL_EPN
            ON
                T_EPND.PARTS_NO = REL_EPN.PARTS_NO AND
                REL_EPN.RELATION_TYPE = :FINAL
            inner join TB001003 R_EPN
            ON
                REL_EPN.RELATED_PARTS_NO = R_EPN.PARTS_NO
            INNER JOIN TB009005 BLK_R
            ON
                R_EPN.DRAWING_BLOCK_NO = BLK_R.BLOCK_NO
            WHERE
                EXISTS
                    (SELECT 1 FROM ARRANGEMENT_FPN_KEY_LIST FPN_KEY WHERE FPN_KEY.PARTS_NO = T_EPND.PARTS_NO UNION ALL SELECT 1 FROM ARRANGEMENT_FPS_KEY_LIST FPS_KEY WHERE FPS_KEY.SUB_PARTS_NO = T_EPND.PARTS_NO )
            GROUP BY
                T_EPND.PARTS_NO,T_EPND.ENGINEERING_PN_REV_NO
            HAVING
                COUNT(DISTINCT BLK_R.BODY_UNIT_DIV) > 1
        ),
        -- 部品取引先には存在するが、サプライヤが工場部品表と異なるデータ集合
        DIST_DIFF_SUP(PARTS_NO,ENGINEERING_PN_REV_NO,FACTORY_PN_REV_NO)
        AS    (
                    SELECT
                        FPN_T.PARTS_NO,
                        FPN_T.ENGINEERING_PN_REV_NO,
                        FPN_T.FACTORY_PN_REV_NO
                    FROM TB004001 FPN_T
                    LEFT JOIN  TB002017 T_SUPPN
                    ON
                        FPN_T.PARTS_NO = T_SUPPN.PARTS_NO AND
                        FPN_T.SUPPLIER_CODE = T_SUPPN.SUPPLIER_CODE AND
                        FPN_T.PROD_BASE_CODE = T_SUPPN.PROD_BASE_CODE AND
                        T_SUPPN.SOURCE_TYPE = :HAIFU_JISSEKI
                    WHERE
                        EXISTS (SELECT 1 FROM TB002017 TT_SUPPN WHERE FPN_T.PARTS_NO = TT_SUPPN.PARTS_NO AND TT_SUPPN.SOURCE_TYPE = :HAIFU_JISSEKI)
                        AND FPN_T.SUPPLIER_CODE IS NOT NULL
                        AND EXISTS
                        (SELECT 1 FROM ARRANGEMENT_FPN_KEY_LIST FPN_KEY WHERE T_SUPPN.PARTS_NO = FPN_KEY.PARTS_NO UNION ALL SELECT 1 FROM ARRANGEMENT_FPS_KEY_LIST FPS_KEY WHERE T_SUPPN.PARTS_NO = FPS_KEY.SUB_PARTS_NO )
                    GROUP BY FPN_T.PARTS_NO,FPN_T.ENGINEERING_PN_REV_NO,FPN_T.FACTORY_PN_REV_NO
                    HAVING
                        COUNT(T_SUPPN.SUPPLIER_CODE) = 0
                ) ,
        /* 親部品存在有無*/
        /* 工場部品表側で存在有無を判断するが、日付が決まってないWorkが存在することも想定されるので期間はみない */
         P_EXIST (PARTS_NO)
         AS          (
                         SELECT
                             T_FPN.PARTS_NO
                         FROM TB004002 FPS_T
                         INNER JOIN TB004001 T_FPN
                         ON
                             FPS_T.SUB_PARTS_NO = T_FPN.PARTS_NO
                         WHERE
                             EXISTS (SELECT 1 FROM ARRANGEMENT_FPN_KEY_LIST FPN_KEY WHERE T_FPN.PARTS_NO = FPN_KEY.PARTS_NO
                                     UNION ALL
                                     SELECT 1 FROM ARRANGEMENT_FPS_KEY_LIST FPS_KEY WHERE T_FPN.PARTS_NO = FPS_KEY.SUB_PARTS_NO )
                            AND EXISTS
                                    (SELECT 1 FROM  TB004001 TT_FPN WHERE FPS_T.PARENT_PARTS_NO = TT_FPN.PARTS_NO)
                         GROUP BY
                             T_FPN.PARTS_NO
                     ) ,
        /* 子部品存在有無*/
        /* 工場部品表側で存在有無を判断するが、日付が決まってないWorkが存在することも想定されるので期間はみない */
         C_EXIST (PARTS_NO)
         AS          (
                         SELECT
                             T_FPN.PARTS_NO
                         FROM TB004002 FPS_T
                         INNER JOIN TB004001 T_FPN
                         ON
                             FPS_T.PARENT_PARTS_NO = T_FPN.PARTS_NO
                         WHERE
                             EXISTS (SELECT 1 FROM ARRANGEMENT_FPN_KEY_LIST FPN_KEY WHERE T_FPN.PARTS_NO = FPN_KEY.PARTS_NO
                                     UNION ALL
                                     SELECT 1 FROM ARRANGEMENT_FPS_KEY_LIST FPS_KEY WHERE T_FPN.PARTS_NO = FPS_KEY.SUB_PARTS_NO )
                            AND EXISTS (SELECT 1    FROM TB004001 TT_FPN WHERE FPS_T.SUB_PARTS_NO = TT_FPN.PARTS_NO)
                         GROUP BY
                             T_FPN.PARTS_NO
                     )
        /* ☆☆☆ここからが本体のSQL☆☆☆ */
        /* 上記で取得した設変情報のキーを元にP/N・P/SをUNIONして画面表示に必要な情報全てを取得する */
        SELECT
            DATA_TYPE,            /* 表示データ区分 1:P/N、2:P/S用のP/N、3:P/S */
            CHANGE_CLS,          /* 変更区分　自動判定結果シンボル */
            NEWOLD,              /* 新旧区分 */
            DRAWING_SERIES,      /* 図面シリーズ */
            DRAWING_BLOCK_NO,      /* 図面ブロックNO */
            ID_DISP,                /* 品目ID （表示用） */
            LINK_EXISTS,            /* 品目IDのリンク有無 */
            ATTENTION_FLAG,      /* 品目ID 要注意マーク */
            LV,                  /* レベル */
            PARTS_NO,              /* 部品番号 （P/Sの場合は構成部品番号） */
            DRAWING_REV_NO,      /* 図面改訂番号 */
            REV_NO,             /* 変番 （P/Nの場合は技術部品改訂番号、P/Sの場合は構成改訂番号） */
            FACTORY_REV_NO,   /* 工場改訂番号 （P/Nの場合は工場部品改訂番号、P/Sの場合は工場構成改訂番号） */
            FACTORY_PN_STATUS,    /* 工場部品ステータス （P/Sの場合は工場構成ステータス） */
            PARTS_NAME,          /* 部品名称 */
            CONSUMPTION_ROUTING,    /* 消費工順 */
            JOB_SEQ_NO,          /* 発生工順 */
            SUPPLIER,              /* 取引先 （カンマ区切り有り） */
            QUANTITY,              /* 員数 */
            PREV_PARENT_PARTS,    /* 旧親部品番号 */
            PREV_PARTS,          /* 旧部品番号 */
            PREV_PARTS_REV,      /* 旧図面改訂番号  */
            UNIT_CLASS,          /* ユニット区分 */
            PROCESSING_CODE,        /* 加工区分 */
            ADOPT_DATE,          /* 採用日 */
            ABOLISH_DATE,          /* 廃止日 */
            PENDING_DECIDED_DATE,   /* 未決決定年月日（暫定未決決定年月日から取得した場合はカッコつき） */
            PARENT_PARTS_NO,        /* 親部品番号 （P/N行は'-'表示） */
            DRAWING_OVER,          /* 図面オーバー */
            DRAWING_COL,            /* 図面カラム */
            DRAWING_CLASS,        /* 図面区分 （Fの場合は'*'表示） */
            DRAWING_NO,          /* 図面番号 */
            INDEX_NO,              /* 見出し番号 */
            KIND,                  /* 種類 */
            E_REMARKS,            /* 技術部品表備考 (SC003030で表示) */
            F_REMARKS,            /* 工場部品表備考（SC004040で表示）*/
            ASTAR2,              /* *2に表示するデータ、管理区分、採確区分 を表示 */
            CANCEL_FLAG,            /* 無効フラグ （暫定無効フラグから取得した場合はカッコつき） */
            SORTKEY,                /* 表示用キー 表示データ区分、部品番号、区分値、新旧区分でソート */
            PARENT_PARTS_EXIST,  /* 親部品有無 */
            CHILD_PARTS_EXIST,    /* 子部品有無 */
            DATA_CHECK_RESULT,    /* データチェック結果 */
            FINAL_BLOCK_TYPE,      /* BODY/UNIT混在ブロック */
            REPR_OF_MAIN_ECS_NO,    /* 主設通代表設通番号 */
            PARTS_STS_JP,          /* 工場部品ステータス名称 （日本語） */
            PARTS_STS_EN,          /* 工場部品ステータス名称 （英語） */
            ID_CNT,             /* 品目ID辞書件数 */
            DIFF_SUP,               /* 配布サプライヤと異なるか （背景色変更用） */
            TITLE_PARTS_NO,             /* タイトル図面番号 */
            TITLE_ENGINEERING_PN_REV_NO,    /* タイトル図面_技術部品改訂番号 */
            TITLE_FACTORY_PN_REV_NO,        /* タイトル図面_工場部品改訂番号 */
            TITLE_DWG_CLS,              /*  タイトル図面_Final図番*/
            EPN_MAX_SERIES,             /* 最大改訂の図面シリーズ */
            EPN_MAX_BLOCK_NO,               /* 最大改訂のブロックNO */
            EPN_MAX_BLOCK_BU,               /* 最大改訂のボディユニット区分 */
            EPN_MAX_PARTS_NAME              /*  最大改訂の部品名称 */
        FROM
            (
                /* ★★★ここからがP/Nのデータ取得★★★ */
                SELECT
                    FPN_KEY.DATA_TYPE, /* 表示データ区分 1:P/N、2:P/S用のP/N */
                    CASE WHEN PREV_PN.PARTS_NO IS NULL THEN EPND.AUTOMATIC_SYMBOL ELSE CAST(:CASTER AS CHAR(2)) END CHANGE_CLS, /* 変更区分 */
                    FPN_KEY.NEWOLD, /* 新旧区分 */
                    EPN.DRAWING_SERIES, /* 図面シリーズ */
                    EPN.DRAWING_BLOCK_NO, /* ブロックNO */
                    /* 部品品目管理にあればID表示、辞書が２件以上あれば？を表示、１件以下ならなければN/Aを表示 */
                    CASE
                        WHEN IDPN.PARTS_NO IS NOT NULL THEN IDPN.ITEM_ID_NO
                        WHEN IDPN.PARTS_NO IS NULL AND ID_CNT.CNT >= 2 THEN :QUESTION
                        ELSE :NOT_APPL
                    END ID_DISP, /* 品目ID */
                    /* 部品品目管理以外の辞書件数が２件以上、または部品品目管理が存在し且つ別のIDが辞書にいればリンク表示 */
                    CASE
                        WHEN ID_CNT.CNT >= 2 THEN '1'
                        WHEN IDPN.PARTS_NO IS NOT NULL AND IDPN.ITEM_ID_NO <> ID_CNT.ITEM_ID_NO THEN '1'
                        ELSE  '0'
                    END LINK_EXISTS, /* 品目IDリンク */
                    DECODE(ID.ATTENTION_FLAG,:ID_ATTENTIONFLG,:ASTER,ID.ATTENTION_FLAG) AS ATTENTION_FLAG, /* 品目ID要注意フラグ */
                    DECODE(EPN.DRAWING_CLASS,:FINAL,'0','1') LV /* レベル FINAL部品の場合は'0'、それ以外は'1' */,
                    FPN.PARTS_NO, /* 部品番号 */
                    EPND.DRAWING_REV_NO, /* 図面改訂NO */
                    FPN.ENGINEERING_PN_REV_NO AS REV_NO, /* 変番 */
                    FPN.FACTORY_PN_REV_NO AS FACTORY_REV_NO, /* 工場部品改訂番号 */
                    FPN.FACTORY_PN_STATUS, /* 工場部品ステータス */
                    EPN.PARTS_NAME AS PARTS_NAME, /* 部品名称 */
                    NVL(F_FPS.CONSUMPTION_ROUTING,'') AS CONSUMPTION_ROUTING, /* 消費工順  FINAL部品の場合は消費工順を表示、それ以外はブランク */
                    FPN.JOB_SEQ_NO, /* 発生工順 */
                    DECODE(FPN.SUPPLIER_CODE,'',SUPPN.PATH,FPN.SUPPLIER_CODE) AS SUPPLIER, /* 取引先コード */
                    NVL(F_EPS.QUANTITY,0) AS QUANTITY, /* 員数  FINAL部品の場合は員数を表示、それ以外は0 */
                    '' AS PREV_PARENT_PARTS, /* 旧親部品番号 */
                    PREV_PN.PATH AS PREV_PARTS, /* 旧部品番号 */
                    PREV_PN.PREV_DRAWING_REV_PATH AS PREV_PARTS_REV, /* 旧図面改訂番号 */
                    NVL(F_FPS.UNIT_CLASS,'') AS UNIT_CLASS, /* ユニット区分 */
                    NVL(F_FPS.PROCESSING_CODE,'') AS PROCESSING_CODE, /* 加工区分  FINAL部品の場合は加工区分を表示、それ以外はブランク */
                    DECODE(FPN.ADOPT_DATE,TO_DATE(:BANPEI_END),'',FPN.ADOPT_DATE) AS ADOPT_DATE, /* 採用年月日 */
                    DECODE(FPN.ABOLISH_DATE,TO_DATE(:BANPEI_END),DECODE(FPN.TMP_ABOLISH_DATE,TO_DATE(:BANPEI_END),'','('||FPN.TMP_ABOLISH_DATE||')'),FPN.ABOLISH_DATE) AS ABOLISH_DATE, /* 廃止年月日 */
                    DECODE(FPN.PENDING_DECIDED_DATE,TO_DATE(:BANPEI_END),'','1') AS PENDING_DECIDED_DATE, /* 未決決定年月日 */
                    '' AS PARENT_PARTS_NO, /* 親部品番号 */
                    EPN.DRAWING_OVER, /* 図面オーバー */
                    EPN.DRAWING_COL, /* 図面カラム */
                    DECODE(EPN.DRAWING_CLASS,:FINAL,CAST(:FINAL AS CHAR(1)),'') AS DRAWING_CLASS, /* 図面区分 */
                    EPND.DRAWING_NO, /* 図面番号 */
                    CAST(:HIFUN AS CHAR(1)) AS INDEX_NO, /* 見出し番号 */
                    CAST(:HIFUN AS CHAR(1)) AS KIND, /* 種類 */
                    EPND.REMARKS AS E_REMARKS, /* 変化点備考 */
                    FPN.REMARKS AS F_REMARKS, /* 工場部品情報備考 */
                    '' AS ASTAR2, /* *2 */
                    DECODE(FPN.CANCEL_FLAG,:CANCEL_FLAG,:ASTER,DECODE(FPN.TMP_CANCEL_FLAG,:CANCEL_FLAG,'(' || :ASTER || ')','')) AS CANCEL_FLAG, /* 無効フラグ */
                    FPN_KEY.DATA_TYPE || FPN_KEY.PARTS_NO || FPN_KEY.DATA_TYPE || DECODE(FPN_KEY.NEWOLD,:NEW,'1',:OLD,'0') AS SORTKEY,
                    DECODE(P_EXT.PARTS_NO,'','',CAST(:ASTER AS CHAR(1))) AS PARENT_PARTS_EXIST, /* 親部品有無 */
                    DECODE(C_EXT.PARTS_NO,'','',CAST(:ASTER AS CHAR(1))) AS CHILD_PARTS_EXIST, /* 子部品有無 */
                    FPN.PARTS_NO AS PARTS_NO_CONDITION, /* 部品番号検索条件 */
                    FPN.DATA_CHECK_RESULT, /*データチェック結果 */
                    DECODE(NVL(FB_EPND.PARTS_NO,''),'','', CAST(:ASTER AS CHAR(1))) AS FINAL_BLOCK_TYPE, /*ボディ／ユニットブロック混在有無*/
                    FPN.REPR_OF_MAIN_ECS_NO, /*主設通代表設通 */
                    PARTS_STS_MST.JP_DISPLAY_NAME AS PARTS_STS_JP, /*部品ステータス 日本語表示名称*/
                    PARTS_STS_MST.EN_DISPLAY_NAME AS PARTS_STS_EN, /*部品ステータス 英語表示名称*/
                    ID_CNT.CNT AS ID_CNT, /*品目ID辞書件数*/
                    DECODE(DSP.PARTS_NO,'','','1') AS DIFF_SUP, /* 図面配布サプライヤと異なるか否か */
                    FPN.PARTS_NO AS TITLE_PARTS_NO,             /* タイトル図面番号 */
                    FPN.ENGINEERING_PN_REV_NO AS TITLE_ENGINEERING_PN_REV_NO,   /* タイトル図面_技術部品改訂番号 */
                    FPN.FACTORY_PN_REV_NO AS TITLE_FACTORY_PN_REV_NO,       /* タイトル図面_工場部品改訂番号 */
                    EPN.DRAWING_CLASS AS TITLE_DWG_CLS,             /*  タイトル図面_Final図番*/
                    EPN_MAX.DRAWING_SERIES AS EPN_MAX_SERIES, /* 最大改訂の図面シリーズ */
                    EPN_MAX.DRAWING_BLOCK_NO AS EPN_MAX_BLOCK_NO, /* 最大改訂のブロックNO */
                    MAX_BLK.BODY_UNIT_DIV AS EPN_MAX_BLOCK_BU, /* 最大改訂のボディユニット区分 */
                    EPN_MAX.PARTS_NAME AS EPN_MAX_PARTS_NAME /* 最大改訂の部品名称 */
                FROM ARRANGEMENT_FPN_KEY_LIST FPN_KEY -- 工場部品設変データ
                INNER JOIN TB004001 FPN -- 工場部品情報
                ON
                    FPN.PARTS_NO = FPN_KEY.PARTS_NO AND
                    FPN.ENGINEERING_PN_REV_NO = FPN_KEY.ENGINEERING_PN_REV_NO AND
                    FPN.FACTORY_PN_REV_NO = FPN_KEY.FACTORY_PN_REV_NO
                LEFT JOIN TB004002 F_FPS -- 工場構成情報　※ファイナルの場合のみ
                ON
                    FPN.PARTS_NO = F_FPS.SUB_PARTS_NO AND
                    F_FPS.PARENT_PARTS_NO = :DUMMY_TOP AND
                    FPN.REPR_OF_MAIN_ECS_NO = F_FPS.REPR_OF_MAIN_ECS_NO
                LEFT JOIN TB001004 F_EPS -- 部品構成　※ファイナルの場合のみ
                ON
                    F_FPS.SUB_PARTS_NO = F_EPS.SUB_PARTS_NO AND
                    F_FPS.PARENT_PARTS_NO = F_EPS.PARENT_PARTS_NO AND
                    F_FPS.ENGINEERING_PS_REV_NO = F_EPS.ENGINEERING_PS_REV_NO
                INNER JOIN TB001001 PN -- 部品マスタ
                ON
                    FPN.PARTS_NO = PN.PARTS_NO
                INNER JOIN TB001002 EPND -- 部品図面
                ON
                    FPN.PARTS_NO = EPND.PARTS_NO AND
                    FPN.ENGINEERING_PN_REV_NO = EPND.ENGINEERING_PN_REV_NO
                LEFT JOIN PREV_PARTS_PATH PREV_PN -- 旧部品情報（カンマ区切り）
                ON
                    FPN.PARTS_NO = PREV_PN.PARTS_NO AND
                    FPN.ENGINEERING_PN_REV_NO = PREV_PN.ENGINEERING_PN_REV_NO AND
                    PREV_PN.ISLEAF = '0' -- 途中経過は不要なので、末端のみを取得する
                INNER JOIN TB001003 EPN -- 部品諸元
                ON
                    FPN.PARTS_NO = EPN.PARTS_NO AND
                    FPN.PARTS_PROP_REV_NO = EPN.PARTS_PROP_REV_NO
                INNER JOIN
                    (SELECT
                        T_EPN.PARTS_NO,
                        T_EPN.DRAWING_SERIES,
                        T_EPN.DRAWING_BLOCK_NO,
                        T_EPN.PARTS_NAME
                    FROM TB001003 T_EPN
                    WHERE
                        (T_EPN.PARTS_NO,T_EPN.PARTS_PROP_REV_NO) IN
                        (SELECT
                            PARTS_NO,
                            MAX(PARTS_PROP_REV_NO)
                        FROM TB001003 T
                        WHERE
                            EXISTS (SELECT 1 FROM ARRANGEMENT_FPN_KEY_LIST A WHERE T.PARTS_NO = A.PARTS_NO)
                        GROUP BY PARTS_NO
                        )
                    ) EPN_MAX -- 部品諸元最大改訂 ※品目IDとの結合に使用する
                ON
                    EPN.PARTS_NO = EPN_MAX.PARTS_NO
                LEFT JOIN P_EXIST P_EXT -- 親部品存在有無
                ON
                    EPND.PARTS_NO = P_EXT.PARTS_NO
                LEFT JOIN C_EXIST C_EXT -- 子部品存在有無
                ON
                    EPND.PARTS_NO = C_EXT.PARTS_NO
                LEFT JOIN TB009005 BLK -- ブロックマスタ　※ユニットブロックの判断に使用
                ON
                    EPN.DRAWING_BLOCK_NO = BLK.BLOCK_NO
                LEFT JOIN TB009005 MAX_BLK -- ブロックマスタ　※最大改訂の部品諸元
                ON
                    EPN_MAX.DRAWING_BLOCK_NO = MAX_BLK.BLOCK_NO
                LEFT JOIN TB006006 IDPN -- 部品品目管理
                ON
                    FPN.PARTS_NO = IDPN.PARTS_NO AND
                    DECODE(BLK.BODY_UNIT_DIV,:UNIT_KBN,:UNTN,EPN.DRAWING_SERIES) = IDPN.MC_DEV_MODEL_CODE
                LEFT JOIN TB006001 ID -- 品目ID
                ON
                    IDPN.ITEM_ID_NO = ID.ITEM_ID_NO
                LEFT JOIN
                    (SELECT
                        MAX(IDDIC.ITEM_ID_NO) AS ITEM_ID_NO, -- 取得できたIDが1件の場合に一致するかを判断する為に取得
                        MDID.MC_DEV_MODEL_CODE,
                        IDDIC.FUNCTION,
                        IDDIC.ITEM_NAME,
                        COUNT(*) AS CNT
                     FROM TB006002 IDDIC
                     INNER JOIN TB006004 MDID
                     ON
                        IDDIC.ITEM_ID_NO = MDID.ITEM_ID_NO
                     GROUP BY MDID.MC_DEV_MODEL_CODE,IDDIC.FUNCTION,IDDIC.ITEM_NAME
                    ) ID_CNT -- 品目ID件数
                ON
                    DECODE(BLK.BODY_UNIT_DIV,:UNIT_KBN,:UNTN,EPN_MAX.DRAWING_SERIES) = ID_CNT.MC_DEV_MODEL_CODE AND
                    PN.PARTS_FUNCTION = ID_CNT.FUNCTION AND
                    EPN_MAX.PARTS_NAME = ID_CNT.ITEM_NAME
                LEFT JOIN PARTS_SUPPLIER_PATH SUPPN -- 取引先情報（カンマ区切り）
                ON
                    FPN.PARTS_NO = SUPPN.PARTS_NO AND SUPPN.ISLEAF = '0'
                INNER JOIN TB011015 PARTS_STS_MST -- 部品ステータス（コードマスタ）
                ON
                    FPN.FACTORY_PN_STATUS = PARTS_STS_MST.CODE_VALUE AND
                    PARTS_STS_MST.CODE_GROUP_ID = :CDGRP005
                LEFT JOIN FINAL_BLOCK_EPND FB_EPND -- ファイナルにボディとユニットが混在する部品図面
                ON
                    EPND.PARTS_NO = FB_EPND.PARTS_NO AND
                    EPND.ENGINEERING_PN_REV_NO = FB_EPND.ENGINEERING_PN_REV_NO
                LEFT JOIN DIST_DIFF_SUP DSP -- 配布実績の取引先と異なる工場部品
                ON
                    FPN.PARTS_NO = DSP.PARTS_NO AND
                    FPN.ENGINEERING_PN_REV_NO = DSP.ENGINEERING_PN_REV_NO AND
                    FPN.FACTORY_PN_REV_NO = DSP.FACTORY_PN_REV_NO
                UNION ALL
                /* ★★★ここからがP/Sのデータ★★★ */
                SELECT
                    FPS_KEY.DATA_TYPE,/* 表示データ区分 3:P/S */
                    CASE WHEN PREV_PS.SUB_PARTS_NO IS NULL THEN EPS.AUTOMATIC_SYMBOL ELSE CAST(:CASTER AS CHAR(2)) END CHANGE_CLS, /* 変更区分 */
                    FPS_KEY.NEWOLD, /* 新旧区分 */
                    P_EPN.DRAWING_SERIES, /* 図面シリーズ */
                    P_EPN.DRAWING_BLOCK_NO, /* ブロックNO */
                    /* 部品品目管理にあればID表示、辞書が２件以上あれば？を表示、１件以下ならなければN/Aを表示 */
                    CASE
                        WHEN IDPN.PARTS_NO IS NOT NULL THEN IDPN.ITEM_ID_NO
                        WHEN IDPN.PARTS_NO IS NULL AND ID_CNT.CNT >= 2 THEN :QUESTION
                        ELSE :NOT_APPL
                    END ID_DISP, /* 品目ID */
                    /* 部品品目管理以外の辞書件数が２件以上、または部品品目管理が存在し且つ別のIDが辞書にいればリンク表示 */
                    CASE
                        WHEN ID_CNT.CNT >= 2 THEN '1'
                        WHEN IDPN.PARTS_NO IS NOT NULL AND IDPN.ITEM_ID_NO <> ID_CNT.ITEM_ID_NO THEN '1'
                        ELSE  '0'
                    END LINK_EXISTS, /* 品目IDリンク */
                    DECODE(ID.ATTENTION_FLAG,:ID_ATTENTIONFLG,:ASTER,ID.ATTENTION_FLAG) AS ATTENTION_FLAG, /* 品目ID要注意フラグ */
                    DECODE(P_EPN.DRAWING_CLASS,:FINAL,'1','2') LV /* レベル */,
                    FPS.SUB_PARTS_NO, /* 部品番号 */
                    P_EPND.DRAWING_REV_NO, /* 図面改訂NO */
                    FPS.PS_REV_NO AS REV_NO, /* 変番 */
                    FPS.FACTORY_PS_REV_NO AS FACTORY_REV_NO, /* 工場構成改訂番号 */
                    FPS.FACTORY_PS_STATUS, /* 工場構成ステータス */
                    '　' || C_EPN.PARTS_NAME AS PARTS_NAME, /* 部品名称 */
                    FPS.CONSUMPTION_ROUTING AS CONSUMPTION_ROUTING, /* 消費工順 */
                    C_FPN.JOB_SEQ_NO AS JOB_SEQ_NO, /* 発生工順 */
                    DECODE(C_FPN.SUPPLIER_CODE,'',SUPPN.PATH,C_FPN.SUPPLIER_CODE) AS SUPPLIER, /* 取引先コード */
                    EPS.QUANTITY AS QUANTITY, /* 員数 */
                    PREV_PS.PARENT_PATH AS PREV_PARENT_PARTS, /* 旧親部品番号 */
                    PREV_PS.PATH AS PREV_PARTS, /* 旧部品番号 */
                    PREV_PS.PREV_DRAWING_REV_PATH AS PREV_PARTS_REV, /* 旧図面改訂番号 */
                    FPS.UNIT_CLASS AS UNIT_CLASS, /* ユニット区分 */
                    FPS.PROCESSING_CODE AS PROCESSING_CODE, /* 加工区分 */
                    DECODE(FPS.ADOPT_DATE,TO_DATE(:BANPEI_END),'',FPS.ADOPT_DATE) AS ADOPT_DATE, /* 採用年月日 */
                    DECODE(FPS.ABOLISH_DATE,TO_DATE(:BANPEI_END),DECODE(FPS.TMP_ABOLISH_DATE,TO_DATE(:BANPEI_END),'','('|| FPS.TMP_ABOLISH_DATE ||')'),FPS.ABOLISH_DATE) AS ABOLISH_DATE, /* 廃止年月日 */
                    DECODE(FPS.PENDING_DECIDED_DATE,TO_DATE(:BANPEI_END),'','1') AS PENDING_DECIDED_DATE, /* 未決決定年月日 */
                    FPS.PARENT_PARTS_NO AS PARENT_PARTS_NO, /* 親部品番号 */
                    C_EPN.DRAWING_OVER, /* 図面オーバー */
                    C_EPN.DRAWING_COL, /* 図面カラム */
                    DECODE(C_EPN.DRAWING_CLASS,:FINAL,CAST(:FINAL AS CHAR(1)),'') AS DRAWING_CLASS, /* 図面区分 */
                    P_EPND.DRAWING_NO, /* 図面番号 */
                    EPS.INDEX AS INDEX_NO, /* 見出し番号 */
                    EPS.KIND AS KIND, /* 種類 */
                    FPS.REMARKS, /* 変化点備考 */
                    FPS.REMARKS, /* 工場構成情報備考 */
                    DECODE(FPS.MANAGEMENT_STATUS,'','',:KANRI||':'||FPS.MANAGEMENT_STATUS) || DECODE(FPS.SUPPLY_CODE,'','',:KYOKYU||':'||FPS.SUPPLY_CODE) || DECODE(FPS.ADOPT_CHECK_CODE,'','',:SAIKAKU||':'||FPS.ADOPT_CHECK_CODE) AS ASTAR2, /* *2 */
                    DECODE(FPS.CANCEL_FLAG,:CANCEL_FLAG,:ASTER,DECODE(FPS.TMP_CANCEL_FLAG,:CANCEL_FLAG,'('|| :ASTER ||')')) AS CANCEL_FLAG, /* 無効フラグ */
                    '2' || FPS_KEY.PARENT_PARTS_NO || FPS_KEY.DATA_TYPE || DECODE(FPS_KEY.NEWOLD,:NEW,'1',:OLD,'0') AS SORTKEY,
                    CAST(:ASTER AS CHAR(1)) AS PARENT_PARTS_EXIST, /* 親部品有無 */
                    DECODE(C_EXT.PARTS_NO,'','',CAST(:ASTER AS CHAR(1))) AS CHILD_PARTS_EXIST, /* 子部品有無 */
                    FPS.PARENT_PARTS_NO AS PARTS_NO_CONDITION, /* 部品番号検索条件 */
                    FPS.DATA_CHECK_RESULT, /*データチェック結果 */
                    DECODE(NVL(FB_EPND.PARTS_NO,''),'','',CAST(:ASTER AS CHAR(1))) AS FINAL_BLOCK_TYPE, /*ボディ／ユニットブロック混在有無*/
                    FPS.REPR_OF_MAIN_ECS_NO, /*主設通代表設通 */
                    PARTS_STS_MST.JP_DISPLAY_NAME AS PARTS_STS_JP, /*部品ステータス 日本語表示名称*/
                    PARTS_STS_MST.EN_DISPLAY_NAME AS PARTS_STS_EN, /*部品ステータス 英語表示名称*/
                    ID_CNT.CNT AS ID_CNT, /*品目ID辞書件数*/
                    DECODE(DSP.PARTS_NO,'','','1') AS DIFF_SUP, /* 図面配布サプライヤと異なるか否か */
                    P_FPN.PARTS_NO AS TITLE_PARTS_NO,               /* タイトル図面番号 */
                    P_FPN.ENGINEERING_PN_REV_NO AS TITLE_ENGINEERING_PN_REV_NO, /* タイトル図面_技術部品改訂番号 */
                    P_FPN.FACTORY_PN_REV_NO AS TITLE_FACTORY_PN_REV_NO,     /* タイトル図面_工場部品改訂番号 */
                    P_EPN.DRAWING_CLASS AS TITLE_DWG_CLS,               /*  タイトル図面_Final図番*/
                    EPN_MAX.DRAWING_SERIES AS EPN_MAX_SERIES, /* 最大改訂の図面シリーズ */
                    EPN_MAX.DRAWING_BLOCK_NO AS EPN_MAX_BLOCK_NO, /* 最大改訂のブロックNO */
                    MAX_BLK.BODY_UNIT_DIV AS EPN_MAX_BLOCK_BU, /* 最大改訂のボディユニット区分 */
                    EPN_MAX.PARTS_NAME AS EPN_MAX_PARTS_NAME /* 最大改訂の部品名称 */
                FROM ARRANGEMENT_FPS_KEY_LIST FPS_KEY -- 工場構成設変データ
                INNER JOIN TB004002 FPS -- 工場構成情報
                ON
                    FPS.SUB_PARTS_NO = FPS_KEY.SUB_PARTS_NO AND
                    FPS.PARENT_PARTS_NO = FPS_KEY.PARENT_PARTS_NO AND
                    FPS.PS_REV_NO = FPS_KEY.PS_REV_NO AND
                    FPS.FACTORY_PS_REV_NO = FPS_KEY.FACTORY_PS_REV_NO
                LEFT JOIN TB001004 EPS -- 部品構成
                ON
                    FPS.SUB_PARTS_NO = EPS.SUB_PARTS_NO AND
                    FPS.PARENT_PARTS_NO = EPS.PARENT_PARTS_NO AND
                    FPS.ENGINEERING_PS_REV_NO = EPS.ENGINEERING_PS_REV_NO
                LEFT JOIN TB004001 P_FPN -- 組み付け先部品　工場部品情報
                ON
                    FPS.PARENT_PARTS_NO = P_FPN.PARTS_NO AND
                    FPS.REPR_OF_MAIN_ECS_NO = P_FPN.REPR_OF_MAIN_ECS_NO
                LEFT JOIN TB001001 PN -- 構成部品　部品マスタ
                ON
                    FPS.SUB_PARTS_NO = PN.PARTS_NO
                LEFT JOIN TB001002 P_EPND -- 組み付け先部品　部品図面
                ON
                    P_FPN.PARTS_NO = P_EPND.PARTS_NO AND
                    P_FPN.ENGINEERING_PN_REV_NO = P_EPND.ENGINEERING_PN_REV_NO
                LEFT JOIN PREV_PARTS_STRUCTURE_PATH PREV_PS -- 旧部品構成情報（カンマ区切り）
                ON
                    FPS.SUB_PARTS_NO = PREV_PS.SUB_PARTS_NO AND
                    FPS.PARENT_PARTS_NO = PREV_PS.PARENT_PARTS_NO AND
                    FPS.ENGINEERING_PS_REV_NO = PREV_PS.ENGINEERING_PS_REV_NO AND
                    PREV_PS.ISLEAF = '0'
                LEFT JOIN TB001003 P_EPN -- 組み付け先部品　部品諸元
                ON
                    P_FPN.PARTS_NO = P_EPN.PARTS_NO AND
                    P_FPN.PARTS_PROP_REV_NO = P_EPN.PARTS_PROP_REV_NO
                LEFT OUTER JOIN TB004001 C_FPN /* 構成部品　工場部品情報(子PNとしての工場部品情報) */
                ON
                    C_FPN.PARTS_NO=FPS.SUB_PARTS_NO AND
                    EXISTS
                    (
                        SELECT    /* 1.PSと採廃期間が重複しているもの, 2.工場ステータスが大きいもの, 3.最大の技術部品改訂 + 工場部品改訂 の順で最も優先度の高いデータを取得 */
                            MAX(
                            CASE WHEN
                              FPS.ADOPT_DATE < DECODE(FPS.FACTORY_PS_STATUS, CAST(:STATUS AS CHAR(2)),  DECODE(MPRT2.FACTORY_PN_STATUS, CAST(:STATUS AS CHAR(2)), MPRT2.ABOLISH_DATE, MPRT2.TMP_ABOLISH_DATE),  MPRT2.TMP_ABOLISH_DATE) AND
                              DECODE(FPS.FACTORY_PS_STATUS, CAST(:STATUS AS CHAR(2)), FPS.ABOLISH_DATE, FPS.TMP_ABOLISH_DATE) < MPRT2.ADOPT_DATE THEN '1' /* 採廃期間が重複している */
                              ELSE '0' /* 採廃期間が重複していない */
                            END || MPRT2.FACTORY_PN_STATUS || MPRT2.ENGINEERING_PN_REV_NO || MPRT2.FACTORY_PN_REV_NO
                              )
                        FROM TB004001 MPRT2
                        WHERE
                            MPRT2.PARTS_NO=C_FPN.PARTS_NO AND
                            MPRT2.CANCEL_FLAG=:CANCEL_FLAG  /*  無効フラグが「有効」(子PNは常に有効なデータのみ取得する) */
                        GROUP BY
                            MPRT2.PARTS_NO
                        HAVING
                            (C_FPN.ENGINEERING_PN_REV_NO || C_FPN.FACTORY_PN_REV_NO) =
                            RIGHT(
                                MAX(
                                    CASE WHEN
                                      FPS.ADOPT_DATE < DECODE(FPS.FACTORY_PS_STATUS, :STATUS,   DECODE(MPRT2.FACTORY_PN_STATUS,:STATUS, MPRT2.ABOLISH_DATE, MPRT2.TMP_ABOLISH_DATE),    MPRT2.TMP_ABOLISH_DATE) AND
                                      DECODE(FPS.FACTORY_PS_STATUS, :STATUS, FPS.ABOLISH_DATE, FPS.TMP_ABOLISH_DATE) <  MPRT2.ADOPT_DATE THEN '1'      /* 採廃期間が重複している */
                                     ELSE '0'                            /* 採廃期間が重複していない */
                                    END || MPRT2.FACTORY_PN_STATUS || MPRT2.ENGINEERING_PN_REV_NO || MPRT2.FACTORY_PN_REV_NO
                                    )
                              , 6)
                    )
                LEFT JOIN TB001003 C_EPN -- 構成部品　部品諸元
                ON
                    C_FPN.PARTS_NO = C_EPN.PARTS_NO AND
                    C_FPN.PARTS_PROP_REV_NO = C_EPN.PARTS_PROP_REV_NO
                LEFT JOIN
                    (SELECT
                        T_EPN.PARTS_NO,
                        T_EPN.DRAWING_SERIES,
                        T_EPN.DRAWING_BLOCK_NO,
                        T_EPN.PARTS_NAME
                    FROM TB001003 T_EPN
                    WHERE
                        (T_EPN.PARTS_NO,T_EPN.PARTS_PROP_REV_NO) IN
                        (SELECT
                            PARTS_NO,
                            MAX(PARTS_PROP_REV_NO)
                        FROM TB001003 T
                        WHERE
                            EXISTS (SELECT 1 FROM ARRANGEMENT_FPS_KEY_LIST A WHERE T.PARTS_NO = A.SUB_PARTS_NO)
                        GROUP BY PARTS_NO
                        )
                    ) EPN_MAX -- 部品諸元最大改訂 ※品目IDとの結合に使用する
                ON
                    C_EPN.PARTS_NO = EPN_MAX.PARTS_NO
                LEFT JOIN TB001002 C_EPND -- 構成部品　部品図面
                ON
                    C_FPN.PARTS_NO = C_EPND.PARTS_NO AND
                    C_FPN.ENGINEERING_PN_REV_NO = C_EPND.ENGINEERING_PN_REV_NO
                LEFT JOIN C_EXIST C_EXT -- 構成部品　子部品有無
                ON
                    C_EPND.PARTS_NO = C_EXT.PARTS_NO
                INNER JOIN TB009005 P_BLK -- 組み付け先部品　ブロックマスタ
                ON
                    P_EPN.DRAWING_BLOCK_NO = P_BLK.BLOCK_NO
                LEFT JOIN TB009005 MAX_BLK -- ブロックマスタ　※最大改訂の部品諸元
                ON
                    EPN_MAX.DRAWING_BLOCK_NO = MAX_BLK.BLOCK_NO
                LEFT JOIN TB006006 IDPN -- 構成部品　部品品目管理
                ON
                    FPS.SUB_PARTS_NO = IDPN.PARTS_NO AND
                    DECODE(P_BLK.BODY_UNIT_DIV,:UNIT_KBN,:UNTN,P_EPN.DRAWING_SERIES) = IDPN.MC_DEV_MODEL_CODE
                LEFT JOIN TB006001 ID -- 品目ID
                ON
                    IDPN.ITEM_ID_NO = ID.ITEM_ID_NO
                LEFT JOIN
                    (SELECT
                        MAX(IDDIC.ITEM_ID_NO) AS ITEM_ID_NO, -- 取得できたIDが1件の場合に一致するかを判断する為に取得
                        MDID.MC_DEV_MODEL_CODE,
                        IDDIC.FUNCTION,
                        IDDIC.ITEM_NAME,
                        COUNT(*) AS CNT
                     FROM TB006002 IDDIC
                     INNER JOIN TB006004 MDID
                     ON
                        IDDIC.ITEM_ID_NO = MDID.ITEM_ID_NO
                     GROUP BY MDID.MC_DEV_MODEL_CODE,IDDIC.FUNCTION,IDDIC.ITEM_NAME
                    ) ID_CNT -- 品目ID辞書件数
                ON
                    DECODE(P_BLK.BODY_UNIT_DIV,:UNIT_KBN,:UNTN,C_EPN.DRAWING_SERIES) = ID_CNT.MC_DEV_MODEL_CODE AND
                    PN.PARTS_FUNCTION = ID_CNT.FUNCTION AND
                    C_EPN.PARTS_NAME = ID_CNT.ITEM_NAME
                LEFT JOIN PARTS_SUPPLIER_PATH SUPPN -- 構成部品　取引先情報（カンマ区切り）
                ON
                    C_FPN.PARTS_NO = SUPPN.PARTS_NO AND SUPPN.ISLEAF = '0'
                INNER JOIN TB011015 PARTS_STS_MST -- 構成ステータス（コードマスタ）
                ON
                    FPS.FACTORY_PS_STATUS = PARTS_STS_MST.CODE_VALUE AND
                    PARTS_STS_MST.CODE_GROUP_ID = :CDGRP005
                LEFT JOIN FINAL_BLOCK_EPND FB_EPND -- 構成部品　ファイナルブロックのボディ／ユニット混在有無
                ON
                    C_FPN.PARTS_NO = FB_EPND.PARTS_NO AND
                    C_FPN.ENGINEERING_PN_REV_NO = FB_EPND.ENGINEERING_PN_REV_NO
                LEFT JOIN DIST_DIFF_SUP DSP -- 構成部品　配布実績取引先との差異
                ON
                    C_FPN.PARTS_NO = DSP.PARTS_NO AND
                    C_FPN.ENGINEERING_PN_REV_NO = DSP.ENGINEERING_PN_REV_NO AND
                    C_FPN.FACTORY_PN_REV_NO = DSP.FACTORY_PN_REV_NO
           ) X
        ORDER BY SORTKEY
;
