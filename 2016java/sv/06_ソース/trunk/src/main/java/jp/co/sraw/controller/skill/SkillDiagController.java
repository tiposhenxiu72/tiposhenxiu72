/*
* ファイル名：SkillDiagController.java
*
* <MODIFICATION HISTORY>
*   (Rev.)     (Date)       (ID/NAME)   (Comment)
*   Rev 1.00   2016/01/05   etoh        新規作成
*/
package jp.co.sraw.controller.skill;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.net.URLConnection;
import java.util.List;
import java.util.Locale;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 * <B>能力診断・結果表示機能用コントローラ</B>
 * <P>
 * アクションプランやエビデンスの登録、表示など。
 */
import jp.co.sraw.common.CommonController;
import jp.co.sraw.dto.SkillAnswerDto;
import jp.co.sraw.entity.CmFileUploadTbl;
import jp.co.sraw.entity.NrSubjectAnswerTbl;
import jp.co.sraw.logger.LoggerWrapper;
import jp.co.sraw.logger.LoggerWrapperFactory;
import jp.co.sraw.oxm.rubric.Rubric;
import jp.co.sraw.oxm.rubric.RubricCategory;
import jp.co.sraw.service.CmFileUploadServiceImpl;
import jp.co.sraw.service.RubricServiceImpl;
import jp.co.sraw.service.SkillDiagServiceImpl;
import jp.co.sraw.util.DateUtil;
import jp.co.sraw.util.DbUtil;
import jp.co.sraw.util.StringUtil;

@Controller
@RequestMapping("/skill/diag")
public class SkillDiagController extends CommonController {

	private static final LoggerWrapper logger = LoggerWrapperFactory.getLogger(RubricMgmtController.class);

	// 遷移先。
	private static final String INDEX_PAGE = "skill/diag/index";
	private static final String VIEW_LIST_PAGE = "skill/diag/view_list";

	// 定数区分/コード。
	private static final String JKBN_LENSNAME = "0001";
	private static final String JKBN_DEGREE = "0006";

	@Autowired
	private RubricServiceImpl rubricService;

	@Autowired
	private SkillDiagServiceImpl diagService;

	@Autowired
	private CmFileUploadServiceImpl fileService;

	@Override
	protected void init() {
		logger.setMessageSource(messageSource);
	}

	// 能力診断トップ画面表示。
	@RequestMapping({ "", "/", "/index" })
	public String index(HttpServletRequest request, Model model, Locale locale) {
		logger.infoCode("I0001", request.getRequestURI());

		// TODO: how to get rkey?
		String rkey = "1000000033";
		Rubric rub = rubricService.findOne(rkey);

		model.addAttribute("rubricKey", rkey);
		model.addAttribute("rubricName", rub.getName());
		model.addAttribute("rubricSummary", rub.getSummary());

		logger.infoCode("I0002", INDEX_PAGE);
		return INDEX_PAGE;
	}

	// 能力診断入力画面表示。
	@RequestMapping("/edit/{rkey}/{lensId}")
	public String edit(HttpServletRequest request, @PathVariable("rkey") String rkey,
			@PathVariable("lensId") String lensId, Model model, Locale locale) {
		logger.infoCode("I0001", request.getRequestURI());

		// TODO:

		logger.infoCode("I0002", INDEX_PAGE);
		return INDEX_PAGE;
	}

	// 能力診断結果一覧画面表示。
	@RequestMapping("/viewList/{rkey}/{lensId}")
	public String viewList(HttpServletRequest request, @PathVariable("rkey") String rkey,
			@PathVariable("lensId") String lensId, Model model, Locale locale) {
		logger.infoCode("I0001", request.getRequestURI());

		Rubric rub = rubricService.findOne(rkey);
		rubricService.filterByLens(rub, Integer.valueOf(lensId));
		model.addAttribute("rubric", rub);

		model.addAttribute("lensName", DbUtil.getJosuName(JKBN_LENSNAME, lensId, locale));
		model.addAttribute("degreeName", lookupDegreeName(locale));

		List<NrSubjectAnswerTbl> answers = diagService.findAllAnswers(userInfo.getTargetUserKey(), rkey);
		model.addAttribute("lastModifiedStr",
				answers.isEmpty() ? "" : DateUtil.dateTimeFormat(answers.get(0).getUpdDate(), false));
		DiagForm form = new DiagForm();
		diagService.populateForm(form, answers, rub);
		model.addAttribute("answers", form);

		logger.infoCode("I0002", VIEW_LIST_PAGE);
		return VIEW_LIST_PAGE;
	}

