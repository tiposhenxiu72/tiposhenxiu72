package jp.co.sraw.controller.portfolio.excel;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;

import jp.co.sraw.controller.portfolio.form.PortfolioForm;
import jp.co.sraw.util.PoiBook;

public abstract class PortfolioExcelHelper<F extends PortfolioForm> {

	public void buildExcelDocument(PoiBook book, List<F> list) {
		// TODO 自動生成されたメソッド・スタブ

	}

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
		return result;
	}

	protected int getCellIntValue(Row row, int sortNo) {
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
}
