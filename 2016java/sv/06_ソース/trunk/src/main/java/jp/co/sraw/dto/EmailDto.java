package jp.co.sraw.dto;

import java.io.Serializable;

public class EmailDto implements Serializable {

	private static long serialVersionUID = 1L;

	private String emailTelno;

	private String emailAddress;

	private String emailPartyCode;

	private String emailRole;

	private String emailTitle;

	private String emailSendDate;

	private String emailPartyName;

	private String emailUrl;

	private String emailRecruit;

	private String emailStartDate;

	private String emailEndDate;

	private String emailMemo;

	private String emailPlace;

	public String getEmailTitle() {
		return emailTitle;
	}

	public void setEmailTitle(String emailTitle) {
		this.emailTitle = emailTitle;
	}

	public String getEmailSendDate() {
		return emailSendDate;
	}

	public void setEmailSendDate(String emailSendDate) {
		this.emailSendDate = emailSendDate;
	}

	public String getEmailPartyName() {
		return emailPartyName;
	}

	public void setEmailPartyName(String emailPartyName) {
		this.emailPartyName = emailPartyName;
	}

	public String getEmailUrl() {
		return emailUrl;
	}

	public void setEmailUrl(String emailUrl) {
		this.emailUrl = emailUrl;
	}

	public String getEmailRecruit() {
		return emailRecruit;
	}

	public void setEmailRecruit(String emailRecruit) {
		this.emailRecruit = emailRecruit;
	}

	public String getEmailStartDate() {
		return emailStartDate;
	}

	public void setEmailStartDate(String emailStartDate) {
		this.emailStartDate = emailStartDate;
	}

	public String getEmailMemo() {
		return emailMemo;
	}

	public void setEmailMemo(String emailMemo) {
		this.emailMemo = emailMemo;
	}

	public String getEmailPlace() {
		return emailPlace;
	}

	public void setEmailPlace(String emailPlace) {
		this.emailPlace = emailPlace;
	}

	public String getEmailAddress() {
		return emailAddress;
	}

	public void setEmailAddress(String emailAddress) {
		this.emailAddress = emailAddress;
	}

	public String getEmailPartyCode() {
		return emailPartyCode;
	}

	public void setEmailPartyCode(String emailPartyCode) {
		this.emailPartyCode = emailPartyCode;
	}

	public String getEmailRole() {
		return emailRole;
	}

	public void setEmailRole(String emailRole) {
		this.emailRole = emailRole;
	}

	public String getEmailTelno() {
		return emailTelno;
	}

	public void setEmailTelno(String emailTelno) {
		this.emailTelno = emailTelno;
	}

	public String getEmailEndDate() {
		return emailEndDate;
	}

	public void setEmailEndDate(String emailEndDate) {
		this.emailEndDate = emailEndDate;
	}

}
