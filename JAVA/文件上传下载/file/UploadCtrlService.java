package jp.co.sraw.file;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import jp.co.sraw.common.CommonConst;
import jp.co.sraw.common.CommonService;

@Scope("prototype")
@Service
public class UploadCtrlService extends CommonService {

	@Autowired
	private FileService fileService;

	private String actionName = CommonConst.FILE_ACTION_NONE;

	private UploadForm form = null;

	public UploadForm getForm() {
		return form;
	}

	public void setForm(UploadForm form) {
		this.form = form;
	}

	@Override
	protected void init() {
		// TODO 自動生成されたメソッド・スタブ

	}

	public int beoforeProcess(MultipartHttpServletRequest request) {

		boolean hasUploadFile = false;

		Iterator<String> itrator = request.getFileNames();

		List<FileDto> fileList = new ArrayList<>();

		while (itrator.hasNext()) {
			String fileName = itrator.next();
			List<MultipartFile> fList = request.getFiles(fileName);
			for (MultipartFile file : fList) {
				if (file.getSize() > 0) {
					hasUploadFile = true;
					FileDto fileDto = new FileDto();
					fileDto.setFieldName(fileName);
					fileDto.setUploadName(file.getOriginalFilename());
					fileDto.SetFileKbn("99");
					fileDto.setFile(file);
					fileList.add(fileDto);
				}
			}
		}

		if (form.getPageMode().equals(CommonConst.PAGE_MODE_EDIT)) {

			// 先回のアップロードファイルが必要です
			if (form.getFileNotNull()) {
				if (form.getPreUploadFileList().size() == 0) {
					// 必要なファイルが存在しません。
					return 1;
				}
				// 本回のアップロードファイルが必要がない
				if (!form.getFileNotNull()) {
					actionName = CommonConst.FILE_ACTION_DEL;
				}
			}

			// 本回のアップロードファイルが必要です
			if (form.getFileNotNull()) {

				if (hasUploadFile) {
					// アップロードファイルがあるの場合
					actionName = CommonConst.FILE_ACTION_CHANGE;
				} else {
					// アップロードファイルがないの場合
					actionName = CommonConst.FILE_ACTION_NONE;
				}
			}

		} else {
			// 新規の場合
			if (form.getFileNotNull()) {
				// アップロードファイルが必要の場合
				if (hasUploadFile) {
					actionName = CommonConst.FILE_ACTION_ADD;
				} else {
					// アップロードファイルがない
					return 1;
				}
			}
		}

		if (actionName.equals(CommonConst.FILE_ACTION_ADD) || actionName.equals(CommonConst.FILE_ACTION_CHANGE)) {

			List<FileDto> uploadFileList = fileService.publicUploadFileList(form.getUserInfo().getTargetUserKey(),
					form.getUserInfo().getLoginUserKey(), fileList);

			if (uploadFileList.size() == 0) {
				return 1;
			} else {
				form.setUploadFileList(uploadFileList);
			}
		} else {
			form.setUploadFileList(form.getPreUploadFileList());
		}

		return 0;
	}

	/**
	 *
	 */
	public void afterProcessFailure() {

		// 編集の場合はエラーがある
		if (actionName.equals(CommonConst.FILE_ACTION_ADD) || actionName.equals(CommonConst.FILE_ACTION_CHANGE)) {
			for (FileDto dto : form.getUploadFileList()) {
				fileService.deleteUploadFile(dto.getUploadKey());
			}
		}
	}

	/**
	 *
	 */
	public void afterProcessSuccess() {
		// 成功するで
		if (actionName.equals(CommonConst.FILE_ACTION_CHANGE) || actionName.equals(CommonConst.FILE_ACTION_DEL)) {
			for (FileDto dto : form.getPreUploadFileList()) {
				fileService.deleteUploadFile(dto.getUploadKey());
			}
		}
	}

}
