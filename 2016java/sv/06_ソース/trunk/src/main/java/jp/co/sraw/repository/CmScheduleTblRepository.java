package jp.co.sraw.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import jp.co.sraw.entity.CmScheduleTbl;

@Repository
public interface CmScheduleTblRepository extends JpaRepository<CmScheduleTbl, String>, JpaSpecificationExecutor<CmScheduleTbl> {

	@Modifying
	@Query(name="CmScheduleTbl.delete")
	public int delete(String refKey, String dataKbn);

}
