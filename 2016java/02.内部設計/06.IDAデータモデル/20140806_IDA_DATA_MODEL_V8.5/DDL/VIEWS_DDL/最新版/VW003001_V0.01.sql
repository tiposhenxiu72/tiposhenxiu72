-- ���w���ݒʂƃI�[�o�[�t���[�̑�\�ݒʂƃI�[�o�[�t���[�̓��w���ݒʂ��܂Ƃ߂Ď擾����VIEW
CREATE VIEW VW003001 (
	REPR_ECS_NO, 		-- ��\�݌v�ʒm���ԍ�
	REPR_ECS_REV_NO,	-- ��\�ݒʉ����ԍ�
	SIMULTANEOUS_ECS_NO,	-- ���w���݌v�ʒm���ԍ�
	SIMULTANEOUS_ECS_ORDER,	-- ���w���ݒʕ��я�
	RANK 			-- 1:���w���ݒʁA2:�I�[�o�[�t���[�ݒʂ̑�\�A3:�I�[�o�[�t���[�ݒʂ̓��w���ݒ�
)
AS (
	SELECT 
		REPR_ECS_NO,
		REPR_ECS_REV_NO,
		SIMULTANEOUS_ECS_NO,
		-- ��\�ݒʔԍ��A��\�ݒʉ����ԍ����ƂɃI�[�o�[�t���[��\�ݒʁi�����j�A�����N�A���w���ݒʔԍ��ŏ��ԕt���i���w���ݒʕ��я��̐����j
		ROW_NUMBER() OVER(PARTITION BY REPR_ECS_NO,REPR_ECS_REV_NO ORDER BY OVER_FLOW_REPR_ECS_NO,RANK,SIMULTANEOUS_ECS_ORDER) AS SIMULTANEOUS_ECS_ORDER,
		RANK
	 FROM (
		-- �w�肵����\�ݒʂ���̓��w��
		SELECT 
			A.REPR_ECS_NO AS REPR_ECS_NO,
			A.REPR_ECS_REV_NO AS REPR_ECS_REV_NO,
			A.SIMULTANEOUS_ECS_NO AS SIMULTANEOUS_ECS_NO,
			' ' AS OVER_FLOW_REPR_ECS_NO,
			A.SIMULTANEOUS_ECS_ORDER AS SIMULTANEOUS_ECS_ORDER,
			1 AS RANK
		FROM TB003002 A
		-- �w�肵���ݒʂ��I�[�o�[�t���[�ɂȂ��Ă���ݒʂ̑�\
		-- (�I�[�o�[�t���[�ݒʂ̑�\)
		UNION ALL
		SELECT 
			C.ECS_NO AS REPR_ECS_NO,
			C.ECS_REV_NO AS REPR_ECS_REV_NO,
			B.ECS_NO  AS SIMULTANEOUS_ECS_NO,
			B.ECS_NO  AS OVER_FLOW_REPR_ECS_NO,
			1 AS SIMULTANEOUS_ECS_ORDER,
			2 AS RANK
		FROM TB003001 B 
		-- �w�肵����\�ݒʂ͍��ڂɉ��������݂��Ȃ��̂ŉ���������������
		INNER JOIN TB003001 C on 
			B.OVERFLOW_REPR_ECS_NO = C.ECS_NO
		WHERE 
			B.OVERFLOW_REPR_ECS_NO <> ''
			-- �I�[�o�[�t���[�̑�\�ݒʂ͍ő�����Ŏ擾����
			AND B.ECS_REV_NO = ( SELECT MAX(D.ECS_REV_NO) FROM TB003001 D WHERE B.ECS_NO = D.ECS_NO GROUP BY D.ECS_NO)
		-- �w�肵���ݒʂ��I�[�o�[�t���[�ɂȂ��Ă���ݒʂ̓��w��
		-- (�I�[�o�[�t���[�ݒʂ̓��w��)
		UNION ALL
		SELECT
			F.ECS_NO AS REPR_ECS_NO,
			F.ECS_REV_NO AS REPR_ECS_REV_NO,
			D.SIMULTANEOUS_ECS_NO AS SIMULTANEOUS_ECS_NO,
			E.ECS_NO  AS OVER_FLOW_REPR_ECS_NO,
			D.SIMULTANEOUS_ECS_ORDER AS SIMULTANEOUS_ECS_ORDER,
			3 AS RANK
		FROM TB003002 D
		-- �I�[�o�[�t���[�ݒʂ̑�\
		INNER JOIN TB003001 E	ON 
			D.REPR_ECS_NO = E.ECS_NO AND
			D.REPR_ECS_REV_NO = E.ECS_REV_NO 
		-- �w�肵����\�ݒʂ́i�I�[�o�[�t���[�ݒʂ̑�\�̑�\�ݒʁj���ڂɉ��������݂��Ȃ��̂ŉ���������������
		INNER JOIN TB003001 F	ON 
			F.ECS_NO = E.OVERFLOW_REPR_ECS_NO
		WHERE 
			E.OVERFLOW_REPR_ECS_NO <> ''
			-- �I�[�o�[�t���[�̑�\�ݒʂ͍ő�����Ŏ擾����
			AND E.ECS_REV_NO = ( SELECT MAX(G.ECS_REV_NO) FROM TB003001 G WHERE E.ECS_NO = G.ECS_NO GROUP BY G.ECS_NO)
	) X 
);
