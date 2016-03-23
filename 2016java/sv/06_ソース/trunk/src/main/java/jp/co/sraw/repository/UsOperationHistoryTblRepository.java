package jp.co.sraw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import jp.co.sraw.entity.UsOperationHistoryTbl;
import jp.co.sraw.entity.UsOperationHistoryTblPK;

@Repository
public interface UsOperationHistoryTblRepository extends JpaRepository<UsOperationHistoryTbl, UsOperationHistoryTblPK>, JpaSpecificationExecutor<UsOperationHistoryTbl> {

}
