package jp.co.sraw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import jp.co.sraw.entity.NrAchievementReportTbl;
import jp.co.sraw.entity.NrAchievementReportTblPK;

@Repository
public interface NrAchievementReportTblRepository extends JpaRepository<NrAchievementReportTbl, NrAchievementReportTblPK>, JpaSpecificationExecutor<NrAchievementReportTbl> {

}
