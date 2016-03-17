        WITH
        /* �ŏ��ɕ\������H�ꕔ�i���̃L�[���X�g���擾���� */
        ARRANGEMENT_FPN_KEY_LIST (PARTS_NO,ENGINEERING_PN_REV_NO,FACTORY_PN_REV_NO,NEWOLD,DATA_TYPE,ADOPT_DATE,ABOLISH_DATE,FACTORY_PN_STATUS)
        AS
        (
        /* NEW��P/N�f�[�^���H�ꕔ�i�����݌v�ʒm���L�[�Ɏ擾���� */
        SELECT
            FPN.PARTS_NO,
            FPN.ENGINEERING_PN_REV_NO,
            FPN.FACTORY_PN_REV_NO,
            CAST(:NEW AS VARCHAR(3)) AS NEWOLD,
            '1' AS DATA_TYPE, /* 1:P/N�f�[�^ */
            FPN.ADOPT_DATE,
            FPN.ABOLISH_DATE,
            FPN.FACTORY_PN_STATUS
        FROM TB004001 FPN
        WHERE FPN.REPR_OF_MAIN_ECS_NO = :ECS_NO
        UNION ALL
        /* OLD��P/N�f�[�^���H�ꕔ�i�����NEW�f�[�^�������ԍ��������������̍ő�̉����Ƃ��Ď擾���� */
        SELECT
            FPN.PARTS_NO,
            FPN.ENGINEERING_PN_REV_NO,
            FPN.FACTORY_PN_REV_NO,
            CAST(:OLD AS VARCHAR(3)) AS NEWOLD,
            '1', /* 1:P/N�f�[�^ */
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
        /* P/S�s�ɕ\������ׂ�NEW��P/N�����q���i�����݂���P/N�ɍi���Ď擾���� */
        SELECT
            FPN.PARTS_NO,
            FPN.ENGINEERING_PN_REV_NO,
            FPN.FACTORY_PN_REV_NO,
            CAST(:NEW AS VARCHAR(3)) AS NEWOLD,
            '2', /* 2:P/S�pP/N�f�[�^ */
            FPN.ADOPT_DATE,
            FPN.ABOLISH_DATE,
            FPN.FACTORY_PN_STATUS
        FROM TB004001 FPN
        WHERE FPN.REPR_OF_MAIN_ECS_NO = :ECS_NO
        AND EXISTS
            (SELECT 1 FROM TB004002 FPS WHERE FPN.PARTS_NO = FPS.PARENT_PARTS_NO AND FPN.REPR_OF_MAIN_ECS_NO = FPS.REPR_OF_MAIN_ECS_NO)
        ),
        /* �����i���̃J���}��؂���i�ċASQL�p���я��j */
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
        /* �����i���̃J���}��؂��� */
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
        /* �ŏ��ɕ\������H��\�����̃L�[���X�g���擾���� */
        ARRANGEMENT_FPS_KEY_LIST (SUB_PARTS_NO,PARENT_PARTS_NO,PS_REV_NO,FACTORY_PS_REV_NO,NEWOLD,DATA_TYPE,ADOPT_DATE,ABOLISH_DATE,FACTORY_PS_STATUS,ENGINEERING_PS_REV_NO)
        AS
        (
        /* NEW��P/S�f�[�^���H��\�������݌v�ʒm���L�[�Ɏ擾���� */
        SELECT
            FPS.SUB_PARTS_NO,
            FPS.PARENT_PARTS_NO,
            FPS.PS_REV_NO,
            FPS.FACTORY_PS_REV_NO,
            CAST(:NEW AS VARCHAR(3)) AS NEWOLD,
            '3' AS DATA_TYPE, /* 3:P/S�f�[�^ */
            FPS.ADOPT_DATE,
            FPS.ABOLISH_DATE,
            FPS.FACTORY_PS_STATUS,
            FPS.ENGINEERING_PS_REV_NO
        FROM TB004002 FPS
        WHERE FPS.REPR_OF_MAIN_ECS_NO = :ECS_NO
        UNION ALL
        /* OLD��P/S�f�[�^���H��\�������NEW�f�[�^�������ԍ��������������̍ő�̉����Ƃ��Ď擾���� */
        SELECT
            FPS.SUB_PARTS_NO,
            FPS.PARENT_PARTS_NO,
            FPS.PS_REV_NO,
            FPS.FACTORY_PS_REV_NO,
            CAST(:OLD AS VARCHAR(3)) AS NEWOLD,
            '3' AS DATA_TYPE, /* 3:P/S�f�[�^ */
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
        /* �����i�\�����̃J���}��؂���i�ċASQL�p���я��j */
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
        /* �����i�\�����̃J���}��؂��� */
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
        /* �������̃J���}��؂���i�ő�̔������^�C�v�ōi��j */
        PARTS_SUPPLIER_MAX_SOURCE_TYPE(PARTS_NO,SOURCE_TYPE)
        AS (
        SELECT
            A.PARTS_NO,
            MAX(A.SOURCE_TYPE) SOURCE_TYPE
        FROM TB002017 A
        WHERE EXISTS (SELECT 1 FROM ARRANGEMENT_FPN_KEY_LIST FPN_KEY WHERE A.PARTS_NO = FPN_KEY.PARTS_NO UNION ALL SELECT 1 FROM ARRANGEMENT_FPS_KEY_LIST FPS_KEY WHERE A.PARTS_NO = FPS_KEY.SUB_PARTS_NO )
        GROUP BY A.PARTS_NO)
        /* �������̃J���}��؂���i�ċASQL�p���я��j */
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
        /* �������̃J���}��؂��� */
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
        /* �t�@�C�i���̃u���b�N�����j�b�g�ƃ{�f�B�ō��݂��镔�i�}�ʏW�� */
        /* �Z�p�̓��ɓ��t�͏����ɂ��ꂸ�ɕ��i�}�ʒP�ʂɑΏە��i�Ɋ֘A�t���t�@�C�i�����i�̃u���b�N���Q�Ƃ��� */
        /* �{�f�B�^���j�b�g�敪��2���ȏ�i���݁j���݂��Ă���ꍇ�ɕ��i�}�ʂ̃L�[����� */
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
        -- ���i�����ɂ͑��݂��邪�A�T�v���C�����H�ꕔ�i�\�ƈقȂ�f�[�^�W��
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
        /* �e���i���ݗL��*/
        /* �H�ꕔ�i�\���ő��ݗL���𔻒f���邪�A���t�����܂��ĂȂ�Work�����݂��邱�Ƃ��z�肳���̂Ŋ��Ԃ݂͂Ȃ� */
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
        /* �q���i���ݗL��*/
        /* �H�ꕔ�i�\���ő��ݗL���𔻒f���邪�A���t�����܂��ĂȂ�Work�����݂��邱�Ƃ��z�肳���̂Ŋ��Ԃ݂͂Ȃ� */
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
        /* �������������炪�{�̂�SQL������ */
        /* ��L�Ŏ擾�����ݕϏ��̃L�[������P/N�EP/S��UNION���ĉ�ʕ\���ɕK�v�ȏ��S�Ă��擾���� */
        SELECT
            DATA_TYPE,            /* �\���f�[�^�敪 1:P/N�A2:P/S�p��P/N�A3:P/S */
            CHANGE_CLS,          /* �ύX�敪�@�������茋�ʃV���{�� */
            NEWOLD,              /* �V���敪 */
            DRAWING_SERIES,      /* �}�ʃV���[�Y */
            DRAWING_BLOCK_NO,      /* �}�ʃu���b�NNO */
            ID_DISP,                /* �i��ID �i�\���p�j */
            LINK_EXISTS,            /* �i��ID�̃����N�L�� */
            ATTENTION_FLAG,      /* �i��ID �v���Ӄ}�[�N */
            LV,                  /* ���x�� */
            PARTS_NO,              /* ���i�ԍ� �iP/S�̏ꍇ�͍\�����i�ԍ��j */
            DRAWING_REV_NO,      /* �}�ʉ����ԍ� */
            REV_NO,             /* �ϔ� �iP/N�̏ꍇ�͋Z�p���i�����ԍ��AP/S�̏ꍇ�͍\�������ԍ��j */
            FACTORY_REV_NO,   /* �H������ԍ� �iP/N�̏ꍇ�͍H�ꕔ�i�����ԍ��AP/S�̏ꍇ�͍H��\�������ԍ��j */
            FACTORY_PN_STATUS,    /* �H�ꕔ�i�X�e�[�^�X �iP/S�̏ꍇ�͍H��\���X�e�[�^�X�j */
            PARTS_NAME,          /* ���i���� */
            CONSUMPTION_ROUTING,    /* ����H�� */
            JOB_SEQ_NO,          /* �����H�� */
            SUPPLIER,              /* ����� �i�J���}��؂�L��j */
            QUANTITY,              /* ���� */
            PREV_PARENT_PARTS,    /* ���e���i�ԍ� */
            PREV_PARTS,          /* �����i�ԍ� */
            PREV_PARTS_REV,      /* ���}�ʉ����ԍ�  */
            UNIT_CLASS,          /* ���j�b�g�敪 */
            PROCESSING_CODE,        /* ���H�敪 */
            ADOPT_DATE,          /* �̗p�� */
            ABOLISH_DATE,          /* �p�~�� */
            PENDING_DECIDED_DATE,   /* ��������N�����i�b�薢������N��������擾�����ꍇ�̓J�b�R���j */
            PARENT_PARTS_NO,        /* �e���i�ԍ� �iP/N�s��'-'�\���j */
            DRAWING_OVER,          /* �}�ʃI�[�o�[ */
            DRAWING_COL,            /* �}�ʃJ���� */
            DRAWING_CLASS,        /* �}�ʋ敪 �iF�̏ꍇ��'*'�\���j */
            DRAWING_NO,          /* �}�ʔԍ� */
            INDEX_NO,              /* ���o���ԍ� */
            KIND,                  /* ��� */
            E_REMARKS,            /* �Z�p���i�\���l (SC003030�ŕ\��) */
            F_REMARKS,            /* �H�ꕔ�i�\���l�iSC004040�ŕ\���j*/
            ASTAR2,              /* *2�ɕ\������f�[�^�A�Ǘ��敪�A�̊m�敪 ��\�� */
            CANCEL_FLAG,            /* �����t���O �i�b�薳���t���O����擾�����ꍇ�̓J�b�R���j */
            SORTKEY,                /* �\���p�L�[ �\���f�[�^�敪�A���i�ԍ��A�敪�l�A�V���敪�Ń\�[�g */
            PARENT_PARTS_EXIST,  /* �e���i�L�� */
            CHILD_PARTS_EXIST,    /* �q���i�L�� */
            DATA_CHECK_RESULT,    /* �f�[�^�`�F�b�N���� */
            FINAL_BLOCK_TYPE,      /* BODY/UNIT���݃u���b�N */
            REPR_OF_MAIN_ECS_NO,    /* ��ݒʑ�\�ݒʔԍ� */
            PARTS_STS_JP,          /* �H�ꕔ�i�X�e�[�^�X���� �i���{��j */
            PARTS_STS_EN,          /* �H�ꕔ�i�X�e�[�^�X���� �i�p��j */
            ID_CNT,             /* �i��ID�������� */
            DIFF_SUP,               /* �z�z�T�v���C���ƈقȂ邩 �i�w�i�F�ύX�p�j */
            TITLE_PARTS_NO,             /* �^�C�g���}�ʔԍ� */
            TITLE_ENGINEERING_PN_REV_NO,    /* �^�C�g���}��_�Z�p���i�����ԍ� */
            TITLE_FACTORY_PN_REV_NO,        /* �^�C�g���}��_�H�ꕔ�i�����ԍ� */
            TITLE_DWG_CLS,              /*  �^�C�g���}��_Final�}��*/
            EPN_MAX_SERIES,             /* �ő�����̐}�ʃV���[�Y */
            EPN_MAX_BLOCK_NO,               /* �ő�����̃u���b�NNO */
            EPN_MAX_BLOCK_BU,               /* �ő�����̃{�f�B���j�b�g�敪 */
            EPN_MAX_PARTS_NAME              /*  �ő�����̕��i���� */
        FROM
            (
                /* �������������炪P/N�̃f�[�^�擾������ */
                SELECT
                    FPN_KEY.DATA_TYPE, /* �\���f�[�^�敪 1:P/N�A2:P/S�p��P/N */
                    CASE WHEN PREV_PN.PARTS_NO IS NULL THEN EPND.AUTOMATIC_SYMBOL ELSE CAST(:CASTER AS CHAR(2)) END CHANGE_CLS, /* �ύX�敪 */
                    FPN_KEY.NEWOLD, /* �V���敪 */
                    EPN.DRAWING_SERIES, /* �}�ʃV���[�Y */
                    EPN.DRAWING_BLOCK_NO, /* �u���b�NNO */
                    /* ���i�i�ڊǗ��ɂ����ID�\���A�������Q���ȏ゠��΁H��\���A�P���ȉ��Ȃ�Ȃ����N/A��\�� */
                    CASE
                        WHEN IDPN.PARTS_NO IS NOT NULL THEN IDPN.ITEM_ID_NO
                        WHEN IDPN.PARTS_NO IS NULL AND ID_CNT.CNT >= 2 THEN :QUESTION
                        ELSE :NOT_APPL
                    END ID_DISP, /* �i��ID */
                    /* ���i�i�ڊǗ��ȊO�̎����������Q���ȏ�A�܂��͕��i�i�ڊǗ������݂����ʂ�ID�������ɂ���΃����N�\�� */
                    CASE
                        WHEN ID_CNT.CNT >= 2 THEN '1'
                        WHEN IDPN.PARTS_NO IS NOT NULL AND IDPN.ITEM_ID_NO <> ID_CNT.ITEM_ID_NO THEN '1'
                        ELSE  '0'
                    END LINK_EXISTS, /* �i��ID�����N */
                    DECODE(ID.ATTENTION_FLAG,:ID_ATTENTIONFLG,:ASTER,ID.ATTENTION_FLAG) AS ATTENTION_FLAG, /* �i��ID�v���Ӄt���O */
                    DECODE(EPN.DRAWING_CLASS,:FINAL,'0','1') LV /* ���x�� FINAL���i�̏ꍇ��'0'�A����ȊO��'1' */,
                    FPN.PARTS_NO, /* ���i�ԍ� */
                    EPND.DRAWING_REV_NO, /* �}�ʉ���NO */
                    FPN.ENGINEERING_PN_REV_NO AS REV_NO, /* �ϔ� */
                    FPN.FACTORY_PN_REV_NO AS FACTORY_REV_NO, /* �H�ꕔ�i�����ԍ� */
                    FPN.FACTORY_PN_STATUS, /* �H�ꕔ�i�X�e�[�^�X */
                    EPN.PARTS_NAME AS PARTS_NAME, /* ���i���� */
                    NVL(F_FPS.CONSUMPTION_ROUTING,'') AS CONSUMPTION_ROUTING, /* ����H��  FINAL���i�̏ꍇ�͏���H����\���A����ȊO�̓u�����N */
                    FPN.JOB_SEQ_NO, /* �����H�� */
                    DECODE(FPN.SUPPLIER_CODE,'',SUPPN.PATH,FPN.SUPPLIER_CODE) AS SUPPLIER, /* �����R�[�h */
                    NVL(F_EPS.QUANTITY,0) AS QUANTITY, /* ����  FINAL���i�̏ꍇ�͈�����\���A����ȊO��0 */
                    '' AS PREV_PARENT_PARTS, /* ���e���i�ԍ� */
                    PREV_PN.PATH AS PREV_PARTS, /* �����i�ԍ� */
                    PREV_PN.PREV_DRAWING_REV_PATH AS PREV_PARTS_REV, /* ���}�ʉ����ԍ� */
                    NVL(F_FPS.UNIT_CLASS,'') AS UNIT_CLASS, /* ���j�b�g�敪 */
                    NVL(F_FPS.PROCESSING_CODE,'') AS PROCESSING_CODE, /* ���H�敪  FINAL���i�̏ꍇ�͉��H�敪��\���A����ȊO�̓u�����N */
                    DECODE(FPN.ADOPT_DATE,TO_DATE(:BANPEI_END),'',FPN.ADOPT_DATE) AS ADOPT_DATE, /* �̗p�N���� */
                    DECODE(FPN.ABOLISH_DATE,TO_DATE(:BANPEI_END),DECODE(FPN.TMP_ABOLISH_DATE,TO_DATE(:BANPEI_END),'','('||FPN.TMP_ABOLISH_DATE||')'),FPN.ABOLISH_DATE) AS ABOLISH_DATE, /* �p�~�N���� */
                    DECODE(FPN.PENDING_DECIDED_DATE,TO_DATE(:BANPEI_END),'','1') AS PENDING_DECIDED_DATE, /* ��������N���� */
                    '' AS PARENT_PARTS_NO, /* �e���i�ԍ� */
                    EPN.DRAWING_OVER, /* �}�ʃI�[�o�[ */
                    EPN.DRAWING_COL, /* �}�ʃJ���� */
                    DECODE(EPN.DRAWING_CLASS,:FINAL,CAST(:FINAL AS CHAR(1)),'') AS DRAWING_CLASS, /* �}�ʋ敪 */
                    EPND.DRAWING_NO, /* �}�ʔԍ� */
                    CAST(:HIFUN AS CHAR(1)) AS INDEX_NO, /* ���o���ԍ� */
                    CAST(:HIFUN AS CHAR(1)) AS KIND, /* ��� */
                    EPND.REMARKS AS E_REMARKS, /* �ω��_���l */
                    FPN.REMARKS AS F_REMARKS, /* �H�ꕔ�i�����l */
                    '' AS ASTAR2, /* *2 */
                    DECODE(FPN.CANCEL_FLAG,:CANCEL_FLAG,:ASTER,DECODE(FPN.TMP_CANCEL_FLAG,:CANCEL_FLAG,'(' || :ASTER || ')','')) AS CANCEL_FLAG, /* �����t���O */
                    FPN_KEY.DATA_TYPE || FPN_KEY.PARTS_NO || FPN_KEY.DATA_TYPE || DECODE(FPN_KEY.NEWOLD,:NEW,'1',:OLD,'0') AS SORTKEY,
                    DECODE(P_EXT.PARTS_NO,'','',CAST(:ASTER AS CHAR(1))) AS PARENT_PARTS_EXIST, /* �e���i�L�� */
                    DECODE(C_EXT.PARTS_NO,'','',CAST(:ASTER AS CHAR(1))) AS CHILD_PARTS_EXIST, /* �q���i�L�� */
                    FPN.PARTS_NO AS PARTS_NO_CONDITION, /* ���i�ԍ��������� */
                    FPN.DATA_CHECK_RESULT, /*�f�[�^�`�F�b�N���� */
                    DECODE(NVL(FB_EPND.PARTS_NO,''),'','', CAST(:ASTER AS CHAR(1))) AS FINAL_BLOCK_TYPE, /*�{�f�B�^���j�b�g�u���b�N���ݗL��*/
                    FPN.REPR_OF_MAIN_ECS_NO, /*��ݒʑ�\�ݒ� */
                    PARTS_STS_MST.JP_DISPLAY_NAME AS PARTS_STS_JP, /*���i�X�e�[�^�X ���{��\������*/
                    PARTS_STS_MST.EN_DISPLAY_NAME AS PARTS_STS_EN, /*���i�X�e�[�^�X �p��\������*/
                    ID_CNT.CNT AS ID_CNT, /*�i��ID��������*/
                    DECODE(DSP.PARTS_NO,'','','1') AS DIFF_SUP, /* �}�ʔz�z�T�v���C���ƈقȂ邩�ۂ� */
                    FPN.PARTS_NO AS TITLE_PARTS_NO,             /* �^�C�g���}�ʔԍ� */
                    FPN.ENGINEERING_PN_REV_NO AS TITLE_ENGINEERING_PN_REV_NO,   /* �^�C�g���}��_�Z�p���i�����ԍ� */
                    FPN.FACTORY_PN_REV_NO AS TITLE_FACTORY_PN_REV_NO,       /* �^�C�g���}��_�H�ꕔ�i�����ԍ� */
                    EPN.DRAWING_CLASS AS TITLE_DWG_CLS,             /*  �^�C�g���}��_Final�}��*/
                    EPN_MAX.DRAWING_SERIES AS EPN_MAX_SERIES, /* �ő�����̐}�ʃV���[�Y */
                    EPN_MAX.DRAWING_BLOCK_NO AS EPN_MAX_BLOCK_NO, /* �ő�����̃u���b�NNO */
                    MAX_BLK.BODY_UNIT_DIV AS EPN_MAX_BLOCK_BU, /* �ő�����̃{�f�B���j�b�g�敪 */
                    EPN_MAX.PARTS_NAME AS EPN_MAX_PARTS_NAME /* �ő�����̕��i���� */
                FROM ARRANGEMENT_FPN_KEY_LIST FPN_KEY -- �H�ꕔ�i�ݕσf�[�^
                INNER JOIN TB004001 FPN -- �H�ꕔ�i���
                ON
                    FPN.PARTS_NO = FPN_KEY.PARTS_NO AND
                    FPN.ENGINEERING_PN_REV_NO = FPN_KEY.ENGINEERING_PN_REV_NO AND
                    FPN.FACTORY_PN_REV_NO = FPN_KEY.FACTORY_PN_REV_NO
                LEFT JOIN TB004002 F_FPS -- �H��\�����@���t�@�C�i���̏ꍇ�̂�
                ON
                    FPN.PARTS_NO = F_FPS.SUB_PARTS_NO AND
                    F_FPS.PARENT_PARTS_NO = :DUMMY_TOP AND
                    FPN.REPR_OF_MAIN_ECS_NO = F_FPS.REPR_OF_MAIN_ECS_NO
                LEFT JOIN TB001004 F_EPS -- ���i�\���@���t�@�C�i���̏ꍇ�̂�
                ON
                    F_FPS.SUB_PARTS_NO = F_EPS.SUB_PARTS_NO AND
                    F_FPS.PARENT_PARTS_NO = F_EPS.PARENT_PARTS_NO AND
                    F_FPS.ENGINEERING_PS_REV_NO = F_EPS.ENGINEERING_PS_REV_NO
                INNER JOIN TB001001 PN -- ���i�}�X�^
                ON
                    FPN.PARTS_NO = PN.PARTS_NO
                INNER JOIN TB001002 EPND -- ���i�}��
                ON
                    FPN.PARTS_NO = EPND.PARTS_NO AND
                    FPN.ENGINEERING_PN_REV_NO = EPND.ENGINEERING_PN_REV_NO
                LEFT JOIN PREV_PARTS_PATH PREV_PN -- �����i���i�J���}��؂�j
                ON
                    FPN.PARTS_NO = PREV_PN.PARTS_NO AND
                    FPN.ENGINEERING_PN_REV_NO = PREV_PN.ENGINEERING_PN_REV_NO AND
                    PREV_PN.ISLEAF = '0' -- �r���o�߂͕s�v�Ȃ̂ŁA���[�݂̂��擾����
                INNER JOIN TB001003 EPN -- ���i����
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
                    ) EPN_MAX -- ���i�����ő���� ���i��ID�Ƃ̌����Ɏg�p����
                ON
                    EPN.PARTS_NO = EPN_MAX.PARTS_NO
                LEFT JOIN P_EXIST P_EXT -- �e���i���ݗL��
                ON
                    EPND.PARTS_NO = P_EXT.PARTS_NO
                LEFT JOIN C_EXIST C_EXT -- �q���i���ݗL��
                ON
                    EPND.PARTS_NO = C_EXT.PARTS_NO
                LEFT JOIN TB009005 BLK -- �u���b�N�}�X�^�@�����j�b�g�u���b�N�̔��f�Ɏg�p
                ON
                    EPN.DRAWING_BLOCK_NO = BLK.BLOCK_NO
                LEFT JOIN TB009005 MAX_BLK -- �u���b�N�}�X�^�@���ő�����̕��i����
                ON
                    EPN_MAX.DRAWING_BLOCK_NO = MAX_BLK.BLOCK_NO
                LEFT JOIN TB006006 IDPN -- ���i�i�ڊǗ�
                ON
                    FPN.PARTS_NO = IDPN.PARTS_NO AND
                    DECODE(BLK.BODY_UNIT_DIV,:UNIT_KBN,:UNTN,EPN.DRAWING_SERIES) = IDPN.MC_DEV_MODEL_CODE
                LEFT JOIN TB006001 ID -- �i��ID
                ON
                    IDPN.ITEM_ID_NO = ID.ITEM_ID_NO
                LEFT JOIN
                    (SELECT
                        MAX(IDDIC.ITEM_ID_NO) AS ITEM_ID_NO, -- �擾�ł���ID��1���̏ꍇ�Ɉ�v���邩�𔻒f����ׂɎ擾
                        MDID.MC_DEV_MODEL_CODE,
                        IDDIC.FUNCTION,
                        IDDIC.ITEM_NAME,
                        COUNT(*) AS CNT
                     FROM TB006002 IDDIC
                     INNER JOIN TB006004 MDID
                     ON
                        IDDIC.ITEM_ID_NO = MDID.ITEM_ID_NO
                     GROUP BY MDID.MC_DEV_MODEL_CODE,IDDIC.FUNCTION,IDDIC.ITEM_NAME
                    ) ID_CNT -- �i��ID����
                ON
                    DECODE(BLK.BODY_UNIT_DIV,:UNIT_KBN,:UNTN,EPN_MAX.DRAWING_SERIES) = ID_CNT.MC_DEV_MODEL_CODE AND
                    PN.PARTS_FUNCTION = ID_CNT.FUNCTION AND
                    EPN_MAX.PARTS_NAME = ID_CNT.ITEM_NAME
                LEFT JOIN PARTS_SUPPLIER_PATH SUPPN -- �������i�J���}��؂�j
                ON
                    FPN.PARTS_NO = SUPPN.PARTS_NO AND SUPPN.ISLEAF = '0'
                INNER JOIN TB011015 PARTS_STS_MST -- ���i�X�e�[�^�X�i�R�[�h�}�X�^�j
                ON
                    FPN.FACTORY_PN_STATUS = PARTS_STS_MST.CODE_VALUE AND
                    PARTS_STS_MST.CODE_GROUP_ID = :CDGRP005
                LEFT JOIN FINAL_BLOCK_EPND FB_EPND -- �t�@�C�i���Ƀ{�f�B�ƃ��j�b�g�����݂��镔�i�}��
                ON
                    EPND.PARTS_NO = FB_EPND.PARTS_NO AND
                    EPND.ENGINEERING_PN_REV_NO = FB_EPND.ENGINEERING_PN_REV_NO
                LEFT JOIN DIST_DIFF_SUP DSP -- �z�z���т̎����ƈقȂ�H�ꕔ�i
                ON
                    FPN.PARTS_NO = DSP.PARTS_NO AND
                    FPN.ENGINEERING_PN_REV_NO = DSP.ENGINEERING_PN_REV_NO AND
                    FPN.FACTORY_PN_REV_NO = DSP.FACTORY_PN_REV_NO
                UNION ALL
                /* �������������炪P/S�̃f�[�^������ */
                SELECT
                    FPS_KEY.DATA_TYPE,/* �\���f�[�^�敪 3:P/S */
                    CASE WHEN PREV_PS.SUB_PARTS_NO IS NULL THEN EPS.AUTOMATIC_SYMBOL ELSE CAST(:CASTER AS CHAR(2)) END CHANGE_CLS, /* �ύX�敪 */
                    FPS_KEY.NEWOLD, /* �V���敪 */
                    P_EPN.DRAWING_SERIES, /* �}�ʃV���[�Y */
                    P_EPN.DRAWING_BLOCK_NO, /* �u���b�NNO */
                    /* ���i�i�ڊǗ��ɂ����ID�\���A�������Q���ȏ゠��΁H��\���A�P���ȉ��Ȃ�Ȃ����N/A��\�� */
                    CASE
                        WHEN IDPN.PARTS_NO IS NOT NULL THEN IDPN.ITEM_ID_NO
                        WHEN IDPN.PARTS_NO IS NULL AND ID_CNT.CNT >= 2 THEN :QUESTION
                        ELSE :NOT_APPL
                    END ID_DISP, /* �i��ID */
                    /* ���i�i�ڊǗ��ȊO�̎����������Q���ȏ�A�܂��͕��i�i�ڊǗ������݂����ʂ�ID�������ɂ���΃����N�\�� */
                    CASE
                        WHEN ID_CNT.CNT >= 2 THEN '1'
                        WHEN IDPN.PARTS_NO IS NOT NULL AND IDPN.ITEM_ID_NO <> ID_CNT.ITEM_ID_NO THEN '1'
                        ELSE  '0'
                    END LINK_EXISTS, /* �i��ID�����N */
                    DECODE(ID.ATTENTION_FLAG,:ID_ATTENTIONFLG,:ASTER,ID.ATTENTION_FLAG) AS ATTENTION_FLAG, /* �i��ID�v���Ӄt���O */
                    DECODE(P_EPN.DRAWING_CLASS,:FINAL,'1','2') LV /* ���x�� */,
                    FPS.SUB_PARTS_NO, /* ���i�ԍ� */
                    P_EPND.DRAWING_REV_NO, /* �}�ʉ���NO */
                    FPS.PS_REV_NO AS REV_NO, /* �ϔ� */
                    FPS.FACTORY_PS_REV_NO AS FACTORY_REV_NO, /* �H��\�������ԍ� */
                    FPS.FACTORY_PS_STATUS, /* �H��\���X�e�[�^�X */
                    '�@' || C_EPN.PARTS_NAME AS PARTS_NAME, /* ���i���� */
                    FPS.CONSUMPTION_ROUTING AS CONSUMPTION_ROUTING, /* ����H�� */
                    C_FPN.JOB_SEQ_NO AS JOB_SEQ_NO, /* �����H�� */
                    DECODE(C_FPN.SUPPLIER_CODE,'',SUPPN.PATH,C_FPN.SUPPLIER_CODE) AS SUPPLIER, /* �����R�[�h */
                    EPS.QUANTITY AS QUANTITY, /* ���� */
                    PREV_PS.PARENT_PATH AS PREV_PARENT_PARTS, /* ���e���i�ԍ� */
                    PREV_PS.PATH AS PREV_PARTS, /* �����i�ԍ� */
                    PREV_PS.PREV_DRAWING_REV_PATH AS PREV_PARTS_REV, /* ���}�ʉ����ԍ� */
                    FPS.UNIT_CLASS AS UNIT_CLASS, /* ���j�b�g�敪 */
                    FPS.PROCESSING_CODE AS PROCESSING_CODE, /* ���H�敪 */
                    DECODE(FPS.ADOPT_DATE,TO_DATE(:BANPEI_END),'',FPS.ADOPT_DATE) AS ADOPT_DATE, /* �̗p�N���� */
                    DECODE(FPS.ABOLISH_DATE,TO_DATE(:BANPEI_END),DECODE(FPS.TMP_ABOLISH_DATE,TO_DATE(:BANPEI_END),'','('|| FPS.TMP_ABOLISH_DATE ||')'),FPS.ABOLISH_DATE) AS ABOLISH_DATE, /* �p�~�N���� */
                    DECODE(FPS.PENDING_DECIDED_DATE,TO_DATE(:BANPEI_END),'','1') AS PENDING_DECIDED_DATE, /* ��������N���� */
                    FPS.PARENT_PARTS_NO AS PARENT_PARTS_NO, /* �e���i�ԍ� */
                    C_EPN.DRAWING_OVER, /* �}�ʃI�[�o�[ */
                    C_EPN.DRAWING_COL, /* �}�ʃJ���� */
                    DECODE(C_EPN.DRAWING_CLASS,:FINAL,CAST(:FINAL AS CHAR(1)),'') AS DRAWING_CLASS, /* �}�ʋ敪 */
                    P_EPND.DRAWING_NO, /* �}�ʔԍ� */
                    EPS.INDEX AS INDEX_NO, /* ���o���ԍ� */
                    EPS.KIND AS KIND, /* ��� */
                    FPS.REMARKS, /* �ω��_���l */
                    FPS.REMARKS, /* �H��\�������l */
                    DECODE(FPS.MANAGEMENT_STATUS,'','',:KANRI||':'||FPS.MANAGEMENT_STATUS) || DECODE(FPS.SUPPLY_CODE,'','',:KYOKYU||':'||FPS.SUPPLY_CODE) || DECODE(FPS.ADOPT_CHECK_CODE,'','',:SAIKAKU||':'||FPS.ADOPT_CHECK_CODE) AS ASTAR2, /* *2 */
                    DECODE(FPS.CANCEL_FLAG,:CANCEL_FLAG,:ASTER,DECODE(FPS.TMP_CANCEL_FLAG,:CANCEL_FLAG,'('|| :ASTER ||')')) AS CANCEL_FLAG, /* �����t���O */
                    '2' || FPS_KEY.PARENT_PARTS_NO || FPS_KEY.DATA_TYPE || DECODE(FPS_KEY.NEWOLD,:NEW,'1',:OLD,'0') AS SORTKEY,
                    CAST(:ASTER AS CHAR(1)) AS PARENT_PARTS_EXIST, /* �e���i�L�� */
                    DECODE(C_EXT.PARTS_NO,'','',CAST(:ASTER AS CHAR(1))) AS CHILD_PARTS_EXIST, /* �q���i�L�� */
                    FPS.PARENT_PARTS_NO AS PARTS_NO_CONDITION, /* ���i�ԍ��������� */
                    FPS.DATA_CHECK_RESULT, /*�f�[�^�`�F�b�N���� */
                    DECODE(NVL(FB_EPND.PARTS_NO,''),'','',CAST(:ASTER AS CHAR(1))) AS FINAL_BLOCK_TYPE, /*�{�f�B�^���j�b�g�u���b�N���ݗL��*/
                    FPS.REPR_OF_MAIN_ECS_NO, /*��ݒʑ�\�ݒ� */
                    PARTS_STS_MST.JP_DISPLAY_NAME AS PARTS_STS_JP, /*���i�X�e�[�^�X ���{��\������*/
                    PARTS_STS_MST.EN_DISPLAY_NAME AS PARTS_STS_EN, /*���i�X�e�[�^�X �p��\������*/
                    ID_CNT.CNT AS ID_CNT, /*�i��ID��������*/
                    DECODE(DSP.PARTS_NO,'','','1') AS DIFF_SUP, /* �}�ʔz�z�T�v���C���ƈقȂ邩�ۂ� */
                    P_FPN.PARTS_NO AS TITLE_PARTS_NO,               /* �^�C�g���}�ʔԍ� */
                    P_FPN.ENGINEERING_PN_REV_NO AS TITLE_ENGINEERING_PN_REV_NO, /* �^�C�g���}��_�Z�p���i�����ԍ� */
                    P_FPN.FACTORY_PN_REV_NO AS TITLE_FACTORY_PN_REV_NO,     /* �^�C�g���}��_�H�ꕔ�i�����ԍ� */
                    P_EPN.DRAWING_CLASS AS TITLE_DWG_CLS,               /*  �^�C�g���}��_Final�}��*/
                    EPN_MAX.DRAWING_SERIES AS EPN_MAX_SERIES, /* �ő�����̐}�ʃV���[�Y */
                    EPN_MAX.DRAWING_BLOCK_NO AS EPN_MAX_BLOCK_NO, /* �ő�����̃u���b�NNO */
                    MAX_BLK.BODY_UNIT_DIV AS EPN_MAX_BLOCK_BU, /* �ő�����̃{�f�B���j�b�g�敪 */
                    EPN_MAX.PARTS_NAME AS EPN_MAX_PARTS_NAME /* �ő�����̕��i���� */
                FROM ARRANGEMENT_FPS_KEY_LIST FPS_KEY -- �H��\���ݕσf�[�^
                INNER JOIN TB004002 FPS -- �H��\�����
                ON
                    FPS.SUB_PARTS_NO = FPS_KEY.SUB_PARTS_NO AND
                    FPS.PARENT_PARTS_NO = FPS_KEY.PARENT_PARTS_NO AND
                    FPS.PS_REV_NO = FPS_KEY.PS_REV_NO AND
                    FPS.FACTORY_PS_REV_NO = FPS_KEY.FACTORY_PS_REV_NO
                LEFT JOIN TB001004 EPS -- ���i�\��
                ON
                    FPS.SUB_PARTS_NO = EPS.SUB_PARTS_NO AND
                    FPS.PARENT_PARTS_NO = EPS.PARENT_PARTS_NO AND
                    FPS.ENGINEERING_PS_REV_NO = EPS.ENGINEERING_PS_REV_NO
                LEFT JOIN TB004001 P_FPN -- �g�ݕt���敔�i�@�H�ꕔ�i���
                ON
                    FPS.PARENT_PARTS_NO = P_FPN.PARTS_NO AND
                    FPS.REPR_OF_MAIN_ECS_NO = P_FPN.REPR_OF_MAIN_ECS_NO
                LEFT JOIN TB001001 PN -- �\�����i�@���i�}�X�^
                ON
                    FPS.SUB_PARTS_NO = PN.PARTS_NO
                LEFT JOIN TB001002 P_EPND -- �g�ݕt���敔�i�@���i�}��
                ON
                    P_FPN.PARTS_NO = P_EPND.PARTS_NO AND
                    P_FPN.ENGINEERING_PN_REV_NO = P_EPND.ENGINEERING_PN_REV_NO
                LEFT JOIN PREV_PARTS_STRUCTURE_PATH PREV_PS -- �����i�\�����i�J���}��؂�j
                ON
                    FPS.SUB_PARTS_NO = PREV_PS.SUB_PARTS_NO AND
                    FPS.PARENT_PARTS_NO = PREV_PS.PARENT_PARTS_NO AND
                    FPS.ENGINEERING_PS_REV_NO = PREV_PS.ENGINEERING_PS_REV_NO AND
                    PREV_PS.ISLEAF = '0'
                LEFT JOIN TB001003 P_EPN -- �g�ݕt���敔�i�@���i����
                ON
                    P_FPN.PARTS_NO = P_EPN.PARTS_NO AND
                    P_FPN.PARTS_PROP_REV_NO = P_EPN.PARTS_PROP_REV_NO
                LEFT OUTER JOIN TB004001 C_FPN /* �\�����i�@�H�ꕔ�i���(�qPN�Ƃ��Ă̍H�ꕔ�i���) */
                ON
                    C_FPN.PARTS_NO=FPS.SUB_PARTS_NO AND
                    EXISTS
                    (
                        SELECT    /* 1.PS�ƍ̔p���Ԃ��d�����Ă������, 2.�H��X�e�[�^�X���傫������, 3.�ő�̋Z�p���i���� + �H�ꕔ�i���� �̏��ōł��D��x�̍����f�[�^���擾 */
                            MAX(
                            CASE WHEN
                              FPS.ADOPT_DATE < DECODE(FPS.FACTORY_PS_STATUS, CAST(:STATUS AS CHAR(2)),  DECODE(MPRT2.FACTORY_PN_STATUS, CAST(:STATUS AS CHAR(2)), MPRT2.ABOLISH_DATE, MPRT2.TMP_ABOLISH_DATE),  MPRT2.TMP_ABOLISH_DATE) AND
                              DECODE(FPS.FACTORY_PS_STATUS, CAST(:STATUS AS CHAR(2)), FPS.ABOLISH_DATE, FPS.TMP_ABOLISH_DATE) < MPRT2.ADOPT_DATE THEN '1' /* �̔p���Ԃ��d�����Ă��� */
                              ELSE '0' /* �̔p���Ԃ��d�����Ă��Ȃ� */
                            END || MPRT2.FACTORY_PN_STATUS || MPRT2.ENGINEERING_PN_REV_NO || MPRT2.FACTORY_PN_REV_NO
                              )
                        FROM TB004001 MPRT2
                        WHERE
                            MPRT2.PARTS_NO=C_FPN.PARTS_NO AND
                            MPRT2.CANCEL_FLAG=:CANCEL_FLAG  /*  �����t���O���u�L���v(�qPN�͏�ɗL���ȃf�[�^�̂ݎ擾����) */
                        GROUP BY
                            MPRT2.PARTS_NO
                        HAVING
                            (C_FPN.ENGINEERING_PN_REV_NO || C_FPN.FACTORY_PN_REV_NO) =
                            RIGHT(
                                MAX(
                                    CASE WHEN
                                      FPS.ADOPT_DATE < DECODE(FPS.FACTORY_PS_STATUS, :STATUS,   DECODE(MPRT2.FACTORY_PN_STATUS,:STATUS, MPRT2.ABOLISH_DATE, MPRT2.TMP_ABOLISH_DATE),    MPRT2.TMP_ABOLISH_DATE) AND
                                      DECODE(FPS.FACTORY_PS_STATUS, :STATUS, FPS.ABOLISH_DATE, FPS.TMP_ABOLISH_DATE) <  MPRT2.ADOPT_DATE THEN '1'      /* �̔p���Ԃ��d�����Ă��� */
                                     ELSE '0'                            /* �̔p���Ԃ��d�����Ă��Ȃ� */
                                    END || MPRT2.FACTORY_PN_STATUS || MPRT2.ENGINEERING_PN_REV_NO || MPRT2.FACTORY_PN_REV_NO
                                    )
                              , 6)
                    )
                LEFT JOIN TB001003 C_EPN -- �\�����i�@���i����
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
                    ) EPN_MAX -- ���i�����ő���� ���i��ID�Ƃ̌����Ɏg�p����
                ON
                    C_EPN.PARTS_NO = EPN_MAX.PARTS_NO
                LEFT JOIN TB001002 C_EPND -- �\�����i�@���i�}��
                ON
                    C_FPN.PARTS_NO = C_EPND.PARTS_NO AND
                    C_FPN.ENGINEERING_PN_REV_NO = C_EPND.ENGINEERING_PN_REV_NO
                LEFT JOIN C_EXIST C_EXT -- �\�����i�@�q���i�L��
                ON
                    C_EPND.PARTS_NO = C_EXT.PARTS_NO
                INNER JOIN TB009005 P_BLK -- �g�ݕt���敔�i�@�u���b�N�}�X�^
                ON
                    P_EPN.DRAWING_BLOCK_NO = P_BLK.BLOCK_NO
                LEFT JOIN TB009005 MAX_BLK -- �u���b�N�}�X�^�@���ő�����̕��i����
                ON
                    EPN_MAX.DRAWING_BLOCK_NO = MAX_BLK.BLOCK_NO
                LEFT JOIN TB006006 IDPN -- �\�����i�@���i�i�ڊǗ�
                ON
                    FPS.SUB_PARTS_NO = IDPN.PARTS_NO AND
                    DECODE(P_BLK.BODY_UNIT_DIV,:UNIT_KBN,:UNTN,P_EPN.DRAWING_SERIES) = IDPN.MC_DEV_MODEL_CODE
                LEFT JOIN TB006001 ID -- �i��ID
                ON
                    IDPN.ITEM_ID_NO = ID.ITEM_ID_NO
                LEFT JOIN
                    (SELECT
                        MAX(IDDIC.ITEM_ID_NO) AS ITEM_ID_NO, -- �擾�ł���ID��1���̏ꍇ�Ɉ�v���邩�𔻒f����ׂɎ擾
                        MDID.MC_DEV_MODEL_CODE,
                        IDDIC.FUNCTION,
                        IDDIC.ITEM_NAME,
                        COUNT(*) AS CNT
                     FROM TB006002 IDDIC
                     INNER JOIN TB006004 MDID
                     ON
                        IDDIC.ITEM_ID_NO = MDID.ITEM_ID_NO
                     GROUP BY MDID.MC_DEV_MODEL_CODE,IDDIC.FUNCTION,IDDIC.ITEM_NAME
                    ) ID_CNT -- �i��ID��������
                ON
                    DECODE(P_BLK.BODY_UNIT_DIV,:UNIT_KBN,:UNTN,C_EPN.DRAWING_SERIES) = ID_CNT.MC_DEV_MODEL_CODE AND
                    PN.PARTS_FUNCTION = ID_CNT.FUNCTION AND
                    C_EPN.PARTS_NAME = ID_CNT.ITEM_NAME
                LEFT JOIN PARTS_SUPPLIER_PATH SUPPN -- �\�����i�@�������i�J���}��؂�j
                ON
                    C_FPN.PARTS_NO = SUPPN.PARTS_NO AND SUPPN.ISLEAF = '0'
                INNER JOIN TB011015 PARTS_STS_MST -- �\���X�e�[�^�X�i�R�[�h�}�X�^�j
                ON
                    FPS.FACTORY_PS_STATUS = PARTS_STS_MST.CODE_VALUE AND
                    PARTS_STS_MST.CODE_GROUP_ID = :CDGRP005
                LEFT JOIN FINAL_BLOCK_EPND FB_EPND -- �\�����i�@�t�@�C�i���u���b�N�̃{�f�B�^���j�b�g���ݗL��
                ON
                    C_FPN.PARTS_NO = FB_EPND.PARTS_NO AND
                    C_FPN.ENGINEERING_PN_REV_NO = FB_EPND.ENGINEERING_PN_REV_NO
                LEFT JOIN DIST_DIFF_SUP DSP -- �\�����i�@�z�z���ю����Ƃ̍���
                ON
                    C_FPN.PARTS_NO = DSP.PARTS_NO AND
                    C_FPN.ENGINEERING_PN_REV_NO = DSP.ENGINEERING_PN_REV_NO AND
                    C_FPN.FACTORY_PN_REV_NO = DSP.FACTORY_PN_REV_NO
           ) X
        ORDER BY SORTKEY
;
