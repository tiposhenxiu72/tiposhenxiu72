package jp.co.sraw.controller.portfolio.excel;

import java.util.List;

import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;

import jp.co.sraw.controller.portfolio.form.GyDegreeForm;
import jp.co.sraw.util.PoiBook;

public class DegreeExcelHelper extends PortfolioExcelHelper<GyDegreeForm> {

	private final String SHEET_NAME = "DEGREE";

	@Override
	public void buildExcelDocument(PoiBook workbook, List<GyDegreeForm> list) {

	}

	@Override
	public Sheet getSheet(Workbook workbook) {
		return workbook.getSheet(SHEET_NAME);
	}

	@Override
	public GyDegreeForm getForm(Row row) {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

}