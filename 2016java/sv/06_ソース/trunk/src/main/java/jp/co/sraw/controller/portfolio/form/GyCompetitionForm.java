/*
* ファイル名：OthersForm.java
*
* <MODIFICATION HISTORY>
*   (Rev.)     (Date)       (ID/NAME)   (Comment)
*   Rev 1.00   2015/12/01   toishigawa  新規作成
*/
package jp.co.sraw.controller.portfolio.form;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.validation.constraints.NotNull;

import org.maru.m4hv.extensions.constraints.CharLength;

import jp.co.sraw.entity.GyCommonTbl;
import jp.co.sraw.entity.GyCompetitionTbl;

/**
 * <B>GyCompetitionFormクラス</B>
 * <P>
 * Formのメソッドを提供する
 */
public class GyCompetitionForm extends PortfolioForm {

	public GyCompetitionForm() {
		super();
	}

	public String getCompetitionLanguage() {
		return this.getLanguage();
	}

	public void setCompetitionLanguage(String competitionLanguage) {
		this.setLanguage(competitionLanguage);
	}

	private BigDecimal amounttotal;

	private String author;

	private String category;

	@Column(name = "competition_language")
	private String competitionLanguage;

	private String field;

	private String fromdate;

	private String member;

	private String provider;

	private String system;

	private String todate;

	@NotNull
	@CharLength(max = 255)
	private String title;

	public String getTitle() {
		return this.title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public BigDecimal getAmounttotal() {
		return this.amounttotal;
	}

	public void setAmounttotal(BigDecimal amounttotal) {
		this.amounttotal = amounttotal;
	}

	public String getAuthor() {
		return this.author;
	}

	public void setAuthor(String author) {
		this.author = author;
	}

	public String getCategory() {
		return this.category;
	}

	public void setCategory(String category) {
		this.category = category;
	}

	public String getField() {
		return this.field;
	}

	public void setField(String field) {
		this.field = field;
	}

	public String getFromdate() {
		return this.fromdate;
	}

	public void setFromdate(String fromdate) {
		this.fromdate = fromdate;
	}

	public String getMember() {
		return this.member;
	}

	public void setMember(String member) {
		this.member = member;
	}

	public String getProvider() {
		return this.provider;
	}

	public void setProvider(String provider) {
		this.provider = provider;
	}

	public String getSystem() {
		return this.system;
	}

	public void setSystem(String system) {
		this.system = system;
	}

	public String getTodate() {
		return this.todate;
	}

	public void setTodate(String todate) {
		this.todate = todate;
	}

	@Override
	public GyCommonTbl getNewTbl() {
		// TODO 自動生成されたメソッド・スタブ
		return new GyCompetitionTbl();
	}

}
