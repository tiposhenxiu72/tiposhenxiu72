/*
* ファイル名：OthersForm.java
*
* <MODIFICATION HISTORY>
*   (Rev.)     (Date)       (ID/NAME)   (Comment)
*   Rev 1.00   2015/12/01   toishigawa  新規作成
*/
package jp.co.sraw.controller.portfolio.form;

import javax.persistence.Column;
import javax.validation.constraints.NotNull;

import org.maru.m4hv.extensions.constraints.CharLength;

import jp.co.sraw.entity.GyCommonTbl;
import jp.co.sraw.entity.GyPrizeTbl;

/**
 * <B>GyPrizeFormクラス</B>
 * <P>
 * Formのメソッドを提供する
 */
public class GyPrizeForm extends PortfolioForm {

	public GyPrizeForm() {
		super();
	}

	public String getPrizeLanguage() {
		return this.getLanguage();
	}

	public void setPrizeLanguage(String prizeLanguage) {
		this.setLanguage(prizeLanguage);
	}

	private String association;

	private String country;

	private String partner;

	@Column(name = "prize_language")
	private String prizeLanguage;

	private String prizetype;

	private String publicationdate;

	private String subtitle;

	@NotNull
	@CharLength(max = 255)
	private String title;

	public String getTitle() {
		return this.title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getAssociation() {
		return this.association;
	}

	public void setAssociation(String association) {
		this.association = association;
	}

	public String getCountry() {
		return this.country;
	}

	public void setCountry(String country) {
		this.country = country;
	}

	public String getPartner() {
		return this.partner;
	}

	public void setPartner(String partner) {
		this.partner = partner;
	}

	public String getPrizetype() {
		return this.prizetype;
	}

	public void setPrizetype(String prizetype) {
		this.prizetype = prizetype;
	}

	public String getPublicationdate() {
		return this.publicationdate;
	}

	public void setPublicationdate(String publicationdate) {
		this.publicationdate = publicationdate;
	}

	public String getSubtitle() {
		return this.subtitle;
	}

	public void setSubtitle(String subtitle) {
		this.subtitle = subtitle;
	}

	@Override
	public GyCommonTbl getNewTbl() {
		// TODO 自動生成されたメソッド・スタブ
		return new GyPrizeTbl();
	}

}
