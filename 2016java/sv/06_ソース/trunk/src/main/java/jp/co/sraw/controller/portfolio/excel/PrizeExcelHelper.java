package jp.co.sraw.controller.portfolio.excel;

import java.util.List;

import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;

import jp.co.sraw.controller.portfolio.form.GyPrizeForm;
import jp.co.sraw.util.PoiBook;

public class PrizeExcelHelper extends PortfolioExcelHelper<GyPrizeForm> {

	private final String SHEET_NAME = "PRIZE";

	@Override
	public void buildExcelDocument(PoiBook workbook, List<GyPrizeForm> list) {

	}

	@Override
	public Sheet getSheet(Workbook workbook) {
		return workbook.getSheet(SHEET_NAME);
	}

	@Override
	public GyPrizeForm getForm(Row row) {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

}