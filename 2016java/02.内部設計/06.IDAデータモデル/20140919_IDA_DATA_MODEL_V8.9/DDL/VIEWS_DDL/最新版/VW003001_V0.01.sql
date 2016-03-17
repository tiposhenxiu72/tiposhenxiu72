-- 同指示設通とオーバーフローの代表設通とオーバーフローの同指示設通をまとめて取得するVIEW
CREATE VIEW VW003001 (
	REPR_ECS_NO, 		-- 代表設計通知書番号
	REPR_ECS_REV_NO,	-- 代表設通改訂番号
	SIMULTANEOUS_ECS_NO,	-- 同指示設計通知書番号
	SIMULTANEOUS_ECS_ORDER,	-- 同指示設通並び順
	RANK 			-- 1:同指示設通、2:オーバーフロー設通の代表、3:オーバーフロー設通の同指示設通
)
AS (
	SELECT 
		REPR_ECS_NO,
		REPR_ECS_REV_NO,
		SIMULTANEOUS_ECS_NO,
		-- 代表設通番号、代表設通改訂番号ごとにオーバーフロー代表設通（昇順）、ランク、同指示設通番号で順番付け（同指示設通並び順の生成）
		ROW_NUMBER() OVER(PARTITION BY REPR_ECS_NO,REPR_ECS_REV_NO ORDER BY OVER_FLOW_REPR_ECS_NO,RANK,SIMULTANEOUS_ECS_ORDER) AS SIMULTANEOUS_ECS_ORDER,
		RANK
	 FROM (
		-- 指定した代表設通からの同指示
		SELECT 
			A.REPR_ECS_NO AS REPR_ECS_NO,
			A.REPR_ECS_REV_NO AS REPR_ECS_REV_NO,
			A.SIMULTANEOUS_ECS_NO AS SIMULTANEOUS_ECS_NO,
			' ' AS OVER_FLOW_REPR_ECS_NO,
			A.SIMULTANEOUS_ECS_ORDER AS SIMULTANEOUS_ECS_ORDER,
			1 AS RANK
		FROM TB003002 A
		-- 指定した設通がオーバーフローになっている設通の代表
		-- (オーバーフロー設通の代表)
		UNION ALL
		SELECT 
			C.ECS_NO AS REPR_ECS_NO,
			C.ECS_REV_NO AS REPR_ECS_REV_NO,
			B.ECS_NO  AS SIMULTANEOUS_ECS_NO,
			B.ECS_NO  AS OVER_FLOW_REPR_ECS_NO,
			1 AS SIMULTANEOUS_ECS_ORDER,
			2 AS RANK
		FROM TB003001 B 
		-- 指定した代表設通は項目に改訂が存在しないので改訂分増幅させる
		INNER JOIN TB003001 C on 
			B.OVERFLOW_REPR_ECS_NO = C.ECS_NO
		WHERE 
			B.OVERFLOW_REPR_ECS_NO <> ''
			-- オーバーフローの代表設通は最大改訂で取得する
			AND B.ECS_REV_NO = ( SELECT MAX(D.ECS_REV_NO) FROM TB003001 D WHERE B.ECS_NO = D.ECS_NO GROUP BY D.ECS_NO)
		-- 指定した設通がオーバーフローになっている設通の同指示
		-- (オーバーフロー設通の同指示)
		UNION ALL
		SELECT
			F.ECS_NO AS REPR_ECS_NO,
			F.ECS_REV_NO AS REPR_ECS_REV_NO,
			D.SIMULTANEOUS_ECS_NO AS SIMULTANEOUS_ECS_NO,
			E.ECS_NO  AS OVER_FLOW_REPR_ECS_NO,
			D.SIMULTANEOUS_ECS_ORDER AS SIMULTANEOUS_ECS_ORDER,
			3 AS RANK
		FROM TB003002 D
		-- オーバーフロー設通の代表
		INNER JOIN TB003001 E	ON 
			D.REPR_ECS_NO = E.ECS_NO AND
			D.REPR_ECS_REV_NO = E.ECS_REV_NO 
		-- 指定した代表設通は（オーバーフロー設通の代表の代表設通）項目に改訂が存在しないので改訂分増幅させる
		INNER JOIN TB003001 F	ON 
			F.ECS_NO = E.OVERFLOW_REPR_ECS_NO
		WHERE 
			E.OVERFLOW_REPR_ECS_NO <> ''
			-- オーバーフローの代表設通は最大改訂で取得する
			AND E.ECS_REV_NO = ( SELECT MAX(G.ECS_REV_NO) FROM TB003001 G WHERE E.ECS_NO = G.ECS_NO GROUP BY G.ECS_NO)
	) X 
);
