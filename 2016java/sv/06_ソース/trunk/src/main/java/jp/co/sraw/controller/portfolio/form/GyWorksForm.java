/*
* ファイル名：OthersForm.java
*
* <MODIFICATION HISTORY>
*   (Rev.)     (Date)       (ID/NAME)   (Comment)
*   Rev 1.00   2015/12/01   toishigawa  新規作成
*/
package jp.co.sraw.controller.portfolio.form;

import javax.validation.constraints.NotNull;

import org.maru.m4hv.extensions.constraints.CharLength;

import jp.co.sraw.entity.GyCommonTbl;
import jp.co.sraw.entity.GyWorksTbl;

/**
 * <B>GySocietyFormクラス</B>
 * <P>
 * Formのメソッドを提供する
 */
public class GyWorksForm extends PortfolioForm {

	public GyWorksForm() {
		super();
	}

	public String getWorksLanguage() {
		return this.getLanguage();
	}

	public void setWorksLanguage(String worksLanguage) {
		this.setLanguage(worksLanguage);
	}

	private String author;

	private String fromdate;

	private String todate;

	private String venue;

	private String worktype;

	@NotNull
	@CharLength(max = 255)
	private String title;

	public String getTitle() {
		return this.title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getAuthor() {
		return this.author;
	}

	public void setAuthor(String author) {
		this.author = author;
	}

	public String getFromdate() {
		return this.fromdate;
	}

	public void setFromdate(String fromdate) {
		this.fromdate = fromdate;
	}

	public String getTodate() {
		return this.todate;
	}

	public void setTodate(String todate) {
		this.todate = todate;
	}

	public String getVenue() {
		return this.venue;
	}

	public void setVenue(String venue) {
		this.venue = venue;
	}

	public String getWorktype() {
		return this.worktype;
	}

	public void setWorktype(String worktype) {
		this.worktype = worktype;
	}

	@Override
	public GyCommonTbl getNewTbl() {
		// TODO 自動生成されたメソッド・スタブ
		return new GyWorksTbl();
	}

}
