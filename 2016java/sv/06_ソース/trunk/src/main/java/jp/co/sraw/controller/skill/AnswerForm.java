package jp.co.sraw.controller.skill;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import jp.co.sraw.util.StringUtil;

/**
 * <B>能力診断の回答用フォーム</B>
 * <P>
 * 個々の項目の回答1つ分。
 */
public class AnswerForm {
	private String subjectCode;

	private String actionPlan;
	private String evidence;
	private MultipartFile evidenceFile;
	private String evidenceFileName;
	private String evidenceFileId;

	private Boolean done;
	private Integer phase;

	private List<AnswerForm> childList;

	/**
	 * 子供の数。中項目用。
	 * 
	 * @param withAnswer
	 *            回答済みのみカウントする?
	 * @return
	 */
	public long getNumChildren(boolean withAnswer) {
		return childList.stream().filter(c -> !withAnswer || StringUtil.isNotNull(c.getSubjectCode())).count();
	}

	/**
	 * 孫の数。大項目用。
	 * 
	 * @param withAnswer
	 *            回答済みのみカウントする?
	 * @return
	 */
	public long getNumGrandchildren(boolean withAnswer) {
		return childList.stream().map(c -> c.getNumChildren(withAnswer)).reduce(0L, Long::sum);
	}

	/**
	 * 回答率。大項目用。
	 * 
	 * @return
	 */
	public long getAnswerRatio() {
		long all = getNumGrandchildren(false);
		if ( all == 0 ) {
			return 100;
		}
		return getNumGrandchildren(true) * 100 / all;
	}

	public String getSubjectCode() {
		return subjectCode;
	}

	public void setSubjectCode(String subjectCode) {
		this.subjectCode = subjectCode;
	}

	public String getActionPlan() {
		return actionPlan;
	}

	public void setActionPlan(String actionPlan) {
		this.actionPlan = actionPlan;
	}

	public String getEvidence() {
		return evidence;
	}

	public void setEvidence(String evidence) {
		this.evidence = evidence;
	}

	public MultipartFile getEvidenceFile() {
		return evidenceFile;
	}

	public void setEvidenceFile(MultipartFile evidenceFile) {
		this.evidenceFile = evidenceFile;
	}

	public String getEvidenceFileName() {
		return evidenceFileName;
	}

	public void setEvidenceFileName(String evidenceFileName) {
		this.evidenceFileName = evidenceFileName;
	}

	public Boolean getDone() {
		return done;
	}

	public void setDone(Boolean done) {
		this.done = done;
	}

	public Integer getPhase() {
		return phase;
	}

	public void setPhase(Integer phase) {
		this.phase = phase;
	}

	public List<AnswerForm> getChildList() {
		return childList;
	}

	public void setChildList(List<AnswerForm> childList) {
		this.childList = childList;
	}

	public String getEvidenceFileId() {
		return evidenceFileId;
	}

	public void setEvidenceFileId(String evidenceFileId) {
		this.evidenceFileId = evidenceFileId;
	}

}
