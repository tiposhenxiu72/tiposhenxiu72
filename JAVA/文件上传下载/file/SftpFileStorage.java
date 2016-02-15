package jp.co.sraw.file;

import com.jcraft.jsch.Channel;
import com.jcraft.jsch.ChannelSftp;
import com.jcraft.jsch.JSch;
import com.jcraft.jsch.JSchException;
import com.jcraft.jsch.Session;
import com.jcraft.jsch.SftpException;

import jp.co.sraw.util.StringUtil;

public class SftpFileStorage implements FileStorage {

	private static final String ACTION_ADD = "ADD";

	private static final String ACTION_DELETE = "DELETE";

	private static final String ACTION_GET = "GET";

	private static final int RERUST_OK = 0;

	private static final int RERUST_NEWWORK_ERROR = 1;

	private static final int RERUST_SFTP_ERROR = 2;

	private String rootPath;

	private String sftpHostName;

	private String sftpUserId;

	private String sftpKey;

	private String tmpFolder;

	private String action = "";

	private String remotePath = "";

	private String localPath = "";

	private String zipFileName = "";

	public String getRootPath() {
		return this.rootPath;
	}

	public void setRootPath(String rootPath) {
		this.rootPath = rootPath;
	}

	public String getSftpHostName() {
		return sftpHostName;
	}

	public void setSftpHostName(String sftpHostName) {
		this.sftpHostName = sftpHostName;
	}

	public String getSftpUserId() {
		return sftpUserId;
	}

	public void setSftpUserId(String sftpUserId) {
		this.sftpUserId = sftpUserId;
	}

	public String getSftpKey() {
		return sftpKey;
	}

	public void setSftpKey(String sftpKey) {
		this.sftpKey = sftpKey;
	}

	public String getTmpFolder() {
		return tmpFolder;
	}

	public void setTmpFolder(String tmpFolder) {
		this.tmpFolder = tmpFolder;
	}

	private String getRemoteFileName() {
		return remotePath + "/" + zipFileName;
	}

	private String getLocalFileName() {
		return localPath;
	}

	private int process() {
		JSch jsch = new JSch();
		Session session = null;
		ChannelSftp sftpChannel = null;
		try {
			session = jsch.getSession(sftpUserId, sftpHostName, 22);
			session.setPassword(sftpKey);
			session.connect();

			Channel channel = session.openChannel("sftp");
			channel.connect();
			sftpChannel = (ChannelSftp) channel;

			checkDir(sftpChannel);

			if (action.equals(ACTION_ADD)) {
				sftpChannel.put(getLocalFileName(), getRemoteFileName());
			}

			if (action.equals(ACTION_GET)) {
				sftpChannel.get(getRemoteFileName(), getLocalFileName());
			}

			if (action.equals(ACTION_DELETE)) {
				sftpChannel.rm(getRemoteFileName());
			}

		} catch (JSchException e) {
			e.printStackTrace();
			return RERUST_NEWWORK_ERROR;
		} catch (SftpException e) {
			e.printStackTrace();
			return RERUST_SFTP_ERROR;
		} finally {
			sftpChannel.exit();
			session.disconnect();
		}
		return RERUST_OK;
	}

	@Override
	public int getFile(FileDto fileDto) {
		this.action = ACTION_GET;
		this.remotePath = this.getRootPath() + fileDto.getStoragePath();
		this.localPath = fileDto.getZipPath();
		return process();
	}

	@Override
	public int putFile(FileDto fileDto) {
		this.action = ACTION_ADD;
		this.zipFileName = fileDto.getZipName();
		this.remotePath = this.getRootPath() + fileDto.getStoragePath();
		this.localPath = fileDto.getZipPath();
		return process();
	}

	@Override
	public int deleteFile(FileDto fileDto) {
		this.action = ACTION_DELETE;
		this.zipFileName = fileDto.getZipName();
		this.remotePath = this.getRootPath() + fileDto.getStoragePath();
		return process();
	}

	private void checkDir(ChannelSftp channelSftp) throws SftpException {
		String crtdir = "";
		for (String dir : (this.getRootPath() + remotePath).split("/")) {
			if (StringUtil.isNotNull(dir)) {
				crtdir = crtdir + "/" + dir;
				if (!channelSftp.stat(crtdir).isDir()) {
					channelSftp.mkdir(crtdir);
				}
			}
		}
	}
}
