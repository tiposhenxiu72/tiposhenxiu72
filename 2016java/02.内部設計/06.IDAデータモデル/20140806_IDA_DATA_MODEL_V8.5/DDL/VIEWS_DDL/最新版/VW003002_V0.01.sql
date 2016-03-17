CREATE VIEW VW003002 (
	REPR_ECS_NO,		-- ��\�݌v�ʒm���ԍ�
	REPR_ECS_REV_NO,        -- ��\�ݒʉ����ԍ�
	RELATED_ECS_NO,         -- �֘A�݌v�ʒm���ԍ�
	RELATED_ECS_ORDER,      -- �֘A�ݒʕ��я�
	RANK                    -- 1:�֘A�ݒʁA2:�I�[�o�[�t���[�ݒʂ̊֘A�ݒ�
)
AS  (
	SELECT 
		REPR_ECS_NO,
		REPR_ECS_REV_NO,
		RELATED_ECS_NO,
		-- ��\�ݒʔԍ��A��\�ݒʉ����ԍ����ƂɃI�[�o�[�t���[��\�ݒʁi�����j�A�����N�A�֘A�ݒʔԍ��ŏ��ԕt���i�֘A�ݒʕ��я��̐����j
		ROW_NUMBER() OVER(PARTITION BY REPR_ECS_NO,REPR_ECS_REV_NO ORDER BY OVER_FLOW_REPR_ECS_NO,RANK,RELATED_ECS_ORDER) AS RELATED_ECS_ORDER,
		RANK
	 FROM (
		-- �w�肵����\�ݒʂ���̊֘A�ݒ�
		SELECT 
			A.REPR_ECS_NO AS REPR_ECS_NO,
			A.REPR_ECS_REV_NO AS REPR_ECS_REV_NO,
			A.RELATED_ECS_NO AS RELATED_ECS_NO,
			' ' AS OVER_FLOW_REPR_ECS_NO,
			A.RELATED_ECS_ORDER AS RELATED_ECS_ORDER,
			1 AS RANK
		FROM TB003003 A
		-- �w�肵���ݒʂ��I�[�o�[�t���[�ɂȂ��Ă���ݒʂ̊֘A�ݒ�
		-- (�I�[�o�[�t���[�ݒʂ̊֘A�ݒ�)
		UNION ALL
		SELECT
			D.ECS_NO AS REPR_ECS_NO,
			D.ECS_REV_NO AS REPR_ECS_REV_NO,
			B.RELATED_ECS_NO AS RELATED_ECS_NO,
			C.ECS_NO AS OVER_FLOW_REPR_ECS_NO,
			B.RELATED_ECS_ORDER AS RELATED_ECS_ORDER,
			2 AS RANK
		FROM TB003003 B
		-- �I�[�o�[�t���[�ݒʂ̑�\
		INNER JOIN TB003001 C	ON 
			B.REPR_ECS_NO = C.ECS_NO AND
			B.REPR_ECS_REV_NO = C.ECS_REV_NO 
		-- �w�肵����\�ݒʂ́i�I�[�o�[�t���[�ݒʂ̑�\�̑�\�ݒʁj���ڂɉ��������݂��Ȃ��̂ŉ���������������
		INNER JOIN TB003001 D	ON 
			D.ECS_NO = C.OVERFLOW_REPR_ECS_NO
		WHERE 
			C.OVERFLOW_REPR_ECS_NO <> ''
			-- �I�[�o�[�t���[�̑�\�ݒʂ͍ő�����Ŏ擾����
			AND C.ECS_REV_NO = ( SELECT MAX(E.ECS_REV_NO) FROM TB003001 E WHERE C.ECS_NO = E.ECS_NO GROUP BY E.ECS_NO)
	) X 
);