/*
* ファイル名：GyConferenceForm.java
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
import jp.co.sraw.entity.GyConferenceTbl;

/**
 * <B>GyConferenceFormクラス</B>
 * <P>
 * Formのメソッドを提供する
 */
public class GyConferenceForm extends PortfolioForm {

	public GyConferenceForm() {
		super();
	}

	public String getResearchKeywordLanguage() {
		return this.getLanguage();
	}

	public void setResearchKeywordLanguage(String researchKeywordLanguage) {
		this.setLanguage(researchKeywordLanguage);
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

	private String author;

	@Column(name = "conference_language")
	private String conferenceLanguage;

	private String conferenceclass;

	private String conferencetype;

	private String invited;

	private String journal;

	private String language;

	private String promoter;

	private String publicationdate;

	private String venue;

	public String getAuthor() {
		return this.author;
	}

	public void setAuthor(String author) {
		this.author = author;
	}

	public String getConferenceLanguage() {
		return this.getLanguage();
	}

	public void setConferenceLanguage(String conferenceLanguage) {
		this.setLanguage(conferenceLanguage);
	}

	public String getConferenceclass() {
		return this.conferenceclass;
	}

	public void setConferenceclass(String conferenceclass) {
		this.conferenceclass = conferenceclass;
	}

	public String getConferencetype() {
		return this.conferencetype;
	}

	public void setConferencetype(String conferencetype) {
		this.conferencetype = conferencetype;
	}

	public String getInvited() {
		return this.invited;
	}

	public void setInvited(String invited) {
		this.invited = invited;
	}

	public String getJournal() {
		return this.journal;
	}

	public void setJournal(String journal) {
		this.journal = journal;
	}

	public String getWlanguage() {
		return this.language;
	}

	public void setWlanguage(String language) {
		this.language = language;
	}

	public String getPromoter() {
		return this.promoter;
	}

	public void setPromoter(String promoter) {
		this.promoter = promoter;
	}

	public String getPublicationdate() {
		return this.publicationdate;
	}

	public void setPublicationdate(String publicationdate) {
		this.publicationdate = publicationdate;
	}

	public String getVenue() {
		return this.venue;
	}

	public void setVenue(String venue) {
		this.venue = venue;
	}

	@Override
	public GyCommonTbl getNewTbl() {
		// TODO 自動生成されたメソッド・スタブ
		return new GyConferenceTbl();
	}

}
