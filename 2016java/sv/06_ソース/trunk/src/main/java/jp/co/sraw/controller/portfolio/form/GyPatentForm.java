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
import jp.co.sraw.entity.GyPatentTbl;

/**
 * <B>GyPatentFormクラス</B>
 * <P>
 * Formのメソッドを提供する
 */
public class GyPatentForm extends PortfolioForm {

	public GyPatentForm() {
		super();
	}

	public String getPatentLanguage() {
		return this.getLanguage();
	}

	public void setPatentLanguage(String patentLanguage) {
		this.setLanguage(patentLanguage);
	}

	private String applicationdate;

	private String applicationid;

	private String applicationperson;

	private String author;

	private String patentdate;

	private String patentid;

	private String publicdate;

	private String publicid;

	private String translationdate;

	private String translationid;

	@NotNull
	private String kbn;

	public String getKbn() {
		return this.kbn;
	}

	public void setKbn(String kbn) {
		this.kbn = kbn;
	}

	private String bango;

	public String getBango() {
		return this.bango;
	}

	public void setBango(String bango) {
		this.bango = bango;
	}

	private String busday;

	public String getBusday() {
		return this.busday;
	}

	public void setBusday(String busday) {
		this.busday = busday;
	}

	@NotNull
	@CharLength(max = 255)
	private String title;

	public String getTitle() {
		return this.title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getApplicationdate() {
		return this.applicationdate;
	}

	public void setApplicationdate(String applicationdate) {
		this.applicationdate = applicationdate;
	}

	public String getApplicationid() {
		return this.applicationid;
	}

	public void setApplicationid(String applicationid) {
		this.applicationid = applicationid;
	}

	public String getApplicationperson() {
		return this.applicationperson;
	}

	public void setApplicationperson(String applicationperson) {
		this.applicationperson = applicationperson;
	}

	public String getAuthor() {
		return this.author;
	}

	public void setAuthor(String author) {
		this.author = author;
	}

	public String getPatentdate() {
		return this.patentdate;
	}

	public void setPatentdate(String patentdate) {
		this.patentdate = patentdate;
	}

	public String getPatentid() {
		return this.patentid;
	}

	public void setPatentid(String patentid) {
		this.patentid = patentid;
	}

	public String getPublicdate() {
		return this.publicdate;
	}

	public void setPublicdate(String publicdate) {
		this.publicdate = publicdate;
	}

	public String getPublicid() {
		return this.publicid;
	}

	public void setPublicid(String publicid) {
		this.publicid = publicid;
	}

	public String getTranslationdate() {
		return this.translationdate;
	}

	public void setTranslationdate(String translationdate) {
		this.translationdate = translationdate;
	}

	public String getTranslationid() {
		return this.translationid;
	}

	public void setTranslationid(String translationid) {
		this.translationid = translationid;
	}

	@Override
	public GyCommonTbl getNewTbl() {
		// TODO 自動生成されたメソッド・スタブ
		return new GyPatentTbl();
	}

}
