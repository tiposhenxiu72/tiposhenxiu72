package jp.co.sraw.util;

import java.io.IOException;
import java.io.OutputStream;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.hssf.usermodel.HSSFPalette;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFShapeGroup;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.util.CellRangeAddress;
import org.springframework.web.multipart.MultipartFile;

/**
 * apache-poiのHSSWorkbookのラッパクラス。
 * <h4>使用例:</h4>
 *
 * <pre>
 * try (PoiBook book = PoiBook.fromResource("hoge.xls")) {
 * 	book.setValue(0, 0, "hoge");
 * 	book.createSheet("fuga
 * 	book.setValue(1, 1, "fuga");
 * 	ByteArrayOutputStream baos = new ByteArrayOutputStream();
 * 	book.write(baos);
 * 	return baos;
 * } catch (IOException e) {
 * } catch (Exception e) {
 * }
 * </pre>
 */
public class PoiBook implements AutoCloseable {
	public HSSFWorkbook book;
	public HSSFSheet activeSheet;

	/**
	 * jar内リソースにあるExcelテンプレートを読み込んでPoiBookインスタンスを生成。
	 *
	 * @param path
	 *            リソースパス
	 * @return
	 * @throws IOException
	 */
	public static PoiBook fromResource(String path) throws IOException {
		PoiBook pb = new PoiBook();
		pb.book = new HSSFWorkbook(new POIFSFileSystem(PoiBook.class.getResourceAsStream(path)));
		pb.activeSheet = pb.book.getSheetAt(0);
		return pb;
	}

	/**
	 * InputStreamで渡されたExcelデータを読み込んで、PoiBookインスタンスを生成。
	 * @param file Excelデータ
	 * @return
	 * @throws IOException
	 */
	public static PoiBook fromResource(MultipartFile file) throws IOException {
		PoiBook pb = new PoiBook();
		pb.book = new HSSFWorkbook(new POIFSFileSystem(file.getInputStream()));
		pb.activeSheet = pb.book.getSheetAt(0);
		return pb;
	}

	private PoiBook() {
	}

	/**
	 * アクティブシートを切り替える。
	 *
	 * @param index
	 */
	public void selectSheetAt(int index) {
		activeSheet = book.getSheetAt(index);
	}

	public void selectSheet(String name) {
		activeSheet = book.getSheet(name);
	}

	public void deleteSheet(String name) {
		HSSFSheet sh = book.getSheet(name);
		if (sh != null && sh != activeSheet) {
			book.removeSheetAt(book.getSheetIndex(sh));
		}
	}

	/**
	 * 行範囲を削除し、その下の指定行分を上にシフトする。
	 * 
	 * @param from
	 * @param to(exclusive)
	 * @param rowsToShift
	 */
	public void deleteRows(int from, int to, int rowsToShift) {
		IntStream.range(from, to).forEach(r -> {
			activeSheet.removeRow(getRowSafe(r));
		});
		if (rowsToShift > 0) {
			activeSheet.shiftRows(to, to + rowsToShift - 1, from - to); // 第2引数はinclusive。
		}
	}

	public void setSheetName(String newName) {
		book.setSheetName(book.getSheetIndex(activeSheet), newName);
	}

	public List<HSSFShapeGroup> topLevelShapeGroup() {
		return activeSheet.getDrawingPatriarch().getChildren().stream().filter(shape -> shape instanceof HSSFShapeGroup)
				.map(s->(HSSFShapeGroup)s)
				.collect(Collectors.toList());
	}

	/**
	 * 新しいシートを作り、アクティブにする。
	 *
	 * @param name
	 *            シート名
	 *
	 */
	public void createSheet(String name) {
		activeSheet = book.createSheet(name);
	}

	/**
	 * 新しいセルに、値をセットする。書式とか罫線はクリアされる(のかな?)。
	 *
	 * @param row
	 *            行番号(0オリジン)
	 * @param col
	 *            列番号(0オリジン)
	 * @param value
	 */
	public void setValue(int row, int col, String value) {
		HSSFRow r = activeSheet.createRow(row);
		HSSFCell cell = r.createCell(col);
		cell.setCellValue(value);
	}

	/**
	 * 既存セルの値を変更する。
	 *
	 * @param row
	 *            行番号(0オリジン)
	 * @param col
	 *            列番号(0オリジン)
	 * @param value
	 */
	public void changeValue(int row, int col, String value) {
		HSSFCell cell = getCellSafe(row, col);
		cell.setCellValue(value);
	}

	public void setRowHeight(int row, short height) {
		getRowSafe(row).setHeightInPoints(height);
	}

	public void fill(int row, int col, short colorIndex) {
		HSSFCell cell = getCellSafe(row, col);
		HSSFCellStyle style = book.createCellStyle();
		style.cloneStyleFrom(cell.getCellStyle());
		style.setFillForegroundColor(colorIndex);
		style.setFillPattern(CellStyle.SOLID_FOREGROUND);
		cell.setCellStyle(style);
	}

	public void setFontColor(int row, int col, short colorIndex) {
		HSSFCell cell = getCellSafe(row, col);
		HSSFCellStyle style = book.createCellStyle();
		style.cloneStyleFrom(cell.getCellStyle());
		HSSFFont font = book.createFont();
		font.setColor(colorIndex);
		style.setFont(font);
		cell.setCellStyle(style);
	}

	public void customizeColor(int[] rgb, short colorIndex) {
		HSSFPalette palette = book.getCustomPalette();
		palette.setColorAtIndex(colorIndex, (byte) rgb[0], (byte) rgb[1], (byte) rgb[2]);
	}

	/**
	 * OutputStreamへ書き出す。
	 *
	 * @param os
	 * @throws IOException
	 */
	public void write(OutputStream os) throws IOException {
		book.write(os);
	}

	/**
	 * セルを結合する
	 * @param row 左上のセルの行番号
	 * @param col 左上のセルの列番号
	 * @param sizeRow 結合する行数
	 * @param sizeCol 結合する列数
	 */
	public void mergeCell(int row, int col, int sizeRow, int sizeCol) {
		activeSheet.addMergedRegion(new CellRangeAddress(row, row + sizeRow, col, col + sizeCol));
	}

	/**
	 * セルが存在するならそれを返す。存在しないなら生成して返す。
	 *
	 * @param row
	 *            行番号(0オリジン)
	 * @param col
	 *            列番号(0オリジン)
	 * @return
	 */
	private HSSFCell getCellSafe(int row, int col) {
		HSSFRow r = getRowSafe(row);
		HSSFCell cell = r.getCell(col);
		if (cell == null) {
			cell = r.createCell(col);
		}
		return cell;
	}

	/**
	 * 行が存在するならそれを返す。存在しないなら生成して返す。
	 *
	 * @param row
	 *            行番号(0オリジン)
	 * @return
	 */
	private HSSFRow getRowSafe(int row) {
		HSSFRow r = activeSheet.getRow(row);
		if (r == null) {
			r = activeSheet.createRow(row);
		}
		return r;
	}

	/**
	 * クローズ。
	 */
	@Override
	public void close() throws Exception {
		if (book != null) {
			book.close();
		}
	}
}
