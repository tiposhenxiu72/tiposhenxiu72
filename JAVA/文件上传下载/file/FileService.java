package jp.co.sraw.file;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.persistence.EntityManager;
import javax.persistence.Query;

import org.hibernate.SQLQuery;
import org.hibernate.transform.Transformers;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Service;

import jp.co.sraw.common.CommonConst;
import jp.co.sraw.common.CommonService;
import jp.co.sraw.entity.CmFileUploadTbl;
import jp.co.sraw.repository.CmFileUploadTblRepository;
import jp.co.sraw.util.DateUtil;
import jp.co.sraw.util.FileUtil;
import jp.co.sraw.util.StringUtil;
import net.lingala.zip4j.core.ZipFile;
import net.lingala.zip4j.exception.ZipException;
import net.lingala.zip4j.model.ZipParameters;
import net.lingala.zip4j.util.Zip4jConstants;

@Scope("prototype")
@Service
public class FileService extends CommonService {

	/** 当日日付の年月フォーマット */
	public static final String DEFAULT_YYYYMM = "yyyyMM";

	/** ファイル格納先のフォルダ名 */
	//public static final String WIN_PATH_ROOT = "/opt/eportfolio/data";

	@Autowired
	private CmFileUploadTblRepository repository;

	@Autowired
	private EntityManager entityManager;

	@Autowired
	private FileStorage fileStorage;

	@Override
	protected void init() {
		// TODO 自動生成されたメソッド・スタブ

	}

