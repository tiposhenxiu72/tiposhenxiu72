package jp.co.sraw.controller.portfolio.excel;

import java.util.List;

import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;

import jp.co.sraw.controller.portfolio.form.GyResearchAreaForm;
import jp.co.sraw.util.PoiBook;

public class ResearchAreaExcelHelper extends PortfolioExcelHelper<GyResearchAreaForm> {

	private final String SHEET_NAME = "RESEARCH_AREA";

	@Override
	public void buildExcelDocument(PoiBook workbook, List<GyResearchAreaForm> list) {

	}

	@Override
	public Sheet getSheet(Workbook workbook) {
		return workbook.getSheet(SHEET_NAME);
	}

	@Override
	public GyResearchAreaForm getForm(Row row) {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

}