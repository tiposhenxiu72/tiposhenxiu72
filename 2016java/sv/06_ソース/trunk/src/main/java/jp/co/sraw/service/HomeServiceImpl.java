/*
* ファイル名：MsRoleServiceImpl.java
*
* <MODIFICATION HISTORY>
*   (Rev.)     (Date)       (ID/NAME)   (Comment)
*   Rev 1.00   2015/12/01   toishigawa  新規作成
*/
package jp.co.sraw.service;

import java.util.List;

import javax.annotation.PostConstruct;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Predicate;
import javax.persistence.criteria.Root;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.domain.Specifications;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.sraw.common.CommonService;
import jp.co.sraw.entity.CmInfoTbl;
import jp.co.sraw.entity.UsInfoTbl;
import jp.co.sraw.logger.LoggerWrapper;
import jp.co.sraw.logger.LoggerWrapperFactory;
import jp.co.sraw.repository.CmInfoTblRepository;
import jp.co.sraw.repository.UsInfoTblRepository;
import jp.co.sraw.util.StringUtil;

/**
* <B>HomeServiceクラス</B>
* <P>
* ホーム(ポータル)サービスのメソッドを提供する
*/
@Service
@Transactional(readOnly = true)
public class HomeServiceImpl extends CommonService {

	@Autowired
	private UsInfoTblRepository usInfoTblRepository;

	@Autowired
	private CmInfoTblRepository cmInfoTblRepository;

	private static final LoggerWrapper logger = LoggerWrapperFactory.getLogger(MsRoleServiceImpl.class);

	@PostConstruct
	protected void init() {
		logger.setMessageSource(messageSource);
	}

	/**
	 * 個人用お知らせ情報取得
	 *
	 * @param form
	 * @param locale
	 * @return
	 */
	public List<UsInfoTbl> findAllUsInfoByUserKey(String userKey) {
		logger.infoCode("I0001"); // I0001=メソッド開始:{0}

		// 取得条件：操作者のユーザキー
		Specification<UsInfoTbl> whereUserKey = StringUtil.isNull(userKey) ? null
				: new Specification<UsInfoTbl>() {
					@Override
					public Predicate toPredicate(Root<UsInfoTbl> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
						return cb.equal(root.get("usUserTbl").get("userKey"), userKey);
					}
				};

		List<UsInfoTbl> resultList = usInfoTblRepository.findAll(Specifications.where(whereUserKey), orderBySendDate());

		logger.infoCode("I0002"); // I0002=メソッド終了:{0}
		return resultList;
	}

	/**
	 * orderBySendDate
	 *
	 * @return
	 */
	private Sort orderBySendDate() {
		// 配信日（降順）
		return new Sort(Sort.Direction.DESC, "sendDate");
	}

	/**
	 * 組織。及び、ロール向けお知らせ情報取得
	 *
	 * @param form
	 * @param locale
	 * @return
	 */
	public List<CmInfoTbl> findAllCmInfoByPartyOrRoll(String partyCode, String role) {
		return cmInfoTblRepository.findAllByPartyOrRoll(partyCode, role);
	}

}
