package jp.co.sraw.file;

public interface FileStorage {

	/**
	 * 指定したファイルを元にファイルサーバ共有フォルダからファイルを取得し、解凍を行いファイルを返す
	 *
	 * @param fileDto
	 *            ファイル格納オブジェクト
	 * @return 0:正常。１：コネクトエラー。2:ファイル取得エラー。3:解凍エラー
	 */
	public int getFile(FileDto fileDto);

	/**
	 * 指定されたファイルをファイルサーバの指定フォルダに圧縮して格納する
	 *
	 * @param fileDto
	 *            ファイル格納オブジェクト
	 * @return 0:正常。１：圧縮エラー。2:コネクトエラー。3:書込みエラー
	 */
	public int putFile(FileDto fileDto);

	/**
	 * 指定されたファイルを削除する
	 *
	 * @param fileDto
	 *            ファイル格納オブジェクト
	 * @return 0:正常。1:コネクトエラー。2:削除エラー
	 */
	public int deleteFile(FileDto fileDto);
}
