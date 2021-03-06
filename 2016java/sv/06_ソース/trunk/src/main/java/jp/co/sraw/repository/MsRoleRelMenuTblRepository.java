package jp.co.sraw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import jp.co.sraw.entity.MsRoleRelMenuTbl;
import jp.co.sraw.entity.MsRoleRelMenuTblPK;

@Repository
public interface MsRoleRelMenuTblRepository extends JpaRepository<MsRoleRelMenuTbl, MsRoleRelMenuTblPK>, JpaSpecificationExecutor<MsRoleRelMenuTbl> {

}
