package jp.co.sraw.controller.portfolio.excel;

import java.util.List;

import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;

import jp.co.sraw.controller.portfolio.form.GyOthersForm;
import jp.co.sraw.util.PoiBook;

public class OthersExcelHelper extends PortfolioExcelHelper<GyOthersForm> {

	private final String SHEET_NAME = "OTHERS";

	@Override
	public void buildExcelDocument(PoiBook workbook, List<GyOthersForm> list) {

	}

	@Override
	public Sheet getSheet(Workbook workbook) {
		return workbook.getSheet(SHEET_NAME);
	}

	@Override
	public GyOthersForm getForm(Row row) {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

}