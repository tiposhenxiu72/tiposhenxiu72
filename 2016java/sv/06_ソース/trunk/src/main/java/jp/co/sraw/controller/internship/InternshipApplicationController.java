/*
* ファイル名：IndexController.java
*
* <MODIFICATION HISTORY>
*   (Rev.)     (Date)       (ID/NAME)   (Comment)
*   Rev 1.00   2015/12/01   toishigawa  新規作成
*/
package jp.co.sraw.controller.internship;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import javax.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jp.co.sraw.common.CommonConst;
import jp.co.sraw.common.CommonController;
import jp.co.sraw.dto.InternshipViewDto;
import jp.co.sraw.entity.ItInternRecruitTblPK;
import jp.co.sraw.logger.LoggerWrapper;
import jp.co.sraw.logger.LoggerWrapperFactory;
import jp.co.sraw.service.InternshipServiceImpl;

/**
 * <B>InternshipApplicationControllerクラス</B>
 * <P>
 * Controllerのメソッドを提供する
 */
@Controller
@RequestMapping("/internship/application")
public class InternshipApplicationController extends CommonController {

	private static final LoggerWrapper logger = LoggerWrapperFactory.getLogger(InternshipController.class);

	@PostConstruct
	protected void init() {
		logger.setMessageSource(messageSource);
	}

	@Autowired
	private InternshipServiceImpl internshipServiceImpl;

	private static final String LIST_PAGE = "internship/application/list";

	private static final String REDIRECT_LIST = "redirect:/internship/application/";
	private static final String EDIT_PAGE = "support/mgmt/edit";

	private static final String FORM_NAME = "form";

	// 連携機関支援
	private static final String CODE_RENKEKIKAN = "1";
	// 公的支援制度
	private static final String CODE_KOTEKI = "2";
	// 支援制度区分
	private static final String CODE_KBN = "0005";
	//
	private static final String CODE_SYBCODE = "0021";

	/**
	 *
	 * @param role
	 * @return
	 */
	private boolean checkAuthority(String role) {
		if (userInfo != null) {
			Collection<GrantedAuthority> authorityList = userInfo.getAuthorities();
			SimpleGrantedAuthority authority = new SimpleGrantedAuthority(role);
			return authorityList.contains(authority);
		}
		return false;
	}

	/**
	 *
	 *
	 * @param name
	 * @param model
	 * @return
	 */
	@RequestMapping({ "", "/", "/list" })
	public String index(Model model) {

		logger.infoCode("I0001");

		List<InternshipViewDto> hirakuList = new ArrayList<>();
		List<InternshipViewDto> kigyoToList = new ArrayList<>();
		List<InternshipViewDto> kyujinList = new ArrayList<>();
		List<InternshipViewDto> sonotaList = new ArrayList<>();

		internshipServiceImpl.findAllInternshipForGohiKeka(userInfo.getTargetUserKey(), hirakuList, kigyoToList, kyujinList, sonotaList);

		model.addAttribute("hirakuList", hirakuList);
		model.addAttribute("kigyoToList", kigyoToList);
		model.addAttribute("kyujinList", kyujinList);
		model.addAttribute("sonotaList", sonotaList);

		if (logger.isDebugEnabled()) {
			logger.debug("LoginUserKey=" + userInfo.getLoginUserKey());
			logger.debug("TargetUserKey=" + userInfo.getTargetUserKey());
		}

		// dump
		modelDump(logger, model, "index");

		return LIST_PAGE;
	}

