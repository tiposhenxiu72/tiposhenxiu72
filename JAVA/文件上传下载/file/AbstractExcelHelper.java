package jp.co.sraw.file;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.springframework.stereotype.Service;

import jp.co.sraw.common.CommonForm;
import jp.co.sraw.util.PoiBook;

@Service
public abstract class AbstractExcelHelper<F extends CommonForm> {

	public static final String DELIMITER = ":";

	public List<F> getFormList(Workbook workbook) {

		Sheet sheet = getSheet(workbook);

		int startRow = 1;

		List<F> list = new ArrayList<>();

		for (int i = startRow; i <= sheet.getLastRowNum(); i++) {
			Row row = sheet.getRow(i);
			if (row != null) {
				list.add(getForm(row));
			}
		}
		return list;
	}

	public abstract Sheet getSheet(Workbook workbook);

	public abstract F getForm(Row row);

	protected String getCellValue(Row row, int sortNo) {
		if (row.getCell(sortNo) == null)
			return null;
		int cellType = row.getCell(sortNo).getCellType();
		String result = "";
		switch (cellType) {
		case org.apache.poi.ss.usermodel.Cell.CELL_TYPE_BLANK:
			break;
		case org.apache.poi.ss.usermodel.Cell.CELL_TYPE_BOOLEAN:
			break;
		case org.apache.poi.ss.usermodel.Cell.CELL_TYPE_ERROR:
			break;
		case org.apache.poi.ss.usermodel.Cell.CELL_TYPE_FORMULA:
			break;
		case org.apache.poi.ss.usermodel.Cell.CELL_TYPE_NUMERIC:
			result = String.valueOf(row.getCell(sortNo).getNumericCellValue());
			break;
		case org.apache.poi.ss.usermodel.Cell.CELL_TYPE_STRING:
			result = row.getCell(sortNo).getStringCellValue();
		default:
			break;
		}
		if (result.contains(DELIMITER))
			result = result.substring(0, result.indexOf(DELIMITER));
		return result;
	}

	protected int getCellIntValue(Row row, int sortNo) {
		if (row.getCell(sortNo) == null)
			return 0;
		int cellType = row.getCell(sortNo).getCellType();
		int result = 0;
		try {
			switch (cellType) {
			case org.apache.poi.ss.usermodel.Cell.CELL_TYPE_BLANK:
				break;
			case org.apache.poi.ss.usermodel.Cell.CELL_TYPE_BOOLEAN:
				break;
			case org.apache.poi.ss.usermodel.Cell.CELL_TYPE_ERROR:
				break;
			case org.apache.poi.ss.usermodel.Cell.CELL_TYPE_FORMULA:
				break;
			case org.apache.poi.ss.usermodel.Cell.CELL_TYPE_NUMERIC:
				result = (int) row.getCell(sortNo).getNumericCellValue();
				break;
			case org.apache.poi.ss.usermodel.Cell.CELL_TYPE_STRING:
				result = Integer.parseInt(row.getCell(sortNo).getStringCellValue());
			default:
				break;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}

	protected BigDecimal getCellBigDecimal(Row row, int sortNo) {
		if (row.getCell(sortNo) == null)
			return null;
		int cellType = row.getCell(sortNo).getCellType();
		BigDecimal result = new BigDecimal(0);
		try {
			switch (cellType) {
			case org.apache.poi.ss.usermodel.Cell.CELL_TYPE_BLANK:
				break;
			case org.apache.poi.ss.usermodel.Cell.CELL_TYPE_BOOLEAN:
				break;
			case org.apache.poi.ss.usermodel.Cell.CELL_TYPE_ERROR:
				break;
			case org.apache.poi.ss.usermodel.Cell.CELL_TYPE_FORMULA:
				break;
			case org.apache.poi.ss.usermodel.Cell.CELL_TYPE_NUMERIC:
				result = new BigDecimal(row.getCell(sortNo).getNumericCellValue());
				break;
			case org.apache.poi.ss.usermodel.Cell.CELL_TYPE_STRING:
				result = new BigDecimal(row.getCell(sortNo).getStringCellValue());
			default:
				break;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}

	public String getDateInfo(Timestamp time) {
		if (time != null) {
			return time.toString();
		}
		return "";
	}

	public void buildExcelDocument(PoiBook workbook, List<F> list) {
		// TODO 自動生成されたメソッド・スタブ

	}
}
