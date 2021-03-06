/*
* ファイル名：IndexController.java
*
* <MODIFICATION HISTORY>
*   (Rev.)     (Date)       (ID/NAME)   (Comment)
*   Rev 1.00   2015/12/01   toishigawa  新規作成
*/
package jp.co.sraw.controller.portfolio;

import java.util.List;
import java.util.Locale;

import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import jp.co.sraw.common.CommonController;
import jp.co.sraw.controller.portfolio.excel.PortfolioExcelHelper;
import jp.co.sraw.dto.MsCodeDto;
import jp.co.sraw.logger.LoggerWrapper;
import jp.co.sraw.logger.LoggerWrapperFactory;
import jp.co.sraw.util.DbUtil;

/**
 * <B>PortfolioControllerクラス</B>
 * <P>
 * Controllerのメソッドを提供する
 */
public abstract class PortfolioController<H extends PortfolioExcelHelper> extends CommonController {

	private static final LoggerWrapper logger = LoggerWrapperFactory.getLogger(PortfolioController.class);

	public static final String FORM_NAME = "form";

	public String REDIRECT_LIST = "redirect:/portfolio/others/";
	public String LIST_PAGE = "portfolio/others/list";
	public String EDIT_PAGE = "portfolio/others/edit";

	public String OP_FUNCID = "";

	//
	public static final String CODE_PUBLICCODE = "0024";

	/**
	 *
	 * @return
	 */
	@RequestMapping(value = { "/copy", "/create", "/update", "/delete" }, method = RequestMethod.GET)
	public String actionPass() {
		return REDIRECT_LIST;
	}

	@Override
	protected void init() {
		// TODO 自動生成されたメソッド・スタブ

	}

	protected void setListToModel(Model model, String listName, Locale locale) {
		List<MsCodeDto> list = DbUtil.getJosuList(listName, locale);
		model.addAttribute("list" + listName, list);
	}

	public abstract H getExcelHelper();

}
