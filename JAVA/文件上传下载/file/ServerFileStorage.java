package jp.co.sraw.file;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

import jp.co.sraw.util.StringUtil;

public class ServerFileStorage implements FileStorage {

	private static final String WIN_DRIVE = "C:/filestorage";

	private String rootPath;

	public String getRootPath() {
		// windowsの場合
		String osName = System.getProperty("os.name").toLowerCase();
		if (osName.startsWith("windows")) {
			return WIN_DRIVE + this.rootPath;
		}
		return this.rootPath;
	}

	public void setRootPath(String rootPath) {
		this.rootPath = rootPath;
	}

	@Override
	public int getFile(FileDto fileDto) {

		String filePathName = this.getRootPath() + fileDto.getStoragePath() + "/" + fileDto.getZipName();

		return copyFile(filePathName, fileDto.getZipPath());
	}

	@Override
	public int putFile(FileDto fileDto) {

		String destPath = this.getRootPath() + fileDto.getStoragePath() + "/" + fileDto.getZipName();

		String dest = this.getRootPath() + fileDto.getStoragePath();

		File destDir = new File(dest);
		if (!destDir.exists()) {
			String crtdir = this.getRootPath();
			for (String dir : fileDto.getStoragePath().split("/")) {
				if (StringUtil.isNotNull(dir)) {
					crtdir = crtdir + "/" + dir;
					File fileDir = new File(crtdir);
					if (!fileDir.exists()) {
						fileDir.mkdir();
					}
				}
			}
		}

		return copyFile(fileDto.getZipPath(), destPath);
	}

	@Override
	public int deleteFile(FileDto fileDto) {

		String destPath = this.getRootPath() + fileDto.getStoragePath() + "/" + fileDto.getZipName();

		File file = new File(destPath);
		boolean b = file.delete();
		if (b)
			return 0;
		return 1;
	}

	private int copyFile(String source, String destination) {

		File sourcefile = new File(source);
		File destfile = new File(destination);

		FileOutputStream outStream = null;
		FileInputStream inputStream = null;

		int i = 0;
		try {

			if (!sourcefile.exists()) {
				return 1;
			}
			if (!destfile.exists()) {
				destfile.createNewFile();
			}

			inputStream = new FileInputStream(sourcefile);
			outStream = new FileOutputStream(destfile);

			byte[] buf = new byte[1024];

			int bytesRead;

			while ((bytesRead = inputStream.read(buf)) > 0) {
				outStream.write(buf, 0, bytesRead);
			}

		} catch (IOException e) {
			i = 1;
			e.printStackTrace();
		} finally {
			try {
				if (inputStream != null)
					inputStream.close();
			} catch (IOException e) {
			}
			try {
				if (outStream != null)
					outStream.close();
			} catch (IOException e) {
			}
		}
		return i;
	}
}
