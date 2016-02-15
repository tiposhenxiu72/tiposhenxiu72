package jp.co.sraw.file;

import java.util.ArrayList;
import java.util.List;

import jp.co.sraw.common.CommonForm;
import jp.co.sraw.common.UserInfo;

public class UploadForm extends CommonForm {

	private List<FileDto> preUploadFileList = new ArrayList<>();

	private List<FileDto> uploadFileList = new ArrayList<>();

	private boolean fileNotNull = false;

	private UserInfo userInfo = null;

	public List<FileDto> getPreUploadFileList() {
		return preUploadFileList;
	}

	public void setPreUploadFileList(List<FileDto> preUploadFileList) {
		this.preUploadFileList = preUploadFileList;
	}

	public List<FileDto> getUploadFileList() {
		return uploadFileList;
	}

	public void setUploadFileList(List<FileDto> uploadFileList) {
		this.uploadFileList = uploadFileList;
	}

	public UserInfo getUserInfo() {
		return userInfo;
	}

	public void setUserInfo(UserInfo userInfo) {
		this.userInfo = userInfo;
	}

	public boolean getFileNotNull() {
		return fileNotNull;
	}

	public void setFileNotNull(boolean fileNotNull) {
		this.fileNotNull = fileNotNull;
	}
}
