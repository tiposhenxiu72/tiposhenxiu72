/*
* ファイル名：FileController.java
*
* <MODIFICATION HISTORY>
*   (Rev.)     (Date)       (ID/NAME)   (Comment)
*   Rev 1.00   2015/12/24     新規作成
*/
package jp.co.sraw.file;

import java.io.File;
import java.io.FileInputStream;
import java.io.OutputStream;
import java.util.Iterator;

import javax.annotation.PostConstruct;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import jp.co.sraw.common.CommonController;
import jp.co.sraw.controller.portfolio.AcademicController;
import jp.co.sraw.controller.portfolio.PortfolioEngine;
import jp.co.sraw.controller.portfolio.excel.AcademicExcelHelper;
import jp.co.sraw.controller.portfolio.form.GyAcademicForm;
import jp.co.sraw.controller.portfolio.service.AcademicServiceImpl;
import jp.co.sraw.logger.LoggerWrapper;
import jp.co.sraw.logger.LoggerWrapperFactory;

/**
 * <B>FileControllerクラス</B>
 * <P>
 * Controllerのメソッドを提供する
 */
@Controller
@RequestMapping("/file")
public class FileController extends CommonController {

	private static final LoggerWrapper logger = LoggerWrapperFactory.getLogger(FileController.class);

	/**
	 * Size of a byte buffer to read/write file
	 */
	private static final int BUFFER_SIZE = 4096;

	@Autowired
	private FileService fileService;

	@PostConstruct
	protected void init() {
		logger.setMessageSource(messageSource);
	}

	@Autowired
	private PortfolioEngine<AcademicController, GyAcademicForm, AcademicServiceImpl, AcademicExcelHelper> engine;


	/**
	 * TODO:
	 * テスト対応
	 * 削除予定
	 *
	 *
	 * @param name
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping({ "/download/{uploadKey}" })
	public void list(HttpServletRequest request, HttpServletResponse response, @PathVariable String uploadKey)
			throws Exception {

		ServletContext context = request.getServletContext();
		String appPath = context.getRealPath("");
		System.out.println("appPath = " + appPath);

		FileDto fileDto = fileService.getFile(uploadKey);
		File downloadFile = new File(fileDto.getUploadPath());
		FileInputStream inputStream = new FileInputStream(downloadFile);

		String mimeType = context.getMimeType(fileDto.getUploadName());
		if (mimeType == null) {
			mimeType = "application/octet-stream";
		}
		System.out.println("MIME type: " + mimeType);

		response.setContentType(mimeType);
		response.setContentLength((int) downloadFile.length());

		String headerKey = "Content-Disposition";
		String headerValue = String.format("attachment; filename=\"%s\"", fileDto.getUploadName());
		response.setHeader(headerKey, headerValue);

		// get output stream of the response
		OutputStream outStream = response.getOutputStream();

		byte[] buffer = new byte[BUFFER_SIZE];
		int bytesRead = -1;

		while ((bytesRead = inputStream.read(buffer)) != -1) {
			outStream.write(buffer, 0, bytesRead);
		}

		inputStream.close();
		outStream.close();

	}
	/**
	 * TODO:
	 * テスト対応
	 * 削除予定
	 *
	 *
	 * @param request
	 * @param response
	 * @return
	 */

	@RequestMapping({ "/upload" })
	public @ResponseBody String upload(MultipartHttpServletRequest request, HttpServletResponse response) {

		Iterator<String> itrator = request.getFileNames();
		MultipartFile file = request.getFile(itrator.next());

		FileDto fileDto=new FileDto();
		fileDto.setFile(file);
		fileDto.SetFileKbn("0");

		String uploadKey = fileService.putUploadFile(fileDto, this.userInfo.getTargetUserKey(), this.userInfo.getLoginUserKey());

		return "{uploadKey:" + uploadKey + "}";
	}
}
