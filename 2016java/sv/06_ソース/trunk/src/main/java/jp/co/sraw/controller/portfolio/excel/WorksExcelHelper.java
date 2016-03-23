package jp.co.sraw.controller.portfolio.excel;

import java.util.List;

import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;

import jp.co.sraw.controller.portfolio.form.GyWorksForm;
import jp.co.sraw.util.PoiBook;

public class WorksExcelHelper extends PortfolioExcelHelper<GyWorksForm> {

	private final String SHEET_NAME = "WORKS";

	@Override
	public void buildExcelDocument(PoiBook workbook, List<GyWorksForm> list) {

	}

	@Override
	public Sheet getSheet(Workbook workbook) {
		return workbook.getSheet(SHEET_NAME);
	}

	@Override
	public GyWorksForm getForm(Row row) {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

}