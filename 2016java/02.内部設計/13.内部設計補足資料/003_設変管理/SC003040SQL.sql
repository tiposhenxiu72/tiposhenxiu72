WITH 
-- ���������ɍ��v����ݒʔԍ����擾����
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
        -- �����͐����������ł͂Ȃ����A���_��͍��v����
        ECS.ECS_REV_NO = SIMUL_ECS.REPR_ECS_REV_NO AND
        ECS.REPR_SIMUL_CLASS = CAST(:SIMUL_CLS as char(1))
    -- �ݐR�ݒʂ͐ݒʔԍ��Ō�������
    LEFT JOIN TB003007 ECS_MT
    ON
        ECS.ECS_NO = ECS_MT.ECS_NO AND
        ECS.ECS_REV_NO = ECS_MT.ECS_REV_NO
    LEFT JOIN TB003005 MT
    ON
        ECS_MT.ECS_SERIES = MT.ECS_SERIES AND
        ECS_MT.ECS_MEETING_DATE = MT.ECS_MEETING_DATE AND
        ECS_MT.ECS_MTG_LOCATION = MT.ECS_MTG_LOCATION
    -- ���{�����͑�\�ݒʔԍ��Ō�������
    -- �����͗��_�㍇�v����̂ŁA�ݒʂł��Ă�
    LEFT JOIN TB003008 ECS_IMPL
    ON
        DECODE(ECS.REPR_SIMUL_CLASS,CAST(:SIMUL_CLS as char(1)),SIMUL_ECS.REPR_ECS_NO,ECS.ECS_NO) = ECS_IMPL.ECS_NO AND
        ECS.ECS_REV_NO = ECS_IMPL.ECS_REV_NO
    WHERE 
        -- �ݒʃV���[�Y�����͂��ꂽ�ꍇ
        ECS.ECS_SERIES = :ECS_SERIES AND
        -- �ۃR�[�h�����͂��ꂽ�ꍇ
        ECS.SECTION_CODE IN (CAST(:SEC_CD AS VARCHAR(30))) AND
        -- ��ANO�����͂��ꂽ�ꍇ
        ECS.SERIAL_NO LIKE CONCAT(:SER_NO,'%') AND
        -- �ݐR�������͂��ꂽ�ꍇ
        ECS_MT.ECS_MEETING_DATE = :MT_DATE AND
        -- ���ݒ�̂ݕ\�����w�肳�ꂽ�ꍇ
        (ECS_MT.ECS_MEETING_DATE IS NULL OR ECS_MT.ECS_MEETING_DATE < SYSDATE) AND
        -- ��̓������͂��ꂽ�ꍇ
        ECS.RECEIVED_DATE >= :RECEIVE_DATE_FROM AND
        ECS.RECEIVED_DATE <= :RECEIVE_DATE_TO AND
        -- �ݐR�ꏊ���w�肳�ꂽ�ꍇ
        ECS_MT.ECS_MTG_LOCATION = :ECS_MT_LOC AND
        -- �ݐR���̂��w�肳�ꂽ�ꍇ
        MT.ECS_MEETING_NAME LIKE CONCAT(:ECS_MT_NAME,'%') AND
        -- �d�����n���w�肳�ꂽ�ꍇ
        ECS_IMPL.DESTINATION = :DEST AND
        -- �ǉ������w�肳�ꂽ�ꍇ
        ECS.ECS_STATUS IN (DECODE(CAST(:YOMITOKI as char(1)),'0',CAST(:YOMITOKI_MISUMI as varchar(100)),'1',cast(:YOMITOKI_SUMI as varchar(100)))) AND 
        -- ��s���s���w�肳�ꂽ�ꍇ
        ECS.PRECEDE_FLAG = :PRECEDE AND
        -- ���R���w�肳�ꂽ�ꍇ
        ECS.REASON = :REASON AND
        -- �ݐR�������͂���Ȃ������ꍇ�͐ݒʃX�e�[�^�X�͐ݐR�\�ȃX�e�[�^�X�ɍi��
        (
            -- �ݐR�\�ȃX�e�[�^�X�F��́A���o�^���A���o�^�ρA�ݐR���A�ݐR�ρi�����L��j
        --  (ECS.ECS_STATUS IN (:STS_RECEIVE || ',' :STS_TMP_REG || ',' :STS_UNDERSTOOD || ',' :STS_EXAMINING || ',' :STS_EXAMED_TBD)) OR
            (ECS.ECS_STATUS IN (cast(:STS_EXAMINABLED as varchar(100)))) OR
            -- �܂��͐�s���s�ŐݐR���I����Ă��Ȃ��f�[�^
            (ECS.PRECEDE_FLAG = :PRECEDE_ON AND (ECS_MT.ECS_MEETING_DATE IS NULL OR ECS_MT.ECS_MEETING_DATE >= SYSDATE))
        )
    -- ���ԂɊ֌W�Ȃ�������\�����w�肳�ꂽ�ꍇ
    UNION 
    SELECT 
        ECS.ECS_NO,
        ECS.ECS_REV_NO,
        DECODE(ECS.REPR_SIMUL_CLASS,CAST(:SIMUL_CLS as char(1)),SIMUL_ECS.REPR_ECS_NO,ECS.ECS_NO) AS REPR_ECS_NO
    FROM TB003001 ECS
    LEFT JOIN TB003002 SIMUL_ECS
    ON
        ECS.ECS_NO = SIMUL_ECS.SIMULTANEOUS_ECS_NO AND 
        -- �����͐����������ł͂Ȃ����A���_��͍��v����
        ECS.ECS_REV_NO = SIMUL_ECS.REPR_ECS_REV_NO AND
        ECS.REPR_SIMUL_CLASS = CAST(:SIMUL_CLS as char(1))
    WHERE 
        ECS.ECS_STATUS = :STS_EXAMED_TBD
),
-- �ݒʂɊ֘A�Â��u���b�NNO���J���}��؂�Ŏ擾����
/* �����i���̃J���}��؂���i�ċASQL�p���я��j */
ECS_BLOCK_ORDER (REPR_OF_MAIN_ECS_NO,DRAWING_BLOCK_NO,ORDER_NUM)
AS (
    SELECT 
        REPR_OF_MAIN_ECS_NO,
        DRAWING_BLOCK_NO,
        ROW_NUMBER() OVER(PARTITION BY REPR_OF_MAIN_ECS_NO ORDER BY DRAWING_BLOCK_NO ) AS ORDER_NUM
    FROM
        (
            SELECT
                FPN.REPR_OF_MAIN_ECS_NO,                                    -- ��\�ݒʔԍ�
                -- �֘A���i�̃^�C�v=F��������΁A�Ώە��i�̕W�藓�}�ʃu���b�NNO�A����Ί֘A���i�̕W�藓�}�ʃu���b�NNO
                CASE 
                    WHEN RP.RELATED_PARTS_NO IS NULL THEN
                        EPN.DRAWING_BLOCK_NO
                    ELSE
                        EPN_F.DRAWING_BLOCK_NO
                END DRAWING_BLOCK_NO                        -- �u���b�NNO
            FROM TB004001 FPN
            -- �֘A���i�̃^�C�v=F�ƊO������
            LEFT JOIN TB001005 RP 
            ON
                FPN.PARTS_NO = RP.PARTS_NO AND RP.RELATION_TYPE = 'F'
            -- �֘A���i�̃^�C�v=F�̕��i�������擾
            LEFT JOIN TB001003 EPN_F
            ON
                EPN_F.PARTS_NO = RP.RELATED_PARTS_NO AND
                EPN_F.PARTS_PROP_REV_NO IN (SELECT MAX(TEPN_F.PARTS_PROP_REV_NO) FROM TB001003 TEPN_F WHERE TEPN_F.PARTS_NO = RP.RELATED_PARTS_NO GROUP BY TEPN_F.PARTS_NO)
            -- �����i�̃^�C�v�̕��i�������擾
            INNER JOIN TB001003 EPN
            ON
                FPN.PARTS_NO = EPN.PARTS_NO AND
                FPN.PARTS_PROP_REV_NO = EPN.PARTS_PROP_REV_NO
            WHERE 
                FPN.SKIP_FLAG = '0'                     -- �ǂݔ�΂�=0(�F�ǂݔ�΂��ȊO)
                AND EXISTS (SELECT 1 FROM ECS_KEY_LIST L WHERE FPN.REPR_OF_MAIN_ECS_NO = L.ECS_NO)
        ) X
    GROUP BY 
        REPR_OF_MAIN_ECS_NO,DRAWING_BLOCK_NO
)
,
/*  �u���b�N���̃J���}��؂��� */
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
/* ���w���ݒʂ̃J���}��؂���i�ċASQL�p���я��j */
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
/* ���w���ݒʂ̃J���}��؂��� */
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
    DECODE(ECS.REPR_SIMUL_CLASS,'0','','1','��','��') AS SIMAL_CLS,                                     /* ���w */
    ECS.RECEIVED_DATE,                                                                                  /* �ݒʎ�̓� */
    ECS.ECS_NO,                                                                                         /* �ݒʔԍ� */
    ECS.ECS_REV_NO,                                                                                     /* �ݒʉ���NO */
    ECS.ECS_TITLE_JP,                                                                                   /* �����i�a���j */
    ECS.ECS_TITLE_EN,                                                                                   /* �����i�p���j */
    CASE WHEN ECS.ECS_STATUS >= :STS_UNDERSTOOD THEN '��' ELSE '������' END AS YOMITOKI,                /* �ǉ��� */
    ECS_MT.ECS_MEETING_DATE,                                                                            /* �ݐR�� */
    LOC.ECS_MTG_LOC_NAME,                                                                               /* �ݐR�ꏊ */
    MT.ECS_MEETING_NAME,                                                                                /* �ݐR���� */
    ECS.DESIGN_SECTION,                                                                                 /* �݌v�� */
    ECS.ECS_ISSUE_MEMBER,                                                                               /* �݌v�S���� */
    ECS.DESIGN_PHONE_NO,                                                                                /* �d�b�ԍ� */
    BLC_PATH.PATH AS BLOCK_NO,                                                                          /* �u���b�NNO */
    PRECEDE_MST.JP_DISPLAY_NAME AS PRECEDE_JP,                                                          /* ��s���s�i�a���j */
    PRECEDE_MST.EN_DISPLAY_NAME AS PRECEDE_EN,                                                          /* ��s���s�i�p���j */
    ATTENTION_MST.JP_DISPLAY_NAME AS ATTENTION_JP,                                                      /* �v���Ӂi�a���j */
    ATTENTION_MST.EN_DISPLAY_NAME AS ATTENTION_EN,                                                      /* �v���Ӂi�p���j */
    REASON_MST.JP_DISPLAY_NAME AS REASON_JP,                                                            /* ���R�i�a���j */
    REASON_MST.EN_DISPLAY_NAME AS REASON_EN,                                                            /* ���R�i�p���j */
    NVL(REPR_ECS.REPR_ECS_NO,'') AS REPR_ECS_NO,                                                        /* ��\�ݒ�NO */
    NVL(REPR_ECS_MT.ECS_MEETING_DATE,'') AS REPR_ECS_MT_DATE,                                           /* ��\�ݒ� �ݐR���i�ŐV�j */
    SIMUL_PATH.PATH AS SIMUL_ECS,                                                                       /* ���w���ݒ� */
    DECODE(ECS.ECS_STATUS,CAST(:STS_EXAMED_TBD AS CHAR(2)),SYSDATE - ECS_MT_FIRST.ECS_MEETING_DATE,0) AS PASSED_DATE,    /* �o�ߓ� */
    DECODE(ECS.ECS_STATUS,CAST(:STS_EXAMED_TBD AS CHAR(2)),ECS_MT_FIRST.ECS_MEETING_DATE,'') AS FIRST_MEETING_DATE,      /* ����ݐR�� */
    BASE.APPLIED_MODEL_CODE,                                                                            /* �Ώ۔N������ */
    DEST_MST.DESTINATION_NAME,                                                                          /* �d�����n */
    APPLIED_MODEL_MST.JP_DISPLAY_NAME AS APPLIED_MODEL_NAME_JP,                                         /* �K�p�Ԏ�i�a���j */
    APPLIED_MODEL_MST.EN_DISPLAY_NAME AS APPLIED_MODEL_NAME_EN,                                         /* �K�p�Ԏ� �i�p���j*/
    DGN_REQD_MST.JP_DISPLAY_NAME AS DGN_REQD_JP,                                                        /* �݌v��]�����i�a���j */
    DGN_REQD_MST.EN_DISPLAY_NAME AS DGN_REQD_EN,                                                        /* �݌v��]�����i�p���j */
    DECODE(ECS_IMPL_0.IMPLEMENT_EVENT_ID,
                '',ECS_IMPL_0.DECIDED_IMPL_DATE,
                IMPL_0_EV_MST.EVENT_NAME) AS DESIDED_IMPL_DATE_0,                                       /* �������Y_���{���� */
    DECODE(ECS_IMPL_0.PARTIAL_PENDING_FLAG,'1','�L��','') AS PARTIAL_FLAG_0,                            /* �������Y_���������t���O */
    ECS_IMPL_0.REMARKS AS REMARKS_0,                                                                    /* �������Y_���l */
    DECODE(ECS_IMPL_1.IMPLEMENT_EVENT_ID,
                '',ECS_IMPL_1.DECIDED_IMPL_DATE,
                IMPL_1_EV_MST.EVENT_NAME) AS DESIDED_IMPL_DATE_1,                                       /* �C�O���Y(��������)_���{���� */
    DECODE(ECS_IMPL_1.PARTIAL_PENDING_FLAG,'1','�L��','') AS PARTIAL_FLAG_1,                            /* �C�O���Y(��������)_���������t���O */
    ECS_IMPL_1.REMARKS AS REMARKS_1,                                                                    /* �C�O���Y(��������)_���l */
    DECODE(ECS_IMPL_2.IMPLEMENT_EVENT_ID,
                '',ECS_IMPL_2.DECIDED_IMPL_DATE,
                IMPL_1_EV_MST.EVENT_NAME) AS DESIDED_IMPL_DATE_2,                                       /* �C�O���Y(SIA�ݐR��)_���{���� */
    DECODE(ECS_IMPL_2.PARTIAL_PENDING_FLAG,'1','�L��','') AS PARTIAL_FLAG_2,                            /* �C�O���Y(SIA�ݐR��)_���������t���O */
    ECS_IMPL_2.REMARKS AS REMARKS_2,                                                                    /* �C�O���Y(SIA�ݐR��)_���l */
    FMC_MST.NEW_SYS_CONTROL_FLAG,                                                                        /* �V�V�X�e���Ǘ��Ώۃt���O(�V�X�e���Ǘ��p) */
    ECS.ECS_STATUS                                                                                  /* �ݒʃX�e�[�^�X(�V�X�e���Ǘ��p)*/
FROM ECS_KEY_LIST KEYLIST
INNER JOIN TB003001 ECS
ON
    KEYLIST.ECS_NO = ECS.ECS_NO AND
    KEYLIST.ECS_REV_NO = ECS.ECS_REV_NO
-- �ݐR�ݒʂ͐ݒʔԍ��Ō�������
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
-- �u���b�N�͑�\�ݒʔԍ��Ō�������
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
-- ���w���͐ݒʔԍ��Ō�������
LEFT JOIN SIMULTANEOUS_ECS_PATH SIMUL_PATH
ON
    ECS.ECS_NO = SIMUL_PATH.REPR_ECS_NO AND
    ECS.ECS_REV_NO = SIMUL_PATH.REPR_ECS_REV_NO AND
    SIMUL_PATH.ISLEAF = '0'
-- ����ݐR�͐ݒʔԍ��Ō�������
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
-- ���w���͐ݒʔԍ��Ō�������i���g����\�ݒʂ̏ꍇ�̓u�����N�j
LEFT JOIN TB003002 REPR_ECS
ON
    ECS.ECS_NO = REPR_ECS.SIMULTANEOUS_ECS_NO AND
    -- �����͐����������ł͂Ȃ����A���_��͍��v����
    ECS.ECS_REV_NO = REPR_ECS.REPR_ECS_REV_NO AND
    ECS.REPR_SIMUL_CLASS = :SIMUL_CLS
-- ��\�ݒʂ̐ݐR�͑�\�ݒʂŌ�������i���g����\�ݒʂ̏ꍇ�̓u�����N�j
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
--���{�����̏W���͑�\�ݒʂŌ�������
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
--���{�����̊e��͏W���ƌ�������i���ʓI�ɑ�\�ݒʂŌ����j
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
--���{�����̊e��͏W���ƌ�������i���ʓI�ɑ�\�ݒʂŌ����j
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
--���{�����̊e��͏W���ƌ�������i���ʓI�ɑ�\�ݒʂŌ����j
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