	private String lookupDegreeName(Locale locale) {
		String name = DbUtil.getJosuName(JKBN_DEGREE, userInfo.getTargetDegree(), locale);
		if (StringUtil.isNull(name)) {
			return "";
		}
		return name + "(" + DbUtil.getAttrText1(JKBN_DEGREE, userInfo.getTargetDegree()) + ")";
	}

	// 能力診断結果全体画面表示。
	@RequestMapping("/viewWhole/{rkey}/{lensId}")
	public String viewWhole(HttpServletRequest request, @PathVariable("rkey") String rkey,
			@PathVariable("lensId") String lensId, Model model, Locale locale) {
		logger.infoCode("I0001", request.getRequestURI());

		// TODO:

		logger.infoCode("I0002", INDEX_PAGE);
		return INDEX_PAGE;
	}

	// 能力診断結果 能力別表示。
	@RequestMapping(value = "/viewItem/{rkey}/{abilityCode:.+}", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
	@ResponseBody
	public SkillAnswerDto viewItem(HttpServletRequest request, @PathVariable("rkey") String rkey,
			@PathVariable("abilityCode") String abilityCode, Model model, Locale locale) {
		logger.infoCode("I0001", request.getRequestURI());
		logger.info(abilityCode);

		Rubric rub = rubricService.findOne(rkey);
		RubricCategory item = rub.buildMap().get(abilityCode);
		NrSubjectAnswerTbl ans = diagService.findByAbilityCode(userInfo.getTargetUserKey(), rkey, abilityCode);
		SkillAnswerDto dto = new SkillAnswerDto();
		diagService.populateDto(dto, downloadBasePath(request), DbUtil.getAttrText1(JKBN_DEGREE, userInfo.getTargetDegree()), ans, item);

		logger.infoCode("I0002");
		return dto;
	}

	// 過去の診断結果表示。
	@RequestMapping("/pastIndex")
	public String pastIndex(HttpServletRequest request, Model model, Locale locale) {
		logger.infoCode("I0001", request.getRequestURI());

		// TODO:

		logger.infoCode("I0002", INDEX_PAGE);
		return INDEX_PAGE;
	}

	// エビデンスダウンロード。
	@RequestMapping("/download/{ukey}")
	public void download(HttpServletRequest request, @PathVariable("ukey") String ukey, HttpServletResponse response,
			Model model, Locale locale) throws IOException {
		logger.infoCode("I0001", request.getRequestURI());

		// uploadKeyとtargetUserKeyで検索(他人のファイルをDLできないよう)。
		// 拡張子からContent-typeを推測(デフォはoctet-stream)。
		CmFileUploadTbl file = fileService.findOne(ukey, userInfo.getTargetUserKey());
		String mimeType = URLConnection.guessContentTypeFromName(file.getFileName());
		if (mimeType == null) {
			mimeType = "application/octet-stream";
		}
		File filepath = new File(file.getRealPath());
		response.setContentLength((int) filepath.length());
		response.setContentType(mimeType);
		response.setHeader(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + file.getFileName());

		// Resourceをreturnする方式だと、content-typeヘッダがtext/htmlになってしまった。
		// Springがオーバールールするのかな?
		// よって、直接responseへ書き込むことにする。
		FileCopyUtils.copy(new FileInputStream(filepath), response.getOutputStream());

		logger.infoCode("I0002");
	}

	private String downloadBasePath(HttpServletRequest request) {
		return request.getContextPath() + "/skill/diag/download/";
	}
}
