package jp.co.sraw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import jp.co.sraw.entity.NrLessonRelSubjectTbl;
import jp.co.sraw.entity.NrLessonRelSubjectTblPK;

@Repository
public interface NrLessonRelSubjectTblRepository extends JpaRepository<NrLessonRelSubjectTbl, NrLessonRelSubjectTblPK>, JpaSpecificationExecutor<NrLessonRelSubjectTbl> {

}