	/**
	 * 指定されたファイルをファイルサーバの指定フォルダに圧縮して格納する
	 *
	 * @param targetUserKey
	 * @param fileList
	 * @return
	 */
	public List<FileDto> publicUploadFileList(String targetUserKey, String loginUserKey, List<FileDto> fileList) {
		List<FileDto> uploadList = new ArrayList<>();
		try {
			for (FileDto dto : fileList) {
				String uploadKey = putUploadFile(dto, targetUserKey, loginUserKey);
				if (uploadKey != null) {
					dto.setUploadKey(uploadKey);
					uploadList.add(dto);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return uploadList;
	}

	/**
	 * 指定されたファイルをファイルサーバの指定フォルダに圧縮して格納する
	 *
	 * @param fileDto
	 * @param operationUserKey
	 * @return
	 */
	public String putUploadFile(FileDto fileDto, String targetUserKey, String loginUserKey) {

		fileDto.setStoragePath(this.makeFilePath(targetUserKey));

		//
		String uploadKey = this.putFileUploadTbl(fileDto.getFileKbn(), fileDto.getUploadName(),
				fileDto.getStoragePath(), fileDto.getSize(), targetUserKey, "1", loginUserKey);
		if (uploadKey == null) {
			return null;
		}

		fileDto.setUploadKey(uploadKey);

		// 1.テンポラリファイルを置く場所のフォルダ名を生成する。
		boolean b = FileUtil.putFile(fileDto.getFile(), fileDto.getUploadPath());
		// エラーがなるの場合
		if (!b) {
			this.deleteFileUploadTbl(fileDto.getUploadKey());
			return null;
		}

		// 2.テンポラリに書き込んだファイルをzip４jで圧縮する。
		int zipResult = this.makeZipFile(fileDto);
		// エラーがなるの場合
		if (zipResult > 0) {
			this.deleteFileUploadTbl(fileDto.getUploadKey());
			return null;
		}

		// 3.引数のファイル格納パスにファイルを出力する。
		int storageResult = fileStorage.putFile(fileDto);
		// エラーがなるの場合
		if (storageResult > 0) {
			this.deleteFileUploadTbl(fileDto.getUploadKey());
			return null;
		} else {
			FileUtil.deleteFile(fileDto.getZipPath());
		}

		return uploadKey;
	}

	/**
	 *
	 * @param operationUserKey
	 * @param downloadList
	 * @return
	 */
	public String getFileWithZip(String operationUserKey, List<String> downloadList) {
		List<FileDto> fileList = new ArrayList<>();
		for (String uploadKey : downloadList) {
			FileDto fileDto = this.getFile(uploadKey);
			if (fileDto != null) {
				fileList.add(fileDto);
			} else {
				return null;
			}
		}
		String zipFileName = makeZipFileList(fileList, false);
		return zipFileName;
	}

	/**
	 *
	 * @param uploadKey
	 * @return
	 */
	public int deleteUploadFile(String uploadKey) {
		FileDto dto = getFileUploalDto(uploadKey);
		int storageResult = fileStorage.deleteFile(dto);
		if (storageResult == 0) {
			this.deleteFileUploadTbl(uploadKey);
			return storageResult;
		}
		return storageResult;
	}

	/**
	 * ユーザキーを元にファイルの格納先となるファイル格納パスを生成する
	 *
	 * @param operationUserKey
	 *            操作対象者ユーザキー
	 * @return ファイル格納パス
	 */
	public String makeFilePath(String operationUserKey) {
		// チェック
		if (StringUtil.isNull(operationUserKey) || operationUserKey.length() < 10) {
			return null;
		}
		String filePath = "";
//		// windowsの場合
//		String osName = System.getProperty("os.name").toLowerCase();
//		if (osName.startsWith("windows")) {
//			filePath = WIN_PATH_ROOT;
//		}
		filePath = filePath + CommonConst.PATH_CHAR + operationUserKey.substring(1);
		filePath = filePath + CommonConst.PATH_CHAR + operationUserKey.substring(2, 4);
		filePath = filePath + CommonConst.PATH_CHAR + operationUserKey.substring(5, 7);
		filePath = filePath + CommonConst.PATH_CHAR + operationUserKey.substring(8, 10);
		filePath = filePath + CommonConst.PATH_CHAR + DateUtil.getSysdate(DEFAULT_YYYYMM);
		return filePath;
	}

	/**
	 * ファイルアップロードテーブルから対象データの取得を行う。
	 *
	 * @param uploadKey
	 *            アップロードキー
	 * @return ファイルアップロードテーブルDTO
	 */
	public FileDto getFileUploalDto(String uploadKey) {
		if (StringUtil.isNull(uploadKey))
			return null;
		CmFileUploadTbl tbl = repository.findOne(uploadKey);
		if (tbl == null)
			return null;
		FileDto dto = new FileDto();
		dto.setUploadKey(tbl.getUploadKey());
		dto.setUploadName(tbl.getFileName());
		dto.setStoragePath(tbl.getFilePutPath());
		return dto;
	}

	/**
	 * ファイルアップロードテーブルから対象データの削除を行う。
	 *
	 * @param uploadKey
	 *            アップロードキー
	 */
	public void deleteFileUploadTbl(String uploadKey) {
		repository.delete(uploadKey);
	}

	/**
	 *
	 * ファイルアップロードテーブルの登録を行う。
	 *
	 * @param uploadKey
	 *            アップロードキー
	 * @param fileKbn
	 *            ファイル区分
	 * @param fileName
	 *            ファイル名
	 * @param filePath
	 *            ファイル格納パス
	 * @param fileSize
	 *            ファイル容量
	 * @param targetUserKey
	 *            操作対象者ユーザキー
	 * @param calcKbn
	 *            容量計算対象区分
	 * @param updUserKey
	 *            ログイン者ユーザキー
	 * @return true:正常終了。false:エラー。
	 */
	public String putFileUploadTbl(String fileKbn, String fileName, String filePath, Long fileSize,
			String targetUserKey, String calcKbn, String updUserKey) {
		if (StringUtil.isNull(fileName) || StringUtil.isNull(filePath) || StringUtil.isNull(targetUserKey)
				|| StringUtil.isNull(updUserKey) || fileSize == 0l)
			return null;
		if (StringUtil.isNull(fileKbn)) {
			fileKbn = "99";
		}
		CmFileUploadTbl entity = new CmFileUploadTbl();
		entity.setFileKbn(fileKbn);
		entity.setFileName(fileName);
		entity.setFilePutPath(filePath);
		entity.setUserKey(targetUserKey);
		entity.setUpdUserKey(updUserKey);
		entity.setCalcFlag(calcKbn);
		entity.setFileSize(fileSize);
		entity.setUpdDate(DateUtil.getNowTimestamp());
		repository.saveAndFlush(entity);
		return entity.getUploadKey();
	}

	/**
	 * ファイルアップロードテーブルから容量制限対象ファイルの使用済み容量を取得する。
	 *
	 * @param operationUserKey
	 *            操作対象者のユーザキー
	 * @return 使用済み容量
	 */
	public long getUserUsedFileSize(String operationUserKey) {
		String fileSizeValue = getSqlValue("FileService.getUserUsedFileSize", "userKey", operationUserKey);
		if (StringUtil.isNotNull(fileSizeValue)) {
			try {
				long fileSize = Long.parseLong(fileSizeValue);
				return fileSize;
			} catch (Exception e) {
				return 0l;
			}
		}
		return 0l;
	}

	/**
	 * 定数テーブルからファイル使用容量制限値を取得する。
	 *
	 * @param operationUserKey
	 *            操作対象者のユーザ区分
	 * @return 使用容量制限値
	 */
	public long getFileSizeLimit(String operationUserKbn) {
		String fileSizeValue = getSqlValue("FileService.getUserUsedFileSize", "userKbn", operationUserKbn);
		if (StringUtil.isNotNull(fileSizeValue)) {
			try {
				long fileSize = Long.parseLong(fileSizeValue);
				return fileSize;
			} catch (Exception e) {
				return 0l;
			}
		}
		return 0l;
	}

	/**
	 *
	 * @param sqlName
	 * @param paraName
	 * @param paraValue
	 * @return
	 */
	private String getSqlValue(String sqlName, String paraName, String paraValue) {

		Query query = entityManager.createNamedQuery(sqlName);

		query.setParameter(paraName, paraValue);
		query.unwrap(SQLQuery.class).setResultTransformer(Transformers.ALIAS_TO_ENTITY_MAP);

		List<Map> resultList = query.getResultList();

		for (int i = 0; i < resultList.size(); i++) {
			return (String) resultList.get(i).get("VALUE");
		}

		return null;
	}

	/**
	 * 指定されたファイル格納パス、ファル名のﾘｽﾄを元にZIPファイルを作成する
	 *
	 * @param fileDto
	 * @return
	 */
	public int makeZipFile(FileDto fileDto) {
		ZipFile zipfile = null;
		try {
			if (fileDto == null) {
				return 2;
			}

			zipfile = new ZipFile(fileDto.getZipPath());
			ZipParameters parameters = new ZipParameters();
			parameters.setCompressionMethod(Zip4jConstants.COMP_DEFLATE);
			parameters.setCompressionLevel(Zip4jConstants.DEFLATE_LEVEL_NORMAL);
			parameters.setEncryptionMethod(Zip4jConstants.ENC_METHOD_AES);
			parameters.setAesKeyStrength(Zip4jConstants.AES_STRENGTH_256);

			parameters.setEncryptFiles(true);
			parameters.setPassword(CommonConst.SECRET_KEY);

			File sourceFile = new File(fileDto.getUploadPath());
			zipfile.addFile(sourceFile, parameters);

			FileUtil.deleteFile(fileDto.getUploadPath());

		} catch (ZipException e) {
			e.printStackTrace();
			return 1;
		}
		return 0;
	}

	/**
	 * 指定されたファイル格納パス、ファル名のﾘｽﾄを元にZIPファイルを作成する
	 *
	 * @param fileList
	 * @param encrypt
	 * @return
	 */
	public String makeZipFileList(List<FileDto> fileList, boolean encrypt) {
		ZipFile zipfile = null;
		String zipFileName = FileDto.TEMP_ROOT + "/" + UUID.randomUUID() + ".zip";
		try {
			if (fileList.size() == 0) {
				return null;
			}

			zipfile = new ZipFile(zipFileName);
			ZipParameters parameters = new ZipParameters();
			parameters.setCompressionMethod(Zip4jConstants.COMP_DEFLATE);
			parameters.setCompressionLevel(Zip4jConstants.DEFLATE_LEVEL_NORMAL);
			parameters.setEncryptFiles(false);
			parameters.setEncryptionMethod(Zip4jConstants.ENC_METHOD_AES);
			parameters.setAesKeyStrength(Zip4jConstants.AES_STRENGTH_256);

			parameters.setSourceExternalStream(true);

			if (encrypt) {
				parameters.setEncryptFiles(encrypt);
				parameters.setPassword(CommonConst.SECRET_KEY);
			}

			for (FileDto fileDto : fileList) {
				File sourceFile = new File(fileDto.getUploadPath());
				parameters.setFileNameInZip(fileDto.getUploadName());
				zipfile.addFile(sourceFile, parameters);
			}

		} catch (ZipException e) {
			e.printStackTrace();
			return null;
		}
		return zipFileName;
	}

	/**
	 * 取得したファイルをzip４jで解凍する。
	 *
	 * @param fileDto
	 * @return
	 */
	public int unZipFile(FileDto fileDto) {
		try {
			ZipFile zipFile = new ZipFile(fileDto.getZipPath());
			if (zipFile.isEncrypted()) {
				zipFile.setPassword(CommonConst.SECRET_KEY);
			}
			zipFile.extractAll(fileDto.getUnZipPath());
		} catch (ZipException e) {
			e.printStackTrace();
			return 1;
		}
		return 0;
	}

	/**
	 * 指定したファイルを元にファイルサーバ共有フォルダからファイルを取得し、解凍を行いファイルを返す
	 *
	 * @param filePath
	 *            ファイル格納パス
	 * @param uploadKey
	 *            ファイル名（アップロードキー）
	 * @return
	 */
	public FileDto getFile(String uploadKey) {
		// 1.引数のファイル格納パスからファイルを取得する。
		FileDto fileDto = getFileUploalDto(uploadKey);
		if (fileDto != null) {
			int i = fileStorage.getFile(fileDto);
			if (i == 0) {
				// 2.取得したファイルをzip４jで解凍する。
				i = unZipFile(fileDto);
				if (i == 0) {
					return fileDto;
				}
				return null;
			}
		}
		return null;
	}

}
