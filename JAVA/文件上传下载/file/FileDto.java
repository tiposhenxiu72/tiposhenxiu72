package jp.co.sraw.file;

import org.springframework.web.multipart.MultipartFile;

public class FileDto {

	public static final String TEMP_ROOT = "/temp";

	private String storagePath;

	private String localPath;

	private String uploadName;

	private String fileKbn;

	private String uploadKey;

	private String fieldName;

	public String getFieldName() {
		return fieldName;
	}

	public void setFieldName(String fieldName) {
		this.fieldName = fieldName;
	}

	private MultipartFile file;

	public String getStoragePath() {
		return storagePath;
	}

	public void setStoragePath(String storagePath) {
		this.storagePath = storagePath;
	}

	public String getUploadName() {
		return this.uploadName;
	}

	public void setUploadName(String uploadName) {
		this.uploadName = uploadName;
	}

	public String getUploadPath() {
		return TEMP_ROOT + "/" + this.uploadKey + ".tmp";
	}

	public String getZipPath() {
		return TEMP_ROOT + "/" + this.uploadKey + ".zip";
	}

	public String getUnZipPath() {
		return TEMP_ROOT;
	}

	public String getZipName() {
		return this.uploadKey + ".zip";
	}

	public String getFileKbn() {
		return fileKbn;
	}

	public void SetFileKbn(String fileKbn) {
		this.fileKbn = fileKbn;
	}

	public String getUploadKey() {
		return uploadKey;
	}

	public void setUploadKey(String uploadKey) {
		this.uploadKey = uploadKey;
	}

	public MultipartFile getFile() {
		return file;
	}

	public void setFile(MultipartFile file) {
		this.file = file;
	}

	public long getSize() {
		if (file != null) {
			return file.getSize();
		}
		return 0;
	}
}
