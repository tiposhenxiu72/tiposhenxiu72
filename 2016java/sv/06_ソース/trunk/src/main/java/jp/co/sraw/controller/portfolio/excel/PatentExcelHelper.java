package jp.co.sraw.controller.portfolio.excel;

import java.util.List;

import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;

import jp.co.sraw.controller.portfolio.form.GyPatentForm;
import jp.co.sraw.util.PoiBook;

public class PatentExcelHelper extends PortfolioExcelHelper<GyPatentForm> {

	private final String SHEET_NAME = "PATENT";

	@Override
	public void buildExcelDocument(PoiBook workbook, List<GyPatentForm> list) {

	}

	@Override
	public Sheet getSheet(Workbook workbook) {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

	@Override
	public GyPatentForm getForm(Row row) {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

}