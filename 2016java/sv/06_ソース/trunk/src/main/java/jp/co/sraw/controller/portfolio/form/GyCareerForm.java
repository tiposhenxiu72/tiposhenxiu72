/*
* ファイル名：OthersForm.java
*
* <MODIFICATION HISTORY>
*   (Rev.)     (Date)       (ID/NAME)   (Comment)
*   Rev 1.00   2015/12/01   toishigawa  新規作成
*/
package jp.co.sraw.controller.portfolio.form;

import javax.persistence.Column;

import jp.co.sraw.entity.GyCareerTbl;
import jp.co.sraw.entity.GyCommonTbl;

/**
 * <B>GyCareerFormクラス</B>
 * <P>
 * Formのメソッドを提供する
 */
public class GyCareerForm extends PortfolioForm {

	public GyCareerForm() {
		super();
	}

	public String getCareerLanguage() {
		return this.getLanguage();
	}

	public void setCareerLanguage(String careerLanguage) {
		this.setLanguage(careerLanguage);
	}

	@Column(name = "career_language")
	private String careerLanguage;

	private String division;

	private String fromdate;

	private String job;

	private String section;

	private String todate;

	public String getDivision() {
		return this.division;
	}

	public void setDivision(String division) {
		this.division = division;
	}

	public String getFromdate() {
		return this.fromdate;
	}

	public void setFromdate(String fromdate) {
		this.fromdate = fromdate;
	}

	public String getJob() {
		return this.job;
	}

	public void setJob(String job) {
		this.job = job;
	}

	public String getSection() {
		return this.section;
	}

	public void setSection(String section) {
		this.section = section;
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
		return new GyCareerTbl();
	}

}
