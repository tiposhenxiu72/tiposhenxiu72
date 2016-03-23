package jp.co.sraw.controller.portfolio.excel;

import java.util.List;

import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;

import jp.co.sraw.controller.portfolio.form.GyConferenceForm;
import jp.co.sraw.util.PoiBook;

public class ConferenceExcelHelper extends PortfolioExcelHelper<GyConferenceForm> {

	private final String SHEET_NAME = "CONFERENCE";

	@Override
	public void buildExcelDocument(PoiBook workbook, List<GyConferenceForm> list) {

	}

	@Override
	public Sheet getSheet(Workbook workbook) {
		return workbook.getSheet(SHEET_NAME);
	}

	@Override
	public GyConferenceForm getForm(Row row) {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

}