	/**
	 *
	 * @param form
	 * @param model
	 * @param attributes
	 * @return
	 */
	@RequestMapping(value = "/refuse", method = RequestMethod.POST)
	public String refuse(@ModelAttribute(FORM_NAME) final InternshipForm form, Model model,
			RedirectAttributes attributes) {

		logger.infoCode("I0001"); // I0001=メソッド開始:{0}

		String key = "internshipKey="+ form.getInternshipKey() +", userKey="+ userInfo.getTargetUserKey();

		ItInternRecruitForm recruitForm = new ItInternRecruitForm();
		ItInternRecruitTblPK pk=new ItInternRecruitTblPK();
		pk.setInternshipKey(form.getInternshipKey());
		pk.setUserKey(userInfo.getTargetUserKey());
		recruitForm.setId(pk);

		//更新テーブル：インターンシップ応募者テーブル
		if (internshipServiceImpl.updateInternRecruit(userInfo,recruitForm)) {
			// DB更新が成功した場合
			logger.infoCode("I1004", key); // I1004=更新しました。{0}
		} else {
			// DB更新が失敗した場合
			logger.errorCode("E1008", key); // E1008=更新に失敗しました。{0}
			model.addAttribute(CommonConst.PAGE_DANGER_MESSAGE, "error.data.message.db.regist"); // error.data.message.db.regist=登録が失敗しました。
		}

		//削除テーブル：インターンシップ応募者添付ファイル
		if (internshipServiceImpl.deleteOneInternRecruitUpload(userInfo, form)) {
			// DB更新が成功した場合
			logger.infoCode("I1003", key); // I1003=削除しました。{0}
			attributes.addFlashAttribute(CommonConst.PAGE_SUCCESS_MESSAGE, "message.data.delete.success"); // message.data.delete.success=データを削除しました。
			logger.infoCode("I0002", form.getPageActionUrl()); // I0002=メソッド終了:{0}
		} else {
			// DB更新が失敗した場合
			logger.errorCode("E1009", key); // E1009=削除に失敗しました。{0}
			attributes.addFlashAttribute(CommonConst.PAGE_DANGER_MESSAGE, "error.data.message.db.remove"); // error.data.message.db.remove=削除が失敗しました。
			logger.errorCode("E0014", form.getPageActionUrl()); // E0014=メソッド異常終了:{0}
		}

		return REDIRECT_LIST;
	}

	/**
	 *
	 * @param form
	 * @param model
	 * @param attributes
	 * @return
	 */
	@RequestMapping(value = "/download", method = RequestMethod.POST)
	public String download(@ModelAttribute(FORM_NAME) final InternshipForm form, Model model,
			RedirectAttributes attributes) {

		logger.infoCode("I0001"); // I0001=メソッド開始:{0}

		if (internshipServiceImpl.download(userInfo, form, "2")) {
			//成功の場合
		} else {
			//失敗の場合
		}

		return LIST_PAGE;
	}

	/**
	 *
	 * @param form
	 * @param model
	 * @param attributes
	 * @return
	 */
	@RequestMapping(value = "/upload", method = RequestMethod.POST)
	public String upload(@ModelAttribute(FORM_NAME) final InternshipForm form, Model model,
			RedirectAttributes attributes) {

		logger.infoCode("I0001"); // I0001=メソッド開始:{0}

		String key = "internshipKey="+ form.getInternshipKey() +", userKey="+ userInfo.getTargetUserKey();

		//更新テーブル：インターンシップ応募者テーブル
		if (internshipServiceImpl.updateInternRecruitForGohiKeka(userInfo, form)) {
			// DB更新が成功した場合
			logger.infoCode("I1004", key); // I1004=更新しました。{0}
		} else {
			// DB更新が失敗した場合
			logger.errorCode("E1008", key); // E1008=更新に失敗しました。{0}
			model.addAttribute(CommonConst.PAGE_DANGER_MESSAGE, "error.data.message.db.regist"); // error.data.message.db.regist=登録が失敗しました。
		}

		//更新テーブル：インターンシップ応募者添付ファイル
		if (internshipServiceImpl.updateInternRecruitUploadForGohiKeka(userInfo, form)) {
			// DB更新が成功した場合
			logger.infoCode("I1004", key); // I1004=更新しました。{0}
		} else {
			// DB更新が失敗した場合
			logger.errorCode("E1008", key); // E1008=更新に失敗しました。{0}
			model.addAttribute(CommonConst.PAGE_DANGER_MESSAGE, "error.data.message.db.regist"); // error.data.message.db.regist=登録が失敗しました。
		}

		// お知らせ情報、お知らせ情報公開範囲登録
		if (internshipServiceImpl.insertCmInfo(userInfo, form, "205", "ROLE_MGMT2", userInfo.getTargetPartyCode())) {
			// DB更新が成功した場合
			logger.infoCode("I1005", key); // I1005=新規作成しました。{0}
		} else {
			// DB更新が失敗した場合
			logger.errorCode("E1007", key); // E1007=登録に失敗しました。{0}
			model.addAttribute(CommonConst.PAGE_DANGER_MESSAGE, "error.data.message.db.regist"); // error.data.message.db.regist=登録が失敗しました。
		}

		return LIST_PAGE;
	}

	/**
	 * ダイレクトアクセス対策
	 *
	 * @return
	 */
	@RequestMapping(value = {"/edit", "/copy", "/create", "/update", "/delete", "/upload", "/refuse", "/download"}, method = RequestMethod.GET)
	public String redirect() {
		logger.warnCode("W1009"); // W1009=URLダイレクトアクセスがありました。
		return CommonConst.REDIRECT_INDEX;
	}

}
