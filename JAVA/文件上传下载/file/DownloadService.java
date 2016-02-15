package jp.co.sraw.file;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.List;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.sraw.util.StringUtil;

@Service
public class DownloadService {

	@Autowired
	private FileService fileService;

	public void downloadZip(HttpServletRequest request, HttpServletResponse response, String userKey, String fileName,
			List<String> downloadList) throws IOException {
		ServletContext context = request.getServletContext();
		String appPath = context.getRealPath("");
		System.out.println("appPath = " + appPath);

		String downloadFilePath = fileService.getFileWithZip(userKey, downloadList);

		if (StringUtil.isNull(downloadFilePath)) {
			response.sendError(HttpServletResponse.SC_NOT_FOUND);
			return;
		}

		File downloadFile = new File(downloadFilePath);
		FileInputStream inputStream = new FileInputStream(downloadFile);

		if (StringUtil.isNotNull(fileName)) {
			fileName = fileName + ".zip";
		} else {
			fileName = downloadFile.getName();
		}

		String mimeType = context.getMimeType("application/zip");
		if (mimeType == null) {
			mimeType = "application/octet-stream";
		}
		System.out.println("MIME type: " + mimeType);

		response.setContentType(mimeType);
		response.setContentLength((int) downloadFile.length());

		String headerKey = "Content-Disposition";
		String headerValue = String.format("attachment; filename=\"%s\"", fileName);
		response.setHeader(headerKey, headerValue);

		// get output stream of the response
		OutputStream outStream = response.getOutputStream();

		byte[] buffer = new byte[4096];
		int bytesRead = -1;

		while ((bytesRead = inputStream.read(buffer)) != -1) {
			outStream.write(buffer, 0, bytesRead);
		}

		inputStream.close();
		outStream.close();
	}
}